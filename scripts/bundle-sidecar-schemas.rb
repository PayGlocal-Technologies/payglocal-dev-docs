#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "set"

ROOT = File.expand_path("..", __dir__)

def deep_dup(obj)
  Marshal.load(Marshal.dump(obj))
end

def collect_refs(obj, refs = Set.new)
  case obj
  when Hash
    obj.each do |k, v|
      refs << v if k == "$ref" && v.is_a?(String) && v.start_with?("#/components/")
      collect_refs(v, refs)
    end
  when Array
    obj.each { |item| collect_refs(item, refs) }
  end
  refs
end

def bundle(sidecar_path, main_path)
  sidecar = YAML.load_file(File.join(ROOT, sidecar_path))
  main = YAML.load_file(File.join(ROOT, main_path))

  op = sidecar.dig("paths")&.values&.first&.fetch("post", nil)
  raise "No POST in #{sidecar_path}" unless op

  refs = collect_refs(op)
  schemas = {}
  responses = {}
  queue = refs.to_a
  seen_s = Set.new
  seen_r = Set.new

  until queue.empty?
    ref = queue.shift
    parts = ref.sub(%r{\A#/}, "").split("/")
    next if parts.length < 3

    kind = parts[1]
    name = parts[2..].join("/")
    case kind
    when "schemas"
      next if seen_s.include?(name)
      seen_s << name
      body = main.dig("components", "schemas", name)
      raise "Missing schema #{name} in #{main_path}" unless body
      schemas[name] = deep_dup(body)
      collect_refs(body).each { |r| queue << r }
    when "responses"
      next if seen_r.include?(name)
      seen_r << name
      body = main.dig("components", "responses", name)
      raise "Missing response #{name} in #{main_path}" unless body
      responses[name] = deep_dup(body)
      collect_refs(body).each { |r| queue << r }
    end
  end

  sidecar["components"] ||= {}
  sidecar["components"]["schemas"] = schemas
  sidecar["components"]["responses"] = responses unless responses.empty?
  if main.dig("components", "securitySchemes", "JwsTokenAuth")
    sidecar["components"]["securitySchemes"] = {
      "JwsTokenAuth" => deep_dup(main.dig("components", "securitySchemes", "JwsTokenAuth"))
    }
  end

  File.write(File.join(ROOT, sidecar_path), sidecar.to_yaml(line_width: -1))
  puts "#{sidecar_path}: #{schemas.size} schemas, #{responses.size} responses"
end

ARGV.each { |f| bundle(f, "openapi.yaml") }

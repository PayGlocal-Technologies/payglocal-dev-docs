#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "set"
require "fileutils"

ROOT = File.expand_path("..", __dir__)

EXTRACTS = [
  {
    source: "openapi.yaml",
    doc_path: "/gl/v1/payments/initiate/paycollect/gpi",
    prod_path: "/gl/v1/payments/initiate/paycollect",
    out: "openapi-v2-paycollect-gpi.yaml",
    title: "PayCollect initiate — GPI (Payments V2)"
  },
  {
    source: "openapi.yaml",
    doc_path: "/gl/v1/payments/initiate/paycollect/standing-instruction/on-demand",
    prod_path: "/gl/v1/payments/initiate/paycollect",
    out: "openapi-v2-paycollect-si-on-demand.yaml",
    title: "PayCollect initiate — SI on demand (Payments V2)"
  },
  {
    source: "openapi.yaml",
    doc_path: "/gl/v1/payments/initiate/paycollect/standing-instruction/auto-debit",
    prod_path: "/gl/v1/payments/initiate/paycollect",
    out: "openapi-v2-paycollect-si-auto-debit.yaml",
    title: "PayCollect initiate — SI auto debit (Payments V2)"
  },
  {
    source: "openapi.yaml",
    doc_path: "/gl/v1/payments/initiate/paycollect/auth",
    prod_path: "/gl/v1/payments/initiate/paycollect",
    out: "openapi-v2-paycollect-auth.yaml",
    title: "PayCollect initiate — authorize (Payments V2)"
  },
  {
    source: "openapi-paydirect.yaml",
    doc_path: "/gl/v1/payments/initiate/gpi",
    prod_path: "/gl/v1/payments/initiate",
    out: "openapi-v2-paydirect-gpi.yaml",
    title: "PayDirect initiate — GPI (Payments V2)"
  },
  {
    source: "openapi-paydirect.yaml",
    doc_path: "/gl/v1/payments/initiate/standing-instruction/on-demand",
    prod_path: "/gl/v1/payments/initiate",
    out: "openapi-v2-paydirect-si-on-demand.yaml",
    title: "PayDirect initiate — SI on demand (Payments V2)"
  },
  {
    source: "openapi-paydirect.yaml",
    doc_path: "/gl/v1/payments/initiate/standing-instruction/auto-debit",
    prod_path: "/gl/v1/payments/initiate",
    out: "openapi-v2-paydirect-si-auto-debit.yaml",
    title: "PayDirect initiate — SI auto debit (Payments V2)"
  },
  {
    source: "openapi-paydirect.yaml",
    doc_path: "/gl/v1/payments/initiate/auth",
    prod_path: "/gl/v1/payments/initiate",
    out: "openapi-v2-paydirect-auth.yaml",
    title: "PayDirect initiate — authorize (Payments V2)"
  }
].freeze

def deep_dup(obj)
  Marshal.load(Marshal.dump(obj))
end

def collect_refs(obj, refs = Set.new)
  case obj
  when Hash
    obj.each do |k, v|
      if k == "$ref" && v.is_a?(String) && v.start_with?("#/components/")
        refs << v
      else
        collect_refs(v, refs)
      end
    end
  when Array
    obj.each { |item| collect_refs(item, refs) }
  end
  refs
end

def resolve_components(spec, refs, resolved_schemas: Set.new, resolved_responses: Set.new)
  queue = refs.to_a
  schemas = spec.dig("components", "schemas") || {}
  responses = spec.dig("components", "responses") || {}

  until queue.empty?
    ref = queue.shift
    _prefix, kind, name = ref.split("/", 4)
    next unless name

    case kind
    when "schemas"
      next if resolved_schemas.include?(name)
      resolved_schemas << name
      body = schemas[name]
      next unless body
      collect_refs(body).each { |r| queue << r unless refs.include?(r) }
      refs << ref
    when "responses"
      next if resolved_responses.include?(name)
      resolved_responses << name
      body = responses[name]
      next unless body
      collect_refs(body).each { |r| queue << r unless refs.include?(r) }
      refs << ref
    end
  end

  [resolved_schemas, resolved_responses]
end

def build_sidecar(source_path, doc_path, prod_path, title)
  spec = YAML.load_file(File.join(ROOT, source_path))
  path_item = spec.dig("paths", doc_path)
  raise "Missing path #{doc_path} in #{source_path}" unless path_item

  path_item = deep_dup(path_item)
  path_item.delete("servers") if path_item.key?("servers")

  operation = path_item["post"]
  raise "Missing POST on #{doc_path}" unless operation

  operation["x-hidden"] = true

  refs = collect_refs(path_item)
  schema_names, response_names = resolve_components(spec, refs)

  servers = [
    { "url" => "https://api.payglocal.in", "description" => "Production" },
    { "url" => "https://api.uat.payglocal.in", "description" => "Sandbox" }
  ]

  out = {
    "openapi" => spec["openapi"] || "3.0.3",
    "info" => {
      "title" => title,
      "version" => "1.0.0",
      "description" => "Payments V2 documentation slice. Production calls use `POST #{prod_path}`."
    },
    "servers" => servers,
    "paths" => {
      prod_path => path_item
    },
    "components" => {
      "securitySchemes" => {
        "JwsTokenAuth" => spec.dig("components", "securitySchemes", "JwsTokenAuth")
      },
      "schemas" => {},
      "responses" => {}
    }
  }

  schema_names.each do |name|
    out["components"]["schemas"][name] = deep_dup(spec.dig("components", "schemas", name))
  end

  response_names.each do |name|
    out["components"]["responses"][name] = deep_dup(spec.dig("components", "responses", name))
  end

  out["components"].delete("responses") if out["components"]["responses"].empty?

  out
end

EXTRACTS.each do |cfg|
  sidecar = build_sidecar(cfg[:source], cfg[:doc_path], cfg[:prod_path], cfg[:title])
  out_path = File.join(ROOT, cfg[:out])
  File.write(out_path, sidecar.to_yaml(line_width: -1))
  puts "Wrote #{cfg[:out]}"
end

puts "Done. Remove doc-only paths from main specs manually (preserves YAML anchors)."

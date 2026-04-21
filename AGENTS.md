# AGENTS.md

Guidance for humans and AI agents contributing to the PayGlocal developer docs.

Read this file once before your first edit. It tells you where things live, the rules that keep pages consistent, and how to verify your changes before opening a PR.

---

## 1. What this repo is

The source for `docs.payglocal.in` — a [Mintlify](https://mintlify.com) (Sequoia theme) documentation site covering PayGlocal's Merchant Onboarding API, Payment APIs, and Standing Instruction flows.

Audience: engineers integrating PayGlocal — partner platforms onboarding sub-merchants, and merchants building payment flows.

---

## 2. Run locally

```bash
npm i -g mint              # one-time
mintlify dev               # starts dev server on :3000
```

- Node 20+ required.
- Hot-reload works for MDX edits.
- **Restart `mintlify dev` after editing `openapi.yaml`** — the spec is cached at startup.
- `mintlify broken-links` checks for dead internal links.

---

## 3. Repo map

```
api-reference/             MDX pages per endpoint (Mintlify auto-renders from openapi.yaml)
  payment/                 Payment API endpoints
  standing-instructions/   Subscription / mandate endpoints
guides/                    Narrative integration guides (iFrame, API flow, etc.)
reference/                 Static lookup tables (state codes, business categories)
key-management/            RSA key setup for Payment API auth
authentication.mdx         Onboarding API auth (HMAC) spec
openapi.yaml               SOURCE OF TRUTH for all 18 endpoints + schemas
docs.json                  Site config: nav, theme, code-sample languages
snippets/                  Reusable MDX fragments
```

Ignore `mint.json.bak` — legacy, superseded by `docs.json`.

---

## 4. The two sources of truth

**`openapi.yaml`** owns:
- Paths, methods, request/response schemas
- Field names, types, enums, examples
- Per-field descriptions and constraints
- Per-endpoint security schemes (`ApiKeyAuth+DigestAuth` for Onboarding, `JwsTokenAuth` for Payment)
- Per-path `servers:` block (Onboarding vs Payment base URLs differ)

**`docs.json`** owns:
- Sidebar navigation structure
- Theme colors, fonts, logos
- Code-sample languages: `bash`, `python`, `java`, `node`

**MDX pages** own:
- Narrative: "When to Use", "Warning" callouts, cross-field rules, error scenarios
- Nothing that belongs in either of the above

**The single rule that keeps this working:**
If a rule is about **one field**, it lives in `openapi.yaml` as that property's `description:`.
If a rule is about **relationships between fields** or page-level behavior, it lives in the MDX.

---

## 5. How endpoint pages work

Every endpoint page is an MDX file with this frontmatter shape:

```mdx
---
title: "Human-readable title"
openapi: "PUT /gcc/v2/partner/merchant/onboard/{onboardingId}/business-details"
---
```

Mintlify matches the `openapi:` value to a path in `openapi.yaml` and auto-renders:
- Method badge (GET/POST/PUT)
- Authorizations panel
- Request Body panel with all fields + descriptions + enums
- Response panel with example
- Interactive playground

**Do not hand-roll** request/response tables, body field lists, or auth sections in MDX. They duplicate the playground and drift out of sync.

The MDX body is for narrative only.

---

## 6. MDX writing conventions

### Section order (applies to every endpoint page)

```
## When to Use              ← purpose + preconditions (1–3 sentences)

<Warning>...</Warning>      ← page-level invariant, if any (e.g., "cannot update after T&C")

## Notes                    ← cross-field rules only (omit if none)

## Error Scenarios          ← table: scenario | HTTP code
```

Overview pages (e.g., `payment/overview.mdx`, `onboarding-overview.mdx`) use `## What Are the ... APIs?` + a `## Endpoint Reference` table instead.

### Link format

- Use site-relative paths: `/api-reference/update-business-details` (no `.mdx` extension).
- Cross-reference external static tables using `/reference/...`.

### What NOT to write

- Field-level constraints like "`bankIfscCode` must be 11 characters" — put this in `openapi.yaml`.
- Supported-value lists that duplicate an enum — the enum already renders in the playground.
- Hand-rolled example requests / responses — they drift.
- Redundant preambles describing what the OpenAPI block above already shows.

### When to write a `## Notes` section

Only if the rule can't live on a single field. Examples that belong:
- "`address.businessOperatingAddress` is required only when `isOperatingSameAsRegistered` is `false`" (cross-field conditional).
- "All five card networks must be present in the array" (collection-level invariant).
- "This endpoint can only be called after all prior steps complete" (page-level ordering).

---

## 7. The two auth systems

The docs cover two completely separate auth mechanisms. Keep them separate in the MDX — do not cross-reference one from the other's pages without flagging.

| Area | Scheme | Headers | OpenAPI security scheme |
|------|--------|---------|------------------------|
| Merchant Onboarding | API Key + HMAC-SHA256 | `x-api-key`, `x-gl-digest` | `ApiKeyAuth` + `DigestAuth` |
| Payment / SI | RSA-signed JWS | `x-gl-token-external` | `JwsTokenAuth` |

`authentication.mdx` covers the Onboarding scheme. `key-management/overview.mdx` covers the Payment scheme. Payment pages also use a per-path `servers:` block in `openapi.yaml` because the base URL differs from Onboarding.

---

## 8. Common tasks — recipes

### Add a new endpoint

1. Add the path block to `openapi.yaml` under `paths:`. Include `operationId`, `summary`, `description`, `tags`, `security`, request/response schemas, and `servers:` if it's a Payment endpoint.
2. Create `api-reference/<area>/<slug>.mdx` with `openapi:` frontmatter matching the path.
3. Add narrative sections per §6.
4. Add the page to `docs.json` → `navigation` → the correct group.
5. Restart `mintlify dev` and verify the page renders.

### Change a field description

Edit the `description:` on the property in `openapi.yaml`. Do not touch MDX.

### Add a cross-field rule

Add a line to `## Notes` in the relevant MDX page. Keep it one sentence.

### Add a new language to code samples

Edit `docs.json` → `api.examples.languages`. Current set: `["bash", "python", "java", "node"]`.

### Delete a page

Delete the MDX file AND remove its entry from `docs.json`. `mintlify broken-links` will fail otherwise.

### Remove a hand-rolled duplicate section

If you find an MDX page with hand-rolled Request/Response/Authorizations sections above or below the OpenAPI-rendered block, delete them. Keep only: `## When to Use`, optional `<Warning>`, optional `## Notes`, `## Error Scenarios`.

---

## 9. Verification checklist — before opening a PR

- [ ] `openapi.yaml` parses: `python3 -c "import yaml; yaml.safe_load(open('openapi.yaml'))"`.
- [ ] `mintlify broken-links` passes.
- [ ] Restart `mintlify dev`; visit every page you changed; confirm the method badge, body, response, and playground all render.
- [ ] No `## Request Body` / `## Response` / `## Authorizations` headings in your MDX — those are Mintlify-rendered.
- [ ] No single-field rules in MDX — they belong in `openapi.yaml`.
- [ ] Links use `/path/...` format, not `/path/....mdx`.
- [ ] Frontmatter has `title` + (`openapi` for endpoint pages, or `description`+`icon` for overview pages).
- [ ] PR description flags anything pending SME validation.

---

## 10. Current status

- 18 endpoints wired in `openapi.yaml` (10 Onboarding + 8 Payment/SI).
- All Onboarding MDX pages have been stripped to narrative-only; single-field rules live in OpenAPI property descriptions.
- All Payment/SI MDX pages have `openapi:` frontmatter; hand-rolled sections removed.
- Code-sample languages locked to bash/python/java/node.

### Known gaps (contributor-visible)

- `required:` field lists in `openapi.yaml` are best-effort from example payloads — validate against backend specs before claiming them authoritative.
- Payment pages lack `## Error Scenarios` tables; Onboarding pages have them. Inconsistent.
- `api-reference/payment/overview.mdx` still describes Payment auth as "RSA/JWE" in places — should be "RSA-signed JWS" (this repo uses JWS; JWE is only for specific encrypted-body flows).
- Payment-page section order drifts from the Onboarding convention. Pick one when enriching.

---

## 11. Gotchas

- **Mintlify caches `openapi.yaml`** at dev-server start. Edits to the spec require `Ctrl+C` + `mintlify dev` to take effect. MDX edits hot-reload normally.
- **Per-path `servers:` blocks override the top-level `servers:` list.** Payment paths need both Production + Sandbox entries explicitly.
- **`docs.json` is the single nav source.** Adding an MDX file without a `docs.json` entry makes the page unreachable from the sidebar (but it IS accessible by URL, which masks the bug).
- **Two base URLs, one spec.** `api.onboard.payglocal.in` for Onboarding, `api.payglocal.in` for Payments. The top-level `servers:` lists both; per-path overrides pin the right one.
- **Deleting an MDX file without updating `docs.json`** leaves a broken sidebar link — `mintlify broken-links` will catch this.
- **Do not commit `mint.json.bak`-style renames without intent.** Legacy Mintlify used `mint.json`; the current config is `docs.json`.

# PayGlocal Developer Docs

Source for **[docs.payglocal.in](https://docs.payglocal.in)** — PayGlocal's developer portal, covering the Partner Merchant Onboarding API and the Merchant Payment APIs.

Built on [Mintlify](https://mintlify.com) (Sequoia theme). MDX for narrative, OpenAPI for endpoint reference.

---

## Run locally

```bash
npm i -g mint         # one-time
mint dev              # http://localhost:3000
```

Node 20 or 22 (LTS). Node 25+ is not supported by the Mintlify CLI. MDX edits hot-reload; **restart after editing `openapi.yaml`** (the spec is cached at startup).

```bash
mint broken-links     # run before opening a PR
```

---

## Architecture at a glance

Three layers. Each has exactly one job.

```
┌─────────────────────┐   ┌─────────────────────┐   ┌─────────────────────┐
│    openapi.yaml     │   │     MDX pages       │   │      docs.json      │
│                     │   │                     │   │                     │
│  Endpoints, fields, │   │  Narrative only:    │   │  Sidebar nav,       │
│  schemas, enums,    │◀──│  "When to Use",     │──▶│  theme, code-sample │
│  auth schemes,      │   │  warnings, cross-   │   │  languages.         │
│  per-path servers.  │   │  field rules, error │   │                     │
│                     │   │  scenarios.         │   │                     │
│  Source of truth    │   │                     │   │                     │
│  for everything     │   │  Frontmatter        │   │  Every new MDX must │
│  API-related.       │   │  binds page to an   │   │  be registered here │
│                     │   │  OpenAPI path.      │   │  or it's orphaned.  │
└─────────────────────┘   └─────────────────────┘   └─────────────────────┘
```

**The rule that keeps this coherent:** single-field constraints live in `openapi.yaml` as property `description:`. Cross-field or page-level rules live in MDX. Nothing is written twice.

---

## Repo map

```
openapi.yaml              SOURCE OF TRUTH — 18 endpoints + schemas + auth
docs.json                 Sidebar nav, theme, code-sample languages
api-reference/            Endpoint pages (Mintlify auto-renders from openapi.yaml)
  payment/                  Merchant Payment endpoints
  standing-instructions/    Subscription / mandate endpoints
guides/                   Narrative guides (API flow, iframe, webhooks, requirements)
plugins/                  E-commerce plugin install pages (Shopify, Woo, Magento, etc.)
no-code/                  Payment Links (no-code GCC dashboard flow)
getting-started/          GCC Dashboard + PayGlocal Identifiers
key-management/           RSA key setup for Merchant Payment APIs
authentication.mdx        HMAC signing spec for Partner Onboarding API
reference/                Static lookup tables (state codes, test cards, FAQ)
snippets/                 Reusable MDX fragments
```

---

## Two auth systems

Different audiences, different schemes. They never cross-reference directly.

| Audience | Scheme | Headers | Base URL |
|----------|--------|---------|----------|
| **Partner** (Onboarding) | API Key + HMAC-SHA256 | `x-api-key`, `x-gl-digest` | `api.onboard.payglocal.in` |
| **Merchant** (Payment / SI) | RSA-signed JWS | `x-gl-token-external` | `api.payglocal.in` |

Each path in `openapi.yaml` has its own `servers:` block that overrides the top-level list.

---

## Sidebar convention

Nav groups are prefixed by audience:

- **Partner:** — for platforms onboarding sub-merchants
- **Merchant:** — for merchants accepting payments
- *(unprefixed)* — shared (Getting Started, Security Setup, Reference, Changelog)

A reader can mentally collapse groups that don't apply to them on first glance.

---

## Where to go next

- **Contributing / conventions / recipes / gotchas** → [`AGENTS.md`](./AGENTS.md) (read once before your first edit)
- **Partner auth spec** → [`authentication.mdx`](./authentication.mdx)
- **Merchant auth spec** → [`key-management/overview.mdx`](./key-management/overview.mdx)
- **Endpoint inventory** → [`openapi.yaml`](./openapi.yaml)

For questions, contact [merchant.support@payglocal.in](mailto:merchant.support@payglocal.in).

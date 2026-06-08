# PayGlocal Developer Portal Redesign — Proposal

> **Branch:** portal-redesign-prototype-v6  
> **Author:** DX Architecture Review  
> **Date:** 2026-06-08  
> **Status:** Draft — Awaiting Review

---

## 1. Executive Summary

### (a) Current State Problems

The PayGlocal developer portal today has 149 MDX files on disk but only 72 are reachable from the navigation — a 45% orphan rate. This is not a cosmetic problem. Among the unreachable content are the only pages that explain how to construct a JWS-signed request (key-management/, 4 files), the only consolidated test card table, the rate-limits policy, error codes, the FAQ, the Changelog, and the Quickstart guide. A developer who lands on the portal cannot find how to authenticate a Payment API call, cannot find a sandbox test card without reading source code, and cannot find what happened when a payment fails. The canonical status table for payment lifecycle states is repeated verbatim in at least 4 different files with no shared snippet, meaning the tables have already drifted from one another. The two-tab structure ("Guides" and "API Reference") conflates onboarding, conceptual explanations, how-to walkthroughs, and API endpoint references into a single flat "Guides" tab, so a developer integrating PayDirect must context-switch across Onboarding, Dashboard, Integration, and Integration Resources groups — none of which have clear Diataxis-mode boundaries. There is no dedicated home for MCA (Multi-Currency Accounts) beyond a four-page stub buried at the bottom of the Guides tab under "MCA Integration," which would be a first-class product line in any merchant's treasury setup.

### (b) The Thesis

The proposed redesign organises the portal around **product lines as the primary IA axis**, not audience personas or user journey stages. Each major PayGlocal product — Payments and Multi-Currency Accounts — gets its own top-level tab, flanked by shared foundation tabs (Get Started, Set Up) and utility tabs (API Reference, Resources). This gives six top-level tabs. The extensibility argument is decisive: when PayGlocal ships a new product, it adds a sibling tab without touching the structure of any existing tab. No current page moves involuntarily. Shared foundations (key management, onboarding, dashboard) are promoted to their own Set Up tab that every product line references but does not own. The Diataxis content model (concept / how-to / reference / recipe) is applied as a page-type constraint, not as a tab structure, so every page knows exactly what it is and what it is not allowed to contain.

### (c) What the Prototype Delivers

The prototype implements a complete nav restructure in docs.json with 6 tabs, promotes all 66 orphan files to appropriate nav positions or retires redundant duplicates, adds 24 net-new pages covering content gaps (Quickstart, Core Concepts, Glossary, Payment Status Lifecycle, Verify Webhook Signatures, JWE/JWS Signing, MCA full section, Go-Live Checklist, Apple Pay/Google Pay stubs, Rate Limits, Idempotency & Retries, Changelog in Update format, Error Codes consolidated, Currencies & Amounts, Service Status, Security Overview, FAQ), eliminates the 6 identified duplication clusters through snippet promotion, adds a client-side JWE+JWS signing widget (Web Crypto API, no external libraries) to every signed Payment API endpoint page, and ships a verifying-signatures.mdx page that is the authoritative guide to checking PayGlocal's response signature — a security gap that was completely absent from the prior docs.

---

## 2. Current-State Audit

### 2.1 Full Current Sitemap

**Tab: Guides**

- Group: Introduction
  - introduction.mdx

- Group: Onboarding
  - onboarding/overview.mdx
  - Group: Partner Onboarding
    - authentication.mdx
    - guides/merchant-requirements.mdx
    - guides/api-flow-overview.mdx
    - guides/partner-onboarding-events.mdx
    - guides/iframe-integration.mdx
  - Group: Merchant Onboarding
    - onboarding/merchant.mdx

- Group: Dashboard
  - getting-started/payglocal-dashboards.mdx
  - getting-started/dashboard-and-key-management.mdx

- Group: Integration
  - integration/overview.mdx
  - Group: No-Code Integration
    - no-code/overview.mdx
    - no-code/payment-link.mdx
    - no-code/invoice-link.mdx
    - no-code/payment-button.mdx
  - Group: API Integration
    - integration/api-overview.mdx
    - Group: Integration Modes
      - merchant/paycollect/overview.mdx
      - merchant/paydirect/overview.mdx
    - Group: Payment Types
      - merchant/regular-payment.mdx
      - api-reference/payment/upi.mdx
      - merchant/recurring-payment.mdx
      - merchant/auth-capture-guide.mdx
      - merchant/paycollect/codedrop.mdx

- Group: Integration Resources
  - merchant/payment-flow.mdx
  - merchant/webhooks.mdx
  - merchant/payment-response-handling.mdx
  - merchant/sdks.mdx

- Group: Merchant store plugins
  - plugins/overview.mdx
  - plugins/shopify.mdx
  - plugins/woocommerce.mdx
  - plugins/magento.mdx
  - plugins/opencart.mdx
  - plugins/wix.mdx

- Group: MCA Integration
  - mca/overview.mdx
  - mca/account-fetch.mdx
  - mca/webhooks.mdx
  - mca/document-upload.mdx

**Tab: API Reference**

- Group: Partner APIs: Merchant Onboarding
  - api-reference/onboarding-overview.mdx
  - api-reference/create-onboarding.mdx
  - api-reference/update-business-details.mdx
  - api-reference/add-beneficial-owner.mdx
  - api-reference/update-bank-details.mdx
  - api-reference/update-auth-signatory.mdx
  - api-reference/upload-documents.mdx
  - api-reference/configure-products.mdx
  - api-reference/get-verification-redirect.mdx
  - api-reference/get-status.mdx
  - api-reference/get-business-categories.mdx

- Group: Payment APIs
  - api-reference/payment/overview.mdx
  - Group: Seamless Flow (PayDirect)
    - api-reference/payments-v2/paydirect/overview.mdx
    - api-reference/payments-v2/paydirect/gpi.mdx
    - api-reference/payments-v2/paydirect/si-on-demand.mdx
    - api-reference/payments-v2/paydirect/si-auto-debit.mdx
    - api-reference/payments-v2/paydirect/auth-capture-authorise.mdx
  - Group: Checkout Flow (PayCollect)
    - api-reference/payments-v2/paycollect/overview.mdx
    - api-reference/payments-v2/paycollect/gpi.mdx
    - api-reference/payments-v2/paycollect/si-on-demand.mdx
    - api-reference/payments-v2/paycollect/si-auto-debit.mdx
    - api-reference/payments-v2/paycollect/auth-capture-authorise.mdx
  - Group: Standing Instruction Sale
    - api-reference/standing-instructions/si-subsequent-payment.mdx
    - api-reference/standing-instructions/si-status.mdx
    - api-reference/standing-instructions/si-cancellation.mdx
  - Group: Capture & reversal
    - api-reference/payment/standalone-capture.mdx
    - api-reference/payment/standalone-reversal.mdx
  - Group: Status
    - api-reference/payments-v2/common/get-transaction-status.mdx
  - Group: Refund
    - api-reference/payment/refund.mdx
  - Group: CodeDrop
    - api-reference/codedrop.mdx
  - Group: Callback Handling
    - api-reference/callback-handling.mdx
  - Group: Payload Templates
    - api-reference/payload-templates.mdx

- Group: Partner APIs: MCA
  - api-reference/mca/overview.mdx
  - api-reference/mca/account-fetch.mdx
  - api-reference/mca/document-upload.mdx

---

### 2.2 Orphan Inventory

The following 66 files exist on disk but appear in no nav entry. They are grouped by theme and annotated by disposition.

#### Cluster A — Key Management (RESCUE — critical security content, highest priority)

These 4 files are the **only** documentation for JWS request signing. They are completely absent from the nav. Without them, a developer has no official guide to constructing the x-gl-token-external header that every Payment API call requires.

| File | Disposition |
|------|-------------|
| key-management/overview.mdx | Rescue → Set Up > Keys & Security |
| key-management/private-key.mdx | Rescue → Set Up > Keys & Security |
| key-management/public-certificate.mdx | Rescue → Set Up > Keys & Security |
| key-management/request-construction.mdx | Rescue → Set Up > Keys & Security |

#### Cluster B — Reference Data (RESCUE — developer-facing lookup tables)

8 files forming a complete reference section that is entirely absent from nav. Developers have no in-nav path to test cards, error codes, rate limits, or the FAQ.

| File | Disposition |
|------|-------------|
| reference/test-cards.mdx | Rescue → Resources > Testing |
| reference/error-codes.mdx | Rescue → Resources > Error Codes |
| reference/rate-limits.mdx | Rescue → Resources > Rate Limits |
| reference/response-codes-and-errors.mdx | Rescue → Resources > Error Codes (merge or link) |
| reference/response-structure.mdx | Rescue → API Reference > Reference Data |
| reference/state-codes.mdx | Rescue → API Reference > Reference Data |
| reference/business-categories.mdx | Rescue → API Reference > Reference Data |
| reference/faq.mdx | Rescue → Resources > FAQ |

#### Cluster C — Changelog & Quickstart (RESCUE — unreachable onboarding and version history)

These two files are not just orphaned; they are actively redirected away from. The /quickstart redirect sends to /introduction, silently discarding a step-by-step walkthrough. The changelog has real API version history in AccordionGroup format.

| File | Disposition |
|------|-------------|
| quickstart.mdx | Rescue → Get Started > Quickstart |
| changelog/index.mdx | Rescue → Resources > Changelog (upgrade to Update format) |

#### Cluster D — Testing Guide (RESCUE — partial overlap with reference/test-cards.mdx)

| File | Disposition |
|------|-------------|
| guides/testing.mdx | Rescue → Payments > Build & Test > Testing Guide; merge test card tables with reference/test-cards.mdx into single canonical source |

#### Cluster E — Integration Chooser (RESCUE — useful orientation page)

| File | Disposition |
|------|-------------|
| guides/integration-chooser.mdx | Rescue → Get Started > Choose Your Path |

#### Cluster F — Webhooks (RESCUE — partner-facing webhook guide)

| File | Disposition |
|------|-------------|
| guides/webhooks.mdx | Rescue → Set Up > Webhooks or Payments > Handle the Result; audit for overlap with merchant/webhooks.mdx and extract shared snippet |

#### Cluster G — PayGlocal Identifiers & GCC Dashboard (RESCUE — Set Up content)

| File | Disposition |
|------|-------------|
| getting-started/payglocal-identifiers.mdx | Rescue → Set Up > Dashboard & Keys |
| getting-started/gcc-dashboard.mdx | Rescue → Set Up > Dashboard & Keys |

#### Cluster H — Integration Flow Diagrams (RESCUE — useful how-to reference)

| File | Disposition |
|------|-------------|
| integration/payment-flow.mdx | Rescue → Payments > Payment Lifecycle (or merge into merchant/payment-flow.mdx) |
| integration/standing-instructions-flow.mdx | Rescue → Payments > Recurring Payments |

#### Cluster I — Abandoned Auth-Capture Sub-Pages (RETIRE — content merged into auth-capture-guide.mdx)

These 5 files were granular sub-pages created when auth-capture was split into steps, then abandoned when the content was consolidated into auth-capture-guide.mdx. Redirects already exist for all of them.

| File | Disposition |
|------|-------------|
| merchant/auth-capture.mdx | Retire — redundant overview, content in auth-capture-guide.mdx |
| merchant/auth-capture/auth-payment-initiation.mdx | Retire — redirect exists |
| merchant/auth-capture/auth-full-capture.mdx | Retire — redirect exists |
| merchant/auth-capture/auth-partial-capture.mdx | Retire — redirect exists |
| merchant/auth-capture/auth-reversal.mdx | Retire — redirect exists |
| merchant/auth-capture/authorization-management.mdx | Retire — redirect exists |

#### Cluster J — Abandoned Recurring-Payment Sub-Pages (RETIRE — content merged into merchant/recurring-payment.mdx)

| File | Disposition |
|------|-------------|
| merchant/recurring-payment/si-payment-initiation.mdx | Retire — redirect exists |
| merchant/recurring-payment/si-transaction-management.mdx | Retire — redirect exists |
| merchant/recurring-payment/si-mandate-management.mdx | Retire — redirect exists |
| merchant/recurring-payment/si-status-check.mdx | Retire — redirect exists |
| merchant/recurring-payment/si-pause-mandate.mdx | Retire — redirect exists |
| merchant/recurring-payment/si-activate-mandate.mdx | Retire — redirect exists |
| merchant/recurring-payment/si-cancel-mandate.mdx | Retire — redirect exists |
| merchant/standing-instructions.mdx | Retire — parallel orphan overview, superseded by recurring-payment.mdx |

#### Cluster K — Abandoned merchant/services/ Sub-Pages (RETIRE — content in consolidated guide pages)

8 files that duplicate individual transaction services already embedded in consolidated guide pages.

| File | Disposition |
|------|-------------|
| merchant/services/auth-reversal.mdx | Retire |
| merchant/services/capture-payment.mdx | Retire |
| merchant/services/initiate-refund.mdx | Retire |
| merchant/services/si-activate.mdx | Retire |
| merchant/services/si-on-demand.mdx | Retire |
| merchant/services/si-pause.mdx | Retire |
| merchant/services/si-status-check.mdx | Retire |
| merchant/services/status-check.mdx | Retire |

#### Cluster L — Abandoned payment-products/ Directory (RETIRE — old IA, partially redirected)

| File | Disposition |
|------|-------------|
| payment-products/api-based-products.mdx | Retire — content in integration/api-overview.mdx |
| payment-products/no-code-products.mdx | Retire — content in no-code/overview.mdx |
| payment-products/pay-collect-guide.mdx | Retire — content in merchant/paycollect/overview.mdx |
| payment-products/pay-direct-guide.mdx | Retire — content in merchant/paydirect/overview.mdx |
| payment-products/payment-methods-by-payglocal.mdx | Retire — content scattered, partial redirects exist |

#### Cluster M — Abandoned payment-services/ Directory (RETIRE — old IA)

| File | Disposition |
|------|-------------|
| payment-services/get-status-service.mdx | Retire |
| payment-services/gpi-service.mdx | Retire |
| payment-services/refund-service.mdx | Retire |
| payment-services/standalone-services.mdx | Retire |
| payment-services/standing-instructions.mdx | Retire |

#### Cluster N — JWT Authentication Files (ASSESS — may contain PayCollect/PayDirect-specific signing notes)

| File | Disposition |
|------|-------------|
| merchant/paycollect/jwt-authentication.mdx | Assess — if unique content, merge into Set Up > Keys & Security |
| merchant/paydirect/jwt-authentication.mdx | Assess — if unique content, merge into Set Up > Keys & Security |

#### Cluster O — Old API Reference Duplicates (RETIRE — superseded by v2 endpoints, redirects exist)

| File | Disposition |
|------|-------------|
| api-reference/payment/get-status.mdx | Retire — redirect to payments-v2/common/get-transaction-status |
| api-reference/payment/gpi-paycollect.mdx | Retire — redirect to payments-v2/paycollect/gpi |
| api-reference/payment/upi-intent.mdx | Retire — superseded |

#### Cluster P — Merchant API Integration Overview (RETIRE — content in integration/api-overview.mdx)

| File | Disposition |
|------|-------------|
| merchant/api-integration.mdx | Retire — duplicate of integration/api-overview.mdx framing |

#### Cluster Q — Regular Payment Sub-Pages (RETIRE — redirects exist to sections in regular-payment.mdx)

| File | Disposition |
|------|-------------|
| merchant/regular-payment/payment-initiation.mdx | Retire — redirect exists |
| merchant/regular-payment/transaction-management.mdx | Retire — redirect exists |

---

### 2.3 Content Duplication and Drift

The following duplication patterns were identified through file-by-file comparison. Each represents a maintenance liability: when the canonical value changes (a new status, a new error code, a revised field name), it must be updated in multiple places, and drift is inevitable.

**Pattern 1 — Transaction Status Table (4 locations)**

The full payment status table (CREATED, INPROGRESS, AUTHORIZED, SENT_FOR_CAPTURE, FAILED, REFUNDED, DISPUTED, CANCELLED, EXPIRED, INITIATED, PENDING, REVERSED, REFUND_INITIATED) appears in full in:
- api-reference/payment/get-status.mdx (orphan, old v1)
- api-reference/payments-v2/common/get-transaction-status.mdx (live nav)
- merchant/payment-response-handling.mdx (live nav)
- merchant/auth-capture-guide.mdx (live nav)

None use a shared snippet. The old v1 page has already drifted (missing REFUND_INITIATED). Fix: create `snippets/payments-v2/status-table.mdx` and replace inline tables in all four files.

**Pattern 2 — JWS Request Signing Steps (4 locations)**

The procedure for constructing the JWS-signed payload (generate private key, sign, attach x-gl-token-external / x-gl-merchantid / x-gl-kid headers) is explained independently in:
- key-management/overview.mdx (orphan)
- key-management/request-construction.mdx (orphan)
- api-reference/payments-v2/paydirect/overview.mdx (live nav)
- api-reference/payments-v2/paycollect/overview.mdx (live nav)

The orphan key-management pages have the most detail. The overview pages have abbreviated versions. No snippet unifies the core steps. Fix: create `snippets/signing/jws-steps.mdx` covering the 5-step process and embed in all four locations.

**Pattern 3 — Webhook Payload Fields (3 locations)**

The webhook payload field descriptions (gid, merchantUniqueId, status, txnStatus, amount, currency, signature) are repeated in:
- merchant/webhooks.mdx (live nav)
- guides/webhooks.mdx (orphan)
- api-reference/callback-handling.mdx (live nav)

Individual payment method API pages also repeat subsets of these fields. Fix: create `snippets/webhooks/callback-fields.mdx` and import in all three files.

**Pattern 4 — PayCollect vs PayDirect Comparison (5 locations)**

The concept explanation (PayCollect = PayGlocal-hosted checkout, no PCI scope; PayDirect = merchant-hosted, full PCI scope) is written out fully in:
- integration/overview.mdx (live nav)
- integration/api-overview.mdx (live nav)
- merchant/api-integration.mdx (orphan, to be retired)
- payment-products/api-based-products.mdx (orphan, to be retired)
- merchant/paycollect/overview.mdx (live nav)
- merchant/paydirect/overview.mdx (live nav)

Fix: canonical comparison lives in Get Started > Core Concepts or Payments > Overview; all other pages use a one-paragraph summary with a "See also" card linking to the canonical page.

**Pattern 5 — Test Card Tables (2 orphan locations)**

Test card numbers appear in:
- guides/testing.mdx (orphan)
- reference/test-cards.mdx (orphan)

The two tables overlap but are not identical — one has additional UPI VPA test values. Neither is in the nav, so there is no canonical source. Both redirect to nothing. Fix: merge into a single `resources/test-cards.mdx` with a unified table; delete both orphan files after migration.

**Pattern 6 — Refund Eligibility Rules (3 locations)**

Refund preconditions (must be SENT_FOR_CAPTURE, cannot refund AUTHORIZED, use reversal instead) appear in:
- api-reference/payment/refund.mdx (live nav)
- merchant/services/initiate-refund.mdx (orphan, to be retired)
- payment-services/refund-service.mdx (orphan, to be retired)

Fix: canonical rules in api-reference/payment/refund.mdx; retiring the orphans removes the duplication.

---

### 2.4 Broken Mental Models

**1. "Guides" contains API reference endpoint pages.**

`api-reference/payment/upi.mdx` is nested inside the Guides tab under "API Integration > Payment Types." A developer looking for the UPI API reference would reasonably look in the API Reference tab. Placing an OpenAPI-bound endpoint page inside a how-to guide tab violates the reader's expectation and breaks Mintlify's tab-based navigation model.

**2. "Integration Resources" is a catch-all for structurally different content.**

The group "Integration Resources" (under Guides) contains: a payment flow sequence diagram (conceptual), a webhooks guide (how-to), a payment response handling page (reference), and an SDKs page (resource link). These are four different Diataxis modes mixed into one group label that signals none of them. A developer wanting to understand what happens after a payment succeeds must guess that "Integration Resources" is where it lives.

**3. Key management is the most critical prerequisite but is unreachable.**

Before a developer can make a single Payment API call, they need to generate an RSA keypair, obtain the PayGlocal public certificate, and construct a JWE+JWS signed payload. The only pages that explain this are in key-management/ — which has zero nav entries. A developer following the nav from Introduction through Onboarding into Integration will attempt to call the API without ever being told about request signing. This is not just a DX problem; it is a security gap — developers who don't know about signing will make unsigned calls and get opaque 401 errors with no guidance.

**4. The Quickstart redirect actively discards the onboarding guide.**

The redirect `/quickstart -> /introduction` is a silent discard. A developer who bookmarked or Googled `/quickstart` arrives at the introduction page with no indication that there was a step-by-step walkthrough available. The `quickstart.mdx` file contains real procedural content (Steps component with 4 numbered steps for making a first API call). It should be rescued and placed in Get Started, not silently redirected away.

**5. MCA is buried at the bottom of "Guides" with no conceptual introduction.**

The four MCA pages (overview, account-fetch, webhooks, document-upload) are grouped under "MCA Integration" at the bottom of a 7-group Guides tab. There is no MCA concepts page, no collections guide, no settlement and FX explanation, and no dedicated API reference section beyond the 3-page stub in the API Reference tab. For a business operating a multi-currency treasury, this is a first-class product, not an afterthought buried below e-commerce plugins.

**6. "Integration Modes" and "Payment Types" are sibling groups that imply a hierarchy that doesn't exist.**

A merchant reads "Integration Modes" (PayCollect vs PayDirect) and "Payment Types" (regular/UPI/recurring/auth-capture/CodeDrop) as parallel categories, but the relationship is orthogonal: every Payment Type can be implemented via either Integration Mode. The current nav implies Mode → Type ordering, but the pages themselves don't consistently reflect this. A developer choosing recurring payments doesn't know whether to read PayCollect overview or PayDirect overview first.

**7. The changelog is unreachable, making API versioning invisible.**

`changelog/index.mdx` contains a real changelog with AccordionGroup entries documenting API version history. It is an orphan with no nav entry and no redirect path. A developer who received an email about an API change cannot find the changelog in the documentation. The portal appears versionless.

---

### 2.5 Mintlify Underutilization

The following Mintlify features are either unused or underused relative to the value they would add for PayGlocal's developer documentation.

| Feature | Currently Used | Should Adopt | Gap / Opportunity |
|---------|---------------|--------------|-------------------|
| `<Steps>` | Yes (34 instances) | Already used | Good coverage; extend to key-management and Go-Live pages |
| `<Card>` / `<CardGroup>` | Yes (297 Cards, 20+ files) | Already used | Overused in some cases as navigation substitutes for real nav |
| `<Tabs>` | Yes (5 instances) | Extend | Only 5 uses — should be used on every PayDirect/PayCollect parallel page to show both options side-by-side |
| `<CodeGroup>` | Yes (3 instances) | Extend heavily | Only 3 uses — every signing code sample, every API call, every webhook verification should show bash/python/java/node side-by-side |
| `<Snippet>` | Yes (7 uses, 11 files) | Extend heavily | Only 11 snippet files for 149 MDX files — status table, JWS steps, webhook fields, refund rules all need snippets |
| Mermaid diagrams | Yes (2 instances) | Extend | Payment status state machine, signing flow, SI mandate lifecycle all benefit from Mermaid; currently only 2 diagrams total |
| `<AccordionGroup>` / `<Accordion>` | Limited (changelog, FAQ, key-management) | Extend | Useful for collapsible field reference tables on API pages |
| `<Expandable>` | Limited (key-management/private-key.mdx) | Extend | Large payloads and verbose field tables should use Expandable |
| `<Update>` (changelog component) | Not used | Adopt — P0 | changelog/index.mdx uses AccordionGroup hack; the native Update component is the correct format |
| `x-codeSamples` in OpenAPI | Not used | Adopt — P1 | Custom code samples on OpenAPI endpoint pages via x-codeSamples extension would replace the need for manual code blocks on each endpoint page |
| `playground.mode: "hide"` | Not used (mode is "simple") | Adopt — P0 for signed endpoints | Signed endpoints (every Payment API) must set playground.mode to "hide" or "simple" with a warning — the Try It button will produce 401 errors because the playground cannot sign requests |
| `<Frame>` | Not used | Adopt — P1 | Dashboard screenshots and UI walkthroughs need Frame for proper image presentation |
| `<Tooltip>` | Not used | Adopt — P2 | Field descriptions on API pages can use Tooltip for inline abbreviation expansions (JWE, JWS, GID, etc.) |
| `llms.txt` | Not used | Adopt — P1 | Adding llms.txt enables AI assistants to navigate the docs structure, improving discoverability in LLM-assisted development |
| Mintlify versioning (`versions`) | Not used | Adopt — P1 for API v1→v2 | The coexistence of v1 endpoints (openapi.yaml) and v2 endpoints (openapi-v2-*.yaml) without versioning UI is confusing; Mintlify versioning would surface this explicitly |
| Custom React MDX components | Yes (implied by jsx snippets) | Extend | The signed-try-it.jsx pattern from the prototype should be the standard for all Payment API endpoint pages |
| AI assistant (Mintlify search) | Not configured | Adopt — P1 | Enabling Mintlify's AI assistant would let developers ask natural-language questions; requires good snippet/snippet coverage first |

---

## 3. Benchmark Findings

### 3.1 Competitor Comparison Table

| Portal | Top-level sections | Organizing principle | Multi-product approach | Try-It behavior | Key adopt / avoid |
|--------|-------------------|---------------------|----------------------|-----------------|-------------------|
| **Stripe** | Docs, API Reference, SDKs, Changelog | Product + audience hybrid (Payments, Connect, Billing, Radar, etc.) | Each product is a top-level section; shared primitives (Authentication, Errors) live in a global section | Playground fully functional with test API keys; no signing required | ADOPT: product-as-tab; clear concept/how-to/reference separation. AVOID: the mega-nav becomes unusable at scale |
| **Adyen** | Integration guides, API Explorer, Changelog | Product line (Payments, Issuing, Platforms, Data) | Sibling sections per product; shared auth in a global "Authentication" section | API Explorer with HMAC signing built into the UI; shows signed headers inline | ADOPT: signed payload UI pattern; HMAC signing shown in context. AVOID: information density is overwhelming for new developers |
| **Razorpay** | Payments, Payroll, Banking+, Quick Commerce | Audience/product hybrid | Product tabs at top level; integration guides per product | Try-it with test credentials pre-loaded | ADOPT: test credentials pre-loaded. AVOID: tab proliferation (8 tabs) is hard to scan |
| **Cashfree** | Guides, API Reference, SDKs, Plugins | Journey-based (Get Started, Integrations, Features) | Products nested under Integrations; no top-level product tabs | Simple HTTP playground; no signing support | ADOPT: clean SDK page format. AVOID: burying products inside journey groups |
| **Juspay** | Overview, API Reference, Guides, SDKs | Audience (merchant, partner) + journey | No explicit multi-product structure; products mentioned contextually | Basic REST playground | AVOID: audience-first IA creates redundancy across sections |
| **PayU** | Get Started, API Reference, Guides, Changelog | Journey-based | Products as sub-sections under a single integration guide | No interactive playground | AVOID: no interactive component means slow time-to-first-call |
| **Plaid** | Products, API Reference, Changelog, Resources | Product-first | Each product (Transactions, Identity, Auth, etc.) is a first-class nav section | N/A (OAuth-based; no Try-It needed) | ADOPT: product-as-primary-axis; Resources as dedicated utility tab |
| **Wise (Transferwise)** | API Reference, Business Payments, Multi-Currency | Product + audience | Multi-currency accounts and business payments are sibling tabs | OpenAPI playground; multi-currency flows shown side-by-side | ADOPT: MCA pattern directly applicable to PayGlocal; currency handling shown prominently |
| **Braintree (PayPal)** | Guides, API Reference, SDKs | Capability-based | Vaulting, Drop-in UI, Hosted Fields as separate guides | No playground; code samples in 6 languages | ADOPT: Expandable field tables. AVOID: no Try-It is a DX regression |

### 3.2 Multi-Product IA Patterns

Stripe, Plaid, and Wise all share the same structural principle: **each product is a sibling section at the top level**, not a subsection of a journey or audience tab. Stripe's "Payments" and "Connect" are siblings, not nested. Plaid's "Transactions" and "Identity" are siblings. Wise's "Business Payments" and "Multi-Currency" are siblings.

The pattern to adopt: **product line as the primary IA axis**. Shared foundations (auth, keys, onboarding) live in a dedicated section that all product lines reference by link. When a new product ships, it becomes a new sibling tab. No existing tab is restructured. This is the only IA pattern that scales beyond two products without causing a reorganization.

The anti-pattern to avoid (seen in Cashfree and PayU): products nested inside a "journey" group (e.g., "Integrations > Payments > PayDirect"). This creates depth that can only be navigated by someone who already knows what they're looking for.

### 3.3 Signing and Try-It Patterns

**AWS SigV4:** Every endpoint reference page shows the signing algorithm inline with code samples in multiple languages. The Try-It UI is explicitly disabled for production calls; AWS provides a separate "AWS CLI" and "Postman collection" download instead. This is the closest analogue to PayGlocal's JWE+JWS approach.

**GitHub Apps JWT:** GitHub shows the JWT construction algorithm on the authentication page with working Node.js and Ruby code samples. The Try-It panel on endpoint pages shows the authorization header structure but uses placeholder values with a clear note: "Replace with your generated JWT." This is the pattern for PayGlocal's x-gl-token-external header.

**Adyen HMAC:** Adyen's API Explorer has a first-class "HMAC signing" tab on each request panel. You paste your HMAC key and the UI computes the HmacSignature field client-side before sending. No external library needed. This is the most directly applicable UX pattern for PayGlocal's signing widget.

**Recommendation:** Adopt a hybrid approach — **static code samples as primary documentation** (bash/python/java/node for the full JWE+JWS construction), with an **optional client-side TEST-key signing widget** (Web Crypto API, no external libraries) embedded on each Payment API endpoint page. The widget generates an ephemeral test keypair in the browser, constructs the JWE+JWS signed payload, and issues the sandbox call. A hardcoded `TEST KEYS ONLY — never paste a production private key` warning is non-dismissible in the widget UI.

### 3.4 Mintlify Exemplars

**Dodo Payments:** Uses `<Update>` component for changelog entries, CardGroup for product navigation on the landing page, and `<Steps>` with inline code samples for every integration flow. The landing page has three role-specific "paths" (merchant / partner / embedded finance) that route to different docs sections. PayGlocal should adopt this role-card pattern on the Get Started landing page.

**Resend:** Uses `<CodeGroup>` on every API endpoint page to show the same call in bash/node/python/ruby simultaneously. Uses `<Expandable>` for large response bodies. Uses `<Frame>` for all screenshots. The API Reference pages use `x-codeSamples` in the OpenAPI spec to supply language-specific samples that appear automatically in the rendered endpoint page. PayGlocal should adopt this pattern to replace the current manual code block duplication.

**Clerk:** Uses Mintlify's `<Tabs>` component on integration guides to show "Next.js vs React Native vs Express" implementations of the same flow side-by-side. Each tab contains its own `<Steps>` sequence. This is directly applicable to PayGlocal's PayCollect vs PayDirect parallel integration guides — the same payment type (e.g., recurring/SI) can be shown in PayCollect and PayDirect tabs on a single page.

---

## 4. Proposed IA and Organizing Principle

### 4.1 The Decision

**Product line is the primary organizing axis.** The portal is organized by what a developer is building, not by what role they play or what stage of a journey they are in.

**Justification — The Extensibility Argument:**

When PayGlocal ships a new product (e.g., an Issuing card product, a Lending API, or a Cross-Border Remittance product), the product-line-as-tab model requires adding one new sibling tab. The journey-as-tab model (Get Started / Build / Launch) would require inserting the new product's content into every existing tab, because every tab would need a new "Get Started with X" section, a new "Build with X" section, and a new "Launch X" section. The audience-as-tab model (Merchant / Partner / Developer) would require deciding which audience "owns" the new product and creating cross-references from the other audiences — a maintenance nightmare.

Product-as-tab is the only model where adding a new product is a localized change (one new tab) rather than a distributed change (updates across all existing tabs).

**Corollary — Shared Foundations are a separate tab, not per-product.**

Authentication, key management, onboarding, and the dashboard are shared across all products. They live in a "Set Up" tab that every product tab references normatively ("Before making your first Payments API call, complete Set Up > Keys & Security"). This avoids duplicating the key management guide in both the Payments tab and the MCA tab.

### 4.2 Proposed Tab Structure

#### Tab 1: Get Started

Universal entry point for all developer roles. Contains: a role-selection landing page (merchant integrating Payments / partner onboarding merchants / MCA exporter), the Quickstart guide (step-by-step first API call), Core Concepts (GID, merchantUniqueId, payment lifecycle mental model, JWE/JWS conceptual overview), Glossary of terms, and a Sandbox page (test credentials, test card numbers, environment URLs).

**Pages:** introduction (keep), quickstart (rescue from orphan), get-started/choose-your-path (new), get-started/concepts (new), get-started/glossary (new)

#### Tab 2: Set Up

Shared foundations required before integrating any PayGlocal product. Contains: Merchant Onboarding (self-service), Partner Onboarding (API-driven, 5 sub-pages), Dashboard (GCC dashboard, dashboard and key management, PayGlocal identifiers), and the Keys & Security group (key-management overview, private key generation, public certificate import, request construction, verifying signatures — the last being new).

This is the only tab that documents JWS/JWE signing. Every other tab links here for the signing procedure rather than repeating it.

**Groups:** Onboarding (merchant + partner), Dashboard, Keys & Security

#### Tab 3: Payments

All payment integration content for direct merchants. Organized by: Overview (what Payments is, PayCollect vs PayDirect comparison), No-Code Integration (payment link, invoice link, payment button), API Integration (modes: PayCollect/PayDirect; payment types: GPI regular / UPI / Recurring/SI / Auth & Capture / CodeDrop / Apple Pay / Google Pay), Handle the Result (webhooks, payment response handling, verifying signatures link), Build & Test (payment flow, testing guide, test cards link), Go-Live Checklist, and E-commerce Plugins.

#### Tab 4: Multi-Currency Accounts

First-class peer tab for MCA. Contains: Overview, Core Concepts (what MCA is, FX rates, settlement), Collections Guide (how to receive inbound payments), Settlement & FX (how funds settle, FX conversion, supported currencies), Dashboard (MCA-specific dashboard features), API reference stub linking to API Reference tab, and Go-Live Checklist. Currently only 4 pages exist; 6 new pages need to be written.

#### Tab 5: API Reference

Auto-rendered from OpenAPI specs. Contains: Onboarding APIs (Partner: merchant onboarding, 11 endpoints from openapi.yaml), Payment APIs (PayDirect and PayCollect endpoints from openapi-v2-* specs), Standing Instructions, Capture & Reversal, Status, Refund, CodeDrop, Callback Handling, Payload Templates, and Reference Data (new: response structure, state codes, business categories, payment status lifecycle). Also contains MCA API endpoints.

#### Tab 6: Resources

Utility tab for developer support content. Contains: Changelog (in Update format), SDKs, Error Codes (consolidated from reference/error-codes.mdx and reference/response-codes-and-errors.mdx), Rate Limits, Idempotency & Retries (new), Currencies & Amounts (new), Service Status (new), Security Overview (new), and FAQ.

### 4.3 How Payments and MCA Coexist

Payments and Multi-Currency Accounts are sibling tabs because they are distinct product lines with different APIs, different onboarding flows, different regulatory contexts (Payments is PA/PG regulated; MCA operates under FEMA/RBI correspondent banking rules), and different merchant personas (a payment gateway integration vs. a treasury/exporter integration).

They share: the Set Up tab (same dashboard, same API key infrastructure, potentially the same onboarding flow for certain merchant types). The shared Set Up tab is the "glue" — a developer who has completed Set Up can then choose Payments or MCA (or both) without repeating authentication setup.

Cross-tab navigation: every MCA page that requires webhook verification links to the Set Up > Keys & Security > Verifying Signatures page. Every Payments page that discusses the x-gl-merchantid header links to Set Up > Dashboard. The cross-references use `<Card>` "See also" blocks, not inline text links, so they are visually scannable.

A developer navigating from MCA to Payments: they arrive at Payments > Overview, which opens with a brief "Already set up? Jump to API Integration" card. All foundational concepts (authentication, key management) are described as "shared with MCA" with a link to Set Up, not re-documented.

### 4.4 Extensibility Test Results

| Scenario | Destination | Rule | Notes |
|----------|-------------|------|-------|
| MCA as full product | Multi-Currency Accounts tab (existing) | Already a sibling tab; expand with 6 new pages | No structural change needed |
| Apple Pay / Google Pay | Payments > API Integration > Payment Methods | New payment method = new page in Payment Types group | Add as stubs initially; expand when API is live |
| Rate-limit policy | Resources > Rate Limits | Operational reference = Resources tab | Keep out of API Reference to avoid cluttering endpoint pages |
| New product line (e.g., Issuing) | New sibling tab at same level as Payments and MCA | Product-as-tab rule; shared auth goes in Set Up | One-time addition, no existing tab touches |
| API v2 | Mintlify versioning (`versions` array) + deprecation notices in API Ref | Version-specific pages use versioning UI; sunset date in Warning callout | Requires docs.json versioning config update |
| New regions / currencies | Resources > Currencies & Amounts; regional notes inline in relevant guides | Reference data = Resources; contextual notes = inline callout | Use a `<Note>` callout: "Available in INR, USD, EUR only" |
| New SDKs / languages | Resources > SDKs | SDK listing = Resources; code samples on endpoint pages via x-codeSamples | Update the openapi spec, not the MDX |
| New e-commerce plugin | Payments > E-commerce Plugins | Plugin listing = Payments tab; follows existing plugins/ pattern | Add one page per plugin, link from overview |

---

## 5. Full Proposed Nav Tree

Every node is listed. Conventions:
- `keep: path/file.mdx` — file stays at current path, no redirect needed
- `move: old/path.mdx -> new/path.mdx` — file moves, redirect required
- `new: proposed/path.mdx` — net-new file, must be created
- `rescue: orphan/path.mdx -> nav/path.mdx` — orphan promoted to nav; file may or may not move

---

```
Tab: Get Started
  Group: Introduction
    Page: Introduction                    keep: introduction.mdx
    Page: Choose Your Path                new: get-started/choose-your-path.mdx
    Page: Quickstart                      rescue: quickstart.mdx -> quickstart.mdx (remove bad redirect)
  Group: Core Concepts
    Page: Core Concepts                   new: get-started/concepts.mdx
    Page: Glossary                        new: get-started/glossary.mdx
  Group: Sandbox & Testing
    Page: Sandbox Environment             new: get-started/sandbox.mdx
    Page: Test Cards                      rescue: reference/test-cards.mdx -> resources/test-cards.mdx

Tab: Set Up
  Group: Onboarding
    Page: Onboarding Overview             keep: onboarding/overview.mdx
    Group: Partner Onboarding
      Page: Authentication                keep: authentication.mdx
      Page: Merchant Requirements         keep: guides/merchant-requirements.mdx
      Page: API Flow Overview             keep: guides/api-flow-overview.mdx
      Page: Partner Onboarding Events     keep: guides/partner-onboarding-events.mdx
      Page: iFrame Integration            keep: guides/iframe-integration.mdx
    Group: Merchant Onboarding
      Page: Merchant Onboarding           keep: onboarding/merchant.mdx
  Group: Dashboard
    Page: PayGlocal Dashboards            keep: getting-started/payglocal-dashboards.mdx
    Page: Dashboard & Key Management      keep: getting-started/dashboard-and-key-management.mdx
    Page: PayGlocal Identifiers           rescue: getting-started/payglocal-identifiers.mdx (add to nav at current path)
    Page: GCC Dashboard                   rescue: getting-started/gcc-dashboard.mdx (add to nav at current path)
  Group: Keys & Security
    Page: Key Management Overview         rescue: key-management/overview.mdx (add to nav at current path)
    Page: Generate Private Key            rescue: key-management/private-key.mdx (add to nav at current path)
    Page: Import Public Certificate       rescue: key-management/public-certificate.mdx (add to nav at current path)
    Page: Construct Signed Request        rescue: key-management/request-construction.mdx (add to nav at current path)
    Page: Verify Response Signatures      new: key-management/verifying-signatures.mdx

Tab: Payments
  Group: Overview
    Page: Payments Overview               new: payments/overview.mdx
    Page: Integration Overview            keep: integration/overview.mdx
    Page: API Integration Guide           keep: integration/api-overview.mdx
  Group: No-Code Integration
    Page: No-Code Overview                keep: no-code/overview.mdx
    Page: Payment Link                    keep: no-code/payment-link.mdx
    Page: Invoice Link                    keep: no-code/invoice-link.mdx
    Page: Payment Button                  keep: no-code/payment-button.mdx
  Group: API Integration
    Group: Integration Modes
      Page: PayCollect (Checkout Flow)    keep: merchant/paycollect/overview.mdx
      Page: PayDirect (Seamless Flow)     keep: merchant/paydirect/overview.mdx
    Group: Payment Types
      Page: Regular Payments (GPI)        keep: merchant/regular-payment.mdx
      Page: UPI Payments                  keep: api-reference/payment/upi.mdx
      Page: Recurring Payments (SI)       keep: merchant/recurring-payment.mdx
      Page: Auth & Capture                keep: merchant/auth-capture-guide.mdx
      Page: CodeDrop                      keep: merchant/paycollect/codedrop.mdx
      Page: Apple Pay                     new: payments/payment-types/apple-pay.mdx
      Page: Google Pay                    new: payments/payment-types/google-pay.mdx
  Group: Handle the Result
    Page: Webhooks & Callbacks            keep: merchant/webhooks.mdx
    Page: Payment Response Handling       keep: merchant/payment-response-handling.mdx
    Page: Verify Response Signatures      link: key-management/verifying-signatures.mdx (cross-reference card)
  Group: Payment Lifecycle
    Page: Payment Flow Sequence           keep: merchant/payment-flow.mdx
    Page: Payment Status Lifecycle        new: reference/payment-status-lifecycle.mdx
    Page: Standing Instructions Flow      rescue: integration/standing-instructions-flow.mdx (add to nav at current path)
  Group: Build & Test
    Page: Testing Guide                   rescue: guides/testing.mdx -> payments/testing.mdx
    Page: Go-Live Checklist               new: payments/go-live.mdx
  Group: E-commerce Plugins
    Page: Plugins Overview                keep: plugins/overview.mdx
    Page: Shopify                         keep: plugins/shopify.mdx
    Page: WooCommerce                     keep: plugins/woocommerce.mdx
    Page: Magento                         keep: plugins/magento.mdx
    Page: OpenCart                        keep: plugins/opencart.mdx
    Page: Wix                             keep: plugins/wix.mdx

Tab: Multi-Currency Accounts
  Group: Overview
    Page: MCA Overview                    keep: mca/overview.mdx (expand content)
    Page: MCA Concepts                    new: mca/concepts.mdx
  Group: Collections
    Page: Collections Guide               new: mca/collections-guide.mdx
  Group: Settlement & FX
    Page: Settlement & FX                 new: mca/settlement-and-fx.mdx
  Group: Dashboard
    Page: MCA Dashboard                   new: mca/dashboard.mdx
  Group: API Integration
    Page: MCA API Guide                   new: mca/api.mdx
    Page: Account Fetch                   keep: mca/account-fetch.mdx
    Page: Webhooks                        keep: mca/webhooks.mdx
    Page: Document Upload                 keep: mca/document-upload.mdx
  Group: Go Live
    Page: MCA Go-Live Checklist           new: mca/go-live.mdx

Tab: API Reference
  Group: Onboarding APIs
    Page: Onboarding API Overview         keep: api-reference/onboarding-overview.mdx
    Page: Create Onboarding               keep: api-reference/create-onboarding.mdx
    Page: Update Business Details         keep: api-reference/update-business-details.mdx
    Page: Add Beneficial Owner            keep: api-reference/add-beneficial-owner.mdx
    Page: Update Bank Details             keep: api-reference/update-bank-details.mdx
    Page: Update Auth Signatory           keep: api-reference/update-auth-signatory.mdx
    Page: Upload Documents                keep: api-reference/upload-documents.mdx
    Page: Configure Products              keep: api-reference/configure-products.mdx
    Page: Get Verification Redirect       keep: api-reference/get-verification-redirect.mdx
    Page: Get Onboarding Status           keep: api-reference/get-status.mdx
    Page: Get Business Categories         keep: api-reference/get-business-categories.mdx
  Group: Payment APIs
    Page: Payment API Overview            keep: api-reference/payment/overview.mdx
    Group: Seamless Flow (PayDirect)
      Page: PayDirect Overview            keep: api-reference/payments-v2/paydirect/overview.mdx
      Page: GPI Regular Payment           keep: api-reference/payments-v2/paydirect/gpi.mdx
      Page: SI On-Demand                  keep: api-reference/payments-v2/paydirect/si-on-demand.mdx
      Page: SI Auto-Debit                 keep: api-reference/payments-v2/paydirect/si-auto-debit.mdx
      Page: Auth & Capture Authorise      keep: api-reference/payments-v2/paydirect/auth-capture-authorise.mdx
    Group: Checkout Flow (PayCollect)
      Page: PayCollect Overview           keep: api-reference/payments-v2/paycollect/overview.mdx
      Page: GPI Regular Payment           keep: api-reference/payments-v2/paycollect/gpi.mdx
      Page: SI On-Demand                  keep: api-reference/payments-v2/paycollect/si-on-demand.mdx
      Page: SI Auto-Debit                 keep: api-reference/payments-v2/paycollect/si-auto-debit.mdx
      Page: Auth & Capture Authorise      keep: api-reference/payments-v2/paycollect/auth-capture-authorise.mdx
    Group: Standing Instructions
      Page: SI Subsequent Payment         keep: api-reference/standing-instructions/si-subsequent-payment.mdx
      Page: SI Status                     keep: api-reference/standing-instructions/si-status.mdx
      Page: SI Cancellation               keep: api-reference/standing-instructions/si-cancellation.mdx
    Group: Capture & Reversal
      Page: Standalone Capture            keep: api-reference/payment/standalone-capture.mdx
      Page: Standalone Reversal           keep: api-reference/payment/standalone-reversal.mdx
    Group: Status
      Page: Get Transaction Status        keep: api-reference/payments-v2/common/get-transaction-status.mdx
    Group: Refund
      Page: Initiate Refund               keep: api-reference/payment/refund.mdx
    Group: CodeDrop
      Page: CodeDrop API                  keep: api-reference/codedrop.mdx
    Group: Callbacks
      Page: Callback Handling             keep: api-reference/callback-handling.mdx
    Group: Payload Templates
      Page: Payload Templates             keep: api-reference/payload-templates.mdx
  Group: MCA APIs
    Page: MCA API Overview                keep: api-reference/mca/overview.mdx
    Page: Account Fetch                   keep: api-reference/mca/account-fetch.mdx
    Page: Document Upload                 keep: api-reference/mca/document-upload.mdx
  Group: Reference Data
    Page: Response Structure              rescue: reference/response-structure.mdx -> api-reference/reference/response-structure.mdx
    Page: State Codes                     rescue: reference/state-codes.mdx -> api-reference/reference/state-codes.mdx
    Page: Business Categories             rescue: reference/business-categories.mdx -> api-reference/reference/business-categories.mdx
    Page: Payment Status Lifecycle        new: reference/payment-status-lifecycle.mdx (cross-linked from Payments tab too)
    Page: API Fields — Transaction        rescue: api-fields/transaction-payment-fields.mdx -> api-reference/fields/transaction-payment-fields.mdx
    Page: API Fields — Response           rescue: api-fields/response-fields.mdx -> api-reference/fields/response-fields.mdx
    Page: API Fields — Risk Data          rescue: api-fields/risk-data-fields.mdx -> api-reference/fields/risk-data-fields.mdx
    Page: API Fields — Response Codes     rescue: api-fields/response-codes.mdx -> api-reference/fields/response-codes.mdx

Tab: Resources
  Group: Changelog
    Page: Changelog                       rescue: changelog/index.mdx -> resources/changelog.mdx (upgrade to Update format)
  Group: Developer Tools
    Page: SDKs & Libraries                keep: merchant/sdks.mdx (no path change; cross-link from Resources)
  Group: Testing
    Page: Test Cards                      rescue: reference/test-cards.mdx -> resources/test-cards.mdx
    Page: Postman Collection              new: resources/postman.mdx
  Group: Error Handling
    Page: Error Codes                     rescue: reference/error-codes.mdx -> resources/error-codes.mdx
    Page: Response Codes & Errors         rescue: reference/response-codes-and-errors.mdx -> resources/response-codes.mdx (or merge into error-codes.mdx)
  Group: API Policies
    Page: Rate Limits                     rescue: reference/rate-limits.mdx -> resources/rate-limits.mdx
    Page: Idempotency & Retries           new: resources/idempotency.mdx
    Page: Currencies & Amounts            new: resources/currencies.mdx
  Group: Security
    Page: Security Overview               new: resources/security-overview.mdx
  Group: Support
    Page: Service Status                  new: resources/status.mdx
    Page: FAQ                             rescue: reference/faq.mdx -> resources/faq.mdx
```

---

## 6. Content Gap Analysis

Every missing page is listed below with path, rationale, and priority. P0 = blocks developer success on critical path. P1 = significant DX gap, developers will be confused without it. P2 = nice-to-have, improves quality.

| Page Title | Proposed Path | Why Needed | Priority |
|-----------|---------------|------------|----------|
| Quickstart | quickstart.mdx | Step-by-step guide to making a first API call; file exists as orphan, redirect silently discards it; must be rescued and added to Get Started nav | P0 |
| Choose Your Path | get-started/choose-your-path.mdx | Role-card landing page routing merchant / partner / MCA exporter to their respective first steps; prevents "where do I start?" confusion | P0 |
| Verify Response Signatures | key-management/verifying-signatures.mdx | Security-critical: explains how to verify PayGlocal's JWS signature on callback/webhook responses using x-gl-token header; currently no page exists for this; decoding without verifying exposes merchants to response tampering | P0 |
| Payment Status Lifecycle | reference/payment-status-lifecycle.mdx | Canonical state machine for all 13 payment statuses with finality flags and action guidance; currently duplicated in 4 places with drift; single source of truth eliminates duplication and drift | P0 |
| Core Concepts | get-started/concepts.mdx | Explains GID, merchantUniqueId, JWE vs JWS (conceptual, not procedural), payment lifecycle mental model, and the PayCollect/PayDirect decision; prerequisite to all integration guides | P0 |
| JWE/JWS Signing (Key Management Overview) | key-management/overview.mdx | File exists as orphan; must be added to nav under Set Up > Keys & Security; is the only conceptual introduction to why requests must be signed | P0 |
| Generate Private Key | key-management/private-key.mdx | File exists as orphan; must be added to nav; contains the only step-by-step key generation guide | P0 |
| Import Public Certificate | key-management/public-certificate.mdx | File exists as orphan; must be added to nav; explains how to obtain and use PayGlocal's public certificate for JWE encryption | P0 |
| Construct Signed Request | key-management/request-construction.mdx | File exists as orphan; must be added to nav; contains the concrete signing algorithm steps and header construction | P0 |
| Testing Guide | payments/testing.mdx | guides/testing.mdx exists as orphan; should be rescued and placed in Payments > Build & Test; contains sandbox setup, test card numbers, and test UPI VPA values | P0 |
| Test Cards (canonical) | resources/test-cards.mdx | Two orphan files (reference/test-cards.mdx and guides/testing.mdx) have overlapping test card tables with no canonical source; must be merged into one file in nav | P0 |
| Go-Live Checklist (Payments) | payments/go-live.mdx | No go-live page exists; merchants have no checklist before moving to production; common source of support tickets | P1 |
| Payments Overview | payments/overview.mdx | Landing page for the Payments tab; explains what the tab contains and routes the developer to their integration path; required for tab landing page convention | P1 |
| Glossary | get-started/glossary.mdx | Terms like GID, JWS, JWE, merchantUniqueId, SI, mandate, PayCollect, PayDirect are used throughout docs without a single definition page | P1 |
| Sandbox Environment | get-started/sandbox.mdx | Consolidates sandbox base URLs, test credentials format, and environment configuration into one page linked from every integration guide | P1 |
| MCA Overview (expanded) | mca/overview.mdx | Existing file is a 4-page stub; needs expansion with product description, use cases, and navigation to the full MCA section | P1 |
| MCA Concepts | mca/concepts.mdx | Explains MCA-specific terminology: virtual accounts, FX rates, settlement windows, correspondent banking; prerequisite to collections and settlement guides | P1 |
| MCA Collections Guide | mca/collections-guide.mdx | How to receive inbound cross-border payments via MCA virtual accounts; no guide currently exists | P1 |
| MCA Settlement & FX | mca/settlement-and-fx.mdx | How funds settle from virtual accounts to merchant bank account; FX conversion rates and timing; no page exists | P1 |
| MCA Dashboard | mca/dashboard.mdx | MCA-specific dashboard features (virtual account balance, FX history, settlement reports); no guide exists | P1 |
| MCA API Guide | mca/api.mdx | Conceptual guide to the MCA API before the endpoint reference; explains authentication, endpoints, and common flows | P1 |
| MCA Go-Live Checklist | mca/go-live.mdx | Go-live checklist specific to MCA activation and compliance verification | P1 |
| PayGlocal Identifiers | getting-started/payglocal-identifiers.mdx | File exists as orphan; explains the GID (Global ID) and merchantUniqueId structure; foundational for debugging | P1 |
| GCC Dashboard | getting-started/gcc-dashboard.mdx | File exists as orphan; explains the GCC (Global Currency Checkout) dashboard; needed for Set Up > Dashboard group | P1 |
| Integration Chooser / Choose Your Path | guides/integration-chooser.mdx | File exists as orphan; decision-tree style guide for choosing No-Code vs API integration; valuable orientation content | P1 |
| Standing Instructions Flow | integration/standing-instructions-flow.mdx | File exists as orphan; sequence diagram for SI/mandate lifecycle; should be in Payments > Payment Lifecycle | P1 |
| Apple Pay Guide | payments/payment-types/apple-pay.mdx | Apple Pay is mentioned in product materials but has no documentation; stub page with requirements and planned availability | P2 |
| Google Pay Guide | payments/payment-types/google-pay.mdx | Google Pay is mentioned in product materials but has no documentation; stub page with requirements and planned availability | P2 |
| Rate Limits | resources/rate-limits.mdx | reference/rate-limits.mdx exists as orphan; must be rescued and placed in Resources; developers have no visibility into API rate limits | P1 |
| Idempotency & Retries | resources/idempotency.mdx | No page exists; common developer question (how do I safely retry a failed payment call?); prevents duplicate charges | P1 |
| Currencies & Amounts | resources/currencies.mdx | No consolidated list of supported currencies, amount formatting rules (minor units vs decimal), or currency-specific limits | P1 |
| Service Status | resources/status.mdx | No status page link in docs; developers have no way to check if an outage is causing their integration failures | P2 |
| Security Overview | resources/security-overview.mdx | High-level security architecture page: PCI DSS scope for PayCollect vs PayDirect, data handling, GDPR notes, responsible disclosure | P2 |
| FAQ | resources/faq.mdx | reference/faq.mdx exists as orphan; must be rescued and placed in Resources | P1 |
| Changelog | resources/changelog.mdx | changelog/index.mdx exists as orphan with AccordionGroup; must be rescued, placed in Resources, and upgraded to Mintlify Update format | P1 |
| Error Codes (consolidated) | resources/error-codes.mdx | reference/error-codes.mdx and reference/response-codes-and-errors.mdx are both orphans with overlapping content; merge into one canonical error reference | P1 |
| Postman Collection | resources/postman.mdx | No Postman collection download page exists; reduces time-to-first-call significantly | P2 |
| Response Structure | api-reference/reference/response-structure.mdx | reference/response-structure.mdx is orphan; explains the JSON response envelope (data, errors, status fields); needed for API Reference tab | P1 |
| State Codes | api-reference/reference/state-codes.mdx | reference/state-codes.mdx is orphan; lists state/province codes used in address fields | P2 |
| API Fields — Transaction | api-reference/fields/transaction-payment-fields.mdx | api-fields/transaction-payment-fields.mdx is orphan; complete field dictionary for payment initiation requests | P1 |
| API Fields — Response | api-reference/fields/response-fields.mdx | api-fields/response-fields.mdx is orphan; complete field dictionary for payment responses | P1 |
| API Fields — Risk Data | api-reference/fields/risk-data-fields.mdx | api-fields/risk-data-fields.mdx is orphan; field dictionary for the riskData object used in fraud screening | P2 |
| API Fields — Response Codes | api-reference/fields/response-codes.mdx | api-fields/response-codes.mdx is orphan; maps numeric response codes to descriptions | P1 |

---

## 7. Migration Plan

### 7.1 URL Mapping Table

The following table covers every page being moved, renamed, or promoted from orphan. Pages that are "keep" (no path change, just added to nav) require no redirect.

| Old URL | New URL | Redirect Needed | Notes |
|---------|---------|-----------------|-------|
| /quickstart | /quickstart | Remove existing redirect to /introduction | File stays; bad redirect removed |
| /changelog | /resources/changelog | Yes | File moves from changelog/index.mdx to resources/changelog.mdx |
| /guides/testing | /payments/testing | Yes | File moves |
| /guides/integration-chooser | /get-started/choose-your-path | Yes | File moves (or new file, old deleted) |
| /reference/test-cards | /resources/test-cards | Yes | File moves |
| /reference/error-codes | /resources/error-codes | Yes | File moves |
| /reference/rate-limits | /resources/rate-limits | Yes | File moves |
| /reference/response-codes-and-errors | /resources/response-codes | Yes | File moves; consider merge with error-codes |
| /reference/response-structure | /api-reference/reference/response-structure | Yes | File moves |
| /reference/state-codes | /api-reference/reference/state-codes | Yes | File moves |
| /reference/business-categories | /api-reference/reference/business-categories | Yes | File moves (or keep at current path if already referenced) |
| /reference/faq | /resources/faq | Yes | File moves |
| /api-fields/transaction-payment-fields | /api-reference/fields/transaction-payment-fields | Yes | File moves |
| /api-fields/response-fields | /api-reference/fields/response-fields | Yes | File moves |
| /api-fields/risk-data-fields | /api-reference/fields/risk-data-fields | Yes | File moves |
| /api-fields/response-codes | /api-reference/fields/response-codes | Yes | File moves |
| /integration/standing-instructions-flow | /payments/standing-instructions-flow | Yes (optional; no existing links) | File moves |
| /merchant/sdks | /resources/sdks | Yes | Cross-link from Resources; may keep original path for backward compat |
| /key-management/overview | /set-up/keys/overview | No path change; add to nav only | Just add nav entry; no redirect |
| /key-management/private-key | /set-up/keys/private-key | No path change; add to nav only | Just add nav entry |
| /key-management/public-certificate | /set-up/keys/public-certificate | No path change; add to nav only | Just add nav entry |
| /key-management/request-construction | /set-up/keys/request-construction | No path change; add to nav only | Just add nav entry |
| /getting-started/payglocal-identifiers | Same path; add to nav | No path change needed | Just add nav entry |
| /getting-started/gcc-dashboard | Same path; add to nav | No path change needed | Just add nav entry |
| /guides/webhooks | /set-up/webhooks or /payments/webhooks | Yes | Audit for unique partner content before moving |
| /payment-products/* | Already covered by existing redirects | Existing redirects maintained | Do not add new redirects; retire files silently |
| /payment-services/* | No redirects exist | No action needed | Retire files; no public links known |
| /merchant/auth-capture | /merchant/auth-capture-guide | Redirect already exists | No new action |
| /merchant/auth-capture/* | /merchant/auth-capture-guide#* | Redirects already exist | No new action |
| /merchant/recurring-payment/* | /merchant/recurring-payment#* | Redirects already exist | No new action |
| /merchant/services/* | No redirects; no public links | Retire files | No action needed |
| /merchant/standing-instructions | /merchant/recurring-payment | Yes (new redirect) | Orphan parallel page; redirect to canonical |
| /merchant/api-integration | /integration/api-overview | Yes (new redirect) | Orphan duplicate; redirect to canonical |
| /api-reference/payment/get-status | /api-reference/payments-v2/common/get-transaction-status | Redirect already exists | Retire file after confirming redirect works |
| /api-reference/payment/gpi-paycollect | /api-reference/payments-v2/paycollect/gpi | Redirect already exists | Retire file |
| /api-reference/payment/upi-intent | /api-reference/payment/upi | Yes (new redirect) | Orphan superseded page |
| /merchant/paycollect/jwt-authentication | /key-management/overview | Yes (after content audit) | After merge into Keys & Security |
| /merchant/paydirect/jwt-authentication | /key-management/overview | Yes (after content audit) | After merge into Keys & Security |
| /integration/payment-flow | /payments/payment-flow | Yes (optional) | If not merged into merchant/payment-flow |

### 7.2 Phased Rollout

**Phase 1: Nav Restructure + New Shells (2 days)**

Goal: Ship the 6-tab structure with all existing nav pages in their new positions. No content quality changes in Phase 1 — pages are moved into the new nav skeleton. New pages required by the nav structure are created as shells (H1 + one-sentence description + "Coming soon" note).

Tasks:
1. Update docs.json navigation to 6-tab structure
2. Add all 66 orphan files to nav (no file moves in Phase 1; path stays the same, just add nav entries)
3. Create shell files for all net-new pages (get-started/concepts, get-started/glossary, key-management/verifying-signatures, reference/payment-status-lifecycle, payments/overview, payments/go-live, mca/concepts, mca/collections-guide, mca/settlement-and-fx, mca/dashboard, mca/api, mca/go-live, resources/idempotency, resources/currencies, resources/status, resources/security-overview, resources/postman, payments/payment-types/apple-pay, payments/payment-types/google-pay)
4. Remove the /quickstart -> /introduction redirect; let quickstart.mdx resolve directly
5. Add new redirects for orphan files that are moving (test-cards, error-codes, rate-limits, faq)
6. Deploy and verify: all 149 MDX files are reachable from nav or have a redirect

**Phase 2: New Content Pages (1 week)**

Goal: Fill all shell pages with real content, promote orphan clusters, and create the signing widget.

Tasks (ordered by priority):
1. P0 — Write key-management/verifying-signatures.mdx with Node/Python code samples and Mermaid flowchart
2. P0 — Write reference/payment-status-lifecycle.mdx with Mermaid stateDiagram and status table; create snippets/payments-v2/status-table.mdx
3. P0 — Write get-started/concepts.mdx covering GID, merchantUniqueId, JWE/JWS concepts
4. P0 — Merge test card tables from guides/testing.mdx and reference/test-cards.mdx into resources/test-cards.mdx
5. P0 — Build snippets/signing/signing-required.mdx (Warning + RawPayloadJourney components)
6. P0 — Build snippets/signing/signed-try-it.jsx (Web Crypto signing widget)
7. P0 — Propagate SigningRequired component and signing widget to all Payment API endpoint pages
8. P1 — Write get-started/glossary.mdx
9. P1 — Write payments/go-live.mdx
10. P1 — Write all 6 MCA content pages (concepts, collections, settlement-and-fx, dashboard, api, go-live)
11. P1 — Write resources/idempotency.mdx
12. P1 — Write resources/currencies.mdx
13. P1 — Upgrade changelog/index.mdx to Mintlify Update format; move to resources/changelog.mdx
14. P1 — Consolidate error-codes: merge reference/error-codes.mdx and reference/response-codes-and-errors.mdx into resources/error-codes.mdx
15. P1 — Create snippet for JWS steps (snippets/signing/jws-steps.mdx) and replace inline repetitions in 4 files
16. P1 — Create snippet for webhook fields (snippets/webhooks/callback-fields.mdx) and replace in 3 files
17. P2 — Write resources/security-overview.mdx
18. P2 — Write resources/status.mdx
19. P2 — Write payments/payment-types/apple-pay.mdx and google-pay.mdx stubs

**Phase 3: Content Quality Pass (ongoing)**

Goal: Apply Diataxis content model enforcement, cross-linking audit, and Mintlify feature adoption across all pages.

Tasks (no deadline; ongoing improvement):
1. Audit every Guides page against Diataxis mode; add page-type front-matter tag (type: concept | how-to | reference | recipe)
2. Replace manual CodeGroup blocks with x-codeSamples in OpenAPI specs where possible
3. Apply Mintlify versioning to separate v1 and v2 API endpoints with deprecation notices on v1 pages
4. Add Mintlify AI assistant configuration
5. Create llms.txt
6. Add Frame component to all dashboard screenshots
7. Retire all orphan files that are not rescued (payment-products/*, payment-services/*, merchant/services/*, redundant auth-capture sub-pages, redundant recurring-payment sub-pages)

### 7.3 Risk and Rollback

**Risk 1: Broken links from third-party sites or Google**

Mitigation: All moves add a redirect in docs.json. The redirects array supports wildcards for directory-level moves. Before retiring any orphan file, verify no external link points to it via `gh search code` or Google Search Console.

Rollback: Mintlify serves from the git repo. A revert commit restores the previous state in under 5 minutes.

**Risk 2: Signing widget security**

Mitigation: The client-side signing widget uses only ephemeral in-browser keys or keys explicitly pasted by the developer. The widget has a non-dismissible warning: "TEST KEYS ONLY — never paste a production private key." The widget never transmits key material to any server (all crypto runs in `crypto.subtle`).

Rollback: The widget is a single JSX component in snippets/. Removing the import from an endpoint page is a one-line change.

**Risk 3: Broken OpenAPI bindings after restructure**

Mitigation: Endpoint pages that use `openapi: POST /gl/v1/payments/initiate` in frontmatter are not being moved in Phase 1. The api.openapi array in docs.json is unchanged. Only nav entries in the tabs array change.

Rollback: Revert docs.json navigation changes; endpoint pages continue to work from previous URLs.

**Risk 4: Content accuracy in new MCA pages**

Mitigation: New MCA pages (concepts, collections, settlement-and-fx) are drafted with placeholders for values that require internal confirmation (FX spread %, settlement T+ timing, FEMA compliance notes). Each placeholder is marked with a `<!-- TODO: confirm with MCA product team -->` comment. Pages ship as "Beta" status in frontmatter until confirmed.

Rollback: MCA tab pages can be unpublished individually in docs.json by removing them from nav without deleting files.

---

## 8. Extensibility Playbook

This table is the canonical decision rule for any future "where does this go?" question. Apply it in order: if Row 1 matches, use Row 1. Only proceed to later rows if no earlier row matches.

| Scenario | Destination | Rule | Notes |
|----------|-------------|------|-------|
| New PayGlocal product line (Issuing, Lending, Remittance, etc.) | New top-level tab at the same level as "Payments" and "Multi-Currency Accounts" | One product = one sibling tab. Never nest a product inside another product's tab. | Shared auth stays in Set Up. New product-specific API endpoints go in API Reference as a new group. |
| New payment method under existing Payments product (Apple Pay, Google Pay, BNPL, etc.) | Payments > API Integration > Payment Types > [New Method] | Payment method = page in Payment Types group | If it has its own OpenAPI spec, add spec to api.openapi array and add endpoint page in API Reference > Payment APIs |
| New e-commerce plugin | Payments > E-commerce Plugins > [Plugin Name] | Plugin = page in E-commerce Plugins group | Follow existing plugins/ naming pattern |
| New API endpoint (within existing product) | API Reference > [Product Group] > [Endpoint Name] | Endpoint = page in the relevant product group in API Reference | Add OpenAPI spec if needed; add nav entry; add redirect if replacing old endpoint |
| New operational/policy document (rate limits, retries, compliance) | Resources > API Policies | Operational reference = Resources tab | Do not put in API Reference (clutters endpoint index) or Guides (not a how-to) |
| New integration guide / how-to (within existing product) | [Product Tab] > [Relevant Group] | How-to = in the product's tab | If it applies to multiple products (e.g., idempotency), put in Resources |
| New SDK or code library | Resources > Developer Tools > SDKs | SDK listing = Resources | Add language to api.examples.languages in docs.json if Mintlify supports it |
| New region or currency support | Resources > Currencies & Amounts | Update the currencies table; add regional note callouts inline in affected guides | Do not create a per-region tab or per-currency page; use a single table with regional columns |
| New security requirement or disclosure | Resources > Security Overview | Security content = Resources | If it affects a specific endpoint (e.g., new signing requirement), add a Warning callout on that endpoint's page linking to Security Overview |
| API versioning (v2 -> v3) | Mintlify versioning (`versions` array in docs.json); deprecation Warning on old endpoint pages | Old version pages stay live with "Deprecated — use v3" Warning callout; new version pages are the default | Add sunset date to Warning callout: "This endpoint will be retired on YYYY-MM-DD" |
| New dashboard feature guide | Set Up > Dashboard (if shared) or [Product Tab] > Dashboard section | Dashboard guide = Set Up if it applies to all products; product-specific dashboard features go in the product tab | MCA Dashboard guide is in the MCA tab, not Set Up, because it is product-specific |

---

## 9. Conventions

### 9.1 Page-Type Templates

Every page in the portal belongs to exactly one of the five types below. The page-type is declared in frontmatter as `type:` and enforced in PR review. Pages must not mix types.

**Type: Concept**

Purpose: Explain what something is and why it exists. Does not tell the reader how to do anything.

```
---
title: [Short noun phrase, not a gerund]
description: [One sentence: what this concept is and why it matters]
type: concept
---

## Overview
[2-3 sentences explaining the concept at a high level]

## How It Works
[Explanation of the mechanism; use Mermaid diagrams for flows and state machines]

## Key Terms
[Inline definitions of terms introduced on this page; link to Glossary for terms defined elsewhere]

## Related
<CardGroup cols={2}>
  <Card title="..." href="...">How-to guide that uses this concept</Card>
  <Card title="..." href="...">Reference page for related data</Card>
</CardGroup>
```

Required: Overview, How It Works. Optional: Key Terms (only if page introduces new terminology). Prohibited: step-by-step instructions, code samples showing API calls.

**Type: Tutorial / How-to**

Purpose: Guide the developer through completing a specific task. Always starts with a precondition ("Before you begin") and ends with a verification step ("Verify it worked").

```
---
title: [Gerund phrase: "Configure", "Set Up", "Integrate", "Handle"]
description: [One sentence: what the developer will be able to do after following this guide]
type: how-to
---

## Before You Begin
<Note>
Prerequisite list as bullet points. Link to concepts page for any term the developer must understand first.
</Note>

## Steps
<Steps>
  <Step title="Step title (verb phrase)">
  Step content. Include code sample if needed.
  <CodeGroup>
    ```bash bash
    ...
    ```
    ```python Python
    ...
    ```
  </CodeGroup>
  </Step>
</Steps>

## Verify
[How the developer confirms the task was completed successfully]

## Next Steps
<CardGroup cols={2}>
  <Card title="..." href="...">Logical next how-to</Card>
</CardGroup>
```

Required: Before You Begin, Steps, Verify. Optional: Next Steps. Prohibited: concept explanations that belong on a concept page.

**Type: Endpoint Reference**

Purpose: Document a single API endpoint. Generated from OpenAPI spec where possible.

```
---
title: [HTTP verb + resource name: "Initiate Payment", "Get Transaction Status"]
description: [One sentence summary of what the endpoint does]
type: reference
openapi: POST /gl/v1/payments/initiate
---

<Warning>
This endpoint requires JWS request signing. See [Construct Signed Request](/set-up/keys/request-construction) before using the Try It panel.
</Warning>

<Snippet file="signing/signing-required.mdx" />

## Overview
[2-3 sentence description. Not a repeat of the OpenAPI summary.]

## Authentication
[Which signing scheme: JWE+JWS for Payment APIs; HMAC for Onboarding APIs]

## Request Payload
[Expandable sections for required vs optional fields if not fully covered by OpenAPI]

## Response
[Key response fields; link to canonical status table snippet]
<Snippet file="payments-v2/status-table.mdx" />

## Error Codes
[Common error codes for this endpoint; link to Resources > Error Codes for full table]

## Code Samples
<CodeGroup>
  ```bash bash
  ...
  ```
  ```python Python
  ...
  ```
  ```java Java
  ...
  ```
  ```node Node.js
  ...
  ```
</CodeGroup>
```

Required: Warning callout on signing, Code Samples. Optional: expandable field tables (use when OpenAPI spec is insufficient). Prohibited: concept explanations, how-to narratives.

**Type: Recipe**

Purpose: Show a complete end-to-end integration pattern for a specific use case (e.g., "Integrate SI for a subscription SaaS"). Recipes combine multiple how-to steps into a coherent narrative. They may link to concept and reference pages but do not duplicate their content.

```
---
title: [Outcome-oriented title: "Set Up Recurring Billing for Subscriptions"]
description: [What the developer will have built by the end]
type: recipe
---

## What You'll Build
[Brief description + diagram of the final architecture]

## Prerequisites
[List of concepts to understand and how-tos to complete first]

## Steps
[Numbered steps, each linking to the relevant how-to page rather than repeating content]

## Complete Code Sample
[Runnable example in the developer's primary language]

## Troubleshooting
[Common failure modes specific to this recipe]
```

Required: What You'll Build, Prerequisites, Steps. Optional: Complete Code Sample, Troubleshooting.

**Type: Reference Table**

Purpose: Enumerable data that developers look up during integration (error codes, status values, currency codes). Optimized for scanning, not reading.

```
---
title: [Noun phrase: "Error Codes", "Payment Statuses", "Supported Currencies"]
description: [One sentence: what data is in this table and when to use it]
type: reference-table
---

## [Table Name]
[<Accordion> or plain markdown table depending on row count]

| Column A | Column B | Column C |
|----------|----------|----------|
...

## Notes
[Brief notes on usage, not concept explanations]
```

Required: At least one table. Optional: Notes. Prohibited: step-by-step instructions, concept explanations.

---

### 9.2 Naming Conventions

**File Names and URL Slugs:**
- All lowercase, hyphen-separated. Never underscores, spaces, or camelCase.
- Slugs are descriptive and human-readable: `verify-response-signatures`, not `vrs` or `verify-sig`.
- Endpoint reference pages: `[verb]-[resource]` — `initiate-payment`, `get-transaction-status`, `initiate-refund`.
- Concept pages: noun phrases — `payment-status-lifecycle`, `core-concepts`, `key-management-overview`.
- How-to pages: gerund phrases — `construct-signed-request`, `configure-webhooks`, `set-up-si-mandate`.
- No version numbers in slugs. Versioning is handled by Mintlify versioning UI, not by URL (`/v2/`).

**Page Title Casing:**
- Title case for page titles (H1 and the `title:` frontmatter field): "Construct Signed Request", "Payment Status Lifecycle".
- Sentence case for group labels and sub-headings (H2, H3): "Before you begin", "How it works".
- Exception: proper nouns always retain their casing: "PayDirect", "PayCollect", "JWE", "JWS", "GPI", "UPI".

**Group Label Style:**
- Group labels use title case: "Keys & Security", "Integration Resources", "Build & Test".
- Verb phrases are acceptable for action-oriented groups: "Handle the Result", "Build & Test", "Go Live".
- Avoid generic labels: "Overview" as a group label is acceptable only if the group is a landing page + one or two orientation pages. Do not use "Overview" for a group with 5+ diverse pages.

**Frontmatter fields required on every MDX page:**
```yaml
---
title: [Title Case page title]
description: [One sentence, 100-160 characters, no trailing period]
type: concept | how-to | reference | recipe | reference-table
---
```

---

### 9.3 Cross-Linking Rules

**When to link:**
- Always link on first mention of a concept that has a dedicated concept page (e.g., first mention of "JWS signing" links to key-management/request-construction).
- Always link at the bottom of a how-to page to the next logical step in the developer journey.
- Always link from a how-to or recipe page to the reference page for any status codes, error codes, or field tables referenced inline.

**How to link:**
- Use inline markdown links for first-mention concept links: `[JWS signing](/set-up/keys/request-construction)`.
- Use `<Card>` components in a "See Also" or "Next Steps" section for navigational cross-references. Do not put navigational links inline in body text.
- Use `<Snippet>` imports for repeated content blocks (status tables, signing steps, webhook fields). Never copy-paste content between pages.

**Snippet Reuse Patterns:**
- Create a snippet whenever the same content block appears on 2 or more pages.
- Snippet files live in `snippets/` and are imported with `<Snippet file="path/to/snippet.mdx" />`.
- Snippets should be pure content (no H1 headers, no frontmatter) so they embed cleanly in any page.
- Required snippets for this redesign:
  - `snippets/payments-v2/status-table.mdx` — canonical payment status table
  - `snippets/signing/jws-steps.mdx` — JWE+JWS signing steps (5-step process)
  - `snippets/signing/signing-required.mdx` — Warning callout for signed endpoints
  - `snippets/webhooks/callback-fields.mdx` — webhook payload field table
  - `snippets/signing/signed-try-it.jsx` — client-side signing widget component

---

### 9.4 Multi-OpenAPI Handling

PayGlocal currently has 10 OpenAPI YAML files. The `api.openapi` array in docs.json lists all 10, and Mintlify merges their path definitions for the playground. This causes an issue: 9 of the 10 specs define exactly one path each (`POST /gl/v1/payments/initiate` or `POST /gl/v1/payments/initiate/paycollect`), and they all have the same operationId pattern. This means the playground conflates them.

**Recommended multi-spec configuration:**

```json
"api": {
  "openapi": [
    "openapi.yaml",
    "openapi-v2-paydirect-gpi.yaml",
    "openapi-v2-paydirect-si-on-demand.yaml",
    "openapi-v2-paydirect-si-auto-debit.yaml",
    "openapi-v2-paydirect-auth.yaml",
    "openapi-v2-paycollect-gpi.yaml",
    "openapi-v2-paycollect-si-on-demand.yaml",
    "openapi-v2-paycollect-si-auto-debit.yaml",
    "openapi-v2-paycollect-auth.yaml"
  ]
}
```

Note: `openapi-paydirect.yaml` (the legacy single-path spec) should be removed from the array and its endpoint coverage absorbed into `openapi-v2-paydirect-gpi.yaml`. A redirect from the old endpoint page covers the URL change.

**Per-endpoint page binding:**
Each MDX endpoint page binds to its spec via the `openapi:` frontmatter field:
```yaml
openapi: POST /gl/v1/payments/initiate  # from openapi-v2-paydirect-gpi.yaml
```

When two specs define the same path (PayDirect and PayCollect both define POST /gl/v1/payments/initiate), Mintlify selects the spec based on which spec file is listed first in the array that contains the operationId matching the page's `openapi:` field. To avoid ambiguity, ensure each spec uses unique operationIds (e.g., `initiatePaymentGPI`, `initiatePaymentSIOnDemand`, `initiatePaymentAuth`) and the MDX page references the operationId, not just the path.

**Long term:** Consolidate the 9 single-path v2 specs into a single `openapi-v2-payments.yaml` with all payment endpoint definitions. This eliminates the operationId collision problem and makes the spec easier to maintain. This is a Phase 3 task (not Phase 1 or 2).

---

## 10. Mintlify Feature Adoption Plan

| Feature | Currently Used | Adopt | Where It Adds Value for PayGlocal | Priority |
|---------|---------------|-------|----------------------------------|----------|
| `<Steps>` | Yes (34 instances) | Already used | Extend to key-management pages and Go-Live checklists | Maintain |
| `<Card>` / `<CardGroup>` | Yes (297 instances) | Already used — reduce in some places | Good for nav role cards on landing pages; overused as nav substitutes in body text | Maintain; audit overuse |
| `<CodeGroup>` | Yes (3 instances) | Extend heavily — P0 | Every API call, every signing code sample, every webhook verification should show bash/python/java/node simultaneously | P0 |
| `<Snippet>` | Yes (11 files, 7 usages) | Extend heavily — P0 | Status table, JWS steps, webhook fields, refund rules, PayCollect/PayDirect comparison need snippets | P0 |
| `<Tabs>` | Yes (5 instances) | Extend — P1 | PayDirect vs PayCollect parallel implementations on same page; Node vs Python signing examples | P1 |
| Mermaid diagrams | Yes (2 instances) | Extend — P1 | Payment status state machine (stateDiagram-v2), signing flow (sequenceDiagram), SI mandate lifecycle | P1 |
| `<AccordionGroup>` | Limited | Extend — P1 | Collapsible field tables on endpoint pages; FAQ entries in Resources > FAQ | P1 |
| `<Expandable>` | Limited (1 file) | Extend — P1 | Large payload examples, verbose response bodies, full field dictionaries | P1 |
| `<Update>` (changelog) | Not used | Adopt — P0 | changelog/index.mdx must be upgraded from AccordionGroup hack to native Update format | P0 |
| `playground.mode: "hide"` | Not used (set to "simple") | Adopt — P0 for signed endpoints | The Try It panel on signed Payment API endpoints will produce 401 errors; must be hidden or show a signed-payload widget instead | P0 |
| `x-codeSamples` (OpenAPI) | Not used | Adopt — P1 | Add language-specific code samples to OpenAPI specs; they render automatically on endpoint pages, reducing manual code block duplication | P1 |
| `<Frame>` | Not used | Adopt — P1 | Dashboard screenshots in Set Up > Dashboard and MCA > Dashboard guides need Frame for proper responsive image display | P1 |
| `<Tooltip>` | Not used | Adopt — P2 | Inline expansion of abbreviations (JWE, JWS, GID, VPA, SI, GCC) on first mention in technical guides | P2 |
| `llms.txt` | Not used | Adopt — P1 | Enables AI coding assistants (Cursor, GitHub Copilot, Claude Code) to navigate docs structure; improves developer discoverability | P1 |
| Mintlify versioning (`versions`) | Not used | Adopt — P1 | v1 vs v2 API endpoint coexistence currently causes confusion; versioning UI surfaces this explicitly | P1 |
| Custom React MDX components | Yes (implied) | Extend — P0 | Signed-try-it.jsx widget must be built and propagated to all Payment API endpoint pages | P0 |
| Mintlify AI assistant | Not configured | Adopt — P1 | Allows developers to ask natural-language questions; requires good snippet coverage first as prerequisite | P1 (after snippet work) |
| `<Columns>` | Not used | Adopt — P2 | Side-by-side comparison of PayCollect vs PayDirect features, or v1 vs v2 API differences | P2 |
| `<Icon>` in groups | Yes (some groups) | Extend | Apply consistently to all nav groups for visual scannability | Maintain |
| `expanded: true` on groups | Yes (API Reference) | Apply consistently | All API Reference groups should be expanded by default; Guides groups should be collapsed by default | Maintain |

---

## 11. Signed-Payload "Try It" Approach

### 11.1 The Decision

**Hybrid approach: static code samples as primary documentation, with an optional client-side TEST-key signing widget on each Payment API endpoint page.**

Justification: Mintlify's default Try It panel sends raw HTTP requests directly from the browser. PayGlocal's Payment APIs require JWE encryption + JWS signing of the raw payload before transmission — a process that involves private key material that must never leave the developer's control. The default playground cannot perform this signing, so every attempt by a developer to use the standard Try It panel against a live sandbox endpoint will produce a 401. This is the most common source of developer confusion on the current portal.

The hybrid approach addresses this:
1. **Static code samples** (in 4 languages: bash, python, java, node) on every endpoint page give developers a copy-pasteable implementation they can run locally with their own keys.
2. **The signing widget** (client-side React + Web Crypto API) lets developers generate ephemeral test keys in the browser and make a signed call to the sandbox without setting up a local environment. This dramatically reduces time-to-first-successful-call.
3. **The standard Try It panel is hidden** (`playground.mode: "hide"`) on all Payment API endpoint pages and replaced by the signing widget. This prevents the confusing 401 experience.

### 11.2 Security Boundary

**What IS allowed in the widget:**
- Generating ephemeral RSA-2048 keypairs entirely within `crypto.subtle` (never leaves the browser)
- Accepting a user-pasted PEM private key (PKCS8 format) for signing — with a non-dismissible WARNING: "TEST KEYS ONLY. Never paste a production private key into this form."
- Accepting a user-pasted PEM public certificate (SPKI format) for JWE encryption
- Performing all JWE and JWS operations client-side via `crypto.subtle`
- Sending the signed request to the sandbox endpoint only (hardcoded URL: `https://api.uat.payglocal.in`)

**What is NOT allowed:**
- Sending any key material to any server (not even PayGlocal servers)
- Allowing the production URL (`https://api.payglocal.in`) to be entered or used
- Persisting any key material in localStorage or sessionStorage
- Pre-loading any real merchant credentials

**Enforcement:**
- The sandbox URL is hardcoded in the widget; the URL field is read-only.
- The WARNING text is rendered in a red `<Warning>` callout before the form. The "Sign and Send" button is disabled until the developer explicitly checks a checkbox acknowledging "I confirm this is a test key only."
- The widget includes a `<!-- SECURITY NOTE: No key material is transmitted to any server. All operations use crypto.subtle in the browser. -->` comment in the JSX source for code review.
- A PR review checklist item: "Does this PR add or modify the signing widget? If yes, security review required."

### 11.3 Raw Payload to JWE/JWS to Send Journey

Every Payment API endpoint page presents the developer with the following documented journey, rendered as a `<Steps>` component:

**Step 1 — Author raw JSON payload**

Construct the payment request object according to the endpoint's schema. The page shows the raw JSON with all required fields highlighted. Code sample shows how to construct this object in each language.

**Step 2 — JWE-encrypt the raw payload**

Encrypt the raw JSON string using:
- Algorithm: RSA-OAEP-256 (key encryption) + A256GCM (content encryption)
- Encryption key: PayGlocal's public certificate (SPKI format, obtained from Set Up > Keys & Security > Import Public Certificate)
- Output: JWE Compact Serialization string

Code sample shows the JWE construction in each language. Links to `snippets/signing/jws-steps.mdx` for the full algorithm details.

**Step 3 — JWS-sign the JWE string**

Sign the JWE string using:
- Algorithm: RS256 (RSASSA-PKCS1-v1_5 with SHA-256)
- Signing key: merchant's RSA private key (generated in Set Up > Keys & Security > Generate Private Key)
- Input: the JWE Compact Serialization string from Step 2
- Output: JWS Compact Serialization string (this is the value of x-gl-token-external)

**Step 4 — Send the POST request with signed headers**

The actual HTTP request body is the raw JSON payload. The JWS-signed token goes in the header, not the body.

Required headers:
- `x-gl-token-external`: the JWS token from Step 3
- `x-gl-merchantid`: the merchant's GID (from Set Up > Dashboard > PayGlocal Identifiers)
- `x-gl-kid`: the key ID for the signing key pair
- `Content-Type: text/plain` (not application/json — the body is sent as raw text to preserve the exact bytes that were signed)

**Step 5 — Verify PayGlocal's response signature**

PayGlocal returns an `x-gl-token` response header containing a JWS-signed version of the response body. Before trusting any payment status, amount, or redirect URL from the response:
1. Extract the `x-gl-token` response header value
2. Verify the JWS signature using PayGlocal's public key
3. Decode the verified payload and use its values (not the raw response body values)

Link to: `key-management/verifying-signatures.mdx` for the full verification procedure with code samples.

### 11.4 Implementation

**Code sample languages:** bash (curl), Python (cryptography + requests), Java (Bouncy Castle), Node.js (node-jose or built-in crypto)

**Widget tech stack:**
- React functional component (MDX-compatible JSX)
- Web Crypto API (`crypto.subtle`) — no external crypto libraries
- Built-in `fetch` for the HTTP request
- Inline CSS (no external CSS dependency)
- Fallback: if browser blocks CORS on the sandbox call, widget renders an equivalent `curl` command that the developer can copy and run locally

**Mintlify limitations and fallbacks:**
- Mintlify does not support server-side code execution, so the widget must be fully client-side. This is a feature, not a limitation — it ensures no key material touches a server.
- Mintlify's MDX environment does not support all React hooks in all contexts. The widget uses only `useState` and `useEffect`, which are universally supported.
- The widget is imported as a snippet: `<Snippet file="signing/signed-try-it.jsx" />` on each endpoint page.
- For endpoint pages where the widget is not yet implemented (Phase 1 shell pages), use the `<Warning>` callout from `signing/signing-required.mdx` as a placeholder.

### 11.5 Onboarding API Note

The Partner Onboarding APIs (Partner APIs: Merchant Onboarding group) use a **different signing scheme** from Payment APIs:

- **Scheme:** HMAC-SHA256 with a shared API key
- **Headers:** `x-gl-auth-token` (not x-gl-token-external), `x-gl-merchantid`
- **No JWE encryption** — request bodies are sent as plain JSON
- **Documentation:** Lives in Set Up > Partner Onboarding > Authentication (authentication.mdx), not in Keys & Security

This distinction must be clearly documented at the top of the Onboarding API Overview page with a Warning callout: "Onboarding APIs use HMAC authentication (x-gl-auth-token), not JWS signing (x-gl-token-external). See Authentication for the Onboarding API signing scheme."

The standard Try It panel (Mintlify playground with "simple" mode) works correctly for Onboarding APIs because HMAC signing can be performed by the playground using a simple header injection. No custom widget is needed.

---

## 12. Open Questions and Assumptions

The following items represent assumptions made in this proposal that require confirmation, and open questions that must be resolved before Phase 2 content work begins.

**1. MCA API maturity:** This proposal treats MCA as a first-class product tab with 6 new pages. It is assumed that the MCA product is stable enough to document in detail. If the MCA API is still in internal beta, the tab should be created with shell pages and a "Coming soon — contact sales" callout rather than full documentation.

**2. Apple Pay and Google Pay timeline:** The proposal includes stub pages for Apple Pay and Google Pay under Payments > Payment Types. It is assumed these products are on the roadmap. If they are not, the stubs should be omitted to avoid misleading developers.

**3. OpenAPI spec consolidation authority:** The proposal recommends consolidating 9 single-path OpenAPI specs into a single `openapi-v2-payments.yaml` in Phase 3. This requires a decision from the API team on whether the current per-mode-per-type spec structure serves a purpose (e.g., separate Postman imports per payment flow). Assumption: consolidation is safe and desired.

**4. Signing widget sandbox CORS policy:** The client-side signing widget sends requests directly from the developer's browser to `https://api.uat.payglocal.in`. This requires the sandbox to return CORS headers allowing `*` or the Mintlify origin. It is assumed the sandbox supports CORS for browser-originated requests. If it does not, the widget can only render a curl command (fallback mode) and cannot execute live calls.

**5. JWS response verification key distribution:** The verifying-signatures.mdx page (a new P0 page) requires publishing PayGlocal's public key (or key URL) for developers to use in response signature verification. It is assumed PayGlocal has a public JWKS endpoint or will provide a static PEM certificate for this purpose. This must be confirmed with the platform team.

**6. Redirect permanence:** The proposal adds new redirects for 15+ moved pages. The question of `permanent: true` vs `permanent: false` is consequential for SEO. Currently, all 40 redirects in docs.json use `permanent: false` (307). For pages that are permanently moved (not temporarily), `permanent: true` (301) should be used. Assumption: all moves in this redesign are permanent; use `permanent: true` for all new redirects.

**7. Changelog Update format content:** Upgrading changelog/index.mdx from AccordionGroup to Mintlify `<Update>` format requires extracting dates, version labels, and descriptions from the current accordion entries. It is assumed the AccordionGroup entries have accurate dates and can be migrated. If changelog content is incomplete or inaccurate, a fresh changelog may be more appropriate.

**8. Partner vs merchant webhook distinction:** guides/webhooks.mdx (orphan) is described as "partner-facing." This implies there are webhook differences between what a partner receives and what a merchant receives. The proposal places it in Set Up or Payments. The correct placement depends on whether the webhook payloads and events are genuinely different. This must be confirmed with the integrations team before placing the page.

**9. GCC Dashboard audience:** getting-started/gcc-dashboard.mdx (orphan) covers the GCC (Global Currency Checkout) dashboard. It is assumed this is a merchant-facing dashboard, not a partner-only dashboard, and belongs in Set Up > Dashboard. If it is partner-only, it belongs in Set Up > Partner Onboarding.

**10. Rate limit values:** reference/rate-limits.mdx (orphan) presumably contains actual rate limit values (requests per minute, burst limits). These values must be current and approved for public documentation before the page is promoted to nav. It is assumed the values are accurate; if rate limits are under revision, the page should use a "Contact support for current rate limits" note as a placeholder.

---
name: dataforseo
description: Use DataForSEO APIs and bundled OpenAPI 3.1 specifications for keyword research, SERP analysis, competitor research, backlinks, business data, domain analytics, on-page SEO, content analysis, merchant data, and AI optimization. Trigger when a user asks for DataForSEO, live SEO metrics, search volume, rankings, SERPs, backlinks, domain competitors, Google Maps business data, technology/WHOIS data, AI visibility, content analysis, merchant/product data, or a DataForSEO request/schema.
---

# DataForSEO

Use the bundled upstream schemas to select endpoints and construct valid requests. The schemas come from `dataforseo/open-ai-actions` and describe `https://api.dataforseo.com`.

## Workflow

1. Start with `references/dataforseo_researcher_toolkit.json` for common SEO research.
2. If the needed operation is absent, search the specialized schema listed below by endpoint path or `operationId`.
3. Read the complete endpoint definition before constructing the request. Do not invent fields, enum values, or defaults.
4. Keep requests narrowly scoped because live DataForSEO calls can incur account charges.
5. Return the API's task status and relevant result fields. Surface API errors rather than guessing or replacing live data with estimates.

## Authentication

DataForSEO requires HTTP Basic Authentication using the API login and API password from <https://app.dataforseo.com/api-access>. The API password differs from the normal account password.

- Read credentials from `DATAFORSEO_LOGIN` and `DATAFORSEO_PASSWORD`.
- Never print, log, commit, or place credentials in URLs or request bodies.
- If credentials are unavailable, explain that live execution is blocked while still providing the validated endpoint and payload.
- Use the credentials only with the HTTPS origin `https://api.dataforseo.com`.

Example request shape:

```bash
curl --fail-with-body --silent --show-error \
  --user "$DATAFORSEO_LOGIN:$DATAFORSEO_PASSWORD" \
  --header 'Content-Type: application/json' \
  --data '{"keywords":["seo"],"location_name":"United States","language_code":"en"}' \
  'https://api.dataforseo.com/v3/keywords_data/google_ads/search_volume/live.ai'
```

Do not run the example unless the user requests live data and the environment contains both credential variables.

## Bundled specifications

- `references/dataforseo_researcher_toolkit.json` — recommended common research operations
- `references/dataforseo_ai_optimization_openapi.json` — AI visibility and optimization data
- `references/dataforseo_backlinks_openapi.json` — backlinks and referring domains
- `references/dataforseo_business_data_openapi.json` — business listings and Google Maps data
- `references/dataforseo_content_analysis_openapi.json` — content analysis and sentiment data
- `references/dataforseo_dataforseo_labs_openapi.json` — keyword, domain, and competitor analytics
- `references/dataforseo_domain_analytics_openapi.json` — WHOIS and technology data
- `references/dataforseo_keywords_data_openapi.json` — keyword volume and trends
- `references/dataforseo_merchant_openapi.json` — merchant and product data
- `references/dataforseo_on_page_openapi.json` — on-page analysis and content parsing
- `references/dataforseo_serp_api_openapi.json` — Google, Bing, and Yahoo SERPs

For endpoint details, search only the relevant JSON file rather than loading every schema.

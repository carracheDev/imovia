# Runtime Validation Report

**Generated**: 2026-10-11
**Target**: `/home/carrache/CARRANOVA`

## Summary

| Step | Status | Exit Code | Details |
|------|--------|-----------|---------|
| API startup | PASS | 0 | NestJS started; `/api/health` returned HTTP 200. |
| API integration tests | PASS | 0 | `npm run test:e2e`: 2 files, 17 tests passed. |
| Flutter tests and analysis | PASS | 0 | `flutter test`: 5 tests passed; `flutter analyze`: no issues. |
| Browser startup and catalog smoke | PASS | 0 | Flutter Web rendered in Chrome; `GET /api/properties` returned HTTP 200 with no browser console errors after setting the local CORS origin. |
| Advertiser browser journey | UNVERIFIED | n/a | Full sign-in → draft → upload → moderation → public-detail flow was not exercised in the browser. |

**Overall**: NEEDS_SIGNOFF — API lifecycle and Flutter catalog checks pass; the full advertiser flow through the Flutter browser client remains unverified.

## Environment

- Docker: available (`docker info` succeeded).
- Node.js: available, v24.21.0.
- Chrome: available, v156.0.8078.79.
- Playwright browser setup: `npm exec --yes --package=playwright -- playwright install chromium` completed successfully.
- Browser check used the locally installed Chrome executable against the running Flutter Web server.

## Test Evidence

- API lifecycle: `apps/api/test/property-lifecycle.e2e-spec.ts`
- Existing API e2e coverage: `apps/api/test/app.e2e-spec.ts`
- Flutter widget coverage: `apps/web/test/widget_test.dart`
- Browser smoke: catalog rendered and requested `http://localhost:3000/api/properties?page=1&pageSize=12` successfully.

## Issue Found and Resolved During Validation

The initial browser request was blocked because the API process had no `WEB_ORIGIN` configured. Restarting it with the exact local Flutter origin (`http://localhost:5001`) enabled the request; the API returned `Access-Control-Allow-Origin: http://localhost:5001`. The supported configuration is documented in `README.md`.

## Known Gaps

- The full advertiser browser flow, including image upload and public detail after moderation, still needs a browser-level run.
- Google Places suggestions were not verified against Google because the API key is not configured; local API lifecycle tests use an internal location and do not depend on that key.

# Changelog

## [0.3.2](https://github.com/pklink/presswerk/releases/tag/v0.3.2) - 2026-10-10

- Added a 180×180 PNG Apple touch icon and linked it in the root layout for iPhone home screen bookmarks.

## [0.3.1](https://github.com/pklink/presswerk/releases/tag/v0.3.1) - 2026-10-10

- Fixed favicon delivery in production builds by moving it under `/images/` and updating the icon link.
- Compacted the footer layout and aligned the language selector, retaining accessible labels and the no-JavaScript submit button.

## [0.3.0](https://github.com/pklink/presswerk/releases/tag/v0.3.0) - 2026-10-04

- Added artist and shop suggestions to the preorder form, built from existing records and rendered with native `datalist` inputs.
- Added a GitHub repository link to the footer, above the version.
- Updated the Docker image to Elixir 1.20.4 on OTP 29.1.1, matching the CI toolchain.
- Ran `mix precommit` on pull requests and published Docker images only after the checks pass.
- Fixed flaky test runs by serializing the SQLite-backed test cases.
- Updated dependencies: gettext 1.0.2, dns_cluster 0.3.1, daisyui 5.7.47, and phoenix_live_dashboard 0.9.1.
- Added Renovate for automated dependency updates.

## [0.2.1](https://github.com/pklink/presswerk/releases/tag/v0.2.1) - 2026-10-04

- Made preorder artists optional. Blank artists are stored as NULL, and the database migration preserves artist-and-album uniqueness for artistless records.
- Updated preorder lists, detail pages, and the dashboard to display records without an artist.
- Run database migrations before starting the development server with `mise run dev`.

## [0.2.0](https://github.com/pklink/presswerk/releases/tag/v0.2.0) - 2026-10-03

- Added separate article and order URLs for preorders, with English and German labels.
- Renamed the existing link field to article URL. A database migration preserves existing links and adds the order URL field.

## [0.1.2](https://github.com/pklink/presswerk/releases/tag/v0.1.2) - 2026-10-03

- Fixed the version shown in the footer when starting the development server with `mise run dev`.
- Tagged Docker images from `main` as `dev` and release images as `latest` and `vX.Y.Z`.
- Added dashboard and preorder list screenshots to the README.

## [0.1.1](https://github.com/pklink/presswerk/releases/tag/v0.1.1) - 2026-10-03

- Released the single-user vinyl preorder tracker with a dashboard, search, filters, and sorting.
- Added mobile-friendly views and English and German localization.
- Added Docker deployment and multi-architecture images for `linux/amd64` and `linux/arm64`.

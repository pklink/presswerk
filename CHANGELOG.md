# Changelog

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

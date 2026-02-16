# Changelog

All notable changes to ws-redmine-wiki-acl will be documented in this file.

## [1.1.1] - 2026-02-16

### Fixed
- Use correct route helper `wiki_acl_page_update_path` in ACL form — was using non-existent `wiki_page_access_path`, causing 500 Internal Server Error on Access Control page

## [1.1.0] - 2026-02-15

### Changed
- Move "Access Control" link into ··· dropdown menu (Redmine `actions_dropdown` structure)
- Rename route to `wiki_acl_page` to avoid conflict with `additionals` plugin

## [1.0.0] - 2026-02-14

### Added
- Per-page, per-user wiki access control
- Restrict wiki pages to specific project members
- View-only and Edit access levels per user
- Admin bypass (admins always have full access)
- Lock icon indicator 🔒 on restricted pages in wiki index
- "Access Control" link in wiki page actions menu
- Unrestricted by default — pages open until explicitly restricted

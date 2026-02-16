# Changelog

All notable changes to ws-redmine-wiki-acl will be documented in this file.

## [1.2.0] - 2026-02-16

### Added
- Plugin settings page with enable/disable toggle (Configure link on Plugins page)

## [1.1.1] - 2026-02-16

### Fixed
- Use correct route helper `wiki_acl_page_update_path` in ACL form (was causing 500 error)

## [1.1.0] - 2026-02-15

### Changed
- Move "Access Control" link into ··· dropdown menu
- Rename route to avoid conflict with `additionals` plugin

## [1.0.0] - 2026-02-14

### Added
- Per-page, per-user wiki access control
- View-only and Edit access levels per user
- Admin bypass (admins always have full access)
- Lock icon 🔒 on restricted pages in wiki index

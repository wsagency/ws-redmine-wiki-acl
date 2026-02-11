# CLAUDE.md — ws-redmine-wiki-acl

## Project
Redmine plugin for per-page, per-user wiki access control.
Open source, MIT license. https://github.com/wsagency/ws-redmine-wiki-acl

## Stack
- **Backend:** Ruby on Rails (Redmine 6.1 plugin architecture, Rails 7.2.3)
- **Frontend:** Vanilla JS, Redmine's existing CSS

## What It Does
Adds per-user access control to individual wiki pages. By default, all pages are accessible
to anyone with wiki permissions (backward compatible). When ACL is enabled on a page,
only listed users can view/edit that page.

## Architecture

### Database
- `wiki_page_acls` table: wiki_page_id, user_id, access_level ('view'|'edit')

### Key Mechanics
1. **Patch WikiController** — `before_action` checks ACL before rendering page
2. **No ACL records** for a page = everyone with wiki permission can access (backward compatible!)
3. **Has ACL records** = only listed users can access
4. **Access levels:** view (read-only), edit (read + write)

### UI
- New "🔒 Access" tab on wiki pages (next to View/Edit/History)
- Checkbox list of project members with access level dropdown
- "Restrict access to specific users" toggle

## Critical Redmine 6.1 + Rails 7.2 Rules
1. `serialize :field, coder: JSON` (NOT `serialize :field, JSON`)
2. Use `prepend` for controller patches (NOT `alias_method_chain`)
3. Register permissions in `project_module` block in init.rb
4. Test with `accept_api_auth` disabled (session auth only)
5. Use Redmine's `before_action :find_wiki, :find_page` helpers where possible
6. Hook into existing WikiController flow, don't replace it

## Files
- `init.rb` — plugin registration, permissions, hooks
- `app/models/wiki_page_acl.rb` — ACL model
- `app/controllers/wiki_acl_controller.rb` — ACL management UI
- `app/views/wiki_acl/` — access control tab views
- `lib/redmine_wiki_acl/patches/wiki_controller_patch.rb` — core access check
- `lib/redmine_wiki_acl/hooks.rb` — add tab to wiki page
- `db/migrate/001_create_wiki_page_acls.rb` — migration
- `config/routes.rb` — routes for ACL controller

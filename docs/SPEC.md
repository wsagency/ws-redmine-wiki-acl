# WS Redmine Wiki ACL — Full Specification

## Overview
Per-page, per-user wiki access control for Redmine. Restricts who can view/edit specific wiki pages.

## Database

### Table: wiki_page_acls
```ruby
create_table :wiki_page_acls do |t|
  t.references :wiki_page, null: false, foreign_key: true, index: true
  t.references :user, null: false, foreign_key: true
  t.string :access_level, null: false, default: 'view'  # 'view' or 'edit'
  t.timestamps
end
add_index :wiki_page_acls, [:wiki_page_id, :user_id], unique: true
```

## Model: WikiPageAcl

```ruby
class WikiPageAcl < ActiveRecord::Base
  belongs_to :wiki_page
  belongs_to :user

  validates :access_level, inclusion: { in: %w[view edit] }
  validates :wiki_page_id, uniqueness: { scope: :user_id }

  scope :viewers, -> { where(access_level: %w[view edit]) }
  scope :editors, -> { where(access_level: 'edit') }
end
```

## Access Logic

### Core Rule
```
IF page has NO ACL records → normal Redmine behavior (everyone with wiki perm sees it)
IF page HAS ACL records → ONLY users in ACL can access
  - 'view' level → can read page
  - 'edit' level → can read AND edit page
```

### Admin Override
- Redmine admin users ALWAYS have access (bypass ACL)
- Project managers with `:manage_wiki_acl` permission can manage ACL

### Checking Access (in WikiController patch)
```ruby
def check_wiki_page_acl
  return true if User.current.admin?
  return true unless @page  # page not found, let Redmine handle 404

  acls = WikiPageAcl.where(wiki_page_id: @page.id)
  return true if acls.empty?  # no restrictions

  user_acl = acls.find_by(user_id: User.current.id)
  unless user_acl
    deny_access  # user not in ACL
    return false
  end

  # For edit actions, check edit level
  if editing_action? && user_acl.access_level != 'edit'
    deny_access
    return false
  end

  true
end
```

### Protected Actions
- `show` — needs 'view' or 'edit' ACL
- `edit`, `update` — needs 'edit' ACL
- `history`, `diff`, `annotate` — needs 'view' or 'edit' ACL
- `destroy` — needs 'edit' ACL + existing Redmine permissions

### Sidebar/Index Filtering
- Wiki index/sidebar should hide pages user can't access
- Hook into `WikiPage` to filter visible pages

## Controller: WikiAclController

### Actions
- `show` — display ACL settings for a wiki page
- `update` — save ACL settings (add/remove users, change levels)

### Routes
```ruby
# In project context
resources :wiki_acl, only: [:show, :update], controller: 'wiki_acl' do
  # page parameter comes from query string: ?page_id=PageTitle
end
```

Or nested under wiki:
```ruby
get 'projects/:project_id/wiki/:id/access', to: 'wiki_acl#show', as: 'wiki_page_access'
patch 'projects/:project_id/wiki/:id/access', to: 'wiki_acl#update'
```

## UI — Access Tab

### Tab Integration
Add "🔒 Access" link to wiki page tabs using Redmine hook:
`:view_layouts_base_content` or by patching WikiHelper.

The tab appears next to: View | Edit | History | 🔒 Access

### Access Page
```
┌─ Page Access Control ──────────────────────────┐
│                                                  │
│ ☑ Restrict access to specific users              │
│                                                  │
│ ┌──────────────────────────────────────────────┐│
│ │ User                    │ Access Level       ││
│ ├──────────────────────────────────────────────┤│
│ │ ☑ Kristijan Lukačin     │ [Edit ▼]          ││
│ │ ☑ Dalibor Stojaković    │ [View ▼]          ││
│ │ ☐ Mario Mataga          │ [View ▼]          ││
│ │ ☐ Petra Tadić           │ [View ▼]          ││
│ │ ☐ Ilija Ćurić           │ [View ▼]          ││
│ └──────────────────────────────────────────────┘│
│                                                  │
│ [Save Access Settings]                           │
│                                                  │
│ ℹ Admins always have access.                    │
│ ℹ Unchecking "Restrict access" removes all      │
│   restrictions and makes the page public.        │
└──────────────────────────────────────────────────┘
```

### Visual Indicators
- Locked pages show 🔒 icon next to title in wiki index
- Locked pages show small "Restricted" badge on the page itself

## Permissions (init.rb)

```ruby
project_module :wiki_acl do
  permission :manage_wiki_acl, {
    wiki_acl: [:show, :update]
  }, require: :member
end
```

This integrates with Redmine's role system — admins assign this permission to roles.

## WikiController Patch

Using `prepend` (Rails 7 / Ruby 3 compatible):

```ruby
module RedmineWikiAcl
  module Patches
    module WikiControllerPatch
      extend ActiveSupport::Concern

      included do
        before_action :check_wiki_page_acl, only: [
          :show, :edit, :update, :history, :diff, :annotate, :destroy,
          :add_attachment
        ]
      end

      private

      def check_wiki_page_acl
        # ... access check logic from above
      end

      def editing_action?
        %w[edit update destroy add_attachment].include?(action_name)
      end
    end
  end
end
```

## Plugin Registration (init.rb)

```ruby
Redmine::Plugin.register :redmine_wiki_acl do
  name 'WS Redmine Wiki ACL'
  author 'Kristijan Lukačin / Web Solutions Ltd (ws.agency)'
  description 'Per-page, per-user wiki access control for Redmine'
  version '1.0.0'
  url 'https://github.com/wsagency/ws-redmine-wiki-acl'
  author_url 'https://ws.agency'

  requires_redmine version_or_higher: '5.0'

  project_module :wiki_acl do
    permission :manage_wiki_acl, { wiki_acl: [:show, :update] }, require: :member
  end
end
```

## i18n

```yaml
en:
  permission_manage_wiki_acl: "Manage wiki page access control"
  wiki_acl:
    access_control: "Access Control"
    restrict_access: "Restrict access to specific users"
    access_level: "Access Level"
    view: "View"
    edit: "Edit"
    save: "Save Access Settings"
    admin_note: "Administrators always have access to all pages."
    unrestrict_note: "Unchecking 'Restrict access' removes all restrictions."
    restricted: "Restricted"
    no_access: "You don't have access to this page."

hr:
  permission_manage_wiki_acl: "Upravljanje pristupom wiki stranicama"
  wiki_acl:
    access_control: "Kontrola pristupa"
    restrict_access: "Ograniči pristup na određene korisnike"
    access_level: "Razina pristupa"
    view: "Pregled"
    edit: "Uređivanje"
    save: "Spremi postavke pristupa"
    admin_note: "Administratori uvijek imaju pristup svim stranicama."
    unrestrict_note: "Isključivanje ograničenja pristupa uklanja sva ograničenja."
    restricted: "Ograničeno"
    no_access: "Nemate pristup ovoj stranici."
```

## Edge Cases
1. **User removed from project** → ACL entry stays but user can't access project anyway
2. **Page deleted** → ACL entries cascade-deleted via foreign key
3. **Page renamed** → wiki_page_id stays same, ACL preserved
4. **Subpages** → each page has independent ACL (no inheritance)
5. **API access** → same ACL check applies (patched before_action runs for API too)

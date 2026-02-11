# WS Redmine Wiki ACL

Per-page, per-user wiki access control for Redmine.

## Features

- **Per-page access control** — restrict individual wiki pages to specific users
- **Two access levels** — View (read-only) and Edit (read + write)
- **Backward compatible** — pages without ACL rules work normally
- **Admin override** — administrators always have full access
- **Visual indicators** — lock icon on restricted pages in wiki index
- **Access management UI** — intuitive checkbox + dropdown interface on each wiki page
- **Dark mode support** — works with both light and dark themes
- **Multi-language** — English and Croatian translations included

## Requirements

- Redmine 5.0 or higher
- Ruby 3.0+
- Rails 7.0+

## Installation

1. Clone or copy the plugin to your Redmine plugins directory:

```bash
cd /path/to/redmine/plugins
git clone https://github.com/wsagency/ws-redmine-wiki-acl.git redmine_wiki_acl
```

2. Run the database migration:

```bash
cd /path/to/redmine
bundle exec rake redmine:plugins:migrate RAILS_ENV=production
```

3. Restart Redmine:

```bash
# If using Puma/Passenger/etc.
touch tmp/restart.txt
```

## Configuration

1. Go to **Administration > Roles and permissions**
2. Enable **"Manage wiki page access control"** for the roles that should manage ACL

## Usage

1. Navigate to any wiki page
2. Click the **"Access Control"** tab (visible to users with ACL management permission)
3. Check **"Restrict access to specific users"**
4. Select users and set their access level (View or Edit)
5. Click **"Save Access Settings"**

### Access Levels

| Level | Can View | Can Edit |
|-------|----------|----------|
| View  | Yes      | No       |
| Edit  | Yes      | Yes      |

### How It Works

- **No ACL records** on a page = everyone with wiki permissions can access (default Redmine behavior)
- **Has ACL records** = only listed users can access the page
- **Admins** always have access, regardless of ACL settings
- Each page has **independent** ACL — no inheritance from parent pages

## Screenshots

*Screenshots coming soon.*

## Uninstall

1. Roll back the migration:

```bash
cd /path/to/redmine
bundle exec rake redmine:plugins:migrate NAME=redmine_wiki_acl VERSION=0 RAILS_ENV=production
```

2. Remove the plugin directory:

```bash
rm -rf plugins/redmine_wiki_acl
```

3. Restart Redmine.

## License

MIT License. See [LICENSE](LICENSE) for details.

## Author

Kristijan Lukacin / [Web Solutions Ltd (ws.agency)](https://ws.agency)

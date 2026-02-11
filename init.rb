require_relative 'lib/redmine_wiki_acl/hooks'

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

Rails.configuration.to_prepare do
  unless WikiController.included_modules.include?(RedmineWikiAcl::Patches::WikiControllerPatch)
    WikiController.include(RedmineWikiAcl::Patches::WikiControllerPatch)
  end
end

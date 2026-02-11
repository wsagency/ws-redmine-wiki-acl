RedmineApp::Application.routes.draw do
  get 'projects/:project_id/wiki/:id/access', to: 'wiki_acl#show', as: 'wiki_page_access'
  patch 'projects/:project_id/wiki/:id/access', to: 'wiki_acl#update'
end

RedmineApp::Application.routes.draw do
  get 'projects/:project_id/wiki/:id/access_control', to: 'wiki_acl#show', as: 'wiki_acl_page'
  patch 'projects/:project_id/wiki/:id/access_control', to: 'wiki_acl#update', as: 'wiki_acl_page_update'
end

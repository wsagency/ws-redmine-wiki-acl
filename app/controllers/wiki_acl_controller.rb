class WikiAclController < ApplicationController
  before_action :find_project
  before_action :find_wiki
  before_action :find_page
  before_action :authorize

  def show
    @acls = WikiPageAcl.where(wiki_page_id: @page.id).index_by(&:user_id)
    @members = @project.members.includes(:user).map(&:user).sort_by(&:name)
    @restricted = @acls.any?
  end

  def update
    WikiPageAcl.where(wiki_page_id: @page.id).delete_all

    if params[:restricted] == '1' && params[:users].present?
      params[:users].each do |user_id, attrs|
        next unless attrs[:enabled] == '1'
        WikiPageAcl.create!(
          wiki_page_id: @page.id,
          user_id: user_id.to_i,
          access_level: attrs[:access_level].presence || 'view'
        )
      end
    end

    flash[:notice] = l(:notice_successful_update)
    redirect_to wiki_acl_page_path(@project, @page.title)
  end

  private

  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_wiki
    @wiki = @project.wiki
    render_404 unless @wiki
  end

  def find_page
    @page = @wiki.find_page(params[:id])
    render_404 unless @page
  end
end

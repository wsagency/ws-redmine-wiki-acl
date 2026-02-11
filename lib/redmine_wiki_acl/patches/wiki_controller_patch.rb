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
        return true if User.current.admin?
        return true unless @page

        acls = WikiPageAcl.where(wiki_page_id: @page.id)
        return true if acls.empty?

        user_acl = acls.find_by(user_id: User.current.id)
        unless user_acl
          deny_access
          return false
        end

        if editing_action? && user_acl.access_level != 'edit'
          deny_access
          return false
        end

        true
      end

      def editing_action?
        %w[edit update destroy add_attachment].include?(action_name)
      end
    end
  end
end

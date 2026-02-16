module RedmineWikiAcl
  class Hooks < Redmine::Hook::ViewListener
    # Add "Access Control" link to wiki page actions dropdown (··· menu)
    def view_layouts_base_body_bottom(context = {})
      controller = context[:controller]
      return '' unless controller.is_a?(WikiController)
      return '' unless controller.action_name.in?(%w[show edit history diff annotate])

      project = controller.instance_variable_get(:@project)
      page = controller.instance_variable_get(:@page)
      return '' unless project && page
      return '' unless User.current.allowed_to?(:manage_wiki_acl, project)

      label = I18n.t(:wiki_acl_access_control)
      url = Rails.application.routes.url_helpers.wiki_page_access_path(project, page.title)

      javascript_tag(%(
        (function() {
          // Redmine actions dropdown structure:
          // .contextual > span.drdn > div.drdn-content > div.drdn-items > [links]
          var dropdownItems = document.querySelector('.contextual .drdn .drdn-content .drdn-items');

          if (dropdownItems) {
            // Add Access Control link inside the ··· dropdown menu
            var a = document.createElement('a');
            a.href = '#{j url}';
            a.className = 'icon icon-lock';
            a.textContent = '#{j label}';
            dropdownItems.appendChild(a);
          } else {
            // Fallback: add as button next to Edit/Watch (before the dropdown trigger)
            var ctx = document.querySelector('.contextual');
            if (ctx) {
              var drdn = ctx.querySelector('.drdn');
              var a = document.createElement('a');
              a.href = '#{j url}';
              a.className = 'icon icon-lock';
              a.textContent = '#{j label}';
              a.style.marginRight = '4px';
              if (drdn) {
                ctx.insertBefore(a, drdn);
              } else {
                ctx.appendChild(a);
              }
            }
          }
        })();
      ))
    end

    # Add stylesheet to wiki pages
    def view_layouts_base_html_head(context = {})
      controller = context[:controller]
      return '' unless controller.is_a?(WikiController) || controller.is_a?(WikiAclController)

      stylesheet_link_tag('wiki_acl', plugin: 'redmine_wiki_acl')
    end

    # Add lock icon indicator in wiki index
    def view_wiki_index_bottom(context = {})
      project = context[:project]
      return '' unless project

      wiki = project.wiki
      return '' unless wiki

      restricted_page_ids = WikiPageAcl.where(
        wiki_page_id: wiki.pages.pluck(:id)
      ).distinct.pluck(:wiki_page_id)

      return '' if restricted_page_ids.empty?

      page_titles = WikiPage.where(id: restricted_page_ids).pluck(:title)
      titles_json = page_titles.to_json

      javascript_tag(%(
        (function() {
          var restrictedTitles = #{titles_json};
          var links = document.querySelectorAll('.wiki-page a, .pages-hierarchy a');
          links.forEach(function(link) {
            var href = link.getAttribute('href') || '';
            restrictedTitles.forEach(function(title) {
              var encoded = encodeURIComponent(title);
              if (href.indexOf('/' + title) !== -1 || href.indexOf('/' + encoded) !== -1) {
                if (link.textContent.indexOf('\\uD83D\\uDD12') === -1) {
                  link.textContent = '\\uD83D\\uDD12 ' + link.textContent;
                  link.classList.add('wiki-acl-restricted');
                }
              }
            });
          });
        })();
      ))
    end
  end
end

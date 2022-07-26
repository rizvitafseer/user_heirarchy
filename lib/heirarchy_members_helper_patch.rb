require_dependency 'members_helper'

module HeirarchyMembersHelperPatch
  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
    end
  end

  module ClassMethods
  end

  module InstanceMethods
    def render_reports_for_new_members(project, limit=100)
    scope = User.active.visible.sorted.not_member_of(project).like(params[:q])
    principal_count = scope.count
    principal_pages = Redmine::Pagination::Paginator.new principal_count, limit, params['page']
    principals = scope.offset(principal_pages.offset).limit(principal_pages.per_page).to_a
    s =
      content_tag(
        'div',
        content_tag(
          'div',
          principals_check_box_tags('membership[user_ids][]', principals),
          :id => 'principals'
        ),
        :class => 'objects-selection'
      )
    links =
      pagination_links_full(principal_pages,
                            principal_count,
                            :per_page_links => false) do |text, parameters, options|
        link_to(
          text,
          autocomplete_project_memberships_path(
            project,
            parameters.merge(:q => params[:q], :format => 'js')
          ),
          :remote => true)
      end
    s + content_tag('span', links, :class => 'pagination')
  end
  end
end
Redmine::Plugin.register :user_heirarchy do
  name 'User Heirarchy plugin'
  author 'Vignesh and Updated by Rizvi'
  description 'User Heirarchy plugin for Redmine'
  url 'https://github.com/rizvitafseer/user_heirarchy'
  version '0.0.2'

  settings default: {}, partial: 'settings/heirarchy'
    # require 'heirarchy_members_controller_patch'
    require_relative "lib/heirarchy_user_patch"
    require_relative "lib/heirarchy_member_patch"
    require_relative "lib/heirarchy_queries_patch"
    require_relative "lib/heirarchy_issue_patch"
    require_relative "lib/heirarchy_time_entry_query_patch"
    # MembersController.include HeirarchyMembersControllerPatch
    User.include HeirarchyUserPatch
    Member.include HeirarchyMemberPatch
    IssueQuery.include HeirarchyQueriesPatch
    Issue.include HeirarchyIssuePatch
    TimeEntryQuery.include HeirarchyTimeEntryQueryPatch
    # permission :manage_members, {:heirarchy => [:update_reportee]}, :require => :member
end

require_dependency 'members_controller'

module HeirarchyMembersControllerPatch
  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
      # after_action :add_reportees
      alias_method :create_without_reportees, :create
      alias_method :create, :create_with_reportees
    end
  end

  module ClassMethods

  end

  module InstanceMethods

    def create_with_reportees
      create_without_reportees
      if params[:reports_to].present?
        user_ids = params[:membership][:user_ids]
        project_id = params[:project_id]
        reports_to = params[:reports_to]
        added_by = User.current
        find_project = Project.find(project_id)
        reports_to.each do |reportee|
          user_ids.each do |user|
            next if user == reportee
            relate_to = UserHeirarchyRelation.where(project_id: find_project.id, reportee_id: user, user_id: reportee)
            unless relate_to.size > 0
              UserHeirarchyRelation.create(project_id: find_project.id, added_by: added_by.id, reportee_id: user, user_id: reportee)
            end
          end
        end
      end
    end

    def update_reportee
    end

  end
end


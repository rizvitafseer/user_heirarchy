require_dependency 'member'

module HeirarchyMemberPatch
  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
      after_destroy :remove_reportees
    end
  end

  module ClassMethods
  end

  module InstanceMethods
    def remove_reportees
      relate_to = UserHeirarchyRelation.where(project_id: self.project_id, reportee_id: self.user_id)
      relate_to.delete_all if relate_to.present?
    end
  end
end
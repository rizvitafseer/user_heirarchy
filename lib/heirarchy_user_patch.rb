require_dependency 'user'

module HeirarchyUserPatch

  @reportees_array = []

  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
      has_many :reports_to, class_name: 'UserHeirarchyRelation', foreign_key: :reportee_id
      has_many :reportees, class_name: 'UserHeirarchyRelation', foreign_key: :user_id
    end
  end

  module ClassMethods
  end

  module InstanceMethods
    def recursive_reportees
      report_s = self.reportees
      report_arry = []
      report_arry << self.id
      report_s.each do |user_relation|
        report_arry << user_relation.reportee_id
        report_arry << user_relation.reportees_loop if user_relation.reportee.reportees.size > 0
      end
      return report_arry.flatten.compact.uniq
    end
  end
end


require 'query'
module HeirarchyTimeEntryQueryPatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)
    base.send(:extend, ClassMethods)
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      alias_method :add_manager_column_without_filters, :initialize_available_filters
      alias_method :initialize_available_filters, :add_manager_column_with_filters
      self.operators_by_filter_type[:list_manager] = ["="]
      self.available_columns = self.available_columns << QueryColumn.new(:heirarchy)
    end
  end

  module ClassMethods
    
  end

  module InstanceMethods
    def add_manager_column_with_filters
      add_manager_column_without_filters 
      if User.current.admin?
        roles_filter = Role.givable
      else
        role_ids = []
        u_roles = User.current.members.map(&:roles).flatten.uniq.map(&:id)
        u_roles.each do |ur|
          role_ids << IssueQuery.get_heirarchy_roles(ur)
        end
        roles_filter = Role.where(id: role_ids.flatten)
      end
      add_available_filter(
      "heirarchy",
      :type => :list_optional, :values => lambda {roles_filter.map{|r| [r.name, r.id] }}
    )

    end

    def sql_for_heirarchy_field(field, operator, value)
      roles = IssueQuery.get_heirarchy_roles(value)
      if self.project_id.present?
        user_ids = Member.where(project_id: self.project_id).joins(:member_roles).where("member_roles.role_id IN (#{roles.join(',')})").map(&:user_id)
      else
        user_ids = Member.joins(:member_roles).where("member_roles.role_id IN (#{roles.join(',')})").map(&:user_id)
      end
      " issues.assigned_to_id IN (#{user_ids.join(',')})"
    end

  end
end

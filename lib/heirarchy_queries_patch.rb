require 'query'
class UserHeirarchyColumn < QueryColumn
  def groupable?
    group_by_statement.present?
  end

  def group_by_statement
    " h_mr.role_id, h_m.project_id"
  end

  def group_value(object)
    mem = Member.where(project_id: object.project_id, user_id: object.assigned_to_id).first
    role_str = mem.member_roles.first.role.id
    role_str
    #"#{object.project.name} #{role_str}"
  end
end

module HeirarchyQueriesPatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)
    base.send(:extend, ClassMethods)
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      alias_method :add_manager_column_without_filters, :initialize_available_filters
      alias_method :initialize_available_filters, :add_manager_column_with_filters
      self.operators_by_filter_type[:list_manager] = ["="]
      self.available_columns = self.available_columns << UserHeirarchyColumn.new(:heirarchy, :sortable => ' h_mr.id', :groupable => true)
    end
  end

  module ClassMethods
    def get_heirarchy_roles(role_id)
      report_roles = [role_id].flatten.compact.map(&:to_i)
      begin
        Role.givable.each do |role|
          next if report_roles.include?(role.id)
            report_roles.push(role.id) if report_roles.include?(Setting.plugin_user_heirarchy["heirarchy_#{role.id}"].to_i) 
            if report_roles.include?(Setting.plugin_user_heirarchy["heirarchy_#{role.id}"].to_i) 
              raise
            end
        end
      rescue
        retry
      end
      report_roles.uniq
    end
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

    def joins_for_order_statement(order_options)
      joins = [super]
      if order_options
        if order_options.include?('h_mr')
          joins << " INNER JOIN #{Member.table_name} h_m ON h_m.project_id = issues.project_id AND issues.assigned_to_id = h_m.user_id INNER JOIN #{MemberRole.table_name} h_mr ON h_mr.member_id = h_m.id"
        end
      end
      joins.any? ? joins.join(' ') : nil
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

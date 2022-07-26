require_dependency 'issue'

module HeirarchyIssuePatch
	def self.included(base) # :nodoc:
	    base.send(:include, InstanceMethods)
	    # base.send(:extend, ClassMethods)
	    # base.class_eval do
	    # end
  	end
  	module ClassMethods
  	end

  	module InstanceMethods
    	def heirarchy
	      self.assigned_to.members.map(&:roles).flatten.uniq.map(&:name).join(',')
    	end
  	end
end
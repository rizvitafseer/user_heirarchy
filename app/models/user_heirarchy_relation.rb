class UserHeirarchyRelation < ActiveRecord::Base
	belongs_to :user, foreign_key: :user_id
	belongs_to :reportee, class_name: "User", foreign_key: :reportee_id 

	def reportees_loop
		reportees_arry = []
		report_s = self.reportee.reportees
		return if report_s.blank?
		report_s.each do |ur|
			reportees_arry << ur.reportee_id
			reportees_arry << ur.reportees_loop if ur.reportee.reportees.size > 0
		end
		reportees_arry
	end

end
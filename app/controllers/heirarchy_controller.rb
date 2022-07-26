class HeirarchyController < ApplicationController

	# before_action :authorize

	def update_reportee
		@member = Member.find(params[:id])
		user_relations = UserHeirarchyRelation.where(reportee_id: @member.user_id, project_id: @member.project_id)
		user_relations.delete_all
		@project = @member.project
		if params[:reports_to].present?
			params[:reports_to].each do |r|
				UserHeirarchyRelation.create(reportee_id: @member.user_id, user_id: r, project_id: @member.project_id)
			end
		end
		respond_to do |format|
			format.js
		end
	end
end
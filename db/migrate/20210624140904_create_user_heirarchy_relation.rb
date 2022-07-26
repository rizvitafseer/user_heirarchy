class CreateUserHeirarchyRelation < ActiveRecord::Migration[5.2]
  def change
    create_table :user_heirarchy_relations do |t|
	    t.integer :user_id
	    t.integer :reportee_id
	    t.integer :project_id
	    t.integer :added_by

	    t.timestamps
    end
  end
end

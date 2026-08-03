class AddAuditToPrescriptions < ActiveRecord::Migration[8.0]
  def change
    add_column :prescriptions, :created_by_id, :integer
    add_column :prescriptions, :updated_by_id, :integer
  end
end

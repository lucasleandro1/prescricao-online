class CreatePrescriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :prescriptions do |t|
      t.string :title
      t.text :content
      t.string :category
      t.integer :position

      t.timestamps
    end
  end
end

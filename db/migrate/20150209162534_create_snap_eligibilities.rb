class CreateSnapEligibilities < ActiveRecord::Migration
  def change
    create_table :snap_eligibilities do |t|
      t.string :snap_dependent_no
      t.string :snap_gross_income

      t.timestamps null: false
    end
  end
end

class CreateSnapEligibilitySeniors < ActiveRecord::Migration
  def change
    create_table :snap_eligibility_seniors do |t|
      t.string :snap_dependent_no
      t.string :snap_gross_income

      t.timestamps null: false
    end
  end
end

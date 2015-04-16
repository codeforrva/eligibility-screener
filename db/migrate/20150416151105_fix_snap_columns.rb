class FixSnapColumns < ActiveRecord::Migration
  def change
    change_column :snap_eligibilities, :snap_dependent_no, :integer
    change_column :snap_eligibilities, :snap_gross_income, :integer
    change_column :snap_eligibility_seniors, :snap_dependent_no, :integer
    change_column :snap_eligibility_seniors, :snap_gross_income, :integer
  end
end

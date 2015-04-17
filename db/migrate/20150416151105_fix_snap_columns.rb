class FixSnapColumns < ActiveRecord::Migration
  def change
    if ActiveRecord::Base.connection.adapter_name = 'PostgreSQL'
      # postgresql needs to cast from string to integer
      change_column :snap_eligibilities, :snap_dependent_no, 'integer USING CAST("snap_dependent_no" AS integer)'
      change_column :snap_eligibilities, :snap_gross_income, 'integer USING CAST("snap_gross_income" AS integer)'
      change_column :snap_eligibility_seniors, :snap_dependent_no, 'integer USING CAST("snap_dependent_no" AS integer)'
      change_column :snap_eligibility_seniors, :snap_gross_income, 'integer USING CAST("snap_gross_income" AS integer)'
    else
      # sqlite3
      change_column :snap_eligibilities, :snap_dependent_no, :integer
      change_column :snap_eligibilities, :snap_gross_income, :integer
      change_column :snap_eligibility_seniors, :snap_dependent_no, :integer
      change_column :snap_eligibility_seniors, :snap_gross_income, :integer
    end
  end
end

class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.string  :phone_number
      t.boolean :enrolled_college
      t.boolean :us_citizen
      t.string  :zip_code
      t.integer :age
      t.integer :people_in_household
      t.boolean :disabled
      t.integer :monthly_income
      t.boolean :on_disability
      t.timestamps null: false
    end
  end
end

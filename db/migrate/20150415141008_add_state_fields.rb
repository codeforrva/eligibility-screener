class AddStateFields < ActiveRecord::Migration
  def change
    change_table :profiles do |t|
      t.string :active_screener
      t.string :food_state
      t.string :science_state
    end
  end
end

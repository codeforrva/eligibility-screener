class RemoveDisabilityColumn < ActiveRecord::Migration
  def change
    change_table :profiles do |t|
      t.remove :disabled
    end
  end
end

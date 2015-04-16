class AddLocale < ActiveRecord::Migration
  def change
    change_table :profiles do |t|
      t.string :locale, null: false, default: :en
    end
  end
end

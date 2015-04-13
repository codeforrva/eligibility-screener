class Profile < ActiveRecord::Base
  validates :phone_number, presence: true, uniqueness: true
  validates :age, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :people_in_household, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :monthly_income, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  def reset!
    attributes.except('id','phone_number','created_at','updated_at').each do |k,v|
      public_send("#{k}=", nil)
    end
    save!
  end
end

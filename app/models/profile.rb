class Profile < ActiveRecord::Base
  validates :phone_number, presence: true, uniqueness: true
  validates :age, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :people_in_household, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :monthly_income, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end

class Profile < ActiveRecord::Base
  validates :phone_number, presence: true, uniqueness: true
  # positive integers
  validates :age, :monthly_income,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :people_in_household,
    numericality: { only_integer: true, greater_than_or_equal_to: 0,
    less_than_or_equal_to: SnapEligibility.maximum(:snap_dependent_no) }, allow_nil: true
  # TODO: state machines collection is not available yet - maybe after all the state machines are defined
  # validates :active_screener, inclusion: { in: Profile.screener_names }, allow_nil: true

  def self.question_attributes
    attribute_names - ['id','phone_number','created_at','updated_at','active_screener'] - state_attributes
  end

  def self.state_attributes
    attribute_names.find_all{ |n| n.ends_with? '_state' }
  end

  def self.screener_names
    state_machines.keys.map &:to_s
  end

  def reset!
    self.class.question_attributes.each do |n|
      public_send("#{n}=", nil)
    end
    self.class.state_attributes.each do |n|
      public_send("#{n}=", 'start')
    end
    save!
  end

  def handle_answer!(ans)
    state_attr = "#{active_screener}_state"
    if ['start', 'qualified', 'disqualified'].include? self[state_attr]
      # send next state
      # qualification may change if the profile has changed
      public_send("next_#{active_screener}!")
    elsif ans == active_screener
      # repeat current state
      self[state_attr]
    else
      # record value
      self[self[state_attr]] = ans
      validate!
      public_send("next_#{active_screener}!") # saves
    end
    self[state_attr] # return new state name
  end

  def write_attribute(attr_name, value)
    # coerce known string values to true or false
    if self.class.columns_hash[attr_name].type == :boolean && value.is_a?(String)
      if %w(true yes y si t yep).include? value
        value = true
      elsif %w(false no n f nope).include? value
        value = false
      else
        raise "Unexpected answer for a Boolean field: #{value}"
      end
    end
    super(attr_name, value)
  end
end

# food stamps
class Profile
  def food_disqualified?
    enrolled_college ||
      us_citizen === false ||
      (!age.nil? && age < 18)
  end

  state_machine :food, attribute: :food_state, initial: :start, namespace: :food do
    state :start
    Profile.question_attributes.map(&:to_sym).each do |n|
      state n
    end
    state :qualified
    state :disqualified

    # this will execute the first matching transition
    event :next do
      # if disqualified but no zip code, get the zip code
      transition all => :zip_code, if: ->(p) { p.zip_code.nil? && p.food_disqualified? }
      # if disqualified with zip code, finished
      transition all => :disqualified, if: ->(p) { p.food_disqualified? }

      # questions
      transition all => :enrolled_college, if: ->(p) { p.enrolled_college.nil? }
      transition all => :us_citizen, if: ->(p) { p.us_citizen.nil? }
      transition all => :age, if: ->(p) { p.age.nil? }
      transition all => :people_in_household, if: ->(p) { p.people_in_household.nil? }
      transition all => :on_disability, if: ->(p) { p.on_disability.nil? }
      transition all => :monthly_income, if: ->(p) { p.monthly_income.nil? }

      # now decide
      transition all => :qualified, if: ->(p) {
        cutoffs = p.age >= 60 || p.on_disability ? SnapEligibilitySenior : SnapEligibility
        cutoff = cutoffs.find_by({ :snap_dependent_no => p.people_in_household })
        p.monthly_income < cutoff.snap_gross_income
      }
      transition all => :disqualified
    end
  end
end

# aperture science
class Profile
  state_machine :science, attribute: :science_state, initial: :start, namespace: :science do
    state :start
    Profile.question_attributes.map(&:to_sym).each do |n|
      state n
    end
    state :qualified
    state :disqualified

    # this will execute the first matching transition
    event :next do
      transition all => :age, if: ->(p) { p.age.nil? }
      transition all => :qualified, if: ->(p) { p.age <= 1000 }
      transition all => :disqualified
    end
  end
end

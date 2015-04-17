class Profile < ActiveRecord::Base
  validates :phone_number, presence: true, uniqueness: true
  # positive integers
  validates :age, :monthly_income,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :people_in_household,
    numericality: { only_integer: true, greater_than_or_equal_to: 0,
    less_than_or_equal_to: SnapEligibility.maximum(:snap_dependent_no) }, allow_nil: true
  # make sure the active screener is a valid state machine
  # uses a lambda so it is evaluated after all the state machines are defined
  validates :active_screener, inclusion: { in: ->(p) { p.class.screener_keys } }, allow_nil: true

  def self.question_attributes
    attribute_names - ['id','phone_number','created_at','updated_at','active_screener','locale'] - state_attributes
  end

  def self.state_attributes
    attribute_names.find_all{ |n| n.ends_with? '_state' }
  end

  # non-localized list of defined screener keys
  def self.screener_keys
    state_machines.keys.map &:to_s
  end

  # localized list of defined screener names
  def self.screener_names
    state_machines.keys.map { |n| I18n.t("#{n}.name") }
  end

  # return the screener key for a given localized name
  def self.screener_key_for(name)
    state_machines.select { |k,v| I18n.t("#{k}.name") == name }.keys.first
  end

  def self.all_instructions
    state_machines.keys.map { |n| I18n.t("#{n}.instructions", name: I18n.t("#{n}.name")) }.join ' '
  end

  # whether a given state name is a start or end state
  # 'start' is always the start state
  # end states either are, or contain, 'qualified' or 'disqualified'
  def start_or_end_state?(state)
    state == 'start' || ['qualified', 'disqualified'].any? { |s| s == state || state.include?(s) }
  end

  def reset!
    self.class.question_attributes.each do |n|
      public_send("#{n}=", nil)
    end
    self.class.state_attributes.each do |n|
      public_send("#{n}=", 'start')
    end
    self.locale = :en
    save!
  end

  def handle_answer!(ans)
    Rails.logger.info active_screener
    state_attr = "#{active_screener}_state"
    if start_or_end_state?(self[state_attr])
      # send next state
      # qualification may change if the profile has changed
      public_send("next_#{active_screener}!")
    elsif [active_screener, I18n.t("#{active_screener}.name")].include? ans
      # repeat current state
      self[state_attr]
    else
      # record value
      self[self[state_attr]] = ans
      validate!
      public_send("next_#{active_screener}!") # saves
    end
     # return new state name for translation
     # end states get prefixed so they can have custom translation text for each screener
    if start_or_end_state?(self[state_attr])
      "#{active_screener}.#{self[state_attr]}"
    else
      self[state_attr]
    end
  end

  def write_attribute(attr_name, value)
    # coerce known string values to true or false
    if self.class.columns_hash[attr_name].type == :boolean && value.is_a?(String)
      if %w(true yes y si t yep).include? value
        value = true
      elsif %w(false no n f nope).include? value
        value = false
      else
        raise I18n.t('error.boolean')
      end
    end
    super(attr_name, value)
  end

  # define a screener with the given name, attributes hash,
  # and a block to execute for the :next event
  def self.screener(name, attrs = {
        custom_states: [] # custom states to add to the state machine in addition to the defaults
      }, &block)
    name = name.to_sym

    state_machine name, attribute: "#{name}_state".to_sym,
      initial: :start, namespace: name do
        # special states
        state :start
        state :qualified
        state :disqualified
        # custom states
        attrs[:custom_states].each do |s|
          state s
        end
        # one state per question attribute
        Profile.question_attributes.map(&:to_sym).each do |n|
          state n
        end

        # pass custom block to the :next event
        event :next, &block
    end
  end
end

# food stamps
class Profile
  def food_disqualified?
    enrolled_college ||
      us_citizen === false ||
      (!age.nil? && age < 18)
  end

  screener :food, custom_states: [:disqualified_age, :disqualified_citizen, :disqualified_college] do
    # if disqualified but no zip code, get the zip code
    transition all => :zip_code, if: ->(p) { p.zip_code.nil? && p.food_disqualified? }
    # if disqualified with zip code, finished
    transition all => :disqualified_age, if: ->(p) { !p.age.nil? && p.age < 18 }
    transition all => :disqualified_citizen, if: ->(p) { p.us_citizen === false }
    transition all => :disqualified_college, if: ->(p) { p.enrolled_college }

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

# aperture science
class Profile
  screener :science do
    transition all => :age, if: ->(p) { p.age.nil? }
    transition all => :qualified, if: ->(p) { p.age <= 1000 }
    transition all => :disqualified
  end
end

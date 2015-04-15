module RegisteredScreeners
  include Enumerable

  def self.included(base)
    @screeners ||= {}
    @screeners[base::Key] = base.new
    base.extend ClassMethods
  end

  def self.keys
    @screeners.keys
  end

  def self.values
    @screeners.values
  end

  def self.[](key)
    @screeners[key]
  end

  def self.each(&block)
    @screeners.each(&block)
  end

  def self.all_instructions
    values.map { |s| s.class.instructions }.join(' ')
  end

  # implement this method in the screeners
  def next_question_for(profile)
    raise "%s has not implemented a next_question_for method yet" % self.class.name
  end

  module ClassMethods
    def key
      self::Key
    end

    def instructions
      self::Instructions % key
    end
  end
end

# TODO: i18n
# TODO: separate files

class FoodStampScreener
  Key = 'food'
  Instructions = "For food stamps, text '%s'."
  include RegisteredScreeners

  def next_question_for(profile)
    "you made it to the FoodStampScreener with profile #%d" % profile.id # TODO
  end
end

class ApertureScreener
  Key = 'science'
  Instructions = "For testing and cake, text '%s'."
  include RegisteredScreeners

  def next_question_for(profile)
    "you made it to the ApertureScreener with profile #%d" % profile.id # TODO
  end
end

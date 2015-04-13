module RegisteredScreeners
  include Enumerable

  def self.included(base)
    @screeners ||= {}
    @screeners[base::Key] = base
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
end

class ApertureScreener
  Key = 'science'
  Instructions = "For testing and cake, text '%s'."
  include RegisteredScreeners
end

class TextMessage
  include ActiveModel::Model
  attr_accessor :From, :Body

  def method_missing(*args)
    # ignore unrecognized values, only grab what we want
  end
end

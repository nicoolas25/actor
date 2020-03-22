# frozen_string_literal: true

class FailWithError < Actor
  def call
    fail!(error: 'Ouch', some_other_key: 42)
  end
end

# class Error < StandardError
#   attr_reader :data
#
#   def initialize(message, data)
#     @data = data
#
#     super(message)
#   end
# end
#
# class FailWithError
#   def call(**_inputs)
#     raise Error.new('Ouch', some_other_key: 42)
#   end
# end

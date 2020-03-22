# frozen_string_literal: true

require_relative './increment_value'

class InheritFromIncrementValue < IncrementValue
  def call
    super

    self.value += 1
  end
end

# class InheritFromIncrementValue < IncrementValue
#   def call(**_inputs)
#     super.tap do |outputs|
#       outputs[:value] += 1
#     end
#   end
# end

# frozen_string_literal: true

class InheritFromIncrementValue < IncrementValue
  def call
    super

    context.value += 1
  end
end

# class InheritFromIncrementValue < IncrementValue
#   def call(**_inputs)
#     super.tap do |outputs|
#       outputs[:value] += 1
#     end
#   end
# end

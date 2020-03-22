# frozen_string_literal: true

class DisallowNilOnInputWithDeprecatedRequired < Actor
  input :name, type: 'String', required: true

  def call; end
end

# class UseRequiredInput
#   def call(**inputs)
#     unless inputs[:name]
#       raise ArgumentError, "A :name input is missing"
#     end
#
#     {}
#   end
# end

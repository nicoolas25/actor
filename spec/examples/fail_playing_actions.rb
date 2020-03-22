# frozen_string_literal: true

require_relative './increment_value'
require_relative './fail_with_error'

class FailPlayingActions < Actor
  input :value, type: 'Integer'
  output :value, type: 'String'

  play IncrementValue,
       IncrementValue,
       FailWithError,
       IncrementValue
end

# class FailPlayingActions < PlayActors
#   ACTIONS = [
#     IncrementValue,
#     IncrementValue,
#     FailWithError,
#     IncrementValue,
#   ]
#
#   def call(**initial_inputs)
#     @tried_actions = []
#     ACTIONS.reduce(initial_inputs) do |inputs, klass|
#       outputs = klass.new
#         .tap { |action| @tried_actions << action }
#         .call(**inputs)
#
#       # Pretty strange this one...
#       # - Should it be `initial_inputs.merge(outputs)`?
#       # - Should it be only `outputs`?
#       inputs.merge(outputs)
#     end
#   rescue
#     rollback
#
#     # Here we lost outputs, do they make sense since we're having an error?
#     raise
#   end
#
#   def rollback
#     return if @tried_action.nil?
#     return if !defined?(@tried_actions)
#
#     @tried_actions.reverse_each(&:rollback)
#   end
# end

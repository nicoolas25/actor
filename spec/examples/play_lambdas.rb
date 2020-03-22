# frozen_string_literal: true

class PlayLambdas < Actor
  output :name, type: 'String'

  play ->(ctx) { ctx.value = 3 },
       IncrementValue,
       ->(ctx) { ctx.name = "Jim number #{ctx.value}" },
       SetNameToDowncase
end

# class PlayLambdas
#   ACTIONS = [
#     -> { { value: 3 } },
#     IncrementValue,
#     ->(value:, **_inputs) { { name: "Jim number #{value}" } },
#     SetNameToDowncase,
#   ]
#
#   def call(**initial_inputs)
#     @tried_actions = []
#     ACTIONS.reduce(initial_inputs) do |inputs, action|
#       if action.is_a?(Class)
#         action = action.new
#         @tried_actions << action
#       end
#
#       outputs = action.call(**inputs)
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

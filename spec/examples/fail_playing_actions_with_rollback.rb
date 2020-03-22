# frozen_string_literal: true

class FailPlayingActionsWithRollback < Actor
  input :value, type: 'Integer'
  output :value, type: 'Integer'
  output :name, type: 'String'

  play AddNameToContext,
       IncrementValueWithRollback,
       IncrementValueWithRollback,
       FailWithError,
       IncrementValueWithRollback
end

# class FailPlayingActionsWithRollback < PlayActors
#   ACTIONS = [
#     AddNameToContext,
#     IncrementValueWithRollback,
#     IncrementValueWithRollback,
#     FailWithError,
#     IncrementValueWithRollback,
#   ]
# end

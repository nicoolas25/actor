# frozen_string_literal: true

class IncrementValueWithRollback < Actor
  input :value, type: 'Integer'
  output :value, type: 'Integer'

  def call
    context.value += 1
  end

  def rollback
    context.value -= 1
  end
end

# class IncrementValue
#   def call(value:, **_inputs)
#     { value: value + 1 }
#   end
#
#   def rollback
#     # Nothing to actually rollback here...
#     # There is no context to update, the approach uses immutable values rather
#     # than an envionment or a context.
#   end
# end

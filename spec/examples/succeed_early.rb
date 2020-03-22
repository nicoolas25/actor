# frozen_string_literal: true

class SucceedEarly < Actor
  def call
    succeed!

    raise 'Should never be called'
  end
end

# class SucceedEarly
#   def call(**_inputs)
#     return {}
#
#     raise 'Should never be called'
#   end
# end

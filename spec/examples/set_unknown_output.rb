# frozen_string_literal: true

class SetUnknownOutput < Actor
  output :name

  def call
    context.foobar = 42
  end
end

# class SetUnknownOutput
#   def call(**_inputs)
#     { foobar: 42 }
#   end
# end

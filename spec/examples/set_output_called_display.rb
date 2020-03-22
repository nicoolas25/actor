# frozen_string_literal: true

class SetOutputCalledDisplay < Actor
  output :display

  def call
    context.display = 'Foobar'
  end
end

# class SetOutputCalledDisplay
#   def call(**_inputs)
#     { display: 'Foobar' }
#   end
# end

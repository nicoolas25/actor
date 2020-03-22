# frozen_string_literal: true

class SetWrongTypeOfOutput < Actor
  output :name, type: 'String'

  def call
    self.name = 42
  end
end

# class SetWrongTypeOfOutput
#   def call(**_inputs)
#     { name: 42 }
#   end
# end

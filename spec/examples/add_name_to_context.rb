# frozen_string_literal: true

class AddNameToContext < Actor
  output :name, type: 'String'

  def call
    context.name = 'Jim'
  end
end

# class AddNameToContext
#   def call(**_inputs)
#     { name: 'Jim' }
#   end
# end

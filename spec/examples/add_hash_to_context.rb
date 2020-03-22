# frozen_string_literal: true

class AddHashToContext < Actor
  output :stuff, type: 'Hash'

  def call
    context.stuff = { name: 'Jim' }
  end
end

# class AddHashToContext
#   def call(**_inputs)
#     { stuff: { name: 'Jim' } }
#   end
# end

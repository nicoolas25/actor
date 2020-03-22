# frozen_string_literal: true

class AddGreetingWithLambdaDefault < Actor
  input :name, default: -> { 'world' }, type: 'String'
  output :greeting, type: 'String'

  def call
    context.greeting = "Hello, #{name}!"
  end
end

# class AddGreetingWithLambdaDefault
#   def call(name:, **_inputs)
#     name ||= 'world'
#
#     { greeting: "Hello, #{name}!" }
#   end
# end

# frozen_string_literal: true

class Actor
  # Adds the `default:` option to inputs. Accepts regular values and lambdas.
  # If no default is set and the value has not been given, raises an error.
  #
  # Example:
  #
  #   class MultiplyThing < Actor
  #     input :counter, default: 1
  #     input :multiplier, default: -> { rand(1..10) }
  #   end
  module Defaultable
    def before
      self.class.inputs.each do |name, input|
        # Pretty tricky to have `@context` and `context` being different things.
        next if @context.key?(name)

        # I like this behavior, it forces to default defaults, even to nil which
        # makes sense to me.
        unless input.key?(:default)
          raise ArgumentError, "Input #{name} on #{self.class} is missing."
        end

        default = input[:default]
        default = default.call if default.respond_to?(:call)
        # At that point, that's exactly the same as `@context[name] = default`,
        # I'm surprised rubocop didn't complained.
        @context.merge!(name => default)
      end

      # Oh no! The ordering happens also here I see.
      super
    end
  end
end

# frozen_string_literal: true

class Actor
  # Add boolean checks to inputs, by calling lambdas starting with `must*`.
  #
  # Example:
  #
  #   class Pay < Actor
  #     input :provider,
  #           must: {
  #             exist: ->(provider) { PROVIDERS.include?(provider) }
  #           }
  #
  #     output :user, required: true
  #   end
  module Conditionable
    def before
      super

      self.class.inputs.each do |key, options|
        next unless options[:must]

        options[:must].each do |name, check|
          value = @context[key]
          next if check.call(value)

          name = name.to_s.sub(/^must_/, '')
          # Why not considering that as a `Failure`? Here, I feel like we loose
          # the context and that it is too bad.
          raise ArgumentError,
                "Input #{key} must #{name} but was #{value.inspect}."
        end
      end
    end
  end
end

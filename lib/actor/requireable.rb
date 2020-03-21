# frozen_string_literal: true

class Actor
  # Ensure your inputs and outputs are not nil by adding `required: true`.
  #
  # Example:
  #
  #   class CreateUser < Actor
  #     input :name, required: true
  #     output :user, required: true
  #   end
  module Requireable
    def self.included(base)
      base.append_before_hooks(BEFORE_HOOK)
      base.append_after_hooks(AFTER_HOOK)
    end

    BEFORE_HOOK = proc do
      check_required_definitions(self.class.inputs, kind: 'Input')
    end

    AFTER_HOOK = proc do
      check_required_definitions(self.class.outputs, kind: 'Output')
    end

    private

    def check_required_definitions(definitions, kind:)
      definitions.each do |key, options|
        next unless options[:required] && @context[key].nil?

        raise ArgumentError,
              "#{kind} #{key} on #{self.class} is required but was nil."
      end
    end
  end
end

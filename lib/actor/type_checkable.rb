# frozen_string_literal: true

class Actor
  # Adds `type:` checking to inputs and outputs. Accepts strings that should
  # match an ancestor. Also accepts arrays.
  #
  # Example:
  #
  #   class ReduceOrderAmount < Actor
  #     input :order, type: 'Order'
  #     input :amount, type: %w[Integer Float]
  #     input :bonus_applied, type: %w[TrueClass FalseClass]
  #   end
  module TypeCheckable
    def self.included(base)
      base.append_before_hooks(BEFORE_HOOK)
      base.append_after_hooks(AFTER_HOOK)
    end

    BEFORE_HOOK = proc do
      check_type_definitions(self.class.inputs, kind: 'Input')
    end

    AFTER_HOOK = proc do
      check_type_definitions(self.class.outputs, kind: 'Output')
    end

    private

    def check_type_definitions(definitions, kind:)
      definitions.each do |key, options|
        type_definition = options[:type] || next
        value = @context[key] || next

        types = Array(type_definition).map { |name| Object.const_get(name) }
        next if types.any? { |type| value.is_a?(type) }

        error = "#{kind} #{key} on #{self.class} must be of type " \
                "#{types.join(', ')} but was #{value.class}"
        raise ArgumentError, error
      end
    end
  end
end

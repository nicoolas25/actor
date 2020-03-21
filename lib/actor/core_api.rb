# frozen_string_literal: true

class Actor
  module CoreAPI
    def self.included(base)
      base.extend(ClassMethods)
    end

    # :nodoc:
    def run_hooks(hooks)
      hooks.each { |hook| instance_eval(&hook) }
    end

    module ClassMethods
      %w[before after].each do |hook_name|
        class_eval(<<~CODE, __FILE__, __LINE__ + 1)
          def #{hook_name}_hooks
            @_#{hook_name}_hooks ||= []
          end
        CODE

        class_eval(<<~CODE, __FILE__, __LINE__ + 1)
          def prepend_#{hook_name}_hooks(*hooks)
            hooks.each do |hook|
              next if #{hook_name}_hooks.include?(hook)
              #{hook_name}_hooks.unshift hook
            end
          end
        CODE

        class_eval(<<~CODE, __FILE__, __LINE__ + 1)
          def append_#{hook_name}_hooks(*hooks)
            hooks.each do |hook|
              next if #{hook_name}_hooks.include?(hook)
              #{hook_name}_hooks << hook
            end
          end
        CODE
      end

      def inputs
        @inputs ||= {}
      end

      def outputs
        @outputs ||= { error: { type: 'String' } }
      end

      def inherited(child)
        super

        child.before_hooks.prepend(*before_hooks)
        child.after_hooks.append(*after_hooks)

        child.inputs.merge!(inputs)
        child.outputs.merge!(outputs)
      end
    end
  end
end

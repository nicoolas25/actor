# frozen_string_literal: true

class Actor
  # Makes the inputs of an actor easily accessible through the class.
  #
  #   class CreateUser < Actor
  #     input :name
  #
  #     def m
  #       name # a #name method has been defined
  #     end
  #   end
  #
  module Attributable
    def self.included(base)
      base.prepend(PrependedMethods)

      base_eigenclass = (class << base; self; end)
      base_eigenclass.prepend(PrependedClassMethods)
    end

    module PrependedClassMethods
      def input(name, **attributes)
        super(name, **attributes)

        define_method(name) do
          context.public_send(name)
        end

        private name
      end
    end

    module PrependedMethods
      # rubocop:disable Naming/MemoizedInstanceVariableName
      def context
        @filtered_context ||= Actor::FilteredContext.new(
          super,
          readers: self.class.inputs.keys,
          setters: self.class.outputs.keys,
        )
      end
      # rubocop:enable Naming/MemoizedInstanceVariableName
    end
  end
end

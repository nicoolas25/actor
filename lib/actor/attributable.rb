# frozen_string_literal: true

class Actor
  # DSL to document the accepted attributes.
  #
  #   class CreateUser < Actor
  #     input :name
  #     output :name
  #   end
  module Attributable
    def self.included(base)
      base.extend(ClassMethods)
      base.prepend(PrependedMethods)
    end

    module ClassMethods
      def inherited(child)
        super

        child.inputs.merge!(inputs)
        child.outputs.merge!(outputs)
      end

      def input(name, **arguments)
        inputs[name] = arguments

        # Instead of dynamically defining methods and risking conflict (like
        # using `:context` as an input name), could it be done in a less magical
        # way, maybe by letting the `Actor#call` extracting what's needed with
        # `Context#[]` or `#fetch_values`. For me that's the principle of least
        # surprise.
        define_method(name) do
          context.public_send(name)
        end

        private name
      end

      def inputs
        @inputs ||= {}
      end

      def output(name, **arguments)
        outputs[name] = arguments
      end

      def outputs
        @outputs ||= { error: { type: 'String' } }
      end
    end

    # I mentioned it on the FilteredContext class, I think this brings more
    # complexity than it brings features. Does that need to be kept?
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

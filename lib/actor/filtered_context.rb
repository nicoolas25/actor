# frozen_string_literal: true

class Actor
  # Represents the result of an action, tied to inputs and outputs.
  #
  # Would it be that bad to not have this safety and have free read/writes into
  # the `Context`? This appears to me to be something complex that doesn't bring
  # that much to the table. Can this feature be removed? It would make the tool
  # a bit sharper, that's a tradeoff.
  class FilteredContext
    def initialize(context, readers:, setters:)
      @context = context
      @readers = readers
      @setters = setters
    end

    def inspect
      "<#{self.class.name} #{context.inspect} " \
        "readers: #{readers.inspect} " \
        "setters: #{setters.inspect}>"
    end

    # Would it be possible to consider fail! and succeed! as available_methods?
    # That would spare that layer of delegation.
    def fail!(**arguments)
      context.fail!(**arguments)
    end

    def succeed!(**arguments)
      context.fail!(**arguments)
    end

    private

    # Pretty sure the code will be fine using `@` instead of att_reader.
    attr_reader :context, :readers, :setters

    # rubocop:disable Style/MethodMissingSuper
    def method_missing(name, *arguments, &block)
      # Does this means we can't call `#success?` on this? I guess we won't as
      # we're return the context, not the filtered interface through it.
      unless available_methods.include?(name)
        raise ArgumentError, "Cannot call #{name} on #{inspect}"
      end

      context.public_send(name, *arguments, &block)
    end
    # rubocop:enable Style/MethodMissingSuper

    def respond_to_missing?(name, _include_private = false)
      available_methods.include?(name)
    end

    def available_methods
      @available_methods ||=
        readers + setters.map { |key| "#{key}=".to_sym }
    end
  end
end

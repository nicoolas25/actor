# frozen_string_literal: true

class Actor
  # Represents the result of an action.
  #
  # From the usage we have here, what would be the downside of using a `Hash`
  # rather than an OpenStruct as a parent for `Context`? It looks full of
  # `#to_h` calls anyway. Adding `fail!` and `succeed!` still works, the API
  # would be less user friendly with all those `context#[]` calls but people
  # are very familiar with Hashes and their API. And you could still have the
  # dynamically defined input methods (if really necessary).
  class Context < OpenStruct
    def self.to_context(data)
      return data if data.is_a?(self)

      new(data.to_h)
    end

    def inspect
      "<ActorContext #{to_h}>"
    end

    def fail!(context = {})
      merge!(context)
      merge!(failure?: true)

      raise Actor::Failure, self
    end

    def succeed!(context = {})
      merge!(context)
      merge!(failure?: false)

      raise Actor::Success, self
    end

    def success?
      !failure?
    end

    def failure?
      super || false
    end

    def merge!(context)
      context.each_pair do |key, value|
        self[key] = value
      end

      self
    end

    def key?(name)
      to_h.key?(name)
    end

    def [](name)
      to_h[name]
    end

    # Redefined here to override the method on `Object`.
    def display
      to_h.fetch(:display)
    end
  end
end

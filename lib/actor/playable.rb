# frozen_string_literal: true

class Actor
  # DSL to call a series of actors with the same context. On failure, calls
  # rollback on any actor that succeeded.
  #
  #   class CreateUser < Actor
  #     play SaveUser,
  #          CreateSettings,
  #          SendWelcomeEmail
  #   end
  module Playable
    def self.included(base)
      base.extend(ClassMethods)
      base.prepend(PrependedMethods)
    end

    # To implement in your actors.
    # The default implementation does nothing.
    def rollback; end

    module ClassMethods
      def inherited(child)
        super

        child.play_actors.concat(play_actors)
      end

      def play(*actors, **options)
        actors.each do |actor|
          play_actors << { actor: actor, **options }
        end
      end

      def play_actors
        @play_actors ||= []
      end
    end

    module PrependedMethods
      def call
        self.class.play_actors.each(&method(:play_actor))
      rescue Actor::Failure
        rollback
        raise
      end

      def rollback
        return unless @_played_actors

        @_played_actors.reverse_each do |actor|
          actor.respond_to?(:rollback) && actor.rollback
        end
      end

      private

      def play_actor(options)
        return if options.key?(:if) && !options.fetch(:if).call(@context)

        actor = options.fetch(:actor)
        result = actor.call(@context)

        return unless actor.is_a?(Class) && actor < Actor

        (@_played_actors ||= []) << result._instance

        raise Actor::Success if result.early_success?
      end
    end
  end
end

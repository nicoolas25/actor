# frozen_string_literal: true

require 'ostruct'

require 'actor/failure'
require 'actor/success'
require 'actor/context'
require 'actor/filtered_context'

require 'actor/core_api'
require 'actor/playable'
require 'actor/attributable'
require 'actor/defaultable'
require 'actor/type_checkable'
require 'actor/requireable'
require 'actor/conditionable'

# Actors should start with a verb, inherit from Actor and implement a `call`
# method.
class Actor
  include CoreAPI

  include Attributable
  include Conditionable
  include Defaultable
  include Requireable
  include TypeCheckable

  include Playable

  class << self
    # Declare an expected input
    def input(name, **arguments)
      inputs[name] = arguments
    end

    # Declare an expected output
    def output(name, **arguments)
      outputs[name] = arguments
    end

    # Call an actor with a given context. Returns the context.
    #
    #   CreateUser.call(name: 'Joe')
    def call(context = {}, **arguments)
      context = Actor::Context.to_context(context).merge!(arguments)
      new(context).tap do |instance|
        context._instance = instance
        instance.run_hooks(before_hooks)
        instance.call
        instance.run_hooks(after_hooks)
      end
      context
    rescue Actor::Success
      context
    end

    alias call! call

    # Call an actor with a given context. Returns the context and does not raise
    # on failure.
    #
    #   CreateUser.result(name: 'Joe')
    def result(context = {}, **arguments)
      call(context, **arguments)
    rescue Actor::Failure => e
      e.context
    end
  end

  private_class_method :new

  # :nodoc:
  def initialize(context)
    @context = context
  end

  def call
    raise NotImplementedError
  end

  private

  # Returns the current context from inside an actor.
  attr_reader :context

  # Can be called from inside an actor to stop execution and mark as failed.
  def fail!(**arguments)
    @context.fail!(**arguments)
  end

  # Can be called from inside an actor to stop execution early.
  def succeed!(**arguments)
    @context.succeed!(**arguments)
  end
end

# frozen_string_literal: true

require 'ostruct'

# Exceptions
require 'actor/error'
require 'actor/failure'
require 'actor/success'
require 'actor/argument_error'

# Context
require 'actor/context'

# Modules
require 'actor/playable'
require 'actor/attributable'
require 'actor/defaultable'
require 'actor/type_checkable'
require 'actor/nil_checkable'
require 'actor/conditionable'

# Actors should start with a verb, inherit from Actor and implement a `call`
# method.
class Actor
  include Attributable
  include Playable
  prepend Defaultable
  prepend TypeCheckable
  prepend NilCheckable
  prepend Conditionable

  class << self
    # Call an actor with a given context. Returns the context.
    #
    #   CreateUser.call(name: 'Joe')
    def call(context = {}, **arguments)
      context = Actor::Context.to_context(context).merge!(arguments)
      new(context)._call
      context
    rescue Actor::Success
      context
    end

    # :nodoc:
    def call!(**arguments)
      warn "DEPRECATED: Prefer `#{name}.call` to `#{name}.call!`."
      call(**arguments)
    end

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

  # :nodoc:
  def initialize(context)
    @context = context
  end

  # To implement in your actors.
  def call; end

  # To implement in your actors.
  def rollback; end

  # :nodoc:
  def _call
    call
  end

  private

  # Returns the current context from inside an actor.
  attr_reader :context

  # Can be called from inside an actor to stop execution and mark as failed.
  def fail!(**arguments)
    context.fail!(**arguments)
  end

  # Can be called from inside an actor to stop execution early.
  def succeed!(**arguments)
    context.succeed!(**arguments)
  end
end

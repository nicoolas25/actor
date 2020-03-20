# frozen_string_literal: true

require 'ostruct'

# I think those two could get their own superclass (beside StandardError).
# I imagine something like `Actor::Response`. Also, can we have an Unknown
# response somehow?
require 'actor/failure'
require 'actor/success'

# Do we need two objects to represent a context? As soon as input / output
# are used, **in** theory, we should mostly have filtered context.
require 'actor/context'
require 'actor/filtered_context'

# This looks like a way to make the library extensible. That's a great idea but
# it looks like none of them is optional. Is you use Actor, you get all that,
# even if you're never using, lets say, `Requireable`.
require 'actor/playable'
require 'actor/attributable'
require 'actor/defaultable'
require 'actor/type_checkable'
require 'actor/requireable'
require 'actor/conditionable'

# Actors should start with a verb, inherit from Actor and implement a `call`
# method.
class Actor
  # All those include/prepend make me believe that there is some plumbing going
  # on with the ancestors hierarchy and calling `super`. I don't have that much
  # experience with that, lets see how it goes!
  include Attributable
  include Playable
  prepend Defaultable
  prepend TypeCheckable
  prepend Requireable
  prepend Conditionable

  class << self
    # Call an actor with a given context. Returns the context.
    #
    #   CreateUser.call(name: 'Joe')
    def call(context = {}, **arguments)
      # Wrapping the given context into another object like this will prevent
      # passing a context as a normal collaborator. One example that comes to
      # mind are mocks. I don't like mock very much but passing a custom
      # context, in a production setup, that seems legit to me.
      #
      # If it is for internal purpose only, using a special keyword argument
      # like `_context` and then delete it from the `**arguments` may work.
      # You could pass directly a `Context`, and only then merge the arguments.
      context = Actor::Context.to_context(context).merge!(arguments)
      new(context).run
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

  # :nodoc:
  def initialize(context)
    @context = context
  end

  # To implement in your actors.
  # I like raising NotImplementedError in those cases.
  def call; end

  # To implement in your actors.
  def rollback; end

  # :nodoc:
  def before; end

  # :nodoc:
  def after; end

  # :nodoc:
  def run
    # Oh, I see, so everyone gonna plug itself on those methods and call super.
    # That is tricky to know which module gonna go first. Usually to achieve
    # that behavior, I'm using an instance variable at the class level holding
    # a list of before_hooks and after_hooks (`Proc`). This way for each class
    # that ordered list is easily available for inspection.
    #
    # Did you consider that approach?
    #
    # The good part is that the included/prepended modules don't have to
    # redefine methods and call super, but 'simply' define the DSL keywords and
    # interact with the base API that register before_hooks and after_hooks.
    #
    # Another good part is that the same codepath is always executed, only the
    # data changes, the content of those before_hooks and after_hooks.
    before
    call
    after
  end

  private

  # Returns the current context from inside an actor.
  attr_reader :context

  # Can be called from inside an actor to stop execution and mark as failed.
  def fail!(**arguments)
    # Should it be context (without the `@`)? I know it makes virtually no
    # difference but it seems more sense regarding the `Attributable` module
    # that is overriding the `#context` method.
    @context.fail!(**arguments)
  end

  # Can be called from inside an actor to stop execution early.
  def succeed!(**arguments)
    @context.succeed!(**arguments)
  end
end

# frozen_string_literal: true

class Actor
  class << self
    def call(entries = {})
      build_context(entries).tap do |context|
        context._check!(:before)
        new(context).call
        context._check!(:after)
      end
    end

    def rules(&rules)
      @_rules = rules if rules
      @_rules
    end

    protected

    def build_context(entries = {})
      @context_class ||= Class.new(Context).tap do |klass|
        if superclass.respond_to?(:build_context, true)
          parent_rules = superclass.build_context._rules
        end
        all_rules = [*parent_rules, *rules]
        klass.define_method(:_rules) { all_rules }
      end
      @context_class.new(entries)
    end
  end

  private_class_method :new

  def initialize(context)
    context._actor = self
    @context = context
  end

  def call
    raise NotImplementedError
  end

  def set(entries)
    @context = @context.set(entries)
  end

  def get(key)
    @context.get(key)
  end

  def get_all(*keys)
    @context.get_all(*keys)
  end

  class Context
    attr_accessor :_actor

    def initialize(store = {})
      @store = store.to_hash
    end

    def set(entries)
      @store.merge!(entries)
      self
    end

    def get(key, *default, &block)
      @store.fetch(key, *default, &(block || _missing_key_proc))
    end

    def get_all(*keys)
      @store.fetch_values(*keys, &_missing_key_proc)
    end

    def to_hash
      @store
    end

    def dup
      self.class.new(@store.dup)
    end

    def _rules
      []
    end

    def _check!(event)
      helper = RuleHelper.new(self, event)
      _rules.each { |rules| helper.instance_exec(&rules) }
    end

    def _missing_key_proc
      proc { |k| raise MissingContextError.new(k, self) }
    end
  end

  class RuleHelper
    attr_reader :context, :event

    def initialize(context, event)
      @context = context
      @event = event
    end

    def before
      yield if event == :before
    end

    def after
      yield if event == :after
    end

    def error!(message)
      raise InvalidContextError.new(message, @context, @event)
    end

    def satisfy(name, message = nil)
      result = yield @context.get(name)
      result || error!(message || "Unsatisfied property on '#{name}' entry")
    end

    def presence_required(name)
      message = "The '#{name}' entry must not be nil"
      satisfy(name, message) { |value| !value.nil? }
    end

    def typed(name, types)
      types = Array(types)
      message = "The '#{name}' entry must be a #{types.inspect}"
      satisfy(name, message) { |value| types.any? { |type| value.is_a?(type) } }
    end
  end

  class Sequencer < self
    class << self
      def inherited(*)
        if superclass.is_a?(Sequencer)
          raise "Please, don't specialize a Sequencer"
        end

        super
      end

      def sequence(actor_classes = nil)
        @_sequence = actor_classes if actor_classes
        @_sequence || []
      end
    end

    def call
      self.class.sequence.reduce(@context.dup) do |context, actor_class|
        actor_class.call(context).tap do |result|
          (@stack ||= []) << result
          set result.to_hash
        end.dup
      end
    rescue StandardError
      rollback
      raise SequenceError.new(@stack, @context)
    end

    def rollback
      @stack&.reverse_each do |context|
        actor = context._actor
        if actor&.respond_to?(:rollback)
          actor.rollback
          set context.to_hash
        end
      end
    end
  end

  class Error < StandardError
    attr_reader :context
  end

  class MissingContextError < Error
    def initialize(missing_key, context)
      @context = context
      super("Key not found: #{missing_key}")
    end
  end

  class InvalidContextError < Error
    attr_reader :event

    def initialize(message, context, event)
      @context = context
      @event = event

      super(message)
    end
  end

  class SequenceError < Error
    attr_reader :stack

    def initialize(stack, context)
      @stack = stack
      @context = context
      super('Sequence failed! Look at the #cause to find out why.')
    end
  end
end

require 'minitest/autorun'

class AddGreeting < Actor
  rules do
    before do
      presence_required :name
      typed :name, String

      satisfy :name, 'name must be lowercase' do |name|
        name =~ /\A[a-z]+\z/
      end
    end

    after do
      presence_required :greeting
    end
  end

  def call
    set greeting: "Hello, #{get :name}!"
  end
end

class NilifyName < Actor
  rules do
    presence_required :name
  end

  def call
    set name: nil
  end
end

class InheritedRules < AddGreeting
  rules do
    presence_required :last_name
  end

  def call
    set name: get_all(:name, :last_name).join(' ')
    super
  end
end

class AddOne < Actor
  rules do
    typed :value, Numeric
  end

  def call
    set value: get(:value).next
  end

  def rollback
    set value: get(:value).pred
  end
end

class FailingActor < Actor
  def call
    raise 'Not good...'
  end
end

class AddOneSequence < Actor::Sequencer
  sequence [AddOne, AddOne]
end

class FailingSequence < Actor::Sequencer
  sequence [AddOne, AddOne, FailingActor, AddOne]
end

class TestActor < Minitest::Test
  def test_usual_flow_result
    result = AddGreeting.call(name: 'joe')
    assert_equal 'Hello, joe!', result.get(:greeting)
  end

  def test_sequence
    result = AddOneSequence.call(value: 0)
    assert_equal 2, result.get(:value)
  end

  def test_failing_sequence_with_rollback
    error = assert_raises(Actor::SequenceError) do
      FailingSequence.call(value: 0)
    end

    assert_equal 0, error.context.get(:value)
    assert_equal 'Not good...', error.cause.message
  end

  def test_missing_entry
    error = assert_raises(Actor::MissingContextError) do
      AddGreeting.call
    end

    assert_equal('Key not found: name', error.message)
    assert_kind_of(Actor::Context, error.context)
  end

  def test_nilifying_required_input
    error = assert_raises(Actor::InvalidContextError) do
      NilifyName.call(name: 'joe')
    end

    assert_equal("The 'name' entry must not be nil", error.message)
  end

  def test_type_mismatch
    error = assert_raises(Actor::InvalidContextError) do
      AddGreeting.call(name: 42)
    end

    assert_equal("The 'name' entry must be a [String]", error.message)
  end

  def test_satisfy_with_message
    error = assert_raises(Actor::InvalidContextError) do
      AddGreeting.call(name: 'Joe')
    end

    assert_equal('name must be lowercase', error.message)
  end

  def test_inherited_rules
    error = assert_raises(Actor::InvalidContextError) do
      InheritedRules.call(name: nil, last_name: 'Do')
    end

    assert_equal("The 'name' entry must not be nil", error.message)
  end

  def test_passing_a_context_keeps_the_same_store
    context = Actor::Context.new(name: 'joe')
    resulting_context = AddGreeting.call(context)
    assert_same(context.to_hash, resulting_context.to_hash)
  end
end

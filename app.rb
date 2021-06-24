# frozen_string_literal: true

require 'wongi-engine'

# Main entry class
class Rete
  def initialize
    raise 'Singleton class cannot be initialized'
  end

  def self.instance
    @instance ||= Wongi::Engine.create
  end
end

rete = Rete.instance
rete  << ['Alice', :friend, 'Bob']
rete  << ['Alice', :age, 35]

p rete.select('Alice', :_, :_)

# Add the rules
friends_rule = rete.rule 'friends' do
  forall do
    # Can have multiple matchers
    # Triggered top down
    # :A are specially interpreted variables
    has :A, :friend, :B
  end
end

rete.rule 'friends of friends' do
  forall do
    has :A, :friend, :B
    has :B, :friend, :C
  end
end

p friends_rule
p rete.productions['friends of friends']

# Get the rules token
friends_rule.tokens.each do |token|
  p token
  p token[:A]
  p token[:B]
end

# Action
rete.rule 'self-printer' do
  forall do
    has :A, :friend, :B
  end

  # Executed when all the rules are matched
  # Production node is activated
  make do
    action do |token|
      puts "#{token[:A]} and #{token[:B]} are friends"
    end
  end
end

rete << ['GG', :friend, 'Ganesh']

rete.rule 'symmetric prdicate' do
  forall do
    has :P, :symmetric, true
    has :X, :P, :Y
  end

  make do
    # Generates a new fact dynamically
    gen :Y, :P, :X
  end
end

rete << [:friend, :symmetric, true]

rete.rule 'inline action' do
  forall do
    has :A, :friend, :B
  end

  make do
    action activate: ->(token) { puts "Activated #{token}" }, deactivate: ->(token) { puts "Deactivated #{token}" }
  end
end

# Custom action
class ExplicitAction
  def initialize(*args, &block)
    puts "args #{args}"
    puts "block #{block}"
  end

  def execute(token)
    puts "Executed #{token}"
  end

  def deexecute(token)
    puts "Deexecuted #{token}"
  end
end

rete.rule 'explicit action' do
  forall do
    has :A, :friend, :B
  end

  make do
    action ExplicitAction, 1, 2, 3 do
      puts 'Test block'
    end
  end
end

rete.query 'friends' do
  search_on :Name
  forall do
    has :Name, :friend, :Friend
  end

  make do
    action do |token|
      puts "Query: #{token[:Name]} and #{token[:Friend]} are friends"
    end
  end
end

rete.execute 'friends', Name: 'Alice'

class FollowsController < ApplicationController
  # in-memory follow state, keyed by species name
  @@state = Hash.new(false)
  @@counts = Hash.new(0)

  def create
    name = params[:name]
    unless @@state[name]
      @@state[name] = true
      @@counts[name] += 1
    end
    redirect_to species_path(name: name)
  end

  def destroy
    name = params[:name]
    if @@state[name]
      @@state[name] = false
      @@counts[name] -= 1 if @@counts[name] > 0
    end
    redirect_to species_path(name: name)
  end

  # helpers for views
  def self.following_for(name) = @@state[name]
  def self.count_for(name)     = @@counts[name]

  def self.reset!
    @@state  = Hash.new(false)
    @@counts = Hash.new(0)
  end

  def self.seed_follow(name, count: 1)
    @@state[name]  = true
    @@counts[name] = count
  end

end

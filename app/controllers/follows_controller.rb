class FollowsController < ApplicationController
  # Per-user follow state: { user_id => { species_name => true/false } }
  @@user_state = Hash.new { |h, k| h[k] = Hash.new(false) }
  # Global follower counts per species: { species_name => count }
  @@counts = Hash.new(0)

  def create
    name = params[:name]
    user_id = current_user&.id || :guest
    
    unless @@user_state[user_id][name]
      @@user_state[user_id][name] = true
      @@counts[name] += 1
    end
    redirect_to species_path(name: name)
  end

  def destroy
    name = params[:name]
    user_id = current_user&.id || :guest
    
    if @@user_state[user_id][name]
      @@user_state[user_id][name] = false
      @@counts[name] -= 1 if @@counts[name] > 0
    end
    redirect_to species_path(name: name)
  end

  # ===== helpers used by views/steps/specs =====
  # Now requires user_id to check per-user follow state
  def self.following_for(name, user_id: nil)
    user_id ||= :guest
    @@user_state[user_id][name]
  end
  
  def self.count_for(name)
    @@counts[name]
  end

  # Returns species followed by a specific user
  def self.followed_species(user_id: nil)
    user_id ||= :guest
    @@user_state[user_id].select { |_, v| v }.keys
  end

  # ===== test seed helpers =====
  def self.reset!
    @@user_state = Hash.new { |h, k| h[k] = Hash.new(false) }
    @@counts = Hash.new(0)
  end

  def self.seed_follow(name, count: 1, user_id: nil)
    user_id ||= :guest
    @@user_state[user_id][name] = true
    @@counts[name] = count
  end

  def self.seed_followers(name, count)
    @@counts[name] = count
  end

end

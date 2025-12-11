# app/controllers/follows_controller.rb
class FollowsController < ApplicationController
  before_action :authenticate_user!

  def create
    name = params[:name]
    species = DexSpecies.find_by("LOWER(name) = ?", name.downcase)

    if species
      SpeciesFollow.find_or_create_by!(user: current_user, dex_species: species)
    end

    redirect_to species_path(name: name)
  end

  def destroy
    name = params[:name]
    species = DexSpecies.find_by("LOWER(name) = ?", name.downcase)

    if species
      SpeciesFollow.where(user: current_user, dex_species: species).delete_all
    end

    redirect_to species_path(name: name)
  end

  # ----- helpers used by controllers/views -----

  def self.following_for(name, user)
    return false unless user
    species = DexSpecies.find_by("LOWER(name) = ?", name.downcase)
    return false unless species

    SpeciesFollow.exists?(user: user, dex_species: species)
  end

  def self.count_for(name)
    species = DexSpecies.find_by("LOWER(name) = ?", name.downcase)
    return 0 unless species

    SpeciesFollow.where(dex_species: species).count
  end

  def self.followed_species(user)
    return [] unless user

    SpeciesFollow
      .joins(:dex_species)
      .where(user: user)
      .pluck("dex_species.name")
  end
end

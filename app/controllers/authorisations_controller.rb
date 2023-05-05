class AuthorisationsController < ApplicationController
  def index
    @authorisations = Authorisation.order(:title).page params[:page]
  end

  def all
  end

  def mark
  end

  def unmark
  end

  def unused_fields
  end

  def used_fields
  end
end

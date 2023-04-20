class AuthorisationsController < ApplicationController
  def index
     @authorisations = Authorisation.paginate(:page => params[:page], :per_page => 10)
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

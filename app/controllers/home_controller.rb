class HomeController < ApplicationController
  
  before_action :authenticate_user! #If this is removed devise login page is rendered every time

  def index
  
end
end
class HomeController < ApplicationController
  
  before_action :authenticate_user! #If this is removed devise login page is rendered every time

  def index
     render :index
  end

def configuration
    @config = Home.new.call
    respond_to do |format|
      format.html { render :text => @config.html_content }
    end
  end
end
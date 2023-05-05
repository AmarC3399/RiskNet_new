class HomeController < ApplicationController
  
  before_action :authenticate_user! 
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
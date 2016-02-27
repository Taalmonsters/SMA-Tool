class VisitorsController < ApplicationController
  before_action :set_user
  
  def index
    @page_title = 'home'
  end
  
end

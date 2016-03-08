class VisitorsController < ApplicationController
  before_action :set_user
  
  def index
    @page_title = 'welcome'
    if @user
      @sub_title = 'welcome, '+@user.name.split(' ')[0]
    end
  end
  
end

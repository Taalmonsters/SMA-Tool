class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :admin_only, :except => [:show, :edit, :update]
  before_action :admin_or_current_user_only, :only => [:show, :edit, :update]

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
    unless current_user.admin?
      unless @user == current_user
        redirect_to :back, :alert => "Access denied."
      end
    end
    respond_to do |format|
      format.html
      format.csv { render text: @user.csv_data(col_sep: "\t") }
    end
  end
  
  def edit
    
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(secure_params)
      redirect_to :back, :notice => "User updated."
    else
      redirect_to :back, :alert => "Unable to update user."
    end
  end

  def destroy
    user = User.find(params[:id])
    user.destroy
    redirect_to users_path, :notice => "User deleted."
  end

  private

  def admin_only
    unless current_user.admin?
      redirect_to :back, :alert => "Access denied."
    end
  end

  def admin_or_current_user_only
    unless current_user.admin? || is_correct_user?
      redirect_to :back, :alert => "Access denied."
    end
  end

  def secure_params
    if @user == current_user
      params.require(:user).permit(:email, :twitter_auth_attributes => [:access_token, :access_secret, :consumer_key, :consumer_secret])
    elsif current_user.admin?
      params.require(:user).permit(:role)
    end
  end

end

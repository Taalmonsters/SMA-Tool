require 'csv'
class TwitterIdSearchesController < ApplicationController
  before_action :set_user
  before_action :check_tw_auth
  before_action :set_twitter_id_search, only: [:show, :edit, :update, :destroy]

  # GET /twitter_id_searches
  # GET /twitter_id_searches.json
  def index
    if @user && !@error
      @twitter_id_searches = @user.twitter_id_searches
      @page_title = 'twitter_id_search'
      @sub_title = 'twitter id searches'
    else
      if !@error
        @error = 'No user'
      end
      redirect_to :root, alert: @error
    end
  end

  # GET /twitter_id_searches/1
  # GET /twitter_id_searches/1.json
  def show
    if @twitter_id_search
      @tweets = @twitter_id_search.tweets
      @page_title = 'twitter_id_search'
      @sub_title = 'twitter id search'
      respond_to do |format|
        format.html
        format.csv { render text: @twitter_id_search.tweets.to_csv(col_sep: "\t") }
      end
    else
      if !@error
        @error = 'No user'
      end
      redirect_to :root, alert: @error
    end
  end

  # GET /twitter_id_searches/new
  def new
    if @user && !@error
      @twitter_id_search = TwitterIdSearch.new
      @twitter_id_search.user_id = @user.id
      @page_title = 'twitter_id_search'
      @sub_title = 'New twitter id search'
    else
      if !@error
        @error = 'No user'
      end
      redirect_to :root, alert: @error
    end
  end

  # GET /twitter_id_searches/1/edit
  def edit
  end

  # POST /twitter_id_searches
  # POST /twitter_id_searches.json
  def create
    if @user && !@error
      @twitter_id_search = TwitterIdSearch.new(twitter_id_search_params)
      respond_to do |format|
        if @twitter_id_search.save
          @user.twitter_id_searches << @twitter_id_search
          @twitter_id_search.get_tweets
          format.html { redirect_to user_twitter_id_search_url(:id => @twitter_id_search.id), notice: 'Twitter id search was successfully created.' }
          format.json { render :show, status: :created, location: @twitter_id_search }
        else
          format.html { render :new }
          format.json { render json: @twitter_id_search.errors, status: :unprocessable_entity }
        end
      end
    else
      if !@error
        @error = 'No user'
      end
      redirect_to :root, alert: @error
    end
  end

  # PATCH/PUT /twitter_id_searches/1
  # PATCH/PUT /twitter_id_searches/1.json
  def update
    respond_to do |format|
      if @twitter_id_search.update(twitter_id_search_params)
        format.html { redirect_to @twitter_id_search, notice: 'Twitter id search was successfully updated.' }
        format.json { render :show, status: :ok, location: @twitter_id_search }
      else
        format.html { render :edit }
        format.json { render json: @twitter_id_search.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /twitter_id_searches/1
  # DELETE /twitter_id_searches/1.json
  def destroy
    @twitter_id_search.destroy
    respond_to do |format|
      format.html { redirect_to user_twitter_id_searches_url, notice: 'Twitter id search was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_twitter_id_search
      if @user && !@error
        @twitter_id_search = TwitterIdSearch.where(:id => params[:id], :user_id => @user.id).first
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def twitter_id_search_params
      params.require(:twitter_id_search).permit(:query)
      # params.fetch(:twitter_id_search, {})
    end
end

require 'csv'
class TwitterSearchesController < ApplicationController
  before_action :set_user
  before_action :check_tw_auth
  before_action :set_twitter_search, only: [:show, :edit, :update, :destroy]

  # GET /twitter_searches
  # GET /twitter_searches.json
  def index
    if @user && !@error
      @twitter_searches = @user.twitter_searches
      @page_title = 'twitter_search'
      @sub_title = 'twitter searches'
    else
      if !@error
        @error = 'No user'
      end
      redirect_to :root, alert: @error
    end
  end

  # GET /twitter_searches/1
  # GET /twitter_searches/1.json
  def show
    if @twitter_search
      page = params[:page] || 1
      number = params[:number] || 10
      @tweets = @twitter_search.tweets.paginate(:page => page, :per_page => number)
      @page_title = 'twitter_search'
      @sub_title = 'twitter search'
      respond_to do |format|
        format.html
        format.csv { render text: @twitter_search.tweets.to_csv(col_sep: "\t") }
      end
    else
      if !@error
        @error = 'No user'
      end
      redirect_to :root, alert: @error
    end
  end

  # GET /twitter_searches/new
  def new
    if @user && !@error
      @twitter_search = TwitterSearch.new
      @twitter_search.user_id = @user.id
      @page_title = 'twitter_search'
      @sub_title = 'New twitter search'
    else
      if !@error
        @error = 'No user'
      end
      redirect_to :root, alert: @error
    end
  end

  # GET /twitter_searches/1/edit
  def edit
  end

  # POST /twitter_searches
  # POST /twitter_searches.json
  def create
    if @user && !@error
      @twitter_search = TwitterSearch.new(twitter_search_params)
      respond_to do |format|
        if @twitter_search.save
          @user.twitter_searches << @twitter_search
          @twitter_search.get_tweets
          format.html { redirect_to user_twitter_search_url(:id => @twitter_search.id), notice: 'Twitter search was successfully created.' }
          format.json { render :show, status: :created, location: @twitter_search }
        else
          format.html { render :new }
          format.json { render json: @twitter_search.errors, status: :unprocessable_entity }
        end
      end
    else
      if !@error
        @error = 'No user'
      end
      redirect_to :root, alert: @error
    end
  end

  # PATCH/PUT /twitter_searches/1
  # PATCH/PUT /twitter_searches/1.json
  def update
    respond_to do |format|
      if @twitter_search.update(twitter_search_params)
        format.html { redirect_to @twitter_search, notice: 'Twitter search was successfully updated.' }
        format.json { render :show, status: :ok, location: @twitter_search }
      else
        format.html { render :edit }
        format.json { render json: @twitter_search.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /twitter_searches/1
  # DELETE /twitter_searches/1.json
  def destroy
    @twitter_search.destroy
    respond_to do |format|
      format.html { redirect_to user_twitter_searches_url, notice: 'Twitter search was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_twitter_search
      if @user && !@error
        @twitter_search = TwitterSearch.where(:id => params[:id], :user_id => @user.id).first
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def twitter_search_params
      params.require(:twitter_search).permit(:query)
      # params.fetch(:twitter_search, {})
    end
end

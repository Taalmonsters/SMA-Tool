require 'csv'
class TwitterStreamsController < ApplicationController
  before_action :set_user
  before_action :check_tw_auth
  before_action :set_twitter_stream, only: [:show, :edit, :update, :destroy, :stop]

  # GET /twitter_streams
  # GET /twitter_streams.json
  def index
    if @user && !@error
      @twitter_streams = @user.twitter_streams
      @page_title = 'twitter_stream'
      @sub_title = 'tweet streams'
    else
      if !@error
        @error = 'No user'
      end
      redirect_to :root, alert: @error
    end
  end

  # GET /twitter_streams/1
  # GET /twitter_streams/1.json
  def show
    if @twitter_stream
      page = params[:page] || 1
      number = params[:number] || 10
      @tweets = @twitter_stream.tweets.paginate(:page => page, :per_page => number)
      @page_title = 'twitter_stream'
      @sub_title = 'tweet stream'
      respond_to do |format|
        format.html
        format.csv { render text: @twitter_stream.tweets.to_csv(col_sep: "\t") }
      end
    else
      if !@error
        @error = 'No user'
      end
      redirect_to :root, alert: @error
    end
  end

  # GET /twitter_streams/new
  def new
    if @user && !@error
      @twitter_stream = TwitterStream.new
      @twitter_stream.user_id = @user.id
      @page_title = 'twitter_stream'
      @sub_title = 'New Tweet Stream'
    else
      if !@error
        @error = 'No user'
      end
      redirect_to :root, alert: @error
    end
  end

  # GET /twitter_streams/1/edit
  def edit
  end

  # POST /twitter_streams
  # POST /twitter_streams.json
  def create
    if @user && !@error
      @twitter_stream = TwitterStream.new(twitter_stream_params)
      respond_to do |format|
        if @twitter_stream.save
          @user.twitter_streams << @twitter_stream
          @twitter_stream.get_stream
          format.html { redirect_to user_twitter_stream_url(:id => @twitter_stream.id), notice: 'Tweet stream was successfully created.' }
          format.json { render :show, status: :created, location: @twitter_stream }
        else
          format.html { render :new }
          format.json { render json: @twitter_stream.errors, status: :unprocessable_entity }
        end
      end
    else
      if !@error
        @error = 'No user'
      end
      redirect_to :root, alert: @error
    end
  end

  # PATCH/PUT /twitter_streams/1
  # PATCH/PUT /twitter_streams/1.json
  def update
    respond_to do |format|
      if @twitter_stream.update(twitter_stream_params)
        format.html { redirect_to @twitter_stream, notice: 'Tweet stream was successfully updated.' }
        format.json { render :show, status: :ok, location: @twitter_stream }
      else
        format.html { render :edit }
        format.json { render json: @twitter_stream.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /twitter_streams/1
  # DELETE /twitter_streams/1.json
  def destroy
    @twitter_stream.destroy
    respond_to do |format|
      format.html { redirect_to user_twitter_streams_url, notice: 'Tweet stream was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def stop
    if @twitter_stream
      new_period = (((Time.now - @twitter_stream.created_at) / 24.hours) - 1).to_i
      @twitter_stream.update_attribute(:period, new_period)
      respond_to do |format|
        format.json { render json: 'Stream stopped', status: 200 }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_twitter_stream
      if @user && !@error
        @twitter_stream = TwitterStream.where(:id => params[:id], :user_id => @user.id).first
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def twitter_stream_params
      params.require(:twitter_stream).permit(:query, :period)
      # params.fetch(:twitter_stream, {})
    end
end

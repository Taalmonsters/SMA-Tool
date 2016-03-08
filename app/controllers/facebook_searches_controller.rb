class FacebookSearchesController < ApplicationController
  before_action :set_user
  before_action :set_facebook_search, only: [:show, :edit, :update, :destroy, :stop, :poll_status_count, :poll_status]

  # GET /facebook_searches
  # GET /facebook_searches.json
  def index
    if @user && !@error
      @facebook_searches = @user.facebook_searches
      @page_title = 'facebook_search'
      @sub_title = 'facebook searches'
    else
      if !@error
        @error = 'No user'
      end
      redirect_to :root, alert: @error
    end
  end

  # GET /facebook_searches/1
  # GET /facebook_searches/1.json
  def show
    @page_title = 'facebook_search'
    @sub_title = 'facebook search'
    if @facebook_search
      page = params[:page] || 1
      number = params[:number] || 10
      @facebook_statuses = @facebook_search.facebook_statuses.paginate(:page => page, :per_page => number)
      respond_to do |format|
        format.html
        format.csv { render text: @facebook_search.facebook_statuses.to_csv(col_sep: "\t") }
      end
    else
      if !@error
        @error = 'No user'
      end
      redirect_to :root, alert: @error
    end
  end

  # GET /facebook_searches/new
  def new
    @page_title = 'facebook_search'
    @sub_title = 'new facebook search'
    if @user && !@error
      @facebook_search = FacebookSearch.new
      @facebook_search.user_id = @user.id
    else
      if !@error
        @error = 'No user'
      end
      redirect_to :root, alert: @error
    end
  end

  # GET /facebook_searches/1/edit
  def edit
  end

  # POST /facebook_searches
  # POST /facebook_searches.json
  def create
    if @user && !@error
      @facebook_search = FacebookSearch.new(facebook_search_params)
      respond_to do |format|
        if @facebook_search.save
          @user.facebook_searches << @facebook_search
          @facebook_search.get_statuses(@user.facebook)
          format.html { redirect_to user_facebook_search_url(:id => @facebook_search.id), notice: 'Facebook search was successfully created.' }
          format.json { render :show, status: :created, location: @facebook_search }
        else
          format.html { render :new }
          format.json { render json: @facebook_search.errors, status: :unprocessable_entity }
        end
      end
    else
      if !@error
        @error = 'No user'
      end
      redirect_to :root, alert: @error
    end
  end

  # PATCH/PUT /facebook_searches/1
  # PATCH/PUT /facebook_searches/1.json
  def update
    respond_to do |format|
      if @facebook_search.update(facebook_search_params)
        format.html { redirect_to @facebook_search, notice: 'Facebook search was successfully updated.' }
        format.json { render :show, status: :ok, location: @facebook_search }
      else
        format.html { render :edit }
        format.json { render json: @facebook_search.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /facebook_searches/1
  # DELETE /facebook_searches/1.json
  def destroy
    @facebook_search.destroy
    respond_to do |format|
      format.html { redirect_to user_facebook_searches_url, notice: 'Facebook search was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def stop
    if @facebook_search
      @facebook_search.update_attribute(:status, :finished)
      respond_to do |format|
        format.json { render json: { 'message' => 'Search stopped' }, status: 200 }
      end
    end
  end
  
  def poll_status_count
    if params[:element]
      @element = params[:element]
      respond_to do |format|
        format.js
      end
    end
  end
  
  def poll_status
    if params[:element]
      @element = params[:element]
      respond_to do |format|
        format.js
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_facebook_search
      if @user && !@error
        @facebook_search = FacebookSearch.where(:id => params[:id], :user_id => @user.id).first
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def facebook_search_params
      params.require(:facebook_search).permit(:query)
      # params.fetch(:facebook_search, {})
    end
end

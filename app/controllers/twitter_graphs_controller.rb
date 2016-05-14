class TwitterGraphsController < ApplicationController
  before_action :set_user
  before_action :check_tw_auth
  before_action :set_twitter_graph, only: [:show, :edit, :update, :destroy, :stop, :poll_status]

  # GET /twitter_graphs
  def index
    if @user && !@error
      @twitter_graphs = @user.twitter_graphs
      @page_title = 'twitter_graph'
      @sub_title = 'twitter graphs'
    else
      if !@error
        @error = 'No user'
      end
      redirect_to :root, alert: @error
    end
  end

  # GET /twitter_graphs/1
  def show
    if @twitter_graph
      @page_title = 'twitter_graph'
      @sub_title = 'twitter graph'
      respond_to do |format|
        format.html
        format.csv { render text: File.read(@twitter_graph.output) }
      end
    else
      if !@error
        @error = 'No user'
      end
      redirect_to :root, alert: @error
    end
  end

  # GET /twitter_graphs/new
  def new
    if @user && !@error
      @twitter_graph = TwitterGraph.new
      @twitter_graph.user_id = @user.id
      @page_title = 'twitter_graph'
      @sub_title = 'New twitter graph'
    else
      if !@error
        @error = 'No user'
      end
      redirect_to :root, alert: @error
    end
  end

  # GET /twitter_graphs/1/edit
  def edit
  end

  # POST /twitter_graphs
  def create
    if @user && !@error
      @twitter_graph = TwitterGraph.new(twitter_graph_params)
      respond_to do |format|
        if @twitter_graph.save
          @user.twitter_graphs << @twitter_graph
          @twitter_graph.get_graph
          format.html { redirect_to user_twitter_graph_url(:id => @twitter_graph.id), notice: 'Twitter graph was successfully created.' }
        else
          format.html { render :new }
        end
      end
    else
      if !@error
        @error = 'No user'
      end
      redirect_to :root, alert: @error
    end
  end

  # PATCH/PUT /twitter_graphs/1
  def update
    respond_to do |format|
      if @twitter_graph.update(twitter_graph_params)
        format.html { redirect_to @twitter_graph, notice: 'Twitter graph was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /twitter_graphs/1
  def destroy
    @twitter_graph.destroy
    respond_to do |format|
      format.html { redirect_to user_twitter_graphs_url, notice: 'Twitter graph was successfully destroyed.' }
    end
  end
  
  def stop
    if @twitter_graph
      @twitter_graph.update_attribute(:status, :finished)
      respond_to do |format|
        format.json { render json: { 'message' => 'Graph stopped' }, status: 200 }
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
    def set_twitter_graph
      if @user && !@error
        @twitter_graph = TwitterGraph.where(:id => params[:id], :user_id => @user.id).first
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def twitter_graph_params
      params.require(:twitter_graph).permit(:query)
    end
end

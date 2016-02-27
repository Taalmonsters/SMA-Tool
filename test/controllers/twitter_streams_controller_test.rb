require 'test_helper'

class TwitterStreamsControllerTest < ActionController::TestCase
  setup do
    @twitter_stream = twitter_streams(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:twitter_streams)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create twitter_stream" do
    assert_difference('TwitterStream.count') do
      post :create, twitter_stream: {  }
    end

    assert_redirected_to twitter_stream_path(assigns(:twitter_stream))
  end

  test "should show twitter_stream" do
    get :show, id: @twitter_stream
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @twitter_stream
    assert_response :success
  end

  test "should update twitter_stream" do
    patch :update, id: @twitter_stream, twitter_stream: {  }
    assert_redirected_to twitter_stream_path(assigns(:twitter_stream))
  end

  test "should destroy twitter_stream" do
    assert_difference('TwitterStream.count', -1) do
      delete :destroy, id: @twitter_stream
    end

    assert_redirected_to twitter_streams_path
  end
end

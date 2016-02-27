require 'test_helper'

class TwitterSearchesControllerTest < ActionController::TestCase
  setup do
    @twitter_search = twitter_searches(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:twitter_searches)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create twitter_search" do
    assert_difference('TwitterSearch.count') do
      post :create, twitter_search: {  }
    end

    assert_redirected_to twitter_search_path(assigns(:twitter_search))
  end

  test "should show twitter_search" do
    get :show, id: @twitter_search
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @twitter_search
    assert_response :success
  end

  test "should update twitter_search" do
    patch :update, id: @twitter_search, twitter_search: {  }
    assert_redirected_to twitter_search_path(assigns(:twitter_search))
  end

  test "should destroy twitter_search" do
    assert_difference('TwitterSearch.count', -1) do
      delete :destroy, id: @twitter_search
    end

    assert_redirected_to twitter_searches_path
  end
end

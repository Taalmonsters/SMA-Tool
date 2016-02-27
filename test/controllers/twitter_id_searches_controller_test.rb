require 'test_helper'

class TwitterIdSearchesControllerTest < ActionController::TestCase
  setup do
    @twitter_id_search = twitter_id_searches(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:twitter_id_searches)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create twitter_id_search" do
    assert_difference('TwitterIdSearch.count') do
      post :create, twitter_id_search: {  }
    end

    assert_redirected_to twitter_id_search_path(assigns(:twitter_id_search))
  end

  test "should show twitter_id_search" do
    get :show, id: @twitter_id_search
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @twitter_id_search
    assert_response :success
  end

  test "should update twitter_id_search" do
    patch :update, id: @twitter_id_search, twitter_id_search: {  }
    assert_redirected_to twitter_id_search_path(assigns(:twitter_id_search))
  end

  test "should destroy twitter_id_search" do
    assert_difference('TwitterIdSearch.count', -1) do
      delete :destroy, id: @twitter_id_search
    end

    assert_redirected_to twitter_id_searches_path
  end
end

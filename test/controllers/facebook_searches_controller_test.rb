require 'test_helper'

class FacebookSearchesControllerTest < ActionController::TestCase
  setup do
    @facebook_search = facebook_searches(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:facebook_searches)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create facebook_search" do
    assert_difference('FacebookSearch.count') do
      post :create, facebook_search: {  }
    end

    assert_redirected_to facebook_search_path(assigns(:facebook_search))
  end

  test "should show facebook_search" do
    get :show, id: @facebook_search
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @facebook_search
    assert_response :success
  end

  test "should update facebook_search" do
    patch :update, id: @facebook_search, facebook_search: {  }
    assert_redirected_to facebook_search_path(assigns(:facebook_search))
  end

  test "should destroy facebook_search" do
    assert_difference('FacebookSearch.count', -1) do
      delete :destroy, id: @facebook_search
    end

    assert_redirected_to facebook_searches_path
  end
end

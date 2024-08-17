require "test_helper"

class LoanRequestsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get loan_requests_index_url
    assert_response :success
  end

  test "should get show" do
    get loan_requests_show_url
    assert_response :success
  end

  test "should get new" do
    get loan_requests_new_url
    assert_response :success
  end

  test "should get create" do
    get loan_requests_create_url
    assert_response :success
  end

  test "should get update" do
    get loan_requests_update_url
    assert_response :success
  end

  test "should get destroy" do
    get loan_requests_destroy_url
    assert_response :success
  end
end

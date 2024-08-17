require "test_helper"

class Admin::LoanRequestsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_loan_requests_index_url
    assert_response :success
  end

  test "should get show" do
    get admin_loan_requests_show_url
    assert_response :success
  end

  test "should get approve" do
    get admin_loan_requests_approve_url
    assert_response :success
  end

  test "should get reject" do
    get admin_loan_requests_reject_url
    assert_response :success
  end

  test "should get adjust" do
    get admin_loan_requests_adjust_url
    assert_response :success
  end
end

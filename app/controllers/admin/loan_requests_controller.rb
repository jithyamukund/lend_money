class Admin::LoanRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin
  before_action :set_loan_request, only: [:show, :approve, :reject, :adjust, :adjustment_update]

  def index
    @loan_requests = LoanRequest.all.order(:status)
  end

  def show
    @loan_request_logs = @loan_request.loan_request_logs
  end

  def approve
    service = LoanRequestApprovalService.new(@loan_request, current_user, params[:note])

    if service.approve
      redirect_to admin_loan_request_path(@loan_request), notice: "Loan Approved by #{current_user.full_name}"
    else
      redirect_to admin_loan_request_path(@loan_request), alert: "Something went wrong!"
    end
  end

  def reject
    service = LoanRequestRejectService.new(@loan_request, current_user, params[:note])

    if service.reject
      redirect_to admin_loan_request_path(@loan_request), notice: "Loan Rejected by #{current_user.full_name}"
    else
      redirect_to admin_loan_request_path(@loan_request), alert: "Something went wrong!"
    end
  end

  def adjust
    @adjustment = @loan_request.loan_request_logs.build
    @last_adjustment = @loan_request.loan_request_logs.order(created_at: :asc).last
  end

  def adjustment_update
    @adjustment = @loan_request.loan_request_logs.build(adjustment_params)

    service = LoanRequestAdjustService.new(@adjustment, @loan_request, current_user)

    if service.adjust
      redirect_to admin_loan_request_path(@loan_request), notice: "Loan Request Adjusted by #{current_user.full_name}"
    else
      redirect_to admin_loan_request_path(@loan_request), alert: "Something went wrong!"
    end
  end

  private

  def adjustment_params
    params.require(:loan_request_log).permit(:amount, :interest_rate, :note)
  end

  def ensure_admin
    unless current_user.admin?
      redirect_to root_path, alert: 'You are not authorized to access this page.'
    end
  end

  def loan_params
    params.require(:loan_request).permit(:amount, :interest_rate)
  end

  def set_loan_request
    @loan_request = LoanRequest.find(params[:id])
  end
end

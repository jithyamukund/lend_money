class LoanRequestsController < ApplicationController
  before_action :set_loan_request, except: [:index, :new, :create]
  before_action :authorize_user, except: [:index, :new, :create]

  def index
    @loan_requests = current_user.loan_requests
  end

  def show
    @loan_request_logs = @loan_request.loan_request_logs
  end

  def new
    @loan_request = LoanRequest.new
  end

  def create
    @loan_request = current_user.loan_requests.build(request_params)
    if @loan_request.save
      redirect_to loan_request_url(@loan_request), notice: "Successfully Requested for Loan"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @loan_request.requested? && @loan_request.update(request_params)
      redirect_to loan_request_url(@loan_request), notice: "Successfully Modified Loan Request."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @loan_request.status == "open"
      redirect_to loan_requests_url, notice: "Unable to delete"
    else
      if @loan_request.destroy
        redirect_to loan_requests_url, notice: "Successfully Deleted Loan Request."
      else
        redirect_to loan_requests_url, notice: "Unable to delete"
      end
    end
  end

  def accept
    service = LoanAdjustmentUserService.new(@loan_request, current_user, params[:note])

    if service.accept
      redirect_to loan_request_url(@loan_request), notice: "Loan Adjustments Accepted by #{current_user.full_name}"
    else
      redirect_to loan_request_url(@loan_request), alert: "Something went wrong!"
    end
  end

  def reject
    service = LoanAdjustmentUserService.new(@loan_request, current_user, params[:note])

    if service.reject
      redirect_to loan_request_url(@loan_request), notice: "Loan Adjustments Rejected by #{current_user.full_name}"
    else
      redirect_to loan_request_url(@loan_request), alert: "Something went wrong!"
    end
  end

  def confirm
    service = LoanAdjustmentUserService.new(@loan_request, current_user, params[:note])

    if service.confirm
      redirect_to loan_request_url(@loan_request), notice: "Loan Confirmed"
    else
      redirect_to loan_request_url(@loan_request), alert: "Something went wrong!"
    end
  end

  def readjustment
    @adjustment = @loan_request.loan_request_logs.build
    @last_adjustment = @loan_request.loan_request_logs.waiting_for_adjustment_acceptance.order(created_at: :asc).last
  end

  def readjustment_update
    @adjustment = @loan_request.loan_request_logs.build(adjustment_params)

    service = LoanRequestReadjustService.new(@adjustment, @loan_request, current_user)

    if service.readjust
      redirect_to loan_request_url(@loan_request), notice: "Loan Request Re-Adjusted by #{current_user.full_name}"
    else
      redirect_to loan_request_url(@loan_request), alert: "Something went wrong!"
    end
  end

  def close
    service = LoanAdjustmentUserService.new(@loan_request, current_user, params[:note])

    if service.close_loan
      redirect_to loan_request_url(@loan_request), notice: "Loan Closed"
    else
      redirect_to loan_request_url(@loan_request), alert: "Something went wrong!"
    end
  end

  private

  def adjustment_params
    params.require(:loan_request_log).permit(:amount, :interest_rate, :note)
  end

  def set_loan_request
    @loan_request = LoanRequest.find(params[:id])
  end

  def request_params
    params.require(:loan_request).permit(:amount, :interest_rate)
  end

  def authorize_user
    unless current_user.admin? || @loan_request.user == current_user
      redirect_to root_path, alert: "You are not authorized to access this loan."
    end
  end
end

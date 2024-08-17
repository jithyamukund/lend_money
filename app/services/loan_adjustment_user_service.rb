class LoanAdjustmentUserService
  def initialize(loan_request, current_user, note)
    @loan_request = loan_request
    @current_user = current_user
    @note = note
  end

  def accept
    return false unless @loan_request.waiting_for_adjustment_acceptance?

    LoanRequest.transaction do
      last_adjustment = @loan_request.loan_request_logs.waiting_for_adjustment_acceptance.order(created_at: :asc).last

      if last_adjustment
        if @loan_request.update(status: 'open')
          adjustment = @loan_request.loan_request_logs.create(
            amount: last_adjustment.amount,
            interest_rate: last_adjustment.interest_rate,
            user: @current_user,
            status: 'open',
            note: @note
          )

          if adjustment.persisted?
            admin_user = User.find_by(role: 1)
            approved_loan = @loan_request.approved_loan.create(
              amount: adjustment.amount,
              interest_rate: adjustment.interest_rate,
              user: admin_user.id
            )
            if approved_loan.persisted? and transfer_funds(admin_user.wallet, @loan_request.user.wallet, @loan_request.amount)
              return true
            else
              raise ActiveRecord::Rollback, "Something went wrong!"
            end
          else
            raise ActiveRecord::Rollback, "Something went wrong!"
          end
        else
          raise ActiveRecord::Rollback, "Failed to update loan request status"
        end
      else
        return false
      end
    end
  end

  def reject
    return false unless @loan_request.waiting_for_adjustment_acceptance?

    LoanRequest.transaction do
      last_adjustment = @loan_request.loan_request_logs.waiting_for_adjustment_acceptance.order(created_at: :asc).last

      if last_adjustment
        if @loan_request.update(status: 'open')
          adjustment = @loan_request.loan_request_logs.create(
            amount: last_adjustment.amount,
            interest_rate: last_adjustment.interest_rate,
            user: @current_user,
            status: 'rejected',
            note: @note
          )

          if adjustment.persisted?
            return true
          else
            raise ActiveRecord::Rollback, "Something went wrong!"
          end
        else
          raise ActiveRecord::Rollback, "Failed to update loan request status"
        end
      else
        return false
      end
    end
  end

  def confirm
    return false unless @loan_request.approved?

    LoanRequest.transaction do
      last_adjustment = @loan_request.loan_request_logs.approved.order(created_at: :asc).last
      if last_adjustment
        if @loan_request.update(status: 'open')
          adjustment = @loan_request.loan_request_logs.create(
            amount: last_adjustment.amount,
            interest_rate: last_adjustment.interest_rate,
            user: @current_user,
            status: 'open',
            note: @note
          )

          if adjustment.persisted?
            admin_user = User.find_by(role: 1)
            approved_loan = @loan_request.create_approved_loan(
              amount: adjustment.amount,
              interest_rate: adjustment.interest_rate,
              user: admin_user
            )
            if approved_loan.persisted? and transfer_funds(admin_user.wallet, @loan_request.user.wallet, @loan_request.amount)
              return true
            else
              raise ActiveRecord::Rollback, "Something went wrong!"
            end
          else
            raise ActiveRecord::Rollback, "Something went wrong!"
          end
        else
          raise ActiveRecord::Rollback, "Failed to Confirm Loan"
        end
      else
        return false
      end
    end
  end

  def close_loan
    return false unless @loan_request.open?

    LoanRequest.transaction do
      approved_loan = @loan_request.approved_loan
      if approved_loan && !approved_loan.is_closed
        if @loan_request.update(status: 'closed')
          adjustment = @loan_request.loan_request_logs.create(
            amount: approved_loan.amount,
            interest_rate: approved_loan.interest_rate,
            user: @current_user,
            status: 'closed',
            note: @note
          )

          if adjustment.persisted?
            admin_user = User.find_by(role: 1)
            approved_loan.update(is_closed: true)
            total_amount = calculate_amount(approved_loan)
            if repay_loan(@loan_request.user.wallet, admin_user.wallet, total_amount, approved_loan.id)
              return true
            else
              raise ActiveRecord::Rollback, "Something went wrong!"
            end
          else
            raise ActiveRecord::Rollback, "Something went wrong!"
          end
        else
          raise ActiveRecord::Rollback, "Failed to Close Loan"
        end
      else
        raise ActiveRecord::Rollback, "No Open Loan Available"
      end
    end
  end

  private

  def transfer_funds(from_wallet, to_wallet, amount)
    raise ArgumentError, "Amount must be positive" if amount <= 0
    raise ArgumentError, "Insufficient funds" if from_wallet.balance < amount

    Wallet.transaction do
      from_wallet.decrement!(:balance, amount)
      to_wallet.increment!(:balance, amount)
    end
  end

  def repay_loan(from_wallet, to_wallet, amount, approved_loan_id)
    raise ArgumentError, "Amount must be positive" if amount <= 0
    amount = from_wallet.balance if from_wallet.balance < amount
    Wallet.transaction do
      from_wallet.decrement!(:balance, amount)
      to_wallet.increment!(:balance, amount)
    end
    approved = ApprovedLoan.find(approved_loan_id)
    approved.update!(closed_amount: amount, closed_at: DateTime.now) if approved
  end

  def calculate_amount(approved_loan)
    principal = approved_loan.amount
    rate_of_interest = approved_loan.interest_rate
    time_difference_in_minutes = ((Time.current - approved_loan.created_at) / 60.0).to_f
    interest_amount = principal * (rate_of_interest/100.0)*time_difference_in_minutes/(60*24*365)
    total = approved_loan.amount + interest_amount.round(2)
    total
  end
end

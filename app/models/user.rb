class User < ApplicationRecord
  enum role: { user: 0, admin: 1 }
  has_one :wallet
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  after_initialize :set_default_role, if: :new_record?
  after_create :initialize_wallet

  private

  def set_default_role
    self.role ||= :user
  end

  def initialize_wallet
    if admin?
      Wallet.create(user: self, balance: 1000000)
    else
      Wallet.create(user: self, balance: 10000)
    end
  end
end

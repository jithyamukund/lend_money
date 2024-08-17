class User < ApplicationRecord
  enum role: { user: 0, admin: 1 }
  has_one :wallet, dependent: :destroy
  has_many :loan_requests, dependent: :destroy

  validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: :is_invalid }
  validate :single_admin, on: :create

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  before_save :capitalize_name
  after_initialize :set_default_role, if: :new_record?
  after_create :initialize_wallet

  def full_name
    "#{first_name} #{last_name}"
  end

  private

  def capitalize_name
    self.first_name = first_name.split.map(&:capitalize).join(' ') if first_name.present?
    self.last_name = last_name.split.map(&:capitalize).join(' ') if last_name.present?
  end

  def single_admin
    if admin? && User.where(role: :admin).exists?
      errors.add(:base, "Only one admin can exist")
    end
  end

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

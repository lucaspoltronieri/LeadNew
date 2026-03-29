class CrmDealPolicy < ApplicationPolicy
  def index?  = account_member?
  def create? = account_member?
  def update? = account_member? && belongs_to_account?
  def destroy? = @user.administrator? && belongs_to_account?
  def move?   = account_member? && belongs_to_account?

  private

  def account_member?
    @user.administrator? || @user.agent?
  end

  def belongs_to_account?
    @record.account_id == @account.id
  end
end

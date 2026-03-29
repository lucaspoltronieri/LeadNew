class CrmPipelinePolicy < ApplicationPolicy
  def index?   = @user.administrator?
  def create?  = @user.administrator?
  def update?  = @user.administrator? && belongs_to_account?
  def destroy? = @user.administrator? && belongs_to_account?

  private

  def belongs_to_account?
    @record.account_id == @account.id
  end
end

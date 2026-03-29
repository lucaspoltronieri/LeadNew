class Api::V1::Accounts::CrmDealsController < Api::V1::Accounts::BaseController
  before_action :current_account
  before_action :check_authorization
  before_action :set_deal, only: [:show, :update, :destroy, :move]

  def index
    @deals = Current.account.crm_deals
                    .for_pipeline(params[:crm_pipeline_id])
                    .includes(:contact, :conversation, :crm_stage)
                    .order(created_at: :asc)

    render json: { payload: deals_payload(@deals) }
  end

  def show
    render json: { payload: deal_payload(@deal) }
  end

  def create
    @deal = Current.account.crm_deals.build(deal_params)
    if @deal.save
      render json: { payload: deal_payload(@deal) }, status: :created
    else
      render json: { error: @deal.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  def update
    if @deal.update(deal_params)
      render json: { payload: deal_payload(@deal) }
    else
      render json: { error: @deal.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  def destroy
    @deal.destroy!
    render json: { success: true }
  end

  # PATCH /api/v1/accounts/:account_id/crm_deals/:id/move
  # Safely moves a deal to a different stage without touching other fields
  def move
    target_stage = Current.account.crm_pipelines
                          .joins(:crm_stages)
                          .where(crm_stages: { id: params[:crm_stage_id] })
                          .first&.crm_stages&.find_by(id: params[:crm_stage_id])

    if target_stage.nil?
      render json: { error: 'Stage not found or does not belong to this account' }, status: :not_found
      return
    end

    if @deal.update(crm_stage: target_stage)
      render json: { payload: deal_payload(@deal) }
    else
      render json: { error: @deal.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  private

  def set_deal
    @deal = Current.account.crm_deals.find(params[:id])
  end

  def deal_params
    params.require(:crm_deal).permit(
      :crm_stage_id, :contact_id, :conversation_id,
      :title, :value, :status, :lost_reason
    )
  end

  def check_authorization
    @deal ? authorize(@deal) : authorize(CrmDeal)
  end

  def deal_payload(deal)
    {
      id: deal.id,
      title: deal.title,
      value: deal.value,
      status: deal.status,
      lost_reason: deal.lost_reason,
      crm_stage_id: deal.crm_stage_id,
      contact: contact_payload(deal.contact),
      conversation: conversation_payload(deal.conversation),
      created_at: deal.created_at,
      updated_at: deal.updated_at
    }
  end

  def deals_payload(deals)
    deals.map { |d| deal_payload(d) }
  end

  def contact_payload(contact)
    return nil unless contact

    {
      id: contact.id,
      name: contact.name,
      email: contact.email,
      phone_number: contact.phone_number,
      avatar_url: contact.avatar_url
    }
  end

  def conversation_payload(conversation)
    return nil unless conversation

    last_msg = conversation.messages.outgoing.last || conversation.messages.last
    {
      id: conversation.id,
      display_id: conversation.display_id,
      status: conversation.status,
      last_message: last_msg&.content
    }
  end
end

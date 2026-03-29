class Api::V1::Accounts::AiAgentsController < Api::V1::Accounts::BaseController
  before_action :current_account
  before_action :check_authorization
  before_action :set_ai_agent, only: [:update, :destroy]

  def index
    @ai_agents = Current.account.ai_agents
    render json: { payload: @ai_agents }
  end

  def create
    @ai_agent = Current.account.ai_agents.build(ai_agent_params)
    
    if @ai_agent.save
      render json: { payload: @ai_agent }, status: :ok
    else
      render json: { error: @ai_agent.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  def update
    if @ai_agent.update(ai_agent_params)
      render json: { payload: @ai_agent }, status: :ok
    else
      render json: { error: @ai_agent.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  def destroy
    @ai_agent.destroy!
    render json: { success: true }, status: :ok
  end

  private

  def set_ai_agent
    @ai_agent = Current.account.ai_agents.find(params[:id])
  end

  def ai_agent_params
    params.require(:ai_agent).permit(
      :inbox_id,
      :name,
      :system_prompt,
      :is_active
    )
  end

  def check_authorization
    @ai_agent ? authorize(@ai_agent) : authorize(AiAgent)
  end
end

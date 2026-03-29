class Api::V1::Accounts::CrmStagesController < Api::V1::Accounts::BaseController
  before_action :current_account
  before_action :set_pipeline
  before_action :set_stage, only: [:update, :destroy]

  def index
    @stages = @pipeline.crm_stages
    render json: { payload: @stages }
  end

  def create
    @stage = @pipeline.crm_stages.build(stage_params)
    if @stage.save
      render json: { payload: @stage }, status: :created
    else
      render json: { error: @stage.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  def update
    if @stage.update(stage_params)
      render json: { payload: @stage }
    else
      render json: { error: @stage.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  def destroy
    @stage.destroy!
    render json: { success: true }
  end

  private

  def set_pipeline
    @pipeline = Current.account.crm_pipelines.find(params[:crm_pipeline_id])
  end

  def set_stage
    @stage = @pipeline.crm_stages.find(params[:id])
  end

  def stage_params
    params.require(:crm_stage).permit(:name, :position, :color)
  end
end

class Api::V1::Accounts::CrmPipelinesController < Api::V1::Accounts::BaseController
  before_action :current_account
  before_action :check_authorization
  before_action :set_pipeline, only: [:show, :update, :destroy]

  def index
    @pipelines = Current.account.crm_pipelines.includes(:crm_stages)
    render json: { payload: @pipelines.as_json(include: :crm_stages) }
  end

  def show
    render json: { payload: @pipeline.as_json(include: :crm_stages) }
  end

  def create
    @pipeline = Current.account.crm_pipelines.build(pipeline_params)
    if @pipeline.save
      render json: { payload: @pipeline.as_json(include: :crm_stages) }, status: :created
    else
      render json: { error: @pipeline.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  def update
    if @pipeline.update(pipeline_params)
      render json: { payload: @pipeline.as_json(include: :crm_stages) }
    else
      render json: { error: @pipeline.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  def destroy
    @pipeline.destroy!
    render json: { success: true }
  end

  private

  def set_pipeline
    @pipeline = Current.account.crm_pipelines.find(params[:id])
  end

  def pipeline_params
    params.require(:crm_pipeline).permit(:name, :description)
  end

  def check_authorization
    @pipeline ? authorize(@pipeline) : authorize(CrmPipeline)
  end
end

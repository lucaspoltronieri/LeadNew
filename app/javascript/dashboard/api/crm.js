/* global axios */
import ApiClient from './ApiClient';

class CrmPipelines extends ApiClient {
  constructor() {
    super('crm_pipelines', { accountScoped: true });
  }

  getStages(pipelineId) {
    return axios.get(`${this.url}/${pipelineId}/crm_stages`);
  }

  createStage(pipelineId, data) {
    return axios.post(`${this.url}/${pipelineId}/crm_stages`, data);
  }

  deleteStage(pipelineId, stageId) {
    return axios.delete(`${this.url}/${pipelineId}/crm_stages/${stageId}`);
  }
}

class CrmDeals extends ApiClient {
  constructor() {
    super('crm_deals', { accountScoped: true });
  }

  getByPipeline(pipelineId) {
    return axios.get(this.url, { params: { crm_pipeline_id: pipelineId } });
  }

  move(id, crm_stage_id) {
    return axios.patch(`${this.url}/${id}/move`, { crm_stage_id });
  }
}

export const CrmPipelinesAPI = new CrmPipelines();
export const CrmDealsAPI = new CrmDeals();

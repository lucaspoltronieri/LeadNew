import { CrmPipelinesAPI, CrmDealsAPI } from '../../api/crm';

const state = {
  pipelines: [],
  currentPipeline: null,
  deals: [],
  uiFlags: {
    isFetchingPipelines: false,
    isFetchingDeals: false,
    isCreating: false,
    isUpdating: false,
  },
};

const getters = {
  getPipelines: $state => $state.pipelines,
  getCurrentPipeline: $state => $state.currentPipeline,
  getDealsByStage: $state => stageId =>
    $state.deals.filter(d => d.crm_stage_id === stageId),
  getAllDeals: $state => $state.deals,
  getUIFlags: $state => $state.uiFlags,
};

const actions = {
  fetchPipelines: async ({ commit }) => {
    commit('SET_UI_FLAG', { isFetchingPipelines: true });
    try {
      const { data } = await CrmPipelinesAPI.get();
      commit('SET_PIPELINES', data.payload);
      if (data.payload.length > 0 && !state.currentPipeline) {
        commit('SET_CURRENT_PIPELINE', data.payload[0]);
      }
    } finally {
      commit('SET_UI_FLAG', { isFetchingPipelines: false });
    }
  },

  setCurrentPipeline: ({ commit, dispatch }, pipeline) => {
    commit('SET_CURRENT_PIPELINE', pipeline);
    dispatch('fetchDeals', pipeline.id);
  },

  fetchDeals: async ({ commit }, pipelineId) => {
    commit('SET_UI_FLAG', { isFetchingDeals: true });
    try {
      const { data } = await CrmDealsAPI.getByPipeline(pipelineId);
      commit('SET_DEALS', data.payload);
    } finally {
      commit('SET_UI_FLAG', { isFetchingDeals: false });
    }
  },

  createDeal: async ({ commit }, dealData) => {
    commit('SET_UI_FLAG', { isCreating: true });
    try {
      const { data } = await CrmDealsAPI.create({ crm_deal: dealData });
      commit('ADD_DEAL', data.payload);
      return data.payload;
    } finally {
      commit('SET_UI_FLAG', { isCreating: false });
    }
  },

  moveDeal: async ({ commit }, { dealId, stageId }) => {
    try {
      const { data } = await CrmDealsAPI.move(dealId, stageId);
      commit('UPDATE_DEAL', data.payload);
    } catch (error) {
      // Revert optimistic update on error
      throw error;
    }
  },

  updateDeal: async ({ commit }, { id, ...dealData }) => {
    commit('SET_UI_FLAG', { isUpdating: true });
    try {
      const { data } = await CrmDealsAPI.update(id, { crm_deal: dealData });
      commit('UPDATE_DEAL', data.payload);
    } finally {
      commit('SET_UI_FLAG', { isUpdating: false });
    }
  },

  deleteDeal: async ({ commit }, dealId) => {
    await CrmDealsAPI.delete(dealId);
    commit('REMOVE_DEAL', dealId);
  },

  createPipeline: async ({ commit }, pipelineData) => {
    const { data } = await CrmPipelinesAPI.create({ crm_pipeline: pipelineData });
    commit('ADD_PIPELINE', data.payload);
    return data.payload;
  },
};

const mutations = {
  SET_UI_FLAG(_state, data) {
    _state.uiFlags = { ..._state.uiFlags, ...data };
  },
  SET_PIPELINES(_state, pipelines) {
    _state.pipelines = pipelines;
  },
  ADD_PIPELINE(_state, pipeline) {
    _state.pipelines.push(pipeline);
  },
  SET_CURRENT_PIPELINE(_state, pipeline) {
    _state.currentPipeline = pipeline;
  },
  SET_DEALS(_state, deals) {
    _state.deals = deals;
  },
  ADD_DEAL(_state, deal) {
    _state.deals.push(deal);
  },
  UPDATE_DEAL(_state, updated) {
    const idx = _state.deals.findIndex(d => d.id === updated.id);
    if (idx !== -1) _state.deals.splice(idx, 1, updated);
  },
  REMOVE_DEAL(_state, dealId) {
    _state.deals = _state.deals.filter(d => d.id !== dealId);
  },
};

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations,
};

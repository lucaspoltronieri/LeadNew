import * as types from '../mutation-types';
import aiAgentsAPI from '../../api/aiAgents';

const state = {
  records: [],
  uiFlags: {
    isFetching: false,
    isCreating: false,
    isUpdating: false,
    isDeleting: false,
  },
};

const getters = {
  getAiAgents: $state => $state.records,
  getUIFlags: $state => $state.uiFlags,
};

const actions = {
  get: async ({ commit }) => {
    commit(types.SET_AI_AGENTS_UI_FLAG, { isFetching: true });
    try {
      const response = await aiAgentsAPI.get();
      commit(types.SET_AI_AGENTS, response.data.payload);
    } catch (error) {
      // Ignore error
    } finally {
      commit(types.SET_AI_AGENTS_UI_FLAG, { isFetching: false });
    }
  },
  create: async ({ commit }, agentData) => {
    commit(types.SET_AI_AGENTS_UI_FLAG, { isCreating: true });
    try {
      const response = await aiAgentsAPI.create(agentData);
      commit(types.ADD_AI_AGENT, response.data.payload);
      return response.data.payload;
    } finally {
      commit(types.SET_AI_AGENTS_UI_FLAG, { isCreating: false });
    }
  },
  update: async ({ commit }, { id, ...agentData }) => {
    commit(types.SET_AI_AGENTS_UI_FLAG, { isUpdating: true });
    try {
      const response = await aiAgentsAPI.update(id, agentData);
      commit(types.EDIT_AI_AGENT, response.data.payload);
      return response.data.payload;
    } finally {
      commit(types.SET_AI_AGENTS_UI_FLAG, { isUpdating: false });
    }
  },
  delete: async ({ commit }, agentId) => {
    commit(types.SET_AI_AGENTS_UI_FLAG, { isDeleting: true });
    try {
      await aiAgentsAPI.delete(agentId);
      commit(types.DELETE_AI_AGENT, agentId);
    } finally {
      commit(types.SET_AI_AGENTS_UI_FLAG, { isDeleting: false });
    }
  },
};

const mutations = {
  [types.SET_AI_AGENTS_UI_FLAG](_state, data) {
    _state.uiFlags = {
      ..._state.uiFlags,
      ...data,
    };
  },
  [types.SET_AI_AGENTS]: (_state, data) => {
    _state.records = data;
  },
  [types.ADD_AI_AGENT]: (_state, data) => {
    _state.records.push(data);
  },
  [types.EDIT_AI_AGENT]: (_state, data) => {
    const index = _state.records.findIndex(record => record.id === data.id);
    if (index !== -1) {
      _state.records.splice(index, 1, data);
    }
  },
  [types.DELETE_AI_AGENT]: (_state, agentId) => {
    _state.records = _state.records.filter(record => record.id !== agentId);
  },
};

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations,
};

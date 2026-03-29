<template>
  <div class="column content-box">
    <div class="row align-center justify-between">
      <div>
        <h1 class="page-title">{{ $t('AI_AGENTS.HEADER') }}</h1>
        <p>{{ $t('AI_AGENTS.DESC') }}</p>
      </div>
      <button class="button nice success" @click="showAddAgentModal">
        {{ $t('AI_AGENTS.ADD_BUTTON') }}
      </button>
    </div>

    <!-- Agent List -->
    <div class="row">
      <div v-if="!uiFlags.isFetching && records.length === 0" class="padding-a-large text-center w-full">
        {{ $t('AI_AGENTS.EMPTY') }}
      </div>
      <woot-loading-state v-if="uiFlags.isFetching" />
      <div v-else class="w-full mt-4">
        <table class="woot-table">
          <thead>
            <tr>
              <th>{{ $t('AI_AGENTS.LIST.NAME') }}</th>
              <th>{{ $t('AI_AGENTS.LIST.INBOX') }}</th>
              <th>{{ $t('AI_AGENTS.LIST.STATUS') }}</th>
              <th>{{ $t('AI_AGENTS.LIST.ACTIONS') }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="agent in records" :key="agent.id">
              <td>{{ agent.name }}</td>
              <td>{{ getInboxName(agent.inbox_id) }}</td>
              <td>
                <span class="badge" :class="agent.is_active ? 'success' : 'alert'">
                  {{ agent.is_active ? $t('AI_AGENTS.LIST.ACTIVE') : $t('AI_AGENTS.LIST.INACTIVE') }}
                </span>
              </td>
              <td>
                <div class="button-group">
                  <button class="button icon only" @click="editAgent(agent)">
                    <i class="ion-edit"></i>
                  </button>
                  <button class="button icon only alert" @click="deleteAgent(agent)">
                    <i class="ion-trash-b"></i>
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Modals -->
    <woot-modal :show.sync="showModal" :on-close="closeModal">
      <ai-agent-form
        :agent="selectedAgent"
        :inboxes="activeInboxes"
        @close="closeModal"
        @submit="handleSubmit"
      />
    </woot-modal>
  </div>
</template>

<script>
import { mapGetters } from 'vuex';
import AiAgentForm from './AiAgentForm';

export default {
  components: {
    AiAgentForm,
  },
  data() {
    return {
      showModal: false,
      selectedAgent: null,
    };
  },
  computed: {
    ...mapGetters({
      records: 'aiAgents/getAiAgents',
      uiFlags: 'aiAgents/getUIFlags',
      inboxes: 'inboxes/getInboxes',
    }),
    activeInboxes() {
      return this.inboxes;
    },
  },
  mounted() {
    this.$store.dispatch('aiAgents/get');
    this.$store.dispatch('inboxes/get');
  },
  methods: {
    getInboxName(id) {
      const inbox = this.inboxes.find(i => i.id === id);
      return inbox ? inbox.name : 'Unknown';
    },
    showAddAgentModal() {
      this.selectedAgent = null;
      this.showModal = true;
    },
    editAgent(agent) {
      this.selectedAgent = agent;
      this.showModal = true;
    },
    async deleteAgent(agent) {
      if (confirm(this.$t('AI_AGENTS.DELETE_CONFIRM', { name: agent.name }))) {
        await this.$store.dispatch('aiAgents/delete', agent.id);
      }
    },
    closeModal() {
      this.showModal = false;
      this.selectedAgent = null;
    },
    async handleSubmit(agentData) {
      if (this.selectedAgent) {
        await this.$store.dispatch('aiAgents/update', { id: this.selectedAgent.id, ...agentData });
      } else {
        await this.$store.dispatch('aiAgents/create', agentData);
      }
      this.closeModal();
    },
  },
};
</script>

<template>
  <div class="crm-kanban h-full flex flex-col bg-n-background">
    <!-- Header -->
    <div class="flex items-center justify-between px-6 py-4 border-b border-n-weak">
      <div class="flex items-center gap-4">
        <h1 class="text-xl font-semibold text-n-slate-12">
          {{ currentPipeline ? currentPipeline.name : $t('CRM.TITLE') }}
        </h1>
        <!-- Pipeline selector -->
        <select
          v-if="pipelines.length > 1"
          v-model="selectedPipelineId"
          class="text-sm rounded-lg border border-n-weak bg-n-background px-3 py-1 text-n-slate-11"
          @change="onPipelineChange"
        >
          <option v-for="p in pipelines" :key="p.id" :value="p.id">
            {{ p.name }}
          </option>
        </select>
      </div>
      <button
        class="flex items-center gap-1 px-3 py-1.5 rounded-lg bg-woot-500 text-white text-sm font-medium hover:bg-woot-600 transition-colors"
        @click="openNewDealModal"
      >
        <span class="i-lucide-plus size-4" />
        {{ $t('CRM.ADD_DEAL') }}
      </button>
    </div>

    <!-- Loading -->
    <div v-if="isFetching" class="flex-1 flex items-center justify-center">
      <woot-spinner />
    </div>

    <!-- Empty state - no pipeline -->
    <div v-else-if="!currentPipeline" class="flex-1 flex flex-col items-center justify-center gap-4 text-n-slate-10">
      <span class="i-lucide-kanban-square size-16 opacity-30" />
      <p class="text-lg">{{ $t('CRM.NO_PIPELINE') }}</p>
      <button class="button nice success" @click="openNewPipelineModal">
        {{ $t('CRM.CREATE_PIPELINE') }}
      </button>
    </div>

    <!-- Kanban Board -->
    <div v-else class="flex-1 overflow-x-auto">
      <div class="flex gap-4 p-6 h-full min-h-0" style="min-width: max-content">
        <div
          v-for="stage in currentPipeline.crm_stages"
          :key="stage.id"
          class="kanban-column flex flex-col w-72 bg-n-alpha-1 rounded-xl border border-n-weak flex-shrink-0"
          @dragover.prevent
          @drop="onDrop($event, stage.id)"
        >
          <!-- Column header -->
          <div class="flex items-center justify-between px-4 py-3 border-b border-n-weak">
            <div class="flex items-center gap-2">
              <span
                class="size-2.5 rounded-full flex-shrink-0"
                :style="{ backgroundColor: stage.color || '#6366f1' }"
              />
              <span class="font-medium text-n-slate-12 text-sm">{{ stage.name }}</span>
              <span class="text-xs text-n-slate-9 bg-n-alpha-2 rounded-full px-1.5 py-0.5">
                {{ getDealsByStage(stage.id).length }}
              </span>
            </div>
          </div>

          <!-- Cards -->
          <div class="flex-1 overflow-y-auto p-3 flex flex-col gap-2">
            <draggable-deal-card
              v-for="deal in getDealsByStage(stage.id)"
              :key="deal.id"
              :deal="deal"
              @edit="openEditDealModal(deal)"
              @delete="deleteDeal(deal)"
              @dragstart="onDragStart($event, deal)"
            />

            <!-- Empty column state -->
            <div
              v-if="getDealsByStage(stage.id).length === 0"
              class="flex-1 flex items-center justify-center text-n-slate-8 text-sm py-8"
            >
              {{ $t('CRM.DROP_HERE') }}
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- New/Edit Deal Modal -->
    <woot-modal :show.sync="showDealModal" :on-close="closeDealModal">
      <crm-deal-form
        :deal="selectedDeal"
        :stages="currentPipeline ? currentPipeline.crm_stages : []"
        @close="closeDealModal"
        @submit="handleDealSubmit"
      />
    </woot-modal>
  </div>
</template>

<script>
import { mapGetters } from 'vuex';
import DraggableDealCard from './DraggableDealCard.vue';
import CrmDealForm from './CrmDealForm.vue';

export default {
  name: 'CrmKanban',
  components: { DraggableDealCard, CrmDealForm },

  data() {
    return {
      selectedPipelineId: null,
      showDealModal: false,
      selectedDeal: null,
      draggedDeal: null,
    };
  },

  computed: {
    ...mapGetters({
      pipelines: 'crm/getPipelines',
      currentPipeline: 'crm/getCurrentPipeline',
      uiFlags: 'crm/getUIFlags',
    }),
    isFetching() {
      return this.uiFlags.isFetchingPipelines || this.uiFlags.isFetchingDeals;
    },
  },

  mounted() {
    this.$store.dispatch('crm/fetchPipelines');
  },

  methods: {
    getDealsByStage(stageId) {
      return this.$store.getters['crm/getDealsByStage'](stageId);
    },
    onPipelineChange() {
      const pipeline = this.pipelines.find(p => p.id === this.selectedPipelineId);
      if (pipeline) this.$store.dispatch('crm/setCurrentPipeline', pipeline);
    },
    onDragStart(event, deal) {
      this.draggedDeal = deal;
      event.dataTransfer.effectAllowed = 'move';
    },
    async onDrop(event, targetStageId) {
      if (!this.draggedDeal || this.draggedDeal.crm_stage_id === targetStageId) return;

      // Optimistic UI update
      const original = { ...this.draggedDeal };
      this.$store.commit('crm/UPDATE_DEAL', { ...this.draggedDeal, crm_stage_id: targetStageId });

      try {
        await this.$store.dispatch('crm/moveDeal', {
          dealId: this.draggedDeal.id,
          stageId: targetStageId,
        });
      } catch {
        // Revert on failure
        this.$store.commit('crm/UPDATE_DEAL', original);
        this.$refs.toast?.show({ type: 'error', message: this.$t('CRM.MOVE_ERROR') });
      }
      this.draggedDeal = null;
    },
    openNewDealModal() {
      this.selectedDeal = null;
      this.showDealModal = true;
    },
    openEditDealModal(deal) {
      this.selectedDeal = deal;
      this.showDealModal = true;
    },
    closeDealModal() {
      this.showDealModal = false;
      this.selectedDeal = null;
    },
    async handleDealSubmit(data) {
      if (this.selectedDeal) {
        await this.$store.dispatch('crm/updateDeal', { id: this.selectedDeal.id, ...data });
      } else {
        await this.$store.dispatch('crm/createDeal', data);
      }
      this.closeDealModal();
    },
    async deleteDeal(deal) {
      if (confirm(this.$t('CRM.DELETE_CONFIRM', { title: deal.title }))) {
        await this.$store.dispatch('crm/deleteDeal', deal.id);
      }
    },
    openNewPipelineModal() {
      // TODO: implement pipeline creation modal
    },
  },
};
</script>

<style scoped>
.crm-kanban {
  height: calc(100vh - 60px);
}
.kanban-column {
  min-height: 300px;
}
</style>

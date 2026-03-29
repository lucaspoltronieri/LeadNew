<template>
  <div class="p-6 w-full max-w-lg">
    <h2 class="text-lg font-semibold mb-5 text-n-slate-12">
      {{ deal ? $t('CRM.FORM.EDIT') : $t('CRM.FORM.NEW') }}
    </h2>

    <form class="flex flex-col gap-4" @submit.prevent="onSubmit">
      <!-- Title -->
      <label class="block">
        <span class="text-sm text-n-slate-11 mb-1 block">{{ $t('CRM.FORM.TITLE') }} *</span>
        <input
          v-model="form.title"
          type="text"
          required
          class="w-full"
          :placeholder="$t('CRM.FORM.TITLE_PLACEHOLDER')"
        />
      </label>

      <!-- Stage -->
      <label class="block">
        <span class="text-sm text-n-slate-11 mb-1 block">{{ $t('CRM.FORM.STAGE') }} *</span>
        <select v-model="form.crm_stage_id" required class="w-full">
          <option v-for="stage in stages" :key="stage.id" :value="stage.id">
            {{ stage.name }}
          </option>
        </select>
      </label>

      <!-- Value -->
      <label class="block">
        <span class="text-sm text-n-slate-11 mb-1 block">{{ $t('CRM.FORM.VALUE') }}</span>
        <input
          v-model.number="form.value"
          type="number"
          min="0"
          step="0.01"
          class="w-full"
          placeholder="0,00"
        />
      </label>

      <!-- Status -->
      <label class="block">
        <span class="text-sm text-n-slate-11 mb-1 block">{{ $t('CRM.FORM.STATUS') }}</span>
        <select v-model="form.status" class="w-full">
          <option value="open">{{ $t('CRM.STATUS.OPEN') }}</option>
          <option value="won">{{ $t('CRM.STATUS.WON') }}</option>
          <option value="lost">{{ $t('CRM.STATUS.LOST') }}</option>
        </select>
      </label>

      <!-- Lost reason (conditional) -->
      <label v-if="form.status === 'lost'" class="block">
        <span class="text-sm text-n-slate-11 mb-1 block">{{ $t('CRM.FORM.LOST_REASON') }} *</span>
        <textarea
          v-model="form.lost_reason"
          rows="2"
          required
          class="w-full"
          :placeholder="$t('CRM.FORM.LOST_REASON_PLACEHOLDER')"
        />
      </label>

      <!-- Actions -->
      <div class="flex justify-end gap-2 pt-2">
        <button type="button" class="button clear" @click="$emit('close')">
          {{ $t('CANCEL') }}
        </button>
        <button type="submit" class="button nice success">
          {{ deal ? $t('CRM.FORM.UPDATE') : $t('CRM.FORM.CREATE') }}
        </button>
      </div>
    </form>
  </div>
</template>

<script>
export default {
  name: 'CrmDealForm',
  props: {
    deal: { type: Object, default: null },
    stages: { type: Array, default: () => [] },
  },
  emits: ['close', 'submit'],
  data() {
    return {
      form: {
        title: '',
        crm_stage_id: this.stages[0]?.id || null,
        value: 0,
        status: 'open',
        lost_reason: '',
      },
    };
  },
  mounted() {
    if (this.deal) {
      this.form = {
        title: this.deal.title,
        crm_stage_id: this.deal.crm_stage_id,
        value: this.deal.value,
        status: this.deal.status,
        lost_reason: this.deal.lost_reason || '',
      };
    } else if (this.stages.length > 0) {
      this.form.crm_stage_id = this.stages[0].id;
    }
  },
  methods: {
    onSubmit() {
      this.$emit('submit', { ...this.form });
    },
  },
};
</script>

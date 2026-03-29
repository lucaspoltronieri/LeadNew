<template>
  <div class="row align-center justify-center p-8">
    <div class="w-full">
      <h2 class="text-xl mb-4">{{ agent ? $t('AI_AGENTS.FORM.EDIT') : $t('AI_AGENTS.FORM.ADD') }}</h2>
      <form @submit.prevent="onSubmit">
        <label>
          {{ $t('AI_AGENTS.FORM.NAME_LABEL') }}
          <input
            v-model="formData.name"
            type="text"
            required
            :placeholder="$t('AI_AGENTS.FORM.NAME_PLACEHOLDER')"
          />
        </label>

        <label>
          {{ $t('AI_AGENTS.FORM.INBOX_LABEL') }}
          <select v-model="formData.inbox_id" required>
            <option v-for="inbox in inboxes" :key="inbox.id" :value="inbox.id">
              {{ inbox.name }}
            </option>
          </select>
        </label>

        <label>
          {{ $t('AI_AGENTS.FORM.PROMPT_LABEL') }}
          <textarea
            v-model="formData.system_prompt"
            rows="5"
            :placeholder="$t('AI_AGENTS.FORM.PROMPT_PLACEHOLDER')"
          ></textarea>
        </label>

        <label class="flex items-center mt-2 mb-4 cursor-pointer">
          <input type="checkbox" v-model="formData.is_active" class="mr-2" />
          {{ $t('AI_AGENTS.FORM.ACTIVE_TOGGLE') }}
        </label>

        <div class="flex flex-row justify-end w-full gap-2 mt-4">
          <button type="button" class="button clear" @click="$emit('close')">
            {{ $t('AI_AGENTS.FORM.CANCEL') }}
          </button>
          <button type="submit" class="button nice success">
            {{ agent ? $t('AI_AGENTS.FORM.UPDATE') : $t('AI_AGENTS.FORM.SAVE') }}
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    agent: {
      type: Object,
      default: null,
    },
    inboxes: {
      type: Array,
      default: () => [],
    },
  },
  data() {
    return {
      formData: {
        name: '',
        inbox_id: '',
        system_prompt: '',
        is_active: true,
      },
    };
  },
  mounted() {
    if (this.agent) {
      this.formData = { ...this.agent };
    } else if (this.inboxes.length > 0) {
      this.formData.inbox_id = this.inboxes[0].id;
    }
  },
  methods: {
    onSubmit() {
      this.$emit('submit', this.formData);
    },
  },
};
</script>

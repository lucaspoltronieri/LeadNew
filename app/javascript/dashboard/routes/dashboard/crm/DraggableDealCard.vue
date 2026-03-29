<template>
  <div
    class="deal-card bg-n-background rounded-lg border border-n-weak p-3 cursor-grab hover:border-woot-300 hover:shadow-md transition-all duration-150 group"
    draggable="true"
    @dragstart="$emit('dragstart', $event)"
  >
    <!-- Title -->
    <div class="flex items-start justify-between gap-2 mb-2">
      <p class="font-medium text-n-slate-12 text-sm leading-snug">{{ deal.title }}</p>
      <div class="flex gap-1 opacity-0 group-hover:opacity-100 transition-opacity flex-shrink-0">
        <button class="p-0.5 rounded text-n-slate-9 hover:text-n-slate-12" @click.stop="$emit('edit')">
          <span class="i-lucide-pencil size-3.5" />
        </button>
        <button class="p-0.5 rounded text-n-slate-9 hover:text-red-500" @click.stop="$emit('delete')">
          <span class="i-lucide-trash-2 size-3.5" />
        </button>
      </div>
    </div>

    <!-- Value badge -->
    <div
      v-if="deal.value > 0"
      class="inline-flex items-center gap-1 text-xs text-emerald-600 bg-emerald-50 dark:bg-emerald-950/40 px-1.5 py-0.5 rounded-md mb-2"
    >
      <span class="i-lucide-trending-up size-3" />
      {{ formatCurrency(deal.value) }}
    </div>

    <!-- Contact info -->
    <div v-if="deal.contact" class="flex items-center gap-2 mt-2 pt-2 border-t border-n-weak">
      <div class="size-5 rounded-full bg-woot-100 flex items-center justify-center flex-shrink-0">
        <span class="text-woot-700 text-[9px] font-bold uppercase">
          {{ deal.contact.name?.charAt(0) || '?' }}
        </span>
      </div>
      <span class="text-xs text-n-slate-10 truncate">{{ deal.contact.name }}</span>
    </div>

    <!-- Last conversation message -->
    <div v-if="deal.conversation?.last_message" class="mt-1.5">
      <p class="text-xs text-n-slate-9 truncate italic">
        "{{ deal.conversation.last_message }}"
      </p>
    </div>

    <!-- Status -->
    <div v-if="deal.status !== 'open'" class="mt-2">
      <span
        class="text-[10px] font-semibold uppercase tracking-wide px-1.5 py-0.5 rounded-full"
        :class="{
          'bg-emerald-100 text-emerald-700 dark:bg-emerald-950/40 dark:text-emerald-400': deal.status === 'won',
          'bg-red-100 text-red-700 dark:bg-red-950/40 dark:text-red-400': deal.status === 'lost',
        }"
      >
        {{ deal.status === 'won' ? '🏆 Ganho' : '❌ Perdido' }}
      </span>
    </div>
  </div>
</template>

<script>
export default {
  name: 'DraggableDealCard',
  props: {
    deal: {
      type: Object,
      required: true,
    },
  },
  emits: ['edit', 'delete', 'dragstart'],
  methods: {
    formatCurrency(value) {
      return new Intl.NumberFormat('pt-BR', {
        style: 'currency',
        currency: 'BRL',
      }).format(value);
    },
  },
};
</script>

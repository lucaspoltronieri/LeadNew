import { frontendURL } from '../../../helper/URLHelper';
import { ROLES } from '../../../constants/permissions.js';

const CrmKanban = () => import('./CrmKanban.vue');

export default {
  routes: [
    {
      path: frontendURL('accounts/:accountId/crm'),
      name: 'crm_kanban',
      component: CrmKanban,
      meta: {
        permissions: [...ROLES],
      },
    },
  ],
};

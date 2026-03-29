import { frontendURL } from '../../../../helper/URLHelper';
import { ROLES } from '../../../../constants/permissions.js';

const SettingsContent = () => import('../Wrapper.vue');
const AiAgentsIndex = () => import('./Index.vue');

export default {
  routes: [
    {
      path: frontendURL('accounts/:accountId/settings/ai_agents'),
      component: SettingsContent,
      props: {
        headerTitle: 'AI_AGENTS.HEADER',
        icon: 'ion-outlet',
        showNewButton: false,
      },
      children: [
        {
          path: '',
          name: 'ai_agents_wrapper',
          component: AiAgentsIndex,
          meta: {
            permissions: ['administrator'],
          },
        },
      ],
    },
  ],
};

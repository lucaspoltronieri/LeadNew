/* eslint no-console: 0 */
import ApiClient from './ApiClient';

class AiAgentsAPI extends ApiClient {
  constructor() {
    super('ai_agents', { accountScoped: true });
  }
}

export default new AiAgentsAPI();

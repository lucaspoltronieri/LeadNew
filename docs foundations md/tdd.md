# Test-Driven Development (TDD) Strategy - LeadNew

## 1. Diretriz Principal
O agente deve obrigatoriamente escrever testes falhos (Red), implementar a funcionalidade (Green) e otimizar o código (Refactor). O Chatwoot utiliza `RSpec` para o backend e `Jest` para o frontend.

## 2. Suíte de Testes - Backend (RSpec)

### 2.1. Billing e Tokens
* **Especificação:** `spec/services/asaas/webhook_processor_spec.rb`
  * *Contexto:* Quando o webhook recebe `PAYMENT_CONFIRMED`.
  * *Expectativa:* Deve atualizar `subscription_status` da Account para `active` e adicionar tokens em `token_ledgers`.
* **Especificação:** `spec/models/token_ledger_spec.rb`
  * *Contexto:* Dedução de tokens após mensagem da IA.
  * *Expectativa:* Não deve permitir que `balance` fique negativo. Se zerar, deve desativar o `ai_agent` da conta.

### 2.2. Módulo CRM
* **Especificação:** `spec/models/crm_deal_spec.rb`
  * *Expectativa:* Um Deal não pode ser criado sem estar atrelado a um `Contact` válido e a um `crm_stage_id`.

## 3. Suíte de Testes - Frontend (Jest/Vue Test Utils)
* **Especificação:** `CrmBoard.spec.js`
  * *Expectativa:* Ao emitir o evento de 'drag' de um card da coluna A para a coluna B, o componente deve disparar uma action Vuex/Pinia executando um `PATCH` para a API alterando o `crm_stage_id` do Deal.
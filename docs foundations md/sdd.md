# Spec-Driven Design (SDD) & Architecture - LeadNew

## 1. Stack Tecnológico Base
* **Backend:** Ruby on Rails 7+ (herdado do Chatwoot)
* **Frontend:** Vue.js 3 + Tailwind CSS
* **Database:** PostgreSQL (dados relacionais) + Redis (filas/Sidekiq)
* **Infra:** Docker, Nginx

## 2. Modificações no Modelo de Dados (Schema)
O Chatwoot utiliza o modelo multi-tenant baseado na tabela `accounts`. Todas as novas tabelas devem pertencer a um `account_id`.

### Novas Entidades (CRM):
* `crm_pipelines`: `id`, `account_id`, `name`, `description`.
* `crm_stages`: `id`, `crm_pipeline_id`, `name`, `order`, `color`.
* `crm_deals`: `id`, `account_id`, `crm_stage_id`, `contact_id` (FK), `value`, `status` (open, won, lost), `lost_reason`.

### Novas Entidades (IA e Billing):
* `ai_agents`: `id`, `account_id`, `inbox_id` (FK), `name`, `system_prompt`, `is_active`.
* `account_billing`: `id`, `account_id`, `asaas_customer_id`, `subscription_status`, `plan_type`.
* `token_ledgers`: `id`, `account_id`, `tokens_purchased`, `tokens_used`, `balance`.

## 3. Arquitetura de Integração Asaas
* **Service Object:** Criar `Asaas::SubscriptionService` em Rails para gerenciar chamadas à API (criação de clientes e assinaturas).
* **Webhook Controller:** Criar rota `/api/v1/webhooks/asaas` para escutar eventos de pagamento (`PAYMENT_CONFIRMED`, `PAYMENT_OVERDUE`).

## 4. Modificação de Interface (Frontend)
* Injetar um novo ícone na barra lateral esquerda (Sidebar) do Chatwoot chamado "Funil".
* Criar view Vue.js `CrmBoard.vue` utilizando a biblioteca `vuedraggable` para renderizar os `crm_stages` e iterar os `crm_deals`.
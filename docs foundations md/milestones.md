# Milestones - Projeto LeadNew

## Milestone 1: Setup e Infraestrutura Base
* **Objetivo:** Preparar o terreno no repositório forkado.
* **Tarefas:**
  1. Configurar o ambiente de desenvolvimento local usando `docker-compose`.
  2. Limpar referências visuais fortes do Chatwoot (cores base) para preparar o white-labeling.
  3. Criar as migrações de banco de dados (`migrations`) para as tabelas de CRM e IA (descritas no SDD).

## Milestone 2: Integração Financeira (SaaS)
* **Objetivo:** Garantir que o sistema pode ser comercializado.
* **Tarefas:**
  1. Construir os Services do Asaas no backend.
  2. Implementar os Webhooks para gestão de status das contas (`Accounts`).
  3. Criar a lógica do painel Super Admin para visualizar os pagamentos e saldos de tokens.

## Milestone 3: O Motor de IA
* **Objetivo:** Implementar os agentes de atendimento baseados em tokens.
* **Tarefas:**
  1. Criar CRUD de Agentes de IA no painel do usuário.
  2. Interceptar a entrada de mensagens (`Message creation hook`) para rotear para o agente de IA se ativo.
  3. Implementar a dedução lógica no `token_ledgers` a cada transação com a API da OpenAI/Anthropic.

## Milestone 4: O CRM Visual (Funil)
* **Objetivo:** O "Canivete Suíço" das vendas.
* **Tarefas:**
  1. Desenvolver a API (Endpoints REST) para Pipelines, Stages e Deals.
  2. Criar a interface Vue.js (Kanban) com Drag and Drop.
  3. Sincronizar os cards de Deals com o painel lateral de conversas.

## Milestone 5: Landing Page e Deploy
* **Objetivo:** Go-to-market.
* **Tarefas:**
  1. Criar Landing Page com a logo minimalista (estilo Minecraft/Robot).
  2. Linkar botão de compra com a API de criação de conta e geração de cobrança no Asaas.
  3. Preparar scripts de deploy para VPS na Hostinger com Nginx e SSL.
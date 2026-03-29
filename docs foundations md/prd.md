# Product Requirements Document (PRD) - LeadNew

## 1. Visão do Produto
O LeadNew é uma plataforma SaaS multicanal de atendimento e CRM de vendas, construída a partir de um fork do repositório open-source Chatwoot. O objetivo é fornecer um "canivete suíço" para empresas gerenciarem contatos, automatizarem atendimento com agentes de Inteligência Artificial nativos e controlarem pipelines de vendas através de um funil Kanban interativo.

## 2. Público-Alvo
Empresas B2B e B2C que necessitam centralizar o atendimento de WhatsApp/Redes Sociais e gerenciar o ciclo de vendas (SDR e Executivo) em uma única plataforma, sem depender de integrações complexas com CRMs externos.

## 3. Escopo Funcional (Features Principais)

### 3.1. Módulo CRM Visual (Kanban)
* **Pipelines Customizáveis:** Capacidade de criar múltiplos funis (ex: SDR, Closer).
* **Estágios do Funil:** Criação e ordenação de colunas (Lead Novo, Contato Inicial, Reunião, Negociação, Ganho/Perdido).
* **Deals (Negociações):** Cards no formato Kanban representando oportunidades. Devem ser linkados aos `Contacts` e `Conversations` já existentes no Chatwoot.
* **Interface Drag-and-Drop:** Movimentação fluida de cards entre estágios, com gatilhos de automação (ex: mudar card de coluna altera status da conversa).

### 3.2. Motor de Agentes de IA
* **Criação de Agentes:** Interface para nomear o bot e definir o System Prompt (diretrizes de comportamento).
* **Alocação Multicanal:** Atribuir agentes específicos a Inboxes diferentes.
* **Handoff (Transbordo):** Capacidade do agente identificar intenção, transferir o atendimento para a fila humana e mover automaticamente o card no funil de vendas.

### 3.3. Gestão SaaS e Billing (Asaas)
* **Integração Asaas:** Cobrança de assinaturas via API do Asaas (Cartão, Pix, Boleto).
* **Economia de Tokens:** Sistema de controle de pacotes de dados. Cada resposta da IA consome tokens do saldo da conta (`Account`).
* **Bloqueio/Desbloqueio:** Webhooks recebendo status de pagamento para suspender ou reativar tenants.

## 4. Requisitos Não-Funcionais
* **Performance:** O frontend Kanban deve renderizar pipelines com mais de 500 cards sem travamentos (paginação ou lazy loading em colunas).
* **Deploy:** Infraestrutura conteinerizada (Docker) otimizada para VPS (Hostinger).
Write-Host "============================================="
Write-Host "   Gerando Migrations - LeadNew"
Write-Host "============================================="

cd src

Write-Host "`n[1/6] Criando tabela: crm_pipelines"
docker-compose exec rails bundle exec rails g migration CreateCrmPipelines account:references name:string description:text

Write-Host "`n[2/6] Criando tabela: crm_stages"
docker-compose exec rails bundle exec rails g migration CreateCrmStages crm_pipeline:references name:string order:integer color:string

Write-Host "`n[3/6] Criando tabela: crm_deals"
docker-compose exec rails bundle exec rails g migration CreateCrmDeals account:references crm_stage:references contact:references value:decimal status:string lost_reason:text

Write-Host "`n[4/6] Criando tabela: ai_agents"
docker-compose exec rails bundle exec rails g migration CreateAiAgents account:references inbox:references name:string system_prompt:text is_active:boolean

Write-Host "`n[5/6] Criando tabela: account_billings"
docker-compose exec rails bundle exec rails g migration CreateAccountBillings account:references asaas_customer_id:string subscription_status:string plan_type:string

Write-Host "`n[6/6] Criando tabela: token_ledgers"
docker-compose exec rails bundle exec rails g migration CreateTokenLedgers account:references tokens_purchased:integer tokens_used:integer balance:integer

Write-Host "`n============================================="
Write-Host "Todas as migrations foram geradas!"
Write-Host "Rode 'docker-compose exec rails bundle exec rails db:migrate' para aplicar no banco."
Write-Host "============================================="

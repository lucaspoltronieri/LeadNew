Write-Host "Iniciando build do base container..."
cd src
docker-compose build base
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Iniciando build de todo o compose e subindo os containers..."
docker-compose up -d --build
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Esperando servicos iniciarem (30 segundos)..."
Start-Sleep -Seconds 30

Write-Host "Rodando as migrations scripts..."
cd ..
.\generate_migrations.ps1

cd src
Write-Host "Aplicando migrations no banco de dados..."
docker-compose exec -T rails bundle exec rails db:migrate
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Testando rspec subscriptions..."
docker-compose exec -T rails bundle exec rspec spec/services/asaas/subscription_service_spec.rb
docker-compose exec -T rails bundle exec rspec spec/controllers/api/v1/webhooks/asaas_controller_spec.rb

Write-Host "==========================="
Write-Host "TUDO FINALIZADO COM SUCESSO"
Write-Host "==========================="

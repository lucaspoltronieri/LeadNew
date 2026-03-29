class SeedLeadnewGlobalConfigs < ActiveRecord::Migration[7.1]
  def up
    default_configs = {
      'EVOLUTION_SERVER_URL' => 'http://evolution_api:8080',
      'EVOLUTION_API_KEY' => 'leadnew_secret_key',
      'ASAAS_API_URL' => 'https://sandbox.asaas.com/api/v3'
    }

    default_configs.each do |name, value|
      config = InstallationConfig.find_or_initialize_by(name: name)
      # Chatwoot stores the value inside a hash in serialized_value
      config.serialized_value = { name => value }
      config.locked = false
      config.save!
    end

    # Reset cache to ensure the application picks up these values immediately
    begin
      GlobalConfig.clear_cache
    rescue StandardError
      # Ignore if cache cannot be cleared during migration (e.g. no Redis yet)
    end
  end

  def down
    # To avoid accidental data loss, we don't delete on rollback
    # but we could if strictly necessary.
  end
end

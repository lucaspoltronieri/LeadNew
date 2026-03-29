require 'net/http'
require 'uri'
require 'json'

module Asaas
  class SubscriptionService
    def initialize
      @api_key = GlobalConfig.get('ASAAS_API_KEY')['ASAAS_API_KEY'].presence || ENV.fetch('ASAAS_API_KEY', '')
      @base_url = GlobalConfig.get('ASAAS_API_URL')['ASAAS_API_URL'].presence || ENV.fetch('ASAAS_API_URL', 'https://sandbox.asaas.com/api/v3')
    end

    def create_customer(name:, email:, cpf_cnpj: nil)
      payload = {
        name: name,
        email: email
      }
      payload[:cpfCnpj] = cpf_cnpj if cpf_cnpj.present?

      perform_request(:post, '/customers', payload, 'create_customer')
    end

    def create_subscription(customer_id:, value:, billing_type: 'PIX', cycle: 'MONTHLY')
      payload = {
        customer: customer_id,
        billingType: billing_type,
        value: value,
        nextDueDate: 1.day.from_now.to_date.to_s,
        cycle: cycle
      }

      perform_request(:post, '/subscriptions', payload, 'create_subscription')
    end

    def create_payment_link(customer_id:, value:, description: 'Recarga de Tokens LeadNew')
      payload = {
        customer: customer_id,
        billingType: 'UNDEFINED',
        value: value,
        dueDate: 1.day.from_now.to_date.to_s,
        description: description
      }

      perform_request(:post, '/payments', payload, 'create_payment_link')
    end

    private

    def perform_request(method, endpoint, payload, action_name)
      uri = URI.parse("#{@base_url}#{endpoint}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == 'https')

      request = case method
                when :post
                  Net::HTTP::Post.new(uri.request_uri)
                when :get
                  Net::HTTP::Get.new(uri.request_uri)
                end

      request['access_token'] = @api_key
      request['Content-Type'] = 'application/json'
      request.body = payload.to_json if payload.present? && method != :get

      begin
        response = http.request(request)
        parsed_response = JSON.parse(response.body) rescue {}

        if response.is_a?(Net::HTTPSuccess)
          parsed_response
        else
          Rails.logger.error("Asaas API Error (#{action_name}): HTTP #{response.code} - #{response.body}")
          nil
        end
      rescue => e
        Rails.logger.error("Asaas API Exception (#{action_name}): #{e.message}")
        nil
      end
    end
  end
end

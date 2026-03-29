module Api
  module V1
    module Webhooks
      class AsaasController < ActionController::API
        def create
          payload = params.to_unsafe_h
          result = Asaas::WebhookProcessorService.new(payload).perform

          if result[:success]
            render json: { status: 'success', message: result[:message] }, status: :ok
          else
            Rails.logger.warn("[AsaasWebhook] Error: #{result[:error]}")
            render json: { status: 'error', message: result[:error] }, status: :ok
          end
        rescue StandardError => e
          Rails.logger.error("[AsaasWebhook] Fatal Exception: #{e.message}")
          head :ok # Return OK anyway to avoid Asaas retrying infinitely on bad data
        end
      end
    end
  end
end

module Asaas
  class WebhookProcessorService
    TOKEN_RATE = 100 # 1.00 BRL = 100 tokens
    
    def initialize(payload)
      @payload = payload
      @event = payload[:event]
      @payment = payload[:payment] || {}
      @customer_id = @payment[:customer]
    end

    def perform
      return { success: false, error: 'Customer ID or Event missing' } if @customer_id.blank? || @event.blank?

      billing = AccountBilling.find_by(asaas_customer_id: @customer_id)
      return { success: false, error: "Billing for customer #{@customer_id} not found" } unless billing

      process_event(billing)
    end

    private

    def process_event(billing)
      case @event
      when 'PAYMENT_CONFIRMED', 'PAYMENT_RECEIVED'
        handle_payment_confirmation(billing)
      when 'PAYMENT_OVERDUE', 'PAYMENT_REFUNDED', 'PAYMENT_CHARGEBACK_REQUESTED'
        billing.update!(subscription_status: 'suspended')
        { success: true, message: "Subscription suspended for #{@customer_id}" }
      else
        { success: true, message: "Event #{@event} ignored" }
      end
    end

    def handle_payment_confirmation(billing)
      # 1. Update status
      billing.update!(subscription_status: 'active')

      # 2. Add tokens to ledger
      value = @payment[:value].to_f
      tokens_to_add = (value * TOKEN_RATE).to_i

      if tokens_to_add > 0
        ledger = billing.account.token_ledger || billing.account.create_token_ledger
        ledger.credit!(tokens_to_add)
        Rails.logger.info("[AsaasWebhook] Credited #{tokens_to_add} tokens to Account #{billing.account_id}")
      end

      { success: true, message: "Payment processed and tokens credited" }
    end
  end
end

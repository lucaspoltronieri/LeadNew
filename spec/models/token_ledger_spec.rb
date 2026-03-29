require 'rails_helper'

RSpec.describe TokenLedger, type: :model do
  let(:account) { create(:account) }
  let(:ledger) { create(:token_ledger, account: account, tokens_purchased: 1000, tokens_used: 100) }

  describe '#calculate_balance' do
    it 'returns purchased minus used tokens' do
      expect(ledger.calculate_balance).to eq(900)
    end
  end

  describe '#credit!' do
    it 'increments tokens_purchased and updates balance' do
      # Start: purchased 1000, used 100, balance 900
      expect { ledger.credit!(500) }.to change { ledger.reload.tokens_purchased }.by(500)
      expect(ledger.balance).to eq(1400)
    end

    it 'does nothing when amount is 0 or negative' do
      expect { ledger.credit!(0) }.not_to change { ledger.reload.tokens_purchased }
      expect { ledger.credit!(-100) }.not_to change { ledger.reload.tokens_purchased }
    end
  end

  describe '#debit!' do
    it 'increments tokens_used and updates balance' do
      expect { ledger.debit!(150) }.to change { ledger.reload.tokens_used }.by(150)
      expect(ledger.balance).to eq(750) # 1000 - (100+150) = 750
    end

    it 'does nothing when amount is 0 or negative' do
      expect { ledger.debit!(0) }.not_to change { ledger.reload.tokens_used }
      expect { ledger.debit!(-50) }.not_to change { ledger.reload.tokens_used }
    end
  end
end

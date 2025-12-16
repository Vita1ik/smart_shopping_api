require 'rails_helper'

describe Scrapers::Miraton::GetShoePrice do
  let(:scraper) { described_class.new(shoe) }

  let(:shoe) { create(:shoe, product_url: 'https://www.miraton.ua/ua/catalog/men/shoes/krossovki_new_balance_000208981/') }

  describe '#run' do
    subject(:run) { scraper.run }

    it { run }
  end
end
require 'rails_helper'

describe Scrapers::Rozetka::GetShoePrice do
  let(:scraper) { described_class.new(shoe) }

  let(:shoe) { create(:shoe, product_url: 'https://rozetka.com.ua/ua/lacoste-5059862479894/p484977239/') }

  describe '#run' do
    subject(:run) { scraper.run }

    it { run }
  end
end
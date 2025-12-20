require 'rails_helper'

describe Scrapers::Miraton::Scraper do
  let(:scraper) { described_class.new(search) }

  let(:brand) { create(:brand, name: 'Adidas') }
  let(:size) { create(:size, name: '42') }
  let(:color) { create(:color, name: 'чорний') }
  let(:category) { create(:category, name: 'кросівки') }
  let(:target_audience) { create(:target_audience, name: 'men') }

  let(:search) do
    create(:search,
           brands: [brand],
           sizes: [size],
           colors: [color],
           categories: [category],
           target_audiences: [target_audience],
           price_min: 2000,
           price_max: 8000
    )
  end

  describe '#run' do
    subject(:run) { scraper.run }

    it { run }
  end
end
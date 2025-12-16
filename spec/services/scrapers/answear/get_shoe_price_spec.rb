require 'rails_helper'

describe Scrapers::Answear::GetShoePrice do
  let(:scraper) { described_class.new(shoe) }

  let(:shoe) { create(:shoe, product_url: 'https://answear.ua/p/krosivky-stepney-workers-club-osier-s-strike-suede-mix-kolir-chornyj-yp02015-1369212') }

  describe '#run' do
    subject(:run) { scraper.run }

    it { run }
  end
end
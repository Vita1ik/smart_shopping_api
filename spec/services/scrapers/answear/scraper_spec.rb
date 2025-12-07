require 'rails_helper'

describe Scrapers::Answear::Scraper do
  let(:scraper) { described_class.new }

  describe '#run' do
    subject(:run) { scraper.run }

    it { run }
  end
end
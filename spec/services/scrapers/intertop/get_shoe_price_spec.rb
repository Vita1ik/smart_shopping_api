require 'rails_helper'

describe Scrapers::Intertop::GetShoePrice do
  let(:scraper) { described_class.new(shoe) }

  let(:shoe) { create(:shoe, product_url: 'https://intertop.ua/uk-ua/product/sneakers-adidas-8294071/') }

  describe '#run' do
    subject(:run) { scraper.run }

    it { run }
  end
end
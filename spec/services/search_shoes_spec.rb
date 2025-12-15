require 'rails_helper'

RSpec.describe SearchShoes do
  # --- 1. Setup Test Data ---
  let(:user) { create(:user) }

  # Ensure you have these factories created in spec/factories/
  let!(:search) { create(:search, user:, **search_params) }
  let!(:brand) { create(:brand) }
  let!(:size) { create(:size) }
  let!(:category) { create(:category) }
  let!(:color) { create(:color) }
  let!(:target_audience) { create(:target_audience) }
  let(:search_params) do
    {
      brand_ids: [brand.id],
      size_ids: [size.id],
      category_ids: [category.id],
      color_ids: [color.id],
      target_audience_ids: [target_audience.id],
      price_min: 1000,
      price_max: 5000
    }
  end

  before do
    described_class::SCRAPERS.keys.each { |name| create(:source, name:)  }
  end

  subject { described_class.new(search, :rozetka) }

  it { subject.call; binding.pry }

  # let(:mock_scraped_results) do
  #   [
  #     OpenStruct.new(
  #       title: 'Nike Air Max 90',
  #       price: '3500',
  #       link: 'https://intertop.ua/ua/product/nike-air-max-90',
  #       images: ['https://img.intertop.ua/1.jpg', 'https://img.intertop.ua/2.jpg']
  #     ),
  #     OpenStruct.new(
  #       title: 'Adidas Ultraboost',
  #       price: '4200',
  #       link: 'https://intertop.ua/ua/product/adidas-ultraboost',
  #       images: ['https://img.intertop.ua/3.jpg']
  #     )
  #   ]
  # end
  #
  # let(:scraper_double) { instance_double(Scrapers::Intertop::Scraper) }
  #
  # before do
  #   # Intercept the call to Scrapers::Intertop::Scraper.new(...)
  #   allow(Scrapers::Intertop::Scraper).to receive(:new).and_return(scraper_double)
  #
  #   # Force the .run method to return our fake data immediately
  #   allow(scraper_double).to receive(:run).and_return(mock_scraped_results)
  # end

  # --- 3. Tests ---
  # describe '#call' do
  #   context 'when parameters are valid' do
  #     it 'creates a new Search record' do
  #       expect { subject.call }.to change(Search, :count).by(1)
  #     end
  #
  #     it 'associates the Search with the User' do
  #       subject.call
  #       expect(Search.last.user).to eq(user)
  #     end
  #
  #     it 'creates Shoe records based on the scraper results' do
  #       # We mocked 2 items in `mock_scraped_results`, so we expect 2 shoes
  #       expect { subject.call }.to change(Shoe, :count).by(2)
  #     end
  #
  #     it 'correctly saves the shoe attributes' do
  #       subject.call
  #
  #       # Check the first shoe (Nike)
  #       shoe = Shoe.find_by(name: 'Nike Air Max 90')
  #
  #       expect(shoe).to be_present
  #       expect(shoe.price).to eq(3500)
  #       expect(shoe.product_url).to eq('https://intertop.ua/ua/product/nike-air-max-90')
  #       expect(shoe.images).to contain_exactly('https://img.intertop.ua/1.jpg', 'https://img.intertop.ua/2.jpg')
  #
  #       # Check that it mapped the Filter IDs correctly from params
  #       expect(shoe.brand_id).to eq(brand.id)
  #       expect(shoe.size_id).to eq(size.id)
  #       expect(shoe.category_id).to eq(category.id)
  #       expect(shoe.color_id).to eq(color.id)
  #       expect(shoe.target_audience_id).to eq(target_audience.id)
  #     end
  #
  #     it 'saves the results array into the Search record' do
  #       subject.call
  #       # Assuming your Search model has a `results` JSONB column
  #       expect(Search.last.results).not_to be_empty
  #     end
  #   end
  #
  #   context 'when the Search model validation fails' do
  #     before do
  #       # Force the Search model to be invalid/fail saving
  #       allow_any_instance_of(Search).to receive(:save).and_return(false)
  #       allow_any_instance_of(Search).to receive_message_chain(:errors, :full_messages).and_return(["Something went wrong"])
  #     end
  #
  #     it 'does not create a Search record' do
  #       expect { subject.call }.not_to change(Search, :count)
  #     end
  #
  #     it 'does not create any Shoe records' do
  #       expect { subject.call }.not_to change(Shoe, :count)
  #     end
  #
  #     it 'populates the errors array' do
  #       subject.call
  #       expect(subject.errors).to include("Something went wrong")
  #     end
  #   end
  # end
end
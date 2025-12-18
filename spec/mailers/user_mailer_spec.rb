require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "discount_alert" do
    # Create mock objects to isolate the test from the database
    let(:user) { double('User', email: 'user@example.com') }
    let(:shoe) { double('Shoe', name: 'Nike Air Max', product_url: 'http://example.com/shoe', images: ['http://example.com/shoe_image']) }

    # Define prices for the test case (20% discount)
    let(:current_price) { 80 }
    let(:previous_price) { 100 }

    let(:mailmail) { UserMailer.discount_alert(user, shoe, current_price, previous_price) }

    it "renders the headers" do
      # 80 is 20% less than 100, so we expect "20% off"
      expect(mail.subject).to eq("Price Drop! Nike Air Max is now 20% off")
      expect(mail.to).to eq(["user@example.com"])
      expect(mail.from).to eq(["notifications@yourshoestore.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Nike Air Max")
    end
  end
end
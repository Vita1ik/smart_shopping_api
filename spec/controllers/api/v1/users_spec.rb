require 'rails_helper'

RSpec.describe "Api::V1::Users", type: :request do
  # Use a factory to create a user (assuming you have a 'user' factory)
  let(:user) { create(:user) }

  # Helper to parse JSON responses
  let(:json) { JSON.parse(response.body) }

  # ---------------------------------------------------------------
  # GET /api/v1/user (Show Profile)
  # ---------------------------------------------------------------
  describe "GET /api/v1/user" do
    context "when user is authenticated" do
      before do
        sign_in user # Devise helper
        get api_v1_user_path # OR get '/api/v1/user'
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it "returns the correct JSON structure from the Presenter" do
        # Verify specific fields returned by Presenters::User
        expect(json).to include(
                          'email' => user.email,
                          'first_name' => user.first_name,
                          'avatar_url' => a_value
                        )
      end
    end

    context "when user is NOT authenticated" do
      before { get api_v1_user_path, as: :json }

      it "returns unauthorized status" do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  # ---------------------------------------------------------------
  # PATCH /api/v1/user (Update Profile)
  # ---------------------------------------------------------------
  describe "PATCH /api/v1/user" do
    let(:valid_attributes) do
      {
        first_name: "New Name",
        last_name: "New Last Name",
        size_id: create(:size).id, # Assuming you have a Size factory
        target_audience_id: create(:target_audience).id
      }
    end

    let(:invalid_attributes) do
      # Assuming you have a validation (e.g., size_id must exist)
      # If you don't have model validations yet, this test might pass with 200,
      # so ensure your User model has validates :first_name, presence: true etc.
      { size_id: 999999 }
    end

    context "when user is authenticated" do
      before { sign_in user }

      context "with valid parameters" do
        before do
          patch api_v1_user_path, params: valid_attributes
        end

        it "updates the user" do
          user.reload
          expect(user.first_name).to eq("New Name")
          expect(user.last_name).to eq("New Last Name")
        end

        it "returns http ok" do
          expect(response).to have_http_status(:ok)
        end

        it "returns the updated object as JSON" do
          expect(json['first_name']).to eq("New Name")
        end
      end

      context "with invalid parameters" do
        before do
          patch api_v1_user_path, params: invalid_attributes
        end

        it "does not update the user" do
          # Assuming the update failed, the size_id should remain nil or whatever it was
          user.reload
          expect(user.size_id).not_to eq(999999)
        end

        it "returns unprocessable entity" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns error messages" do
          # Expecting { "errors": { "size": ["must exist"] } }
          expect(json['errors']).to be_present
        end
      end

      context "with unpermitted parameters" do
        it "does not allow updating sensitive fields (e.g. email)" do
          original_email = user.email
          patch api_v1_user_path, params: { email: "hacker@example.com" }

          user.reload
          expect(user.email).to eq(original_email)
        end
      end
    end

    context "when user is NOT authenticated" do
      it "returns unauthorized" do
        patch api_v1_user_path, params: { first_name: "Hack" }, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
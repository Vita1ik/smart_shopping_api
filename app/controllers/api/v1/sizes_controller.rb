module Api
  module V1
    class SizesController < ApiController
      before_action :authenticate_user!

      def index
        render json: Size.all.map { Presenters::Base.new(_1).as_json }
      end
    end
  end
end

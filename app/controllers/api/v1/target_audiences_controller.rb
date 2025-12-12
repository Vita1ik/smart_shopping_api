module Api
  module V1
    class TargetAudiencesController < ApiController
      before_action :authenticate_user!

      def index
        render json: TargetAudience.all.map { Presenters::Base.new(_1).as_json }
      end
    end
  end
end

module Api
  module V1
    class TargetAudiencesController < ApiController
      before_action :authenticate_user!

      def index
        render json: TargetAudience.all.map { { id: _1.id, name: _1.display_name } }
      end
    end
  end
end

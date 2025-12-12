module Presenters
  class User < Presenters::BasePresenter
    def as_json
      {
        first_name: resource.first_name,
        avatar_url: resource.avatar,
        email: resource.email,
        size: Presenters::Size.new(resource.size).as_json,
        target_audience: Presenters::TargetAudience.new(resource.target_audience).as_json,
      }
    end

    private

    attr_reader :user
  end
end
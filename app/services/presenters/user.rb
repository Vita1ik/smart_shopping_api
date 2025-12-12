module Presenters
  class User < Presenters::Base
    def as_json
      {
        first_name: resource.first_name,
        avatar_url: resource.avatar,
        email: resource.email,
        size: Presenters::Base.new(resource.size).as_json,
        target_audience: Presenters::Base.new(resource.target_audience).as_json,
      }
    end

    private

    attr_reader :user
  end
end
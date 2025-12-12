module Presenters
  class BasePresenter
    def initialize(resource)
      @resource = resource
    end

    def as_json
      raise NotImplementedError
    end

    private

    attr_reader :resource
  end
end
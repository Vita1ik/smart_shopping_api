module Presenters
  class Base
    def initialize(resource)
      @resource = resource
    end

    def as_json = resource&.attributes

    private

    attr_reader :resource
  end
end
module Presenters
  class Size < Presenters::BasePresenter
    def as_json = resource&.attributes
  end
end
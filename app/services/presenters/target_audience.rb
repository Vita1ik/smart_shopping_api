module Presenters
  class TargetAudience < Presenters::BasePresenter
    def as_json = resource&.attributes
  end
end
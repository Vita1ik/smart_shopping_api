module Presenters
  class Shoe < Presenters::Base
    def as_json
      {
        id: resource.id,
        images: resource.images,
        name: resource.name,
        price: resource.price
      }
    end
  end
end
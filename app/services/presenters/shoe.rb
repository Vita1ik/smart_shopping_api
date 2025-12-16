module Presenters
  class Shoe < Presenters::Base
    def as_json
      {
        id: resource.id,
        images: resource.images,
        name: resource.name,
        price: resource.price,
        product_url: resource.product_url
      }
    end
  end
end
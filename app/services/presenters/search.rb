module Presenters
  class Search < Presenters::Base
    def as_json
      {
        id: resource.id,
        price_min: resource.price_min,
        price_max: resource.price_max,

        # filters / associations
        brands: resource.brands.map(&:name),
        sizes: resource.sizes.map(&:name),
        colors: resource.colors.map(&:name),
        categories: resource.categories.map(&:name),
        target_audiences: resource.target_audiences.map(&:name),
      }
    end
  end
end
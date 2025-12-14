ActiveAdmin.register Category do
  permit_params :name, :slug

  active_admin_import before_batch_import: ->(importer) {
    csv_headers = importer.headers.keys

    name_index = csv_headers.index('name')

    if name_index
      importer.headers['slug'] = :slug

      importer.csv_lines.each do |row|
        name_value = row[name_index]

        if name_value.present?
          row << name_value.parameterize
        end
      end
    end
  }

  filter :name
  filter :slug
end

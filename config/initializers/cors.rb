# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # In development, you can allow all origins ('*')
    # In production, replace '*' with your actual frontend URL (e.g., 'https://myapp.netlify.app')
    origins '*'

    resource '*',
             headers: :any,
             # CRITICAL: You must allow OPTIONS here
             methods: [:get, :post, :put, :patch, :delete, :options, :head],
             # If you send the Token in the header, you might need to expose it
             expose: ['Authorization']
  end
end
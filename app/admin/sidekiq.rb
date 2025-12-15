ActiveAdmin.register_page 'Sidekiq' do
  menu label: 'Sidekiq',
       url: -> { sidekiq_web_path }
end

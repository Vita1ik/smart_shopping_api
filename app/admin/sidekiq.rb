ActiveAdmin.register_page 'Sidekiq' do
  menu label: 'Sidekiq', parent: 'Administration', priority: 1,
       url: -> { sidekiq_web_path }
end

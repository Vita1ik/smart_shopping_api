RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with :truncation
    Rails.application.load_seed
  end

  config.around do |example|
    DatabaseCleaner.strategy = cleaning_strategy(example)
    run_with_cleaning(example)
  end

  def cleaning_strategy(example)
    return :truncation if clean_with_truncation?(example)

    :transaction
  end

  def clean_with_truncation?(example)
    example.metadata[:js] == true || example.metadata[:cleaner] == :truncation
  end

  def run_with_cleaning(example)
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end

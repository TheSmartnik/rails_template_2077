gem 'interactor'
gem 'interactor-rails'

gem 'typhoeus' if yes?('Add typhoeus?')

additional_gems = ask('Any gems you want to add(separate with whitespace)?')
if additional_gems.present?
  additional_gems.split(' ').each do |gem_name|
    gem gem_name
  end
end

gem_group :development, :test do
  gem 'pry'
  gem 'rspec-rails'
  gem 'factory_bot' #🤦‍♀️
  gem 'factory_bot_rails'
end


after_bundle do
  generate('rspec:init')

  rails_command("db:create")

  model_to_generate = ask('Any models you want to generate right away(separate with whitespace)?')
  if model_to_generate.present?
    model_to_generate.split(' ').each do |model|
      columns = ask('Columns: (separate with whitespace)')
      generate(:model, "#{model} columns")
    end
  end

  rails_command("db:migrate")

  git :init
  git add: '.'
  git commit: %Q{ -m 'Initial commit' }
end

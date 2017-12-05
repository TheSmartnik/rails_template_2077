gem 'interactor'
gem 'interactor-rails'

add_vcr if yes?('Add VCR?')

additional_gems = ask('Any gems you want to add(separate with whitespace)?')
if additional_gems.present?
  additional_gems.split(' ').each do |gem_name|
    gem gem_name
  end
end

gem_group :development, :test do
  gem 'pry'
  gem 'rspec-rails'
  gem 'factory_bot'
  gem 'factory_bot_rails'
end

file 'spec/support/factory_bot.rb',  <<-CODE
  RSpec.configuration.include FactoryBot::Syntax::Methods
CODE

after_bundle do
  generate('rspec:install')

  require_support_dir_in_specs

  rails_command("db:create")

  generate_extra_models

  rails_command("db:migrate")

  git :init
  git add: '.'
  git commit: %Q{ -m 'Initial commit' }
end

def require_support_dir_in_specs
  file_path = "#{destination_root}/spec/rails_helper.rb"
  line_to_replace = "Dir[Rails.root.join('spec/support/**/*.rb')]"
  text = File.read(file_path).gsub("# #{line_to_replace}", line_to_replace)
  File.open(file_path, 'w') { |f| f << file_path }
end

def generate_extra_models
  model_to_generate = ask('Any models you want to generate right away(separate with whitespace)?')

  if model_to_generate.present?
    model_to_generate.split(' ').each do |model|
      columns = ask("Columns for #{model}: (separate with whitespace)")
      generate(:model, "#{model} #{columns}")
    end
  end
end

def add_vcr
  gem 'webmock'
  gem 'vcr'

  file 'spec/support/vcr.rb',  <<-CODE
    RSpec.configure do
      VCR.configure do |config|
        config.cassette_library_dir = Rails.root.join('spec/fixtures/vcr_cassettes')
        config.hook_into :webmock
        config.configure_rspec_metadata!
        config.allow_http_connections_when_no_cassette = false
        config.ignore_localhost = true
      end
    end
  CODE
end

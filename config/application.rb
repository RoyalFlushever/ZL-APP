require_relative 'boot'
require 'rails/all'
require 'csv'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Zlapp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    # setup bower components folder for lookup
    config.assets.paths << Rails.root.join('vendor', 'assets', 'bower_components', 'lib')
    config.assets.paths << Rails.root.join('app', 'assets', 'videos')
    # fonts
    config.assets.precompile << /\.(?:svg|eot|woff|ttf)$/
    # images
    config.assets.precompile << /\.(?:png|jpg)$/
    # precompile vendor assets
    config.assets.precompile += %w( base.js )
    config.assets.precompile += %w( base.css )
    config.assets.precompile += %w( select.dataTables.min.css )
    # precompile themes
    config.assets.precompile += [
      'wraith/themes/theme-a.css',
      'jquery.fileupload.css',
    ]
    # Controller assets
    config.assets.precompile += [
                                 # Scripts
                                 'forms.js',
                                 'tables.js',
                                 
                                 #for controller
                                 'index.js',
                                 'upload.js',
                                 'companies.js',
                                 'progress.js',
                                 'result.js',
                                 'charges.js'
                               ]
  end
end

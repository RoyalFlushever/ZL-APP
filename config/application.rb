require_relative 'boot'

require 'rails/all'

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
    # precompile themes
    config.assets.precompile += [
      'wraith/themes/theme-a.css',
    #                              'angle/themes/theme-b.css',
    #                              'angle/themes/theme-c.css',
    #                              'angle/themes/theme-d.css',
                                 # 'wraith/themes/theme-e.css'
                                 # 'angle/themes/theme-f.css',
                                 # 'angle/themes/theme-g.css',
                                 # 'angle/themes/theme-h.css'
                               ]
    # Controller assets
    config.assets.precompile += [
                                 # Scripts
                                 'forms.js',
                                 'tables.js',
                                 #for controller
                                 'index.js'
                               ]

  end
end

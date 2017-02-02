require_relative 'boot'

require 'rails'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'

require 'asutils'
require_relative 'initializers/plugins'

# Maybe we won't need these?

# DISABLED BY MST # require 'active_record/railtie'
# DISABLED BY MST # require 'action_mailer/railtie'
# DISABLED BY MST # require 'active_job/railtie'
# DISABLED BY MST # require 'action_cable/engine'
# DISABLED BY MST # require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ArchivesspacePublic
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Add plugin controllers and models
    config.paths["app/controllers"].concat(ASUtils.find_local_directories("public/controllers"))
    config.paths["app/models"].concat(ASUtils.find_local_directories("public/models"))

    # Load the shared 'locales'
    ASUtils.find_locales_directories.map{|locales_directory| File.join(locales_directory)}.reject { |dir| !Dir.exist?(dir) }.each do |locales_directory|
      config.i18n.load_path += Dir[File.join(locales_directory, '**' , '*.{rb,yml}')]
    end

    I18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]

    # Allow overriding of the i18n locales via the 'local' folder(s)
    if not ASUtils.find_local_directories.blank?
      ASUtils.find_local_directories.map{|local_dir| File.join(local_dir, 'public', 'locales')}.reject { |dir| !Dir.exist?(dir) }.each do |locales_override_directory|
        I18n.load_path += Dir[File.join(locales_override_directory, '**' , '*.{rb,yml}')]
      end
    end

    # Add template static assets to the path
    if not ASUtils.find_local_directories.blank?
      ASUtils.find_local_directories.map{|local_dir| File.join(local_dir, 'public', 'assets')}.reject { |dir| !Dir.exist?(dir) }.each do |static_directory|
        config.assets.paths.unshift(static_directory)
      end
    end
  end
end

# Load plugin init.rb files (if present)
ASUtils.find_local_directories('public').each do |dir|
  init_file = File.join(dir, "plugin_init.rb")
  if File.exist?(init_file)
    load init_file
  end
end
Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true
 #config.consider_all_requests_local = false # changed by CdLB
  # See: https://wyeworks.com/blog/2016/1/12/improvements-to-error-responses-in-rails-5-api-mode
  # Changing consider_all_requests_local to false was required in order to get json error
  # messages instead of html error page in development mode.
  debug_exception_response_format = :api     # added by CdLB for API mode.

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => 'public, max-age=172800'
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # Provide a 32-bit password salt instead of "encrypted cookie"
 #config.action_dispatch.encrypted_cookie_salt = "F7yGgRAvn83J8O8dcnrtj+B6OOr5tKbxV+YmexmunXk="
 #config.action_dispatch.encrypted_cookie_salt = "\xFFE\xDF\x91\x94\x18\x01\r\x8B\xC2\xE2B3`S2\xA8N\xBC\xE68Q&\xB7`/\xC1rXv\xEFC"
  config.action_dispatch.encrypted_cookie_salt = "pRaj41IblAGnz070x8vfIX1pmqHp7PaZ8kVA9NZJAe3AxThaHrUwuIeXmR5RaQ1F1acPpc7IW-jXqtkztQ2Zng"
end

if defined?(Rails)
  I18n.load_path += Dir[File.dirname(__FILE__) + "/../../locales/**/*.yml"]

  if Rails.version >= "3"
    require "active_record"
    require "password_strength/active_record/ar3"
  else
    require "password_strength/active_record/ar2"
  end
end

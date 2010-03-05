if defined?(Rails)
  if Rails.version >= "3"
    require "active_record"
    require "password_strength/active_record/ar3"
  else
    require "password_strength/active_record/ar2"
  end
end

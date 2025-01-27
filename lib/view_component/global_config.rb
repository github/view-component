module ViewComponent
  GlobalConfig = (defined?(Rails) && Rails.application) ? Rails.application.config.view_component : Config.defaults # standard:disable Naming/ConstantName
end

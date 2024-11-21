begin
  config_file = Rails.root.join("config/common_tags.yml")
  if File.exist?(config_file)
    COMMON_TAGS_CONFIG = YAML.load_file(config_file)[Rails.env]
    Rails.application.config.common_tags = if COMMON_TAGS_CONFIG
      COMMON_TAGS_CONFIG.fetch("common_tags", [])
    else
      []
    end
  else
    Rails.logger.warn "Common tags configuration file not found at #{config_file}"
    Rails.application.config.common_tags = []
  end
rescue => e
  Rails.logger.error "Error loading common tags configuration: #{e.message}"
  Rails.application.config.common_tags = []
end

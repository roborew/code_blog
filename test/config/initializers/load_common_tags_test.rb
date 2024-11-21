require "test_helper"

class LoadCommonTagsTest < ActiveSupport::TestCase
  def setup
    @config_file = Rails.root.join("config/common_tags.yml")
    # Clean up any existing file before each test
    File.delete(@config_file) if File.exist?(@config_file)
    # Store original logger
    @original_logger = Rails.logger
    # Create a string buffer for capturing log messages
    @log_buffer = StringIO.new
    Rails.logger = Logger.new(@log_buffer)
  end

  def teardown
    # Clean up after each test
    File.delete(@config_file) if File.exist?(@config_file)
    # Restore original logger
    Rails.logger = @original_logger
  end

  def test_initializer_loads_config
    yaml_content = {
      "test" => { "common_tags" => ["tag1", "tag2"] }
    }
    File.write(@config_file, yaml_content.to_yaml)

    load Rails.root.join("config/initializers/load_common_tags.rb")
    assert_equal ["tag1", "tag2"], Rails.application.config.common_tags
  end

  def test_initializer_handles_missing_config_file
    load Rails.root.join("config/initializers/load_common_tags.rb")
    
    assert_equal [], Rails.application.config.common_tags
    assert_includes @log_buffer.string, "Common tags configuration file not found at #{@config_file}"
  end

  def test_initializer_handles_yaml_parse_error
    File.write(@config_file, ": invalid: yaml: content")

    load Rails.root.join("config/initializers/load_common_tags.rb")
    
    assert_equal [], Rails.application.config.common_tags
    assert_includes @log_buffer.string, "Error loading common tags configuration:"
  end
end

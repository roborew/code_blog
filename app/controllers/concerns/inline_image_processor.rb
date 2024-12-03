module InlineImageProcessor
  extend ActiveSupport::Concern

  def process_inline_images(content)
    return content unless current_record

    content.gsub(/!\[([^\]]*)\]\((https?:\/\/[^\/]+\/temp-file\/([^\)]+))\)/) do |match|
      alt_text = $1
      filename = $3

      begin
        # Get the file directly from tmp/uploads directory
        base_filename = filename.split(".").first
        file_path = Rails.root.join("tmp/uploads").glob("#{base_filename}.*").first

        if file_path && File.exist?(file_path)
          decoded_data = File.binread(file_path)
          content_type = Marcel::MimeType.for(file_path)

          image = current_record.content_images.attach(
            io: StringIO.new(decoded_data),
            filename: "#{SecureRandom.uuid}#{File.extname(file_path)}",
            content_type: content_type
          ).first

          "![#{alt_text}](#{rails_blob_url(image)})\r\n"
        else
          Rails.logger.error "Temp file not found: #{filename}"
          match
        end
      rescue => e
        Rails.logger.error "Error processing image: #{e.class} - #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        match
      end
    end
  end

  private

  def current_record
    @article || @page
  end
end

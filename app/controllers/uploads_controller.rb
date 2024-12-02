class UploadsController < ApplicationController
  def upload_image
    unless current_user
      render json: { error: "Unauthorized" }, status: :unauthorized and return
    end

    if params[:file].present?
      begin
        # Create a directory for temporary uploads if it doesn't exist
        tmp_uploads_dir = Rails.root.join("tmp/uploads")
        FileUtils.mkdir_p(tmp_uploads_dir)

        # Generate a unique filename
        filename = "#{SecureRandom.uuid}#{File.extname(params[:file].original_filename)}"
        file_path = tmp_uploads_dir.join(filename)

        # Save the file
        File.binwrite(file_path, params[:file].read)

        # Generate a URL for the temporary file
        temp_url = Rails.application.routes.url_helpers.serve_temp_file_url(
          filename: filename,
          host: request.base_url
        )

        render json: { url: temp_url }, status: :ok
      rescue => e
        Rails.logger.error("File upload error: #{e.message}")
        render json: { error: "File upload failed" }, status: :unprocessable_entity
      end
    else
      render json: { error: "No file provided" }, status: :unprocessable_entity
    end
  end

  def serve_temp_file
    unless current_user
      render json: { error: "Unauthorized" }, status: :unauthorized and return
    end

    base_filename = params[:filename].split(".").first
    matching_file = Rails.root.glob("tmp/uploads/#{base_filename}.*").first

    if matching_file && File.exist?(matching_file)
      send_file matching_file,
                disposition: "inline",
                type: Marcel::MimeType.for(matching_file)
    else
      render json: { error: "File not found" }, status: :not_found
    end
  end
end

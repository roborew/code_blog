namespace :cleanup do
  desc "Remove temporary files older than 24 hours"
  task temp_files: :environment do
    tmp_uploads_dir = Rails.root.join("tmp/uploads")
    return unless Dir.exist?(tmp_uploads_dir)

    Dir.glob(tmp_uploads_dir.join("*")).each do |file|
      if File.mtime(file) < 24.hours.ago
        File.delete(file)
        Rails.logger.info "Deleted temporary file: #{file}"
      end
    end
  end
end

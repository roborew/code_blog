class ArticlesController < ApplicationController
  require "open-uri"

  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_article, only: [ :show, :edit, :update, :destroy ]

  # GET /articles or /articles.json
  def index
    @articles = Article.all
  end

  # GET /articles/1 or /articles/1.json
  def show
  end

  # GET /articles/new
  def new
    @article = Article.new
    @existing_tags = []
  end

  # GET /articles/1/edit
  def edit
    Rails.logger.debug { "Editing Article ID: #{@article.id} - #{@article.title}" }
    @existing_tags = @article.tags.pluck(:name).map { |name| { "name" => name } }.to_json
    @existing_category = @article.category&.name
  end

  # POST /articles or /articles.json
  def create
    @article = current_user.articles.build(article_params)

    # Process inline images and attach them to content_images
    @article.content = process_inline_images(@article.content)

    respond_to do |format|
      if @article.save
        update_tags(@article)
        update_categories(@article)
        @article.save
        format.html { redirect_to @article, notice: t(".success") }
        format.json { render :show, status: :created, location: @article }
      else
        set_existing_tags_from_params
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /articles/1 or /articles/1.json
  def update
    respond_to do |format|
      # Process inline images and attach them to content_images
      article_params_with_processed_images = article_params
      article_params_with_processed_images[:content] = process_inline_images(article_params[:content])

      if @article.update(article_params_with_processed_images)
        update_tags(@article)
        update_categories(@article)
        @article.save
        format.html { redirect_to @article, notice: t(".success") }
        format.json { render :show, status: :ok, location: @article }
      else
        set_existing_tags_from_params
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /articles/1 or /articles/1.json
  def destroy
    @article.destroy!
    respond_to do |format|
      format.html { redirect_to articles_path, status: :see_other, notice: t(".success") }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_article
      @article = Article.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def article_params
      params.require(:article).permit(:title, :content, :status, :publication_date, :cover_image, :abstract)
    end

    def update_tags(article)
      if params[:tags].present?
        tag_objects = JSON.parse(params[:tags])
        tag_names = tag_objects.pluck("value")
        article.tags = tag_names.map { |name| Tag.find_or_create(name, current_user) }
      else
        article.tags.clear
      end
    end

    def update_categories(article)
      if params[:category].present?
        category_objects = JSON.parse(params[:category])
        category_names = category_objects.pluck("value")
        category = Category.find_or_create(category_names.first, current_user)
        article.category = category
      else
        article.category = nil
      end
    end

    def set_existing_tags_from_params
      if params[:tags].present?
        tag_objects = JSON.parse(params[:tags])
        @existing_tags = tag_objects.map { |t| { "name" => t["value"] } }.to_json
      end
    end

    def process_inline_images(content)
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

            image = @article.content_images.attach(
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
      end + "\r\n"
    end
end

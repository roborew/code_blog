class Articles::CoverImagesController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :authenticate_user!
  before_action :set_article

  def destroy
    @article.cover_image.purge_later
    respond_to do |format|
      format.html { redirect_to edit_article_path(@article) }
      format.turbo_stream { render turbo_stream: turbo_stream.remove(dom_id(@article, :cover_image)) }
    end
  end

  private

  def set_article
    @article = Article.find(params[:article_id])
  end
end

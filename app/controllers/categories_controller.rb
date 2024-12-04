class CategoriesController < ApplicationController
  def search
    query = params[:q]
    categories = Category.where("name ILIKE ?", "%#{query}%")
                          .where("user_id IS NULL OR user_id = ?", current_user.id)
                          .limit(10)
                          .pluck(:name)

    render json: categories
  end

  def index
    @categories = Category.left_joins(:articles)
                         .select("categories.*, COUNT(articles.id) as articles_count")
                         .group("categories.id")
                         .order("articles_count DESC, categories.name ASC")
  end

  def show
  end

  def new
  end

  def edit
  end
end

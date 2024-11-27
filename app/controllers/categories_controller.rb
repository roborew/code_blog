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
  end

  def show
  end

  def new
  end

  def edit
  end
end

class TagsController < ApplicationController
  def search
    query = params[:q]
    tags = Tag.where("name ILIKE ?", "%#{query}%")
              .where("user_id IS NULL OR user_id = ?", current_user.id)
              .limit(10)
              .pluck(:name)

    render json: tags
  end
end

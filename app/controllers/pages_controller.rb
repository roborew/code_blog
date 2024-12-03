class PagesController < ApplicationController
  before_action :set_page, only: %i[show edit update destroy]

  def index
    @pages = Page.all
  end

  def show
  end

  def new
    @page = Page.new
  end

  def edit
  end
  def create
    @page = Page.new(page_params)
    if @page.save
      redirect_to @page, notice: t('.success')
    else
      render :new
    end
  end


  def update
    if @page.update(page_params)
      redirect_to @page, notice: t('.success')
    else
      render :edit
    end
  end

  def destroy
    @page.destroy
    redirect_to pages_url, notice: t('.success')
  end

  private

  def set_page
    @page = Page.friendly.find(params[:id])
  end

  def page_params
    params.require(:page).permit(:title, :content)
  end
end

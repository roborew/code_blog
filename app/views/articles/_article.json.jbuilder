json.extract! article, :id, :title, :content, :publication_date, :created_at, :updated_at
json.url article_url(article, format: :json)

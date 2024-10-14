  # This file should ensure the existence of records required to run the application in every environment (production,
  # development, test). The code here should be idempotent so that it can be executed at any point in every environment.
  # The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
  #
  # Example:
  #
  #   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
  #     MovieGenre.find_or_create_by!(name: genre_name)
  #   end

  # Create a user
  user = User.create!(
    email: 'user@example.com',
    password: 'password',
    password_confirmation: 'password'
  )

  # Create 10 articles
  10.times do |i|
    Article.create!(
      title: "Article Title #{i + 1}",
      content: "This is the content for article #{i + 1}.",
      #  published_date: Date.current,
      user: user
    )
  end

#  # Delete all articles
#  Article.delete_all

#  # Delete specific user
#  User.find_by(email: 'user@example.com')&.destroy

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "\n== Seeding the database with fixtures =="
system("bin/rails db:fixtures:load")

User.all.each do |user|
  20.times do |i|
    expense = Expense.create!(description: "expense for something #{rand(100..10000)}", user: user, amount: rand(100..500))

    item = Item.create!(expense: expense, name: "Item for #{expense.description}", cost: expense.amount)

    Split.create!(user: user, item: item, amount: item.cost / 5)

    User.where.not(id: user.id).sample(4).each do |split_user|
      Split.create!(user: split_user, item: item, amount: item.cost / 5)
    end
  end
end


# gem install --version 1.3.0 sinatra
require 'pry'
gem 'sinatra', '1.3.0'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'
require "better_errors"

configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = File.expand_path("..", __FILE__)
end

before do
  # Need to make instance variable
  @db = SQLite3::Database.new "store.sqlite3"
  # Allows to use the key name as opposed to index number
  @db.results_as_hash = true
end

# Home page
get '/' do
  @users = '/users'
  @back = '/products'
  erb :home
end

# Display all users
get '/users' do
  @rs = @db.execute("SELECT * FROM users;")
  @back = '/'
  erb :show_users
end

# Display all products 
get '/products' do
  @on_sale = @db.execute("SELECT * FROM products WHERE on_sale = 't';")
  @rs = @db.execute("SELECT * FROM products;")
  @back = '/'
  erb :show_products
end

# Display a specific product
get '/products/:id' do
  @id = params[:id]
  @name = params[:name]
  @price = params[:product_price]
  @on_sale = params[:on_sale]
  sql = "SELECT * FROM products WHERE id = #{@id};"
  @row = @db.get_first_row(sql)
  erb :update_product
end

# Update product
post '/products/:id' do
  @id = params[:id]
  @name = params[:product_name]
  @price = params[:product_price]
  sql = "UPDATE products SET name='#{@name}', price=#{@price} WHERE id=#{@id};"
  @rs = @db.execute(sql)
  sql = "SELECT * FROM products WHERE id = #{@id};"
  @row = @db.get_first_row(sql)
  erb :update_product
end

# Create new product
post '/products' do
  @name = params[:product_name]
  @price = params[:product_price]
  sql = "INSERT INTO products ('name', 'price') VALUES ('#{name}', #{price});"
  @rs = @db.execute(sql)
  erb :created_product
end

# Delete product
post '/products/:id/destroy' do
end

# Return HTML form for creating new product
get '/product/new' do
  erb :new_product
end

# @rows = first item after select item to update
# put this in href for update button
# get '/product/:id/edit' do
#   @id
#   sql = SELECT * from products where id = @id
#   @row = @db.get_first_row(sql)
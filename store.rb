# gem install --version 1.3.0 sinatra
require 'pry'
gem 'sinatra', '1.3.0'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'
require 'better_errors'
require 'open-uri'
require 'json'
require 'uri'

#APIkey = AIzaSyDwnQ5cOPLODuEf-lJerLupLLxhYyPmRu8

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
  erb :home, :layout => false
end

# Display all users
get '/users' do
  @rs = @db.execute("SELECT * FROM users;")
  erb :show_users
end

get '/users.json' do
  # Only select info needed
  @rs = @db.execute("SELECT id, name FROM users;")
  # Convert to JSON
  @rs.to_json
end

# Display all products 
get '/products' do
  @rs = @db.execute("SELECT * FROM products;")
  erb :show_products
end

# Update product
post '/products/:id' do
  @id = params[:id]
  @name = params[:product_name]
  @price = params[:product_price]
  @on_sale = params[:on_sale]
  @action = "updated"
  @rs = @db.execute("UPDATE products SET name='#{@name}', price=#{@price}, on_sale='#{@on_sale}' WHERE id=#{@id};")
  @rs = @db.execute("SELECT * FROM products;")
  erb :confirmation
end

# Display a specific product
get '/products/:id' do
  @id = params[:id]
  @name = params[:name]
  @price = params[:product_price]
  @on_sale = params[:on_sale]
  @q = params[:q]
  file = open("https://www.googleapis.com/shopping/search/v1/public/products?key=AIzaSyDwnQ5cOPLODuEf-lJerLupLLxhYyPmRu8&country=US&q=#{URI.escape(@q)}&alt=json&maxResults=10",:ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE)
  # .read returns file as string
  @results = JSON.load(file.read)
  @row = @db.get_first_row("SELECT * FROM products WHERE id = #{@id};")
  erb :product_details
end

get '/products/:id/search' do
  # Query sting
  @id = params[:id]
  @name = params[:name]
  @q = params[:q]
  file = open("http://search.twitter.com/search.json?q=#{URI.escape(@q)}")
  # .read returns file as string
  @results = JSON.load(file.read)
  @row = @db.get_first_row("SELECT * FROM products WHERE id = #{@id};")
  erb :results_twitter, :layout => false
end

get '/product/new' do
  @rs = @db.execute("SELECT * FROM products;")
  erb :new_product
end

post '/new-product' do
  @name = params[:product_name]
  @price = params[:product_price]
  @on_sale = params[:on_sale]
  @rs = @db.execute("INSERT INTO products ('name', 'price', 'on_sale') VALUES('#{@name}', '#{@price}', '#{@on_sale}');")
  @rs = @db.execute("SELECT * FROM products;")
  erb :confirmation_added
end

# Display UI to update/delete specific product
get '/products/:id/edit' do
  @id = params[:id]
  @name = params[:name]
  @price = params[:product_price]
  @on_sale = params[:on_sale]
  @row = @db.get_first_row("SELECT * FROM products WHERE id = #{@id};")
  erb :update_product
end

# Display UI to update/delete specific product
get '/products/:id/destroy' do
  @id = params[:id]
  @name = params[:name]
  @price = params[:product_price]
  @on_sale = params[:on_sale]
  @row = @db.get_first_row("SELECT * FROM products WHERE id = #{@id};")
  erb :delete_product
end

# Delete product
post '/products/:id/destroy' do
  @id = params[:id]
  name = params[:product_name]
  @price = params[:product_price]
  @action = "deleted"
  @rs = @db.execute("DELETE FROM products WHERE id=#{@id};")
  @rs = @db.execute("SELECT * FROM products;")
  erb :confirmation
end

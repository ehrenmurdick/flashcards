require 'sinatra'
require "sqlite3"


db = SQLite3::Database.new "test.db"

# Create a table
rows = db.execute <<-SQL
  CREATE TABLE IF NOT EXISTS cards (
    front text,
    back text
  );
SQL


# I think this returns an Enumrable
# which means instead of a block you can probably just call #to_a
# so get rid of the do...end and relace it with .to_a
puts "this is line #{__LINE__} happening"


# GET :index
get '/' do
  #puts "this is line #{__LINE__} happening"
  flashcards = db.execute("select * from cards").to_a

  # get all the cards out of the db
  # put them into an array
  # render the index.html.erb with those cards passed in
  erb :index, locals: {flashcards: flashcards}
end


get '/new' do
  erb :new
end

post '/create' do
  db.execute("INSERT INTO cards (front, back) VALUES (?, ?)", params["flashcard_front"],params["flashcard_back"])

  redirect '/'
end

get '/study' do
  offset = (params[:offset] || 0).to_i
  flipped = params[:flipped] == "true"
  last = params[:last] == "true"

  if flipped
    card = db.execute("select front from cards limit 1 offset ?", offset).first.first
  elsif 
    card = db.execute("select back from cards limit 1 offset ?", offset).first.first
  else   
    card = db.execute("select back from cards order by front desc limit 1", offset)
  end
  erb :study, locals: {card: card, flipped: flipped, offset: offset, last: last}
end

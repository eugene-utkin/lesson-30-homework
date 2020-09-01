require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'

def init_db
  @db = SQLite3::Database.new 'blogposts.db'
  @db.results_as_hash = true
end

before do
  init_db
end

configure do
  init_db
  @db.execute 'CREATE TABLE IF NOT EXISTS Posts
  (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "created_date" DATE,
    "content" TEXT,
    "author" TEXT
  )'
  @db.execute 'CREATE TABLE IF NOT EXISTS Comments
  (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "created_date" DATE,
    "comment" TEXT,
    "post_id" INTEGER
  )'
end

get '/' do
  @results = @db.execute 'SELECT * FROM Posts ORDER BY id DESC'
  erb :index 
end

get '/new' do
  erb :new
end

post '/new' do
  
  @content = params[:content]
  @author = params[:author]

  hh = {  :author => 'Type author!',
          :content => 'Type text!'}

@error = hh.select {|key,_| params[key] == ""}.values.join("<br />")


  if @error != ''
    return erb :new
  end

  @db.execute 'insert into Posts (created_date, content, author) values (datetime(), ?, ?)', [@content, @author]

  redirect to '/'
end

get '/details/:post_id' do
  post_id = params[:post_id]

  results = @db.execute 'SELECT * FROM Posts WHERE id = ?', [post_id]
  @row = results[0]

  @comments = @db.execute 'SELECT * FROM Comments WHERE post_id = ? ORDER BY id', [post_id]

  erb :details
end

post '/details/:post_id' do
  post_id = params[:post_id]
  content = params[:content]
  author = params[:author]

  if content.length <= 0
    @error = 'Type comment!'
    results = @db.execute 'SELECT * FROM Posts WHERE id = ?', [post_id]
  @row = results[0]

  @comments = @db.execute 'SELECT * FROM Comments WHERE post_id = ? ORDER BY id', [post_id]
    return erb :details
  end

  @db.execute 'insert into Comments (created_date, comment, post_id) values (datetime(), ?, ?)', [content, post_id]

  redirect to ('/details/' + post_id)
end
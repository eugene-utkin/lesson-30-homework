require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'

set :database, {adapter: "sqlite3", database: "blogposts.db"}

class Post < ActiveRecord::Base
  validates :post, presence: true, length: { minimum: 3 }
  validates :author, presence: true
end

class Comment < ActiveRecord::Base
  validates :message, presence: true, length: { minimum: 3 }
end

before do
  @posts = Post.all
  @comments = Comment.all
end

get '/' do
  @results = Post.order('created_at DESC')
  erb :index 
end

get '/new' do
  @c = Post.new
  erb :new
end

post '/new' do

  @c = Post.new params[:post]
    if @c.save
      erb "<h2>Спасибо, вы опубликовали пост!</h2>"
      redirect to '/'
    else
      @error = @c.errors.full_messages.first
      erb :new
 end

  
end

get '/details/:post_id' do

  
  
  post_id = params[:post_id]

  results = Post.where(id: post_id)
  @row = results[0]

  @commentresults = Comment.where(post: post_id).order('created_at DESC')

  @d = Comment.new

  erb :details
end

post '/details/:post_id' do
  post_id = params[:post_id]
  results = Post.where(id: post_id)
  @row = results[0]

  @commentresults = Comment.where(post: post_id).order('created_at DESC')

  @d = Comment.new params[:comment]
  @d.post = post_id
    if @d.save
      erb "<h2>Спасибо за комментарий!</h2>"
      redirect to ('/details/' + post_id)
    else
      @error = @d.errors.full_messages.first
      erb :details
 end

end
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'
require 'uri'
require 'cgi'
require 'pry'

before do
  @genres = query_db('SELECT DISTINCT genre FROM videos;')
end

get '/' do
  erb :home
end

get '/videos' do
  @videos = query_db('SELECT * FROM videos;')
  erb :videos
end

get '/videos/new' do
  erb :new_video
end

post '/videos/create' do
  sql = "INSERT INTO videos (title, description, url, genre)
          VALUES ('#{params[:title]}', '#{params[:description]}', '#{params[:url]}', '#{params[:genre]}');"
  query_db(sql)
  redirect to('/videos')
end

post '/videos/update' do
  sql = "UPDATE videos SET
    title='#{params[:title].gsub("'", "''")}',
    description='#{params[:description].gsub("'", "''")}',
    url='#{params[:url].gsub("'", "''")}',
    genre='#{params[:genre].gsub("'", "''")}' WHERE id=#{params[:id]}"
  query_db(sql)
  redirect to("/video/#{params[:id]}")
end

get '/video/:id' do
  results = query_db("SELECT * FROM videos WHERE id=#{ params[:id] }")
  @video = results.first
  erb :video
end

get '/videos/:id/edit' do
  results = query_db("SELECT * FROM videos WHERE id=#{ params[:id] }")
  @video = results.first
  erb :edit_video
end

get '/videos/:id/delete' do
  query_db("DELETE FROM videos WHERE id=#{ params[:id] }")
  redirect to('/videos')
end

get '/videos/genre/:genre' do
  @videos = query_db("SELECT * FROM videos WHERE genre LIKE '#{params[:genre]}'")
  erb :videos
end

def query_db(sql)
  db = SQLite3::Database.open('videos.db')
  db.results_as_hash = true
  puts "SQL: #{ sql }"
  db.execute(sql)
end

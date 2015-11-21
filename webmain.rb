require 'sinatra'
require 'sinatra/reloader' if development?
require 'slim'
require 'sass'
require './database'
require './changer'

# Roadworrks display application
class RoadworksApp < Sinatra::Application
  if development?
    db = Database.connect_postgres 'roadworks'
  else
    db = Database.connect_via_path ENV['DATABASE_URL']
  end

  db.use_table 'roadworks'

  now = DateTime.now

  @roadworks = db.roadworks
               .where('start_date < ?', now + 7)
               .where('end_date > ?', now - 7)

  roadlist = @roadworks.select(:road).distinct.all.map { |works| works[:road] }

  # Sort the 'M'otorways before 'A' roads, and then
  # ... M2, M3, M20 ...
  # not M2, M20, M3

  @roadlist = roadlist.sort do |left, right|
    if left[0] != right[0]
      right[0] <=> left[0]
    else
      left[1..-1].to_i - right[1..-1].to_i
    end
  end

  class << self
    attr_reader :roadlist, :roadworks
  end

  def roads
    self.class.roadlist
  end

  def road_table
    self.class.roadworks
  end

  def like(location)
    loc = "%#{location}%"

    road_table.order(:end_date)
      .where(Sequel.ilike :location, loc)
      .or(Sequel.ilike :description, loc)
      .all
  end

  get('/css/style.css') { scss :style }

  get('/')              { slim :index }

  get '/road/:road' do
    @road_data = road_table.order(:end_date)
                 .where(road: params[:road])
                 .all

    slim :road_data, layout: false
  end

  get '/location/:location' do
    @road_data = like params[:location]
    slim :road_data, layout: false
  end

  private

  def data_file_date
    @data_file_date ||= if Sinatra::Application.development?
                          `heroku config:get DATA_FILE_DATE`.chomp
                        else
                          ENV['DATA_FILE_DATE']
                        end
  end
end

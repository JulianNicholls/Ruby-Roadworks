require 'sinatra'
require 'sinatra/reloader' if development?
require 'slim'
require 'sass'
require 'sequel'

CHANGES = {
  /jn/i           => 'Junction',
  /jct(\d)/i      => 'Junction \1',
  /j(\d)/i        => 'Junction \1',
  /jct jct/i      => 'Junction',
  /jct/i          => 'Junction',
  /SB/            => 'Southbound',
  /NB/            => 'Northbound',
  /WB/            => 'Westbound',
  /EB/            => 'Eastbound',
  /\bsouth/i      => 'South',
  /\bnorth/i      => 'North',
  /\bwest/i       => 'West',
  /\beast/i       => 'East',
  /hardshoulder/i => 'hard shoulder',
  %r{c/way}       => 'carriageway',
  /&/             => 'and'
}

def multi_gsub(str, changes, road)
  changes.each { |search, replace| str.gsub!(search, replace) }

  str.gsub(/#{road}/i, '')
end

# Roadworrks display application
class RoadworksApp < Sinatra::Application
  if development?
    db = Sequel.postgres('roadworks')
  else
    db = Sequel.connect ENV['DATABASE_URL']
  end

  now = DateTime.now
  @roadworks = db[:roadworks]
               .where('start_date < ?', now + 7)
               .where('end_date > ?', now - 7)
  roadlist = @roadworks.select(:road).distinct.all.map { |works| works[:road] }

  @roadlist = roadlist.sort do |left, right|
    if left[0] != right[0]
      right[0] <=> left[0]     # 'M'otorways before 'A' roads
    else
      left[1..-1].to_i - right[1..-1].to_i   # ...M2, M3, M20... not M2, M20, M3
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

    road_table
      .order(:end_date)
      .where(Sequel.ilike :location, loc)
      .or(Sequel.ilike :description, loc)
      .all
  end

  get('/css/style.css') { scss :style }

  get '/' do
    slim :index
  end

  get '/road/:road' do
    @road_data = road_table
      .order(:end_date)
      .where(road: params[:road])
      .all

    slim :road_data, layout: false
  end

  get '/location/:location' do
    @road_data = like params[:location]
    slim :road_data, layout: false
  end
end

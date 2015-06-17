require 'sinatra'
require 'sinatra/reloader' if development?
require 'slim'
require 'sass'
require 'sequel'

class RoadworksApp < Sinatra::Application

  CHANGES = {
    /jn/i           => 'Junction',
    /jct(\d)/i      => 'Junction \1',
    /j(\d)/i        => 'Junction \1',
    /jct jct/i      => 'Junction',
    /jct/i          => 'Junction',
    /SB/            => 'Southbound',
    /NB/            => 'Northbound',
    /hardshoulder/i => 'hard shoulder',
    %r{c/way}       => 'carriageway',
    /&/             => 'and'
  }

  db = Sequel.postgres('roadworks')
  @roadworks = db[:roadworks]
  roadlist = @roadworks.select(:road).distinct.all.map { |r| r[:road] }

  @roadlist = roadlist.sort { |a, b|
    if a[0] != b[0]
      b[0] <=> a[0]     # 'M'otorways before 'A' roads
    else
      a[1..-1].to_i - b[1..-1].to_i   # ...M2, M3, M20... rather than M2, M20, M3
    end
  }

  class << self
    attr_reader :roadlist, :roadworks
  end

  def roads
    self.class.roadlist
  end

  def road_table
    self.class.roadworks
  end

  def multi_gsub(str, changes, road)
    changes.each { |s, r| str.gsub!( s, r ) }

    str.gsub( /#{road}/i, '' )
  end

  get('/css/style.css') { scss :style }

  get '/' do
    slim :index
  end

  get '/road/:road' do
    @road_data = road_table.where(road: params[:road]).all
    slim :road_data, layout: false
  end

  get '/location/:location' do
    loc = "%#{params[:location]}%"
    @road_data = road_table.where(Sequel.ilike :location, loc).or(Sequel.ilike :description, loc).all
    slim :road_data, layout: false
  end
end

require 'sinatra'
require 'sinatra/reloader' if development?
require 'slim'
require 'sass'
require 'sequel'

class RoadworksApp < Sinatra::Application

  db = Sequel.postgres('roadworks')
  @roadworks = db[:roadworks]
  roadlist = @roadworks.select(:road).distinct.all.map { |r| r[:road] }

  @roadlist = roadlist.sort { |a, b|
    if a[0] != b[0]
      b[0] <=> a[0]
    else
      a[1..-1].to_i - b[1..-1].to_i
    end
  }

#  puts @roadlist.join ', '

  class << self
    attr_reader :roadlist, :roadworks
  end

  def roads
    self.class.roadlist
  end

  def road_table
    self.class.roadworks
  end

  get('/css/style.css') { scss :style }

  get '/' do
    slim :index
  end

  get '/road/:road' do
    @road_data = road_table.filter(road: params[:road]).all
    slim :road_data, layout:false
  end
end

__END__

@@style

body {
  background: white;
  color: #111;
  font-family: "Lucida Sans", "Lucida Grande", Lucida, sans-serif;
  font-size: 12pt;
  line-height: 15pt;
}

h1, h2 {
    font-size: 150%;
    color: #008;
    text-align: center;
    margin-bottom: .5ex;
}

h2 { font-size: 120%; }

p { font-family: Georgia, "New Century Schoolbook", "Nimbus Roman No9 L", serif; margin-bottom: 1ex; }

a {
    color: #44a;
    text-decoration: none;
    font-family: "Lucida Sans", "Lucida Grande", Lucida, sans-serif;

    &:hover { background-color: #ddf; }
}


/*** Header and Footer */

header {
    height: 120px;
    background: #f8f8f8 url('/header-bg.png') repeat-x;

    img  { float: left; margin: 10px; }
    h1   { letter-spacing: 0.08em; padding-top: 40px; font-size: 280%; }
}

footer {
    margin-top: 40px;
    background-color: #eee;
    overflow: hidden;
    height: 80px;
    line-height: 40px;
    padding: 0;

    small {
        text-align: center;
        font-size: 65%;
        clear: both;
        display: block;
    }

    img { margin: 10px 2em 0 10px; float: left; }

    nav {
        display: block;
        font-size: 80%;

        li { display: inline; float: left; width: 6em; }
    }
}


/*** Containers */

.container { width: 960px; margin: 0 auto }

div#form-holder {
    float: right;
    background-color: #ccc;
    padding: 10px;
    width: 385px;
    margin-left: 20px;
}

div#roadworks-info {
    clear: both;
    padding: 6px 10px;
    background-color: #dbb;
    color: #060;
    min-height: 200px;
    overflow: auto;
}

fieldset { padding: 0 20px 10px 20px; }

legend { color: #008; }

label {
    float: left;
    width: 8.5em;
    margin-top: 5px;
}

input, select {
    width: 50%;
    padding: 2px;
    font-size: 11pt;
    margin-top: 5px;
    display: block;         /* Safari defaults to inline-block which breaks 2-column label/field view */
}

article {       /* A road defaults */
    border: 5px solid white;
    border-radius: 15px;
    margin: 4px 0;
    padding: 5px 10px;
    background-color: #00af5d;
    color: white;

    p {
        font-family: "Lucida Sans", "Lucida Grande", Lucida, sans-serif;
        margin: 10px 20px;
    }

    h1 {    /* A road name */
        color: #ffe800;
        display: inline;
        font-size: 115%;
        font-weight: bold;
        margin-right: 10px;
    }

    &.m-way {
        background-color: #004fb0;

        h1 {
            color: White;
        }
    }
}

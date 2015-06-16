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
    @road_data = road_table.where(road: params[:road]).all
    slim :road_data, layout: false
  end

  get '/location/:location' do
    loc = "%#{params[:location]}%"
    @road_data = road_table.where(Sequel.ilike :location, loc).or(Sequel.ilike :description, loc).all
    slim :road_data, layout: false
  end
end

__END__

@@style

$bkgr: #222;
$text: #eee;
$form: #333;
$legend: #ddf;
$h1text: #008;
$h2text: #ff8;
$footer: #eee;
$header: #ddf;
$links: #ffd;
$footerlinks: #00c;
$roadworks: #333;
$a-road: #00af5d;
$m-way: #004fb0;

body {
  margin: 0;
  padding: 0;
  background: $bkgr;
  color: $text;
  font-family: "Lucida Sans", "Lucida Grande", Lucida, sans-serif;
  font-size: 12pt;
  line-height: 15pt;
}

h1, h2 {
    font-size: 150%;
    color: $h1text;
    text-align: center;
    margin-bottom: .5ex;
}

h2 {
    font-size: 120%;
    color: $h2text;
}

p { font-family: Georgia, "New Century Schoolbook", "Nimbus Roman No9 L", serif; margin-bottom: 1ex; }

a {
    color: $links;
    text-decoration: none;
    font-family: "Lucida Sans", "Lucida Grande", Lucida, sans-serif;

    &:hover { background-color: lighten($bkgr, 30%); }
}


/*** Header and Footer */

header {
    height: 120px;
    background: $footer url('/header-bg.png') repeat-x;

    img  { float: left; margin: 10px; }
    h1   { letter-spacing: 0.05em; padding-top: 40px; font-size: 280%; }
}

footer {
    margin-top: 40px;
    background-color: $footer;
    color: $bkgr;
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

    a {
      color: $footerlinks;

      &:hover { background-color: lighten($bkgr, 60%); }
    }

    img {
        margin: 10px 2em 0 10px;
        float: left;
    }

    nav {
        display: block;
        font-size: 80%;

        li {
            display: inline;
            float: left;
            width: 6em;
        }
    }
}


/*** Containers */

.container { width: 960px; margin: 0 auto }

div#form-holder {
    float: right;
    background-color: $form;
    padding: 10px;
    width: 385px;
    margin-left: 10px;
}

fieldset { padding: 0 20px 10px 20px; }

legend { color: $legend; }

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

div#roadworks-info {
    clear: both;
    padding: 6px 10px;
    background-color: $roadworks;
    color: $a-road;
    min-height: 200px;
    overflow: auto;
}

article {       /* A road defaults */
    border: 5px solid white;
    border-radius: 15px;
    margin: 5px 0;
    padding: 5px 10px;
    background-color: $a-road;
    color: white;

    span.delays { margin-left: 40px; }

    p {
        font-family: "Lucida Sans", "Lucida Grande", Lucida, sans-serif;
        margin: 10px 20px;
    }

    h1 {    /* A road name */
        color: #ffe800;
        display: inline;
        font-size: 115%;
        font-weight: bold;
        margin-right: 20px;
    }

    &.m-way {
        background-color: $m-way;

        h1 { color: White; }
    }
}

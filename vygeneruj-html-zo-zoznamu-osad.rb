# encoding: utf-8
require 'uri'
require 'open-uri'
require 'json'
require 'active_support/all' # todo: require class necessary for mb_chars method only
komunity = {}
okres = nil

Dir.glob('atlas-romskych-komunit/*.csv').each do |csv_filename|
  File.read(csv_filename).split("\n").each do |line|
    next if line.include?('KRAJ')
    next if line.include?('Charakteristiky')
    next if line.include?('Názov obce')
  
    if line.include?('OKRES')
      okres = line.split(';').first.strip[6..-1].split(' ').collect{|w| w.mb_chars.capitalize}.join ' '
      next
    end
  
    obec, _, lokalizacia_osidlenia, _, _,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_, pocet_obyvatelov, _   = line.split(';')
    if obec && obec.size > 0 && lokalizacia_osidlenia && lokalizacia_osidlenia.size == 0
      komunity["#{obec}, okres #{okres}"] = {:pocet_obyvatelov => pocet_obyvatelov.to_i}
    end

  end
end


uri = URI.parse('https://maps.googleapis.com/maps/api/geocode/json')
params = { 'key' => "AIzaSyBbMdumQYUCDgDZImeuTaNtmUH_yNHYWSg"  }

komunity.keys.each do |adresa|
  params['address'] = adresa
  uri.query = URI.encode_www_form params 
  response = uri.open.read
  json_response = JSON.parse response
  if json_response['results'].size > 0 && json_response['results'].first['geometry']
    location_hash = json_response['results'].first['geometry']['location']
    lat, lon = location_hash['lat'], location_hash['lng']
    komunity[adresa][:lat], komunity[adresa][:lon] = lat, lon
    puts "ok: #{adresa}, #{lat} #{lon}"
  else
    puts "not found: #{adresa}"
  end

end

waypoints = komunity.collect do |adresa, infohash|
  lat, lon = infohash[:lat], infohash[:lon]
  <<STRING
  <wpt lat="#{lat}" lon="#{lon}">
	<name><![CDATA[#{adresa} (#{infohash[:pocet_obyvatelov]} obyvateľov)]]></name>
</wpt>
STRING
end

gpx = <<STRING
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<gpx version="1.1" creator="Locus Android"
 xmlns="http://www.topografix.com/GPX/1/1"
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd"
 xmlns:gpxx="http://www.garmin.com/xmlschemas/GpxExtensions/v3"
 xmlns:gpxtrkx="http://www.garmin.com/xmlschemas/TrackStatsExtension/v1"
 xmlns:gpxtpx="http://www.garmin.com/xmlschemas/TrackPointExtension/v2"
 xmlns:locus="http://www.locusmap.eu">
	
#{waypoints.join("\n")}

</gpx>
STRING

File.open('osady.gpx', 'wb'){|f| f.write gpx}
puts 'successfully generated osady.gpx'

html_template = File.read('index.html.template')
leaflet_js = komunity.collect do |adresa, infohash|
  lat, lon = infohash[:lat], infohash[:lon]
  "marker = L.marker(new L.LatLng(#{lat}, #{lon}));
	 marker.bindPopup('#{adresa} (#{infohash[:pocet_obyvatelov]} obyvateľov)');
	markers.addLayer(marker);"
end

File.open('index.html', 'wb'){|f| f.write html_template.sub('MARKERS_BE_HERE', leaflet_js.join("\n"))}
puts 'successfully generated html/index.html'

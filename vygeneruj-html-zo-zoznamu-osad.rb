# encoding: utf-8
require 'uri'
require 'open-uri'
require 'json'

osady = []
okres = nil

File.read('zoznam-osad-raw').split("\n").each do |line|
  if line.include?('Okres')
    okres = line[6..-1].strip
    next
  end
  
  if line.include?('- ')
    osady_inside_line = line[2..-1].split(', ').collect{|osada| "#{osada.strip}, okres #{okres}"}
    osady_inside_line
    osady << osady_inside_line
  end
  
end

osady.flatten!

uri = URI.parse('https://maps.googleapis.com/maps/api/geocode/json')
params = { 'key' => "KEY_HERE"  }

osady_a_poloha = {}
osady.each do |osada|
  params['address'] = osada
  uri.query = URI.encode_www_form params 
  response = uri.open.read
  json_response = JSON.parse response
  if json_response['results'].size > 0 && json_response['results'].first['geometry']
    location_hash = json_response['results'].first['geometry']['location']
    lat, lon = location_hash['lat'], location_hash['lng']
    osady_a_poloha[osada] = [lat, lon]
    puts "ok: {osada}, #{lat} #{lon}"
  else
    puts "not found: #{osada}"
  end

end

waypoints = osady_a_poloha.collect do |osada, latlon|
  lat, lon = latlon
  <<STRING
  <wpt lat="#{lat}" lon="#{lon}">
	<name><![CDATA[#{osada}]]></name>
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
leaflet_js = osady_a_poloha.collect do |osada, latlon|
  lat, lon = latlon
  "marker = L.marker(new L.LatLng(#{lat}, #{lon}));
	 marker.bindPopup('#{osada}');
	markers.addLayer(marker);"
end

File.open('index.html', 'wb'){|f| f.write html_template.sub('MARKERS_BE_HERE', leaflet_js.join("\n"))}
puts 'successfully generated html/index.html'

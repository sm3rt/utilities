#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'system/getifaddrs'

@@scanned = false
@results = ""

get '/' do

  if System.get_ifaddrs.include? :wlan0
  	@results = `iwlist wlan0 scan | grep -i 'ssid'` 
  	@aps = @results.split("\n");
  	@aps.map! {|x| x.gsub('"','').gsub('ESSID:','').strip }
  	puts @aps.inspect
  	erb :index
  else 	
     redirect "/plug_it_in"
  end
end

get '/plug_it_in' do
	"Plug in the wifi adaptor buster!"
end

post '/connect' do
  puts params.inspect    
  basestation = params['basestation']
  password = params['password']
    
  "/connect"

  doc = "ctrl_interface=/var/run/wpa_supplicant\n"+
  "ctrl_interface_group=0\n"+
  "eapol_version=1\n"+
  "ap_scan=1\n"+
  "fast_reauth=1\n"+
  "\n"+
  "network={\n"+
  "        ssid=\"#{basestation}\"\n"+
  "        proto=WPA\n"+
  "        key_mgmt=WPA-PSK\n"+
  "        pairwise=TKIP\n"+
  "        group=TKIP\n"+
  "        psk=\"#{password}\"\n"+
  "}\n"

  File.open('/etc/wpa_supplicant.conf', 'w') {|f| f.write(doc) }

  #redirect '/'
end

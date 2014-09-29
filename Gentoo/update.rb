#!/usr/bin/env ruby
# encoding: UTF-8
require 'yaml'
require 'pathname'
require 'open-uri'
require 'base64'

path = Pathname.new(File.dirname(__FILE__))

config = YAML.load_file(path + 'config.yml')

location = config['Location'].dup
location['$MIRROR'] = config['Mirror']
location['$ARCH'] = config['Arch']
latestStage = config['LatestStage'].dup
latestStage['$PLATFORM'] = config['Platform']

open("#{location}/#{latestStage}", "rb") do |file|
    stage = Pathname.new(/^\s*[^#].*$/.match(file.read)[0].chomp.strip)
    config['Folder'], config['Stage3'] = stage.split
    config['Folder'] = config['Folder'].to_s
    config['Stage3'] = config['Stage3'].to_s
end

digests = config['Digests'].dup
digests['$STAGE3'] = config['Stage3']

open("#{location}/#{config['Folder']}/#{digests}", "rb") do |file|
    siganture = Base64.decode64(/^-----BEGIN PGP SIGNATURE-----\s*(Version:[^\n]+)?(.*)\s*-----END PGP SIGNATURE-----$/m.match(file.read)[2].chomp.strip.tr("\n", ''))
    config['KeyID'] = "0x" + siganture[19, 8].unpack('H*').first.upcase
end

puts "Latest Gentoo #{config['Stage3']} with KeyID #{config['KeyID']}"

File.write(path + 'config.yml', config.to_yaml, { mode: 'wb' })

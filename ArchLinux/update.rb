#!/usr/bin/env ruby
# encoding: UTF-8
require 'yaml'
require 'pathname'
require 'open-uri'
require 'base64'

path = Pathname.new(File.dirname(__FILE__))

config = YAML.load_file(path + 'config.yml')

location = config['Location'].dup
location['$MAINMIRROR'] = config['MainMirror']
location2 = location.dup
location['$VERSION'] = 'latest'
config['Version'] = nil

open("#{location}/#{config['SHASum']}", "rb") do |file|
    file.read.split("\n").each do |line|
        next if line.strip[0] == '#'
        parts = line.split[1].split('-')
        config['Version'] = parts[2].to_s if parts[1] == 'bootstrap' and parts[-1].split('.')[0] == config['Arch']
    end
end

fail("Failed to load ArchLinux version") unless config['Version']

location2['$VERSION'] = config['Version']
bootstrap = config['Bootstrap'].dup
bootstrap['$VERSION'] = config['Version']
bootstrap['$ARCH'] = config['Arch']

signature = config['Signature'].dup
signature['$BOOTSTRAP'] = bootstrap

open("#{location2}/#{signature}", "rb") do |file|
    config['KeyID'] = "0x" + file.read[23, 4].unpack('H*').first.upcase
end

puts "Latest ArchLinux #{bootstrap} with KeyID #{config['KeyID']}"

File.write(path + 'config.yml', config.to_yaml, { mode: 'wb' })

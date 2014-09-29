#!/usr/bin/env ruby
# encoding: UTF-8
require 'erb'
require 'pathname'

require_relative '../lib/utils.rb'
require_relative '../lib/shell_utils.rb'

path = Pathname.new(File.dirname(__FILE__))

bootstrapFile = []
bootstrapTemplate = []

bootstrapFile << 'bootstrap.sh'
bootstrapTemplate << bootstrapFile.last + '.erb'

bootstrapFile << 'bootstrap_existing.sh'
bootstrapTemplate << bootstrapFile.last + '.erb'


class Bootstrap
    def initialize(path)
        @Config = getConfig(path)
        @Path = path
    end

    def getLocale(locale)
        locale = locale.split(' ').first
        localePart1, localePart2 = locale.split('.')
        "#{localePart1}.#{localePart2.upcase}"
    end

    def checkConfig
        true
    end

    def getBinding
        return binding
    end
end

bootstrap = Bootstrap.new(path)

exit unless bootstrap.checkConfig

bootstrapFile.each_index do |i|
    template = ERB.new(File.read(path + bootstrapTemplate[i]))
    compiled = template.result(bootstrap.getBinding)
    sha512 = calculateSHA(compiled)
    compiled.sub!(/^SHASUM=''$/, "SHASUM='#{sha512}'")
    File.write(path + bootstrapFile[i], compiled, { mode: 'wb' })

    puts "Compiled #{bootstrapTemplate[i]} to #{bootstrapFile[i]} with SHA512 #{sha512}"
end

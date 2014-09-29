#!/usr/bin/env ruby
# encoding: UTF-8

require 'erb'
require 'pathname'


require_relative '../lib/utils.rb'

path = Pathname.new(File.dirname(__FILE__))

bootstrapFile = 'bootstrap.sh'
bootstrapTemplate = bootstrapFile + '.erb'



class Bootstrap
    def initialize(path)
        @Config = getConfig(path)
        @Path = path
        @KernelConfig = getKernelConfig(path)
    end

    def getLocale(locale)
        locale = locale.split(' ').first
        localePart1, localePart2 = locale.split('.')
        localePart2.gsub!('-', '')
        "#{localePart1}.#{localePart2.downcase}"
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

template = ERB.new(File.read(path + bootstrapTemplate))

compiled = template.result(bootstrap.getBinding)

sha512 = calculateSHA(compiled)

compiled.sub!(/^SHASUM=''$/, "SHASUM='#{sha512}'")

File.write(path + bootstrapFile, compiled, { mode: 'wb' })

puts "Compiled #{bootstrapTemplate} to #{bootstrapFile} with SHA512 #{sha512}"

#!/usr/bin/env ruby
# encoding: UTF-8
require 'yaml'
require 'erb'
require 'pathname'
require 'openssl'

Path = Pathname.new(File.dirname(__FILE__))

BootstrapFile = 'bootstrap.sh'
BootstrapTemplate = BootstrapFile + '.erb'



class Bootstrap
    def initialize()
        @Config = Hash[YAML.load_file(Path + 'config.yml').map { |(k,v)| [ k.to_sym, v ] }]
        @Path = Path
	@KernelConfig = File.read(Path.parent + 'Kernel' + 'kernel.config')
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

bootstrap = Bootstrap.new

exit unless bootstrap.checkConfig

template = ERB.new(File.read(Path + BootstrapTemplate))

compiled = template.result(bootstrap.getBinding)

sha512 = OpenSSL::Digest::SHA512.digest(compiled).unpack('H*').first.downcase

compiled.sub!(/^SHASUM=''$/, "SHASUM='#{sha512}'")

File.write(Path + BootstrapFile, compiled, { mode: 'wb' })

puts "Compiled #{BootstrapTemplate} to #{BootstrapFile} with SHA512 #{sha512}"

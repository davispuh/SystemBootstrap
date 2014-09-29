# encoding: UTF-8

require 'yaml'
require 'openssl'

def getConfig(path, config = 'config.yml')
    Hash[YAML.load_file(path + config).map { |(k,v)| [ k.to_sym, v ] }]
end

def getKernelConfig(path, config = 'kernel.config')
    File.read(path.parent + 'Kernel' + config)
end

def calculateSHA(data)
    OpenSSL::Digest::SHA512.digest(data).unpack('H*').first.downcase
end

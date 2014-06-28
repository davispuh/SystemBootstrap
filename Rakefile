# encoding: UTF-8
task :default => :compile

desc 'Update'
task :update do
    %w{Gentoo}.each do |system|
        require_relative system + '/update.rb'
    end
end

desc 'Compile'
task :compile do
    %w{Gentoo}.each do |system|
        require_relative system + '/compile.rb'
    end
end

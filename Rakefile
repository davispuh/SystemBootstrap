# encoding: UTF-8
task :default => :compile

desc 'Update'
task :update do
    %w{ArchLinux Gentoo}.each do |system|
        require_relative system + '/update.rb'
    end
end

desc 'Compile'
task :compile do
    %w{ArchLinux Gentoo}.each do |system|
	puts "=== #{system} ==="
        require_relative system + '/compile.rb'
    end
end

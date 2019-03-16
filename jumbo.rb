#!/usr/bin/env ruby

require 'net/ssh'
require 'optparse'
require 'yaml'

USER = 'root'
PASS = 'foobarbaz'

def is_installed?(package, hosts)	
	hosts.each do |host|
		puts "Creating ssh connection with #{host}"
		Net::SSH.start(host, USER, :password => PASS) do|ssh|
	 	result = ssh.exec!("dpkg -l |grep #{package} | wc -l")
	 	#puts result.to_i

		 	if result.to_i == 0
		 		return false
		 	else
		 		return true
		 	end 
		 end
	end
end


def is_running?(service, hosts)
	hosts.each do |host|
		puts "Creating ssh connection with #{host}"
		Net::SSH.start(host,USER, :password => PASS) do|ssh|
	 	result = ssh.exec!("ps -ef | grep -v grep| grep #{service}| wc -l")
		 	if result.to_i == 0
		 		return false
		 	else
		 		return true
		 	end
		 end
	end

end

def create_file(filename, hosts, mode, owner, content)
	hosts.each do |host|
		puts "Creating ssh connection with #{host}"
		Net::SSH.start(host,USER, :password => PASS) do |ssh|
			ssh.exec!("touch #{filename} && chmod #{mode} #{filename} && chown #{owner}:#{owner} #{filename} && echo '#{content}' > #{filename}")
			puts "File Creation Complete"
		end
	end
end

def restart_service(service, hosts)
	hosts.each do |host|
		puts "Creating ssh connection with #{host}"
		Net::SSH.start(host,USER, :password => PASS) do |ssh|
			ssh.exec!("service #{service} restart")
			puts "service #{service} restarted"
		end
	end
end

def uninstall_package(package, hosts)
	hosts.each do |host|
		puts "Creating ssh connection with #{host}"
		Net::SSH.start(host,USER, :password => PASS) do |ssh|
			ssh.exec!("apt-get purge #{package} -y")
			puts "package #{package} uninstalled"
		end
	end
end


def install_package(package, hosts)
	hosts.each do |host|
		puts "Creating ssh connection with #{host}"
		Net::SSH.start(host,USER, :password => PASS) do |ssh|
			ssh.exec!("apt-get install #{package} -y")
			puts "package #{package} installed"
		end
	end
end


def start_service(service, hosts)
	hosts.each do |host|
		puts "Creating ssh connection with #{host}"
		Net::SSH.start(host,USER, :password => PASS) do |ssh|
			ssh.exec!("service #{service} start")
			puts "service #{service} started"
		end
	end
end

hosts = []
options = {}

OptionParser.new do |opts|
	opts.banner = "Usage: jumbo.rb -i hostFile -f configFile"
	opts.on("-i","--inventory=file", "Host File Path") do |file|
		options[:host] = file
	end

	opts.on("-f", "--conf=conf", "Config File Location") do |conf|
		options[:conf] = conf
	end

end.parse!

if File.exist?(options[:host]) && File.exist?(options[:conf])
	hosts = File.read(options[:host]).split("\n")
	#puts hosts.class
	#puts options

	for key,value in YAML.load_file(options[:conf]) do
		package = ""
		service = ""
		filename = ""
		owner = ""
		content = ""
		mode = ""
		for i, j in value do
			
			if key == "Packages" && i["action"] == "install"
				package = i["name"]
				puts package
				if is_installed?(package, hosts)
					puts "Package #{package} already installed...Doing nothing"
				else
					install_package(package, hosts)
				end
			elsif key == "Service" && i["action"] == "start"
				service = i["name"]
				#puts service
				if is_running?(service, hosts)
					p "Service #{service} already running...doing nothing"
				else
					start_service(service, hosts)
				end 
# Will override file each time
			elsif key == "File" && i["action"] == "create"
				filename = i["name"]
				#puts filename
				mode = i["mode"].to_i
				#puts mode
				owner = i["owner"]
				#puts owner
				content = i["content"]
				#puts content
				service = i["notify"]
				#puts service
				create_file(filename, hosts, mode, owner, content)
				if not service.to_s.empty?
				restart_service(service, hosts)
				end

			elsif key == "Packages" && i["action"] == "remove"
				package = i["name"]
				#puts package
				if is_installed?(package, hosts)
					uninstall_package(package, hosts)
				else
					puts "Package #{package} not found..."
				end
					
					
			end 
		end
	end
end


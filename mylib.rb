require 'net/ssh'
require 'optparse'
require 'yaml'

USER = 'root'
PASS = 'REDACTED'

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
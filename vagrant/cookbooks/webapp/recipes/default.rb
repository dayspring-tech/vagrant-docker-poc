#
# Cookbook Name:: webapp
# Recipe:: default
#
# Copyright (C) 2022 Dayspring Tech, Inc.
#
# All rights reserved - Do Not Redistribute
#

node[:deploy].each do |application, deploy|
	if node['vagrant']
		# put the www-data user into the vagrant group
		# so the Apache process can read things owned by vagrant
		group "vagrant" do
			action :modify
			members "apache"
			append true
		end

		# put the localhost site in place
		web_app "#{application}" do
			server_name "localhost"
			server_aliases ['none']
			docroot "#{deploy[:deploy_to]}/#{deploy[:document_root]}"
			enable true
			allow_override "All"
			port '80'
			cookbook "webapp"
		end
	end
end

#
# Cookbook:: apache2
# Definition:: web_app
#
# Copyright:: 2008-2013, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

define :web_app, template: 'web_app.conf.erb', local: false, enable: true, server_port: 80 do
  application_name = params[:name]

  template "#{node['apache']['dir']}/sites-available/#{application_name}.conf" do
    source params[:template]
    local params[:local]
    owner 'root'
    group node['apache']['root_group']
    mode '0644'
    cookbook params[:cookbook] if params[:cookbook]
    variables(
      application_name: application_name,
      params: params
    )
  end

  if params[:enable]
    execute "enable site #{application_name}" do
      command "ln -s #{node['apache']['dir']}/sites-available/#{application_name}.conf #{node['apache']['dir']}/sites-enabled/#{application_name}.conf"
    end
  end
end

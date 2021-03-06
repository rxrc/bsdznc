#
# Cookbook Name:: bsdznc
# Provider:: default
#
# Copyright 2015 Evan Sosenko
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

def whyrun_supported?
  true
end

use_inline_resources

action :create do
  run_context.include_recipe 'sysctl'

  package 'znc' do
    action :install
  end

  user node['bsdznc']['user'] do
    uid node['bsdznc']['uid']
    home '/nonexistent'
    shell '/usr/sbin/nologin'
    system true
    action :create
  end

  group node['bsdznc']['group'] do
    gid node['bsdznc']['gid']
    system true
    action :create
  end

  directory "#{node['bsdznc']['config_path']}/configs" do
    user node['bsdznc']['user']
    group node['bsdznc']['group']
    mode '0750'
    recursive true
    action :create
  end

  template "#{node['bsdznc']['config_path']}/configs/znc.conf" do
    source 'znc.conf.erb'
    user node['bsdznc']['user']
    group node['bsdznc']['group']
    mode '0640'
    action :create
    not_if do
      ::File.exist?("#{node['bsdznc']['config_path']}/configs/znc.conf")
    end
  end

  directory '/etc/rc.conf.d' do
    user 'root'
    group 'wheel'
    mode '0755'
    action :create
  end

  file '/etc/rc.conf.d/mac_portacl.conf' do
    content 'mac_portacl_load="YES"'
    user 'root'
    group 'wheel'
    mode '0644'
    action :create
  end

  execute 'kldload -n mac_portacl.ko' do
    user 'root'
  end

  sysctl_param 'net.inet.ip.portrange.reservedhigh' do
    value 0
    action :apply
  end

  sysctl_param 'security.mac.portacl.enabled' do
    value 1
    action :apply
  end

  sysctl_param 'security.mac.portacl.suser_exempt' do
    value 1
    action :apply
  end

  sysctl_param 'security.mac.portacl.rules' do
    value ["uid:#{node['bsdznc']['uid']}:tcp:#{node['bsdznc']['irc_port']}",
           "uid:#{node['bsdznc']['uid']}:tcp:#{node['bsdznc']['web_port']}"
          ].join(',')
    action :apply
  end

  service 'znc' do
    action :enable
  end
end

action :start do
  service 'znc' do
    action :start
  end
end

action :stop do
  service 'znc' do
    action :stop
  end
end

action :restart do
  service 'znc' do
    action [:stop, :start]
  end
end

action :destroy do
  service 'znc' do
    action [:stop, :disable]
  end

  sysctl_param 'security.mac.portacl.enabled' do
    value 0
    action [:apply, :remove]
  end

  sysctl_param 'net.inet.ip.portrange.reservedhigh' do
    value 1023
    action :apply
  end

  file '/etc/rc.conf.d/mac_portacl.conf' do
    action :delete
  end

  directory node['bsdznc']['config_path'] do
    action :delete
  end

  user node['bsdznc']['user'] do
    action :remove
  end

  group node['bsdznc']['group'] do
    action :remove
  end

  package 'znc' do
    action :remove
  end
end

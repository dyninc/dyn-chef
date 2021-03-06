#
# Cookbook Name:: dyn
# Recipe:: ec2
#
# Copyright:: 2010, Opscode, Inc <legal@opscode.com>
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

include_recipe 'dyn'

# "i-17734b7c.example.com" => ec2.public_hostname
dyn_rr node["ec2"]["instance_id"] do
  record_type "CNAME"
  fqdn "#{node["ec2"]["instance_id"]}.#{node["dyn"]["domain"]}"
  rdata({ "cname" => "#{node["ec2"]["public_hostname"]}." })
  customer node["dyn"]["customer"]
  username node["dyn"]["username"]
  password node["dyn"]["password"]
  zone     node["dyn"]["zone"]
  action :update
end

new_hostname = "#{node["dyn"]["ec2"]["type"]}-#{node["dyn"]["ec2"]["env"]}-#{node["ec2"]["instance_id"]}"
new_fqdn = "#{new_hostname}.#{node["dyn"]["domain"]}"

dyn_rr new_hostname do
  record_type "CNAME"
  fqdn new_fqdn
  rdata({ "cname" => "#{node["ec2"]["public_hostname"]}." })
  customer node["dyn"]["customer"]
  username node["dyn"]["username"]
  password node["dyn"]["password"]
  zone     node["dyn"]["zone"]
  action :update
end

ruby_block "edit resolv conf" do
  block do
    rc = Chef::Util::FileEdit.new("/etc/resolv.conf")
    rc.search_file_replace_line(/^search/, "search #{node["dyn"]["domain"]} compute-1.internal")
    rc.search_file_replace_line(/^domain/, "domain #{node["dyn"]["domain"]}")
    rc.write_file
  end
end

ruby_block "edit etc hosts" do
  block do
    rc = Chef::Util::FileEdit.new("/etc/hosts")
    new_hosts_entry = "#{node["ec2"]["local_ipv4"]} #{new_fqdn} #{new_hostname}"
    rc.insert_line_if_no_match(new_hosts_entry, new_hosts_entry)
    rc.write_file
  end
end

execute "hostname --file /etc/hostname" do
  action :nothing
end

file "/etc/hostname" do
  content new_hostname
  notifies :run, "execute[hostname --file /etc/hostname]", :immediately
end

node.automatic_attrs["hostname"] = new_hostname
node.automatic_attrs["fqdn"] = new_fqdn

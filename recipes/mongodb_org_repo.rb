#
# Cookbook Name:: mongodb
# Recipe:: mongodb_org_repo
#
# Copyright 2011, edelight GmbH
# Authors:
#       Miquel Torres <miquel.torres@edelight.de>
#
# Copyright 2016, Sous Chefs
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

# Sets up the repositories for stable mongodb-org packages found here:
# http://www.mongodb.org/downloads#packages
node.override['mongodb']['package_name'] = 'mongodb-org'

package_version_major = node['mongodb']['package_version'].to_f

package_repo_url = case node['platform']
                   when 'redhat', 'oracle', 'centos' # ~FC024
                     "https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/#{package_version_major}/#{node['kernel']['machine'] =~ /x86_64/ ? 'x86_64' : 'i686'}"
                   when 'fedora'
                     "https://repo.mongodb.org/yum/redhat/7/mongodb-org/#{package_version_major}/#{node['kernel']['machine'] =~ /x86_64/ ? 'x86_64' : 'i686'}"
                   when 'amazon'
                     "https://repo.mongodb.org/yum/amazon/2013.03/mongodb-org/#{package_version_major}/x86_64/"
                   end

case node['platform_family']
when 'debian'
  # Adds the repo: http://www.mongodb.org/display/DOCS/Ubuntu+and+Debian+packages
  apt_repository 'mongodb' do
    uri node['mongodb']['repo']
    distribution "#{node['lsb']['codename']}/mongodb-org/#{package_version_major}"
    components node['platform'] == 'ubuntu' ? ['multiverse'] : ['main']
    keyserver 'hkp://keyserver.ubuntu.com:80'
    key package_version_major >= 3.2 ? 'EA312927' : '7F0CEB10'
  end
when 'rhel', 'fedora'
  yum_repository 'mongodb' do
    description 'mongodb RPM Repository'
    baseurl package_repo_url
    gpgkey "https://www.mongodb.org/static/pgp/server-#{package_version_major}.asc"
    gpgcheck true
    sslverify true
    enabled true
  end
else
  # pssst build from source
  Chef::Log.warn("Adding the #{node['platform_family']} mongodb-org repository is not yet not supported by this cookbook")
end

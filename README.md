# Dyn / Chef Integration Developer Preview

*Feedback Welcome* as we get this ready for prime time.

DESCRIPTION
===========

Automatically configures system DNS using Dyn's API.

REQUIREMENTS
============

Chef 0.8+.

A Dyn Traffic Management account.

The `dyn-rb` gem. The `dyn::default` recipe installs this gem from http://rubygems.org

Works on any platform Chef runs on that can install gems from Rubygems.org.

ATTRIBUTES
==========

The following attributes need to be set either in a role or on a node directly, they are not set at the cookbook level:

* dyn.customer - Customer ID
* dyn.username - Username
* dyn.password - Password
* dyn.zone - Zone
* dyn.domain - Domain

Example JSON:

    {
      "dyn": {
        "customer": "CUSTOMER",
        "username": "USERNAME",
        "password": "PASSWORD",
        "zone": "ZONE",
        "domain": "DOMAIN"
      }
    }

EC2 specific attributes:

* dyn.ec2.type - type of system, web, db, etc. Default is 'ec2'.
* dyn.ec2.env - logical application environment the system is in. Default is 'prod'.

RESOURCES
=========

rr
--

DNS Resource Record.

Actions:

Applies to the DNS record being managed.

* `:create`
* `:replace`
* `:update`
* `:delete`

Attribute Parameters:

* `record_type` - DNS record type (CNAME, A, etc)
* `rdata` - record data, see the Dyn API documentation.
* `ttl` - time to live in seconds
* `fqdn` - fully qualified domain name
* `username` - dyn username
* `password` - dyn password
* `customer` - dyn customer id
* `zone` - DNS zone

None of the parameters have default values.

Example:

    dyn_rr "webprod" do
      record_type "A"
      rdata({"address" => "10.1.1.10"})
      fqdn "webprod.#{node.dyn.domain}"
      customer node[:dyn][:customer]
      username node[:dyn][:username]
      password node[:dyn][:password]
      zone     node[:dyn][:zone]
    end

RECIPES
=======

This cookbook provides the following recipes.

default
-------

The default recipe installs Dyn's `dyn-rb` gem during the Chef run's compile time to ensure it is available in the same run as utilizing the `dyn_rr` resource/provider.

ec2
---

**Only use this recipe on Amazon AWS EC2 hosts!**

The `dyn::ec2` recipe provides an example of working with the Dyn API with EC2 instances. It creates CNAME records based on the EC2 instance ID (`node.ec2.instance_id`), and a constructed hostname from the dyn.ec2 attributes.

The recipe also edits `/etc/resolv.conf` to search `compute-1.internal` and the dyn.domain and use dyn.domain as the default domain, and it will set the nodes hostname per the DNS settings.

a_record
--------

The `dyn::a_record` recipe will create an `A` record for the node using the detected hostname and IP address from `ohai`.

FURTHER READING
===============

Information on the Dyn API:

* [PDF](http://cdn.dyndns.com/pdf/Dynect-API.pdf)

Dyn REST Ruby Library:

* [Gem](http://rubygems.org/gems/dyn-rb)
* [Code](http://github.com/dyninc/dyn-rb)

LICENSE AND AUTHOR
==================

- Author: Sunny Gleason (<adam@opscode.com>)
- Copyright: 2014, Dynamic Network Services, Inc.
- Original Author: Adam Jacob (<adam@opscode.com>)
- Copyright: 2010-2013, Opscode, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

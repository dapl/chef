#
# Cookbook Name:: dapl
# Recipe:: default
#
# Copyright (C) 2016
#
# All rights reserved - Do Not Redistribute
#

dapl_server 'primary' do
  config node.dapl
end

puts "node.dapl = "
puts node.dapl.inspect

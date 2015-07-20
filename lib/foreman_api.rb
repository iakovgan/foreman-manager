# require "rest_client"
require "json"
require "uri"


require 'foreman_api/resource'
Dir[File.dirname(__FILE__) + '/foreman_api/*.rb'].each {|file| require file }

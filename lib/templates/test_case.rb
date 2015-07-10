require 'ostruct'

class SuccessDefinition
  def initialize(obj)
  end
end

class TestCase
  attr_accessor :name, :url, :headers, :type, :data_path, :success

  def initialize(args)
    obj = OpenStruct.new(args)
    @name = obj.name
    @url = obj.url
    @headers = obj.headers || []
    @type = obj.type || "GET"
    @data_path = obj.data_path
    @success = obj.success
  end

  def get_binding
    binding
  end
end

p TestCase.new({
  :name => "List all posts",
  :path => "/api/feeds",
  :type => "POST",
  :data_path => "/data.json",
  :success => SuccessDefinition.new(:xpath => "//data")
})
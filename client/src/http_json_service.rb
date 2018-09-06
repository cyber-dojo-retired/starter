require_relative 'service_error'
require 'json'
require 'net/http'

module HttpJsonService # mix-in

  def get(args, method)
    name = method.to_s
    json = http(name, jsoned_args(name, args)) { |uri|
      Net::HTTP::Get.new(uri)
    }
    result(json, name)
  end

  def http(method, args)
    uri = URI.parse("http://#{hostname}:#{port}/#{method}")
    http = Net::HTTP.new(uri.host, uri.port)
    request = yield uri.request_uri
    request.content_type = 'application/json'
    request.body = args
    response = http.request(request)
    JSON.parse(response.body)
  end

  def jsoned_args(method, args)
    parameters = self.class.instance_method(method).parameters
    Hash[parameters.map.with_index { |parameter,index|
      [parameter[1], args[index]]
    }].to_json
  end

  def result(json, name)
    fail error(name, 'bad json') unless json.class.name == 'Hash'
    exception = json['exception']
    fail error(name, pretty(exception)) unless exception.nil?
    fail error(name, 'no key') unless json.key?(name)
    json[name]
  end

  def error(name, message)
    ServiceError.new(self.class.name, name, message)
  end

  def pretty(json)
    JSON.pretty_generate(json)
  end

end

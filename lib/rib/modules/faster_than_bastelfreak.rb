require 'json'
require'net/http'

class RIB::Module::FasterThanBastelfreak < RIB::Module

  BASE_URL = 'https://flipez.de/ftb/api?q='

  timeout ftb: 10

  describe 'Benchmark the given URL against bastelfreaks blog'
  def ftb(url)
    url.sub!(/\A(https?:\/\/)?/, 'https://')
    uri = URI("#{BASE_URL}#{url}")
    "%s reached a FTB™ Score of %s" % [url[8..-1], get_score(uri)]
  end

  private

  def get_score(uri)
    response  = Net::HTTP.get_response uri
    result    = JSON.parse(response.body)
    result['test']['result']
  end
end


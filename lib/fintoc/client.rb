require 'faraday'
require 'faraday_middleware'

require_relative 'paginator'

module Fintoc
  class Client
    def initialize(base_url: nil, api_key: nil, user_agent: nil, params: {})
      @base_url = base_url
      @api_key = api_key
      @user_agent = user_agent
      @params = params
      @_client = nil
    end

    def client
      if @_client.nil?
        @_client = Faraday.new(url: @base_url, headers: @headers, params: @params) do |f|
          f.request :json
          f.response :raise_error
          f.response :json, parser_options: { symbolize_names: true }
        end
      end
      @_client
    end

    def headers
      { Authorization: @api_key, 'User-Agent': @user_agent }
    end

    def request(path: nil, paginated: false, method: 'get', params: {}, json: {})
      return Paginator.paginate(@_client, path, params) if paginated

      response = @_client.run_request(method, path, json, @headers) do |req|
        req.params = params.dup
      end
      response.response_body
    end

    def extend(base_url: nil, api_key: nil, user_agent: nil, params: nil)
      Client.new(
        base_url: base_url || @base_url,
        api_key: api_key || @api_key,
        user_agent: user_agent || @user_agent,
        params: params ? { **@params, **params } : @params
      )
    end
  end
end

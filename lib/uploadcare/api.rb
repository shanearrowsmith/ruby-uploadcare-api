require 'faraday'
require 'faraday_middleware'
require 'json'
require 'ostruct'

require 'uploadcare/api/project'
require 'uploadcare/api/file'
require 'uploadcare/api/file_list'

module Uploadcare
  class Api
    attr_reader :options

    CDN_URL_REGEX = /
       (?<uuid>[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})
       (?:\/-\/(?<operations>.*?))?\/?$
       /ix

    def initialize(options = {})
      @options = Uploadcare::default_settings.merge(options)
      @uploader = Uploadcare::Uploader.new(@options)
    end

    def project
      @project ||= Uploadcare::Api::Project.new(self, request(:get, "/project/"))
    end

    # proxy file for uploading
    def upload_file(path)
      @uploader.upload_file path
    end

    def upload_ruby_file(file)
      @uploader.upload_ruby_file file
    end

    # proxy url for uploading
    def upload_file_by_url(url, *options)
      @uploader.upload_url(url, *options)
    end
    alias_method :upload_url, :upload_file_by_url

    # get the files
    # if caching is enabled - it will not get it for every request
    # but you will need to reload it manualy
    def files(page = 1)
      if @options[:cache_files] && @page_loaded == page
        @files ||= load_files(page)
      else
        load_files(page)
      end

      @page_loaded = page
      @files
    end

    # forse load of files list
    def load_files(page = 1)
      @files = Api::FileList.new(self, request(:get, '/files/', { page: page }))
    end

    # TODO: implement better interface for geting file object by:
    # 1. any valid url given
    # 2. UUID
    # 3. Upoading for custom url
    # 4. Upload given file objects
    # def file uuid_or_url
    # end

    def store_file(uuid)
      object = request :put, "/files/#{uuid}/storage/"
      file = Uploadcare::Api::File.new(self, object) if object
    end

    def delete_file uuid
      object = request :delete, "/files/#{uuid}/storage/"
      file = Uploadcare::Api::File.new(self, object) if object
    end

    # wtf section
    # just leave it here for backwards compability
    def uuid(source)
      source = source.uuid if source.is_a? Api::File
      m = CDN_URL_REGEX.match(source)
      m && m['uuid']
    end

    def cdn_url(base_cdn_url, *operations)
      m = CDN_URL_REGEX.match(base_cdn_url)
      operations = m['operations'].split('/-/') + operations if m['operations']
      path = operations.empty? ? m['uuid'] : [m['uuid'], operations].join('/-/')
      ::File.join @options[:static_url_base], path, '/'
    end
    alias_method :public_url, :cdn_url

    def file(source_cdn_url)
      m = CDN_URL_REGEX.match(source_cdn_url)
      resp = request(:get, "/files/#{m['uuid']}/")
      resp['operations'] = m['operations'].split('/-/') if m['operations']
      Api::File.new(self, resp)
    end

    def request(method = :get, path = "/files/", params = {})
      connection = Faraday.new url: @options[:api_url_base] do |frd|
        frd.request :url_encoded
        frd.use FaradayMiddleware::FollowRedirects, limit: 3
        frd.adapter :net_http # actually, default adapter, just to be clear
        frd.headers['Authorization'] = "Uploadcare.Simple #{@options[:public_key]}:#{@options[:private_key]}"
        frd.headers['Accept'] = "application/vnd.uploadcare-v#{@options[:api_version]}+json"
        frd.headers['User-Agent'] = Uploadcare::user_agent
      end 

      # get the response
      response = connection.send method, path, params

      # and try to get actual data
      # 404 code return in html instead of JSON, so - safety wrapper
      begin
        object = JSON.parse(response.body)
      rescue JSON::ParserError
        object = false
      end

      # and returning the object (file actually) or raise new error
      if response.status < 300
        object
      else
        message = "HTTP code #{response.status}"
        if object # add active_support god damn it
          message += ": #{object["detail"]}"
        else
          message += ": unknown error occured."
        end

        raise ArgumentError.new(message)
      end
    end
    alias_method :api_request, :request

  end
end

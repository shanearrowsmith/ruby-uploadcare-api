require 'faraday'
require 'json'
require 'ostruct'

require 'uploadcare/api/project'
require 'uploadcare/api/file'

module Uploadcare
  class Api
    attr_reader :options

    def initialize(options = {})
      @options = Uploadcare::default_settings.merge(options)
    end

    # Get project info
    def project
      resp = response(:get, '/project/')
      Project.new(
        collaborators: resp['collaborators'].map {|col|
          Project::Collaborator.new(
            name: col['name'],
            email: col['email']
          )
        },
        name: resp['name'],
        public_key: resp['pub_key']
      )
    end

    # Get files list
    def files(page = 1)
      Api::FileList.new(self, response(:get, '/files/', {page: page}))
    end

    @@cdn_url_re = /
      (?<uuid>[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})
      (?:\/-\/(?<operations>.*?))?\/?$
      /ix

    def uuid(source)
      source = source.file_id if source.is_a? Api::File
      m = @@cdn_url_re.match(source)
      m && m['uuid']
    end

    def cdn_url(base_cdn_url, *operations)
      m = @@cdn_url_re.match(base_cdn_url)
      operations = m['operations'].split('/-/') + operations if m['operations']
      path = operations.empty? ? m['uuid'] : [m['uuid'], operations].join('/-/')
      ::File.join @options[:static_url_base], path, '/'
    end

    alias_method :public_url, :cdn_url

    def file(source_cdn_url)
      m = @@cdn_url_re.match(source_cdn_url)
      resp = response(:get, "/files/#{m['uuid']}/")
      resp['operations'] = m['operations'].split('/-/') if m['operations']
      Api::File.new(self, resp)
    end

    def delete_file(file_id)
      response :delete, "/files/#{file_id}/"
    end

    def store_file(file_id)
      response :post, "/files/#{file_id}/storage/"
    end

  protected
    def response method, path, params = {}
      connection = Faraday.new url: @options[:api_url_base] do |faraday|
        faraday.request :url_encoded
        faraday.adapter Faraday.default_adapter
        faraday.headers['Authorization'] = "UploadCare.Simple #{@options[:public_key]}:#{@options[:private_key]}"
        faraday.headers['Accept'] = "application/vnd.uploadcare-v#{@options[:api_version]}+json"
        faraday.headers['User-Agent'] = Uploadcare::user_agent
      end
      r = connection.send(method, path, params)
      if r.status < 300
        JSON.parse(r.body) unless r.body.nil? or r.body == ""
      else
        msg = (r.body.nil? or r.body == "") ? r.status : JSON.parse(r.body)["detail"]
        raise ArgumentError.new(msg)
      end
    end
  end
end

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

    def file(file_id)
      Api::File.new(self, response(:get, "/files/#{file_id}/"))
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

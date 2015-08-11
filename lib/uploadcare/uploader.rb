require 'mime/types'
require 'timeout'

module Uploadcare
  class Uploader
    def initialize(options = {})
      @options = Uploadcare::default_settings.merge(options)
    end

    def upload_url(url, timeout=30, interval=0.3)
      token = response :post, '/from_url/', { source_url: url, pub_key: @options[:public_key], store: @options[:store] }
      Timeout.timeout(timeout) do
        sleep interval while (r = upload_url_status(token))['status'] != 'success'
        r.fetch('file_id')
      end
    end

    def upload_file(path)

      resp = response :post, '/base/', {
        UPLOADCARE_PUB_KEY: @options[:public_key],
        UPLOADCARE_STORE: @options[:store],
        file: Faraday::UploadIO.new(path, MIME::Types.of(path)[0].content_type)
      }
      resp['file']
    end

    def upload_url_status(token)
      resp = response(:post, '/from_url/status/', token)
      raise ArgumentError.new(resp['error']) if resp['status'] == 'error'
      resp
    end

    def upload_ruby_file(file)
      resp = response :post, '/base/', {
        UPLOADCARE_PUB_KEY: @options[:public_key],
        UPLOADCARE_STORE: @options[:store],
        file: Faraday::UploadIO.new(file.tempfile.path, file.type)
      }
      resp['file']
    end 
    
  protected
    ##
    # @see http://martinottenwaelter.fr/2010/12/ruby19-and-the-ssl-error/
    # @see https://gist.github.com/938183

    # TODO: refactor this peach of unstable mess.
    # 
    def response method, path, params = {}
      # For Ubuntu
      ca_path = '/etc/ssl/certs' if File.exists?('/etc/ssl/certs')
      connection = Faraday.new ssl: { ca_path: ca_path }, 
        url: @options[:upload_url_base] do |faraday|
          faraday.request :multipart
          faraday.request :url_encoded
          faraday.adapter Faraday.default_adapter
          faraday.headers['User-Agent'] = Uploadcare::user_agent
        end
      r = connection.send(method, path, params)
      raise ArgumentError.new(r.body) if r.status != 200
      begin
        JSON.parse(r.body)
      rescue JSON::ParserError
        r.body
      end
    end
  end
end

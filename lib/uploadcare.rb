require 'faraday'
require 'json'
require 'ostruct'

require 'uploadcare/api'
require 'uploadcare/uploader'
require 'uploadcare/version'

module Uploadcare
  def self.default_settings
    {
      public_key: 'demopublickey',
      private_key: 'demoprivatekey',
      upload_url_base: 'https://upload.uploadcare.com',
      api_url_base: 'https://api.uploadcare.com',
      static_url_base: 'https://ucarecdn.com',
      api_version: '0.2',
      widget_version: '0.1.17',
    }
  end

  def self.user_agent
    "uploadcare-api-ruby/#{Uploadcare::VERSION}"
  end
end

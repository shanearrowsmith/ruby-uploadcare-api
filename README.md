[![Build Status](https://secure.travis-ci.org/uploadcare/ruby-uploadcare-api.png?branch=master)](http://travis-ci.org/uploadcare/ruby-uploadcare-api)

A ruby wrapper for uploadcare.com service.

## Installation

Add this line to your application's Gemfile:

    gem 'uploadcare-api'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install uploadcare-api

## Usage
Api initializing:
    
    @api = Uploadcare::Api.new(CONFIG)

File uploading:
    
    @file = File.open("your-file.png")
    @api.upload_file(@file.path)
    # => "c969be02-9925-4a7e-aa6d-b0730368791c"

File retrieving:
  
    uuid = "c969be02-9925-4a7e-aa6d-b0730368791c"
    @file = @api.file(uuid)

Project:
    
    project = @api.project
    # => => {"collaborators"=>[], "name"=>"demo", "pub_key"=>"demopublickey", "autostore_enabled"=>true} 

Project files:
    
    files = @api.files

    file = files[0]
    # => #<Uploadcare::Api::File original_file_url=nil, image_info={"width"=>500, "geo_location"=>nil, "datetime_original"=>nil, "height"=>375}, mime_type="image/jpeg", is_ready=true, url="https://api.uploadcare.com/files/3dba8c89-fba3-4f73-a3a9-0734968f6f4c/", uuid="3dba8c89-fba3-4f73-a3a9-0734968f6f4c", original_filename="tatoo.jpg", datetime_uploaded="2013-10-05T10:47:22.299Z", size=74913, original_file="", is_image=true, datetime_stored=nil, datetime_removed="2013-10-05T10:47:52.955Z", source=nil>


## Testing

Run `bundle exec rspec`.

To run tests with your own keys, make a `spec/config.yml` file like this:

    public_key: 'PUBLIC KEY'
    private_key: 'PRIVATE KEY'

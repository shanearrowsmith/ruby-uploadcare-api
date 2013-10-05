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
```ruby
@api = Uploadcare::Api.new(CONFIG)
```

File uploading:
```ruby
@file = File.open("your-file.png")
@api.upload_file(@file.path)
=> "c969be02-9925-4a7e-aa6d-b0730368791c"
```

File retrieving:
```ruby
uuid = "c969be02-9925-4a7e-aa6d-b0730368791c"
@file = @api.file(uuid)
  
=> #<Uploadcare::Api::File ...
```

Project:
```ruby
project = @api.project
=> #<Uploadcare::Api::Project name="demo", pub_key="demopublickey", collaborators=[]>
```

Project files:
```ruby    
@api.files

=> #<Uploadcare::Api::FileList:0x007fdd71246020 ...

file = files[0]

=> #<Uploadcare::Api::File ...

files_array = @api.files.to_a

=> [#<Uploadcare::Api::File ...
  ...
  ...
  ...
  ]
```

## Testing

Run `bundle exec rspec`.

To run tests with your own keys, make a `spec/config.yml` file like this:

    public_key: 'PUBLIC KEY'
    private_key: 'PRIVATE KEY'

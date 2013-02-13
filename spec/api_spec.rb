require 'spec_helper'
require 'uri'
require 'socket'

describe Uploadcare::Api do
  before :each do
    @api = Uploadcare::Api.new(CONFIG)
    @uploader = Uploadcare::Uploader.new(CONFIG)
  end

  it 'should show project' do
    project = @api.project
    project.should be_an_instance_of(Uploadcare::Api::Project)
    project.public_key.should == CONFIG[:public_key]
  end

  it 'should return paginated list of files' do
    @uploader.upload_file File.join(File.dirname(__FILE__), 'view.png')
    files = @api.files(1)
    files.should be_an_instance_of Uploadcare::Api::FileList
    files.files.first.should be_an_instance_of Uploadcare::Api::File
    files.page.should == 1
    files.per_page.should > 0
    files.total.should > 0
    files.pages.should > 0

    expect { @api.files(files.pages + 1) }.to raise_error(ArgumentError)
  end

  it 'should get file info' do
    file_id = @uploader.upload_file File.join(File.dirname(__FILE__), 'view.png')
    file = @api.file(file_id)
    file.should be_an_instance_of Uploadcare::Api::File
    file.file_id.should == file_id
    file.original_filename.should == 'view.png'
  end

  it 'should use api version' do
    api = Uploadcare::Api.new(CONFIG.merge(api_version: '0.x'))
    expect { api.project }.to raise_error(ArgumentError)
  end

  it 'should fail after ssl error' do
    url = URI::parse CONFIG[:api_url_base]
    url.host = Socket.getaddrinfo(url.host, url.scheme).first[2]
    api = Uploadcare::Api.new(CONFIG.merge api_url_base: url.to_s)
    expect { api.project }.to raise_error(Faraday::Error::ConnectionFailed)
  end
end

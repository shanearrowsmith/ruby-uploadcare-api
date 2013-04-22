require 'time'

module Uploadcare
  class Api::File < OpenStruct
    def initialize(api, *args)
      @api = api
      super(*args)
    end

    def delete
      @api.delete_file(file_id)
      reload
    end

    def store
      @api.store_file(file_id)
      reload
    end

    def public_url(*operations)
      operations = @table[:operations] + operations if @table[:operations]
      path = operations.empty? ? file_id : [file_id, operations].join('/-/')
      File.join @api.options[:static_url_base], path, '/'
    end

    def reload
      @table.update @api.file(file_id).instance_variable_get('@table')
    end

    def last_keep_claim
      Time.parse(@table[:last_keep_claim]) if @table[:last_keep_claim]
    end

    def upload_date
      Time.parse(@table[:upload_date]) if @table[:upload_date]
    end

    def removed
      Time.parse(@table[:removed]) if @table[:removed]
    end
  end

  class Api::FileList
    attr_accessor :files, :page, :per_page, :total, :pages
    
    def initialize api, results
      @api = api
      @files = results['results'].map{|obj| Api::File.new(api, obj)}
      @page = results['page'].to_i
      @per_page = results['per_page'].to_i
      @total = results['total'].to_i
      @pages = results['pages'].to_i
    end
  end
end

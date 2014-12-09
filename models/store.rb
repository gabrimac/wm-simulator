class Store
  attr_reader :filename, :content, :type

  def initialize filename, content, type, options={}
    @filename = filename
    @content = content
    @type = type
  end

  def save
    File.open("./public/#{type}/#{@filename}", "w") { |f| f.write(@content) }
  end

  class << self

    def all(type)
      files = Dir.entries("./public/#{type}")
      files.delete(".")
      files.delete("..")
      files.map{ |filename| Store.find(filename, type) }
    end

    def find(filename, type)
      begin
        Store.new(File.basename(filename), File.new("./public/#{type}/#{filename}", "r").read, "#{type}")
      rescue
        return nil
      end
    end

  end

end

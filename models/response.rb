class Response
  attr_reader :filename, :content

  def initialize filename, content
    @filename = filename
    @content = content
  end

  def save
    begin
      File.open("./public/responses/#{@filename}", "a") { |f| f.write(@content) }
    rescue
      File.open("./public/responses/#{@filename}", "w") { |f| f.write(@content) }
    end
  end

  class << self

    def find(filename)
      begin
        Response.new(File.basename(filename), File.new("./public/responses/#{filename}", "r").read)
      rescue
        return nil
      end
    end

  end

end

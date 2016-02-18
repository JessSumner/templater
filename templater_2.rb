class Templater
  require "json"
  attr_reader :html_template, :data_file
  def initialize(html_template, data_file)
    @html_template = html_template
    @data_file = data_file
    @each_block = []
  end

  def run
    template_string = arrange_template_into_an_array_of_lines.
      join("\n").
      gsub("<* ", '#{json.').
      gsub(" *>", '}')
    eval("\"#{template_string}\"")
  end

  def arrange_template_into_an_array_of_lines
    open_html_file.split("\n").inject([]) do |array_of_lines, line|
      if line.include? "<* EACH"
        open_new_each_block(line)
      elsif line.include? "<* ENDEACH"
        complete_block = close_last_each_block
        if open_each_block?
          last_each_block << complete_block
        else
          array_of_lines << complete_block.run_through_block(json)
        end
      elsif open_each_block?
        last_each_block << line
      else
        array_of_lines << line
      end
      array_of_lines
    end
  end

  private

  def open_html_file
    File.read(html_template)
  end

  def open_new_each_block(line)
    @each_block << EachBlock.new(line: line)
  end

  def close_last_each_block
    @each_block.pop
  end

  def open_each_block?
    @each_block.any?
  end

  def last_each_block
    @each_block.last
  end

  def json
    JsonObject.new(convert_json)
  end

  def convert_json
    JSON.parse(File.read(data_file))
  end
end

class EachBlock
  def initialize(line: nil, lines: [], key: nil, value: nil)
    if line
      @key, @value = line.gsub(/<\* EACH (\S*) (\S*) \*>/) {|words| "#{$1},#{$2}"}.strip.split(",")
    else
      @key = key
      @value = value
    end
    @lines = lines
  end

  def <<(line)
    @lines << line
  end

  def run_through_block(data)
    eval("data.#{@key}").each_with_index.map do |item_of_key, index|
      @lines.map do |each_block_line|
        new_line = each_block_line.gsub(@value, "#{@key}[#{index}]")
        if new_line.is_a?(EachBlock)
          new_line.run_through_block(data)
        else
          new_line
        end
      end
    end
  end

  def gsub(pattern, replacement)
    key = @key.gsub(pattern, replacement)
    self.class.new(key: key, value: @value, lines: @lines)
  end
end

class JsonObject
  def initialize(json)
    @json = json
  end

  def method_missing(method, *arg, &block)
    value = @json["#{method}"]
    value_from_hash(value)
  end

  private

  def value_from_hash(value)
    if value.is_a?(Hash)
      JsonObject.new(value)
    elsif value.is_a?(Array)
      value.map { |val| value_from_hash(val) }
    else
      value
    end
  end
end

puts Templater.new(ARGV[0], ARGV[1]).run

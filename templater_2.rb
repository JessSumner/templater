class Templater
  attr_reader :html_template, :data_file
  def initialize(html_template, data_file)
    @html_template = html_template
    @data_file = data_file
    @each_block = []
  end

  def run
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
          array_of_lines << complete_block
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
end

class EachBlock
  def initialize(line: nil, lines: [])
    @line = line
    @lines = lines
  end

  def <<(line)
    @lines << line
  end
end

puts Templater.new(ARGV[0], ARGV[1]).arrange_template_into_an_array_of_lines

class Templater
  attr_reader :html_template
  def initialize(html_template)
    @html_template = html_template
  end

  def run 
    puts open_html_file
  end

  private

  def open_html_file
    File.read(html_template)
  end
end

Templater.new(ARGV[0]).run

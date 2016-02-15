class Templater
  attr_reader :html_template
  def initialize(html_template)
    @html_template = html_template
  end

  def run
    variables_hash = open_html_file.scan(/[<][*]\s?(.+)\s?[*][>]/).flatten.inject({}) do |variables_hash, key|
      variables_hash["<* #{key}*>"] = "replace_me"
      variables_hash
    end
    puts open_html_file.gsub(/[<][*](\s?)(.+)(\s?)[*][>]/, variables_hash)
  end

  private

  def open_html_file
    File.read(html_template)
  end
end

Templater.new(ARGV[0]).run

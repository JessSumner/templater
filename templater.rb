class Templater
  require 'json'
  attr_reader :html_template, :data_file
  def initialize(html_template, data_file)
    @html_template = html_template
    @data_file = data_file
  end

  def run
    variables_hash = open_html_file.scan(/[<][*]\s?(.+)\s?[*][>]/).flatten.inject({}) do |variables_hash, key|
      if key.include? "ENDEACH"
        variables_hash["<* #{key}*>"] = "empty"
      elsif key.include? "EACH "
        variables_hash["<* #{key}*>"] = "each loop here"
      else key == /[a-zA-Z][.][a-zA-Z]/
        variables_hash["<* #{key}*>"] = flatten_json_hash(convert_json)[key.strip]
      end
      variables_hash
    end
    puts open_html_file.gsub(/[<][*](\s?)(.+)(\s?)[*][>]/, variables_hash)
    puts variables_hash
    puts flatten_json_hash(convert_json)["students"]

  end

  private

  def open_html_file
    File.read(html_template)
  end

  def convert_json
    JSON.parse(File.read(data_file))
  end

  def flatten_json_hash(hash)
    hash.each_with_object({}) do |(key, value), new_hash|
      if value.is_a?(Hash)
        flatten_json_hash(value).map do |h_k, h_v|
          new_hash["#{key}.#{h_k}"] = h_v
        end
      else
        new_hash[key] = value
      end
    end
  end
end

Templater.new(ARGV[0], ARGV[1]).run

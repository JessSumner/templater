class Templater
  require 'json'
  attr_reader :html_template, :data_file
  def initialize(html_template, data_file)
    @html_template = html_template
    @data_file = data_file
  end

  def run
    variables_hash = open_html_file.scan(/[<][*]\s?(.+)\s?[*][>]/).flatten.inject({}) do |variables_hash, key|
      variables_hash["<* #{key}*>"] = "replace_me"
      variables_hash
    end
    puts open_html_file.gsub(/[<][*](\s?)(.+)(\s?)[*][>]/, variables_hash)
    puts flatten_json_hash(convert_json)
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
          new_hash["#{key}.#{h_k}".to_sym] = h_v
        end
      else
        new_hash[key] = value
      end
    end
  end
end

Templater.new(ARGV[0], ARGV[1]).run

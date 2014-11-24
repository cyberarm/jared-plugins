# TODO
require "multi_json"
require "jared/plugin"
require_relative "version"

class ListBuilder
  def initialize
    @plugins = []
    @list    = []
    @keys =  [:plugin, :description, :version, :command, :main_class,
              :jared_version, :rubygem, :rubygem_name, :github, :github_repo,
              :ruby_platform, :platform]
    @path = File.expand_path(File.dirname(__FILE__))
    @files = Dir["#{@path}/../Library/*.rb"]
    process_files

    generate_list
    build_it
  end

  def process_files
    @files.each do |file|
      @plugin = Jared::Plugin.new {|plugin|}
      begin
        _file = open(file)
        loop do
          parse(_file.readline)
        end
      rescue EOFError
      end
      @plugins << @plugin
    end
  end

  def parse(string)
    @keys.each do |key|
      if string.start_with?("#{key.to_s} ")
        substring = string.sub(key.to_s, '').strip
        if substring == "true" or substring ==  "false"
          @plugin.send("#{key}=", true) if substring == "true"
          @plugin.send("#{key}=", false) unless substring == "true"
          puts substring
        else
          @plugin.send("#{key}=", substring.delete("\\\"").strip)
        end
      end
    end
  end

  def generate_list
    @plugins.each do |plugin|
      object = {}
      @keys.each do |key|
        object[key.to_s] = plugin.send(key)
      end
      @list << object
    end
    p @list
  end

  def build_it
    it = {
      "spec_version" => VERSION,
      "plugins" => @list
    }
    File.open("#{@path}/../jared-plugins.json", 'w') do |file|
      file.write MultiJson.dump(it, :pretty => true)
    end
  end
end


ListBuilder.new

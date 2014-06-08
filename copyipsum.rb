#! /usr/bin/env ruby

require 'optparse'
require 'ostruct'
require 'pp'
require 'net/http'

class CopyIpsum

  PARAGRAPH_SIZES = %w(short medium long verylong)
  OUTPUT_OPTIONS  = %w(print copy both)

  @@ipsum_uri = "http://loripsum.net/api"

  def self.parse(args)
    @options = OpenStruct.new
    @options.output = 'copy'

    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: #{File.basename(__FILE__)} [options]"
      opts.separator ""
      opts.separator "Specific options:"

      opts.on("-p NUM", "--paragraphs NUM", "Number of paragraphs to generate. Defaults to 4.") do |count|
        @options.paragraphs = count
      end

      opts.on('-s NUM', '--size NUM', PARAGRAPH_SIZES, "Select size of paragraph.",
              "    (#{PARAGRAPH_SIZES.join(', ')})") do |s|
        @options.size = s
      end

      opts.on('-a', '--allcaps', 'Use ALL CAPS.') do |caps|
        @options.allcaps = 'allcaps'
      end

      opts.on('-b', '--decorate', 'Add decorated text, including bold, italic and mark.') do |d|
        @options.decorate = 'decorate'
      end

      opts.on('-c', '--code', 'Add code examples.') do |code|
        @options.code = 'code'
      end

      opts.on('-d', '--dl', 'Add definition lists.') do |dl|
        @options.dl = 'dl'
      end

      opts.on('-H', '--headers', 'Add headers.') do |h|
        @options.headers = 'headers'
      end

      opts.on('-l', '--link', 'Add links.') do |l|
        @options.link = 'link'
      end

      opts.on('-q', '--bq', 'Add block quotes.') do |bq|
        @options.bq = 'bq'
      end

      opts.on('-t', '--plaintext', 'Return plain text, no HTML') do |p|
        @options.plaintext = 'plaintext'
      end

      opts.on('-o', '--ol', 'Add ordered lists.') do |ol|
        @options.ol = 'ol'
      end

      opts.on('-u', '--ul', 'Add unordered lists.') do |ul|
        @options.ul = 'ul'
      end

      opts.on('-O OUTPUT', '--output OUTPUT', OUTPUT_OPTIONS, 'Output option.',
              "   (#{OUTPUT_OPTIONS.join(', ')})") do |o|

        @options.output = o
      end

      opts.on_tail("-h", "--help", "--usage", "Show this message") do |help|
        puts opts
        exit
      end

    end

    opt_parser.parse(args)

    get_ipsum

  end

  private

  def self.build_uri
    @options.each_pair.to_a.each do |key, value|
      @@ipsum_uri += "/#{value}" unless key == :output
    end
  end

  def self.copy(input)
    str = input.to_s
    IO.popen('pbcopy', 'w') { |f| f << str }
    str
  end

  def self.get_ipsum
    ipsum = fetch_ipsum


    if( %w(copy both).include? @options.output )
      copy(ipsum)
    end

    if( %w(print both).include? @options.output )
      puts ipsum
    end
  end

  def self.fetch_ipsum
    build_uri

    uri = URI(@@ipsum_uri)

    result = Net::HTTP.get_response(uri)
    result.body if result.is_a?(Net::HTTPSuccess)
  end

end

ipsum = CopyIpsum.parse(ARGV)

require 'erb'
require 'fileutils'

module StaticSiteDsl
  def page(name, &blk)
    @pages ||= {}
    @pages[name] = blk
  end

  def call
    dir = 'site'
    FileUtils.mkdir_p dir

    @pages.each_pair do |name, proc|
      File.open(File.join(dir, name + '.html'), 'w') do |fw|
        fw.puts proc.call
      end
    end
  end

  def render(template, &blk)
    ERB.new(File.read(template)).result(binding, &blk)
  end
end

class SplendorVeritatisIndices
  extend StaticSiteDsl

  def self.layout
    render 'views/_layout.erb' do
      yield
    end
  end

  page 'index' do
    render 'views/frames.erb'
  end

  page 'intro' do
    layout do
      render 'views/intro.erb'
    end
  end

  page 'antiphonale' do
    layout do
      IndexRenderer.new('antiphonale').render
    end
  end
end

class IndexRenderer
  def initialize(index)
    @index = index

    @site = 'http://unpeudetout.info/splendorveritatis' # originally 'http://splendorveritatis.org'
    @book_path = @index
  end

  def index_path(i)
    File.join 'data', i+'.txt'
  end

  def page_url(page)
    "#{@site}/#{@book_path}/large-#{page}.html"
  end

  def render
    b = '' # output buffer
    File.open(index_path(@index)) do |fr|
      title = fr.gets
      b << "<h1>#{title}</h1>"

      i = 1
      fr.each_line do |l|
        i += 1
        next if l.start_with? '#'
        next if l =~ /^\s*$/
        b << entry(l, i)
      end
    end
    b
  end

  def entry(str, line)
    m = str.match(/^(\d+)\s+(=*)(.*)$/)

    if m.nil?
      return error(str, line)
    end

    page = m[1]
    heading_level = m[2].size rescue 0
    label = m[3]

    label = modify label, heading_level

    "<p class=\"lvl#{heading_level}\"><a href=\"#{page_url(page)}\" target=\"content\"><span class=\"pageno\">#{page}</span> #{label}</a></p>"
  end

  def error(str, line)
    "<p><b>Error on line #{line}: '#{str}'</b></p>"
  end

  def modify(str, heading_level)
    shortcuts = {
      'v' => 'ad vesperas',
      'vig' => 'ad vigilias',
      'n1' => 'in i. nocturno',
      'n2' => 'in ii. nocturno',
      'n3' => 'in iii.nocturno',
      'L' => 'ad laudes', # uppercase, in order to avoid l vs. 1 confusion
      '1' => 'ad primam',
      '3' => 'ad tertiam',
      '6' => 'ad sextam',
      '9' => 'ad nonam',
      'v2' => 'in ii. vesperis',
    }

    str
      .gsub(/in festo/i, '')
      .gsub(/[a-zL0-9]+/) do |match|
      ((heading_level == 0) && shortcuts[match]) || match
    end
  end
end

SplendorVeritatisIndices.call

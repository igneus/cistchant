require 'fileutils'

require 'tilt'
require 'tilt/haml'
require 'tilt/erb'

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
    Tilt.new(template).render(&blk)
  end
end

class SplendorVeritatisIndices
  extend StaticSiteDsl

  page 'index' do
    render 'views/frames.erb'
  end

  page 'intro' do
    render 'views/_layout.haml' do
      render 'views/intro.erb'
    end
  end

  page 'antiphonale' do
    render 'views/_layout.haml' do
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
    m = str.match(/^(\d+)\:\s+(=*)(.*)$/)

    if m.nil?
      return error(str, line)
    end

    page = m[1]
    heading_level = m[2].size rescue 0
    label = m[3]

    label = modify label

    "<p class=\"lvl#{heading_level}\"><a href=\"#{page_url(page)}\" target=\"content\"><span class=\"pageno\">#{page}</span> #{label}</a></p>"
  end

  def error(str, line)
    "<p><b>Error on line #{line}: '#{str}'</b></p>"
  end

  def modify(str)
    str.gsub(/in festo/i, '')
  end
end

SplendorVeritatisIndices.call

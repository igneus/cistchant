require 'nyny'
require 'haml'

class SplendorVeritatisIndices < NYNY::App
  get '/' do
    render 'views/frames.erb'
  end

  get '/intro' do
    render 'views/_layout.haml' do
      render 'views/intro.erb'
    end
  end

  get '/antiphonale' do
    render 'views/_layout.haml' do
      IndexRenderer.new('antiphonale').render
    end
  end
end

class IndexRenderer
  def initialize(index)
    @index = index

    @site = 'http://splendorveritatis.org'
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

require 'ostruct'

require 'slim'
require 'sass'


task :default => :build

task :build do |t|
  optional_option_hash = {}
  Slim::Embedded.options[:markdown] = {superscript: true}
  template = Slim::Template.new('index.slim', optional_option_hash)
  scope = OpenStruct.new(author: 'Vladimir', year: 2014, items: [])
  html = template.render(scope)
  html = Redcarpet::Render::SmartyPants.render(html)
  File.open('index.html', 'w') do |file|
    file.write(html)
  end

  sass_source = File.open('style.sass') { |file| file.read }
  sass_engine = Sass::Engine.new(sass_source, :syntax => :sass)
  css = sass_engine.render
  File.open('style.css', 'w') do |file|
    file.write(css)
  end
end


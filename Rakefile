require 'ostruct'
require 'date'

require 'slim'
require 'sass'
require 'coffee-script'

def pattern(hash, &block)
  from, to = hash.flatten
  rule({from => -> (task) { task.sub(from, to) }}) do |t|
    puts "#{t.source} -> #{t.name}"
    block.call t
  end
end

task :default => :compile

directory 'build'

task :compile => [
  'build',
  'build/images',
  'build/internal-communication-and-project-management-with-podio.html',
  'build/back-end-api-development.html',
  'build/designing-better-app-icons.html',
  'build/index.html',
  'build/style.css',
  'build/script.js',
]

task 'build/images' => 'images' do |t|
  sh 'cp -r images build/'
end

pattern %r{^build/(.*)\.js$} => '\1.coffee' do |t|
  File.write(t.name, CoffeeScript.compile(File.read(t.source)))
end

pattern %r{^build/(.*)\.css$} => '\1.sass' do |t|
  options = {
    syntax: :sass,
  }

  File.write(t.name, Sass::Engine.new(File.read(t.source), options).render)
end

pattern %r{^build/(.*)\.html$} => '\1.slim' do |t|
  options = {
    markdown: {
      superscript: true
    }
  }

  template = Slim::Template.new(t.source, options)
  scope = OpenStruct.new(year: Date.today.year)
  html = template.render(scope)
  html = Redcarpet::Render::SmartyPants.render(html)

  File.write(t.name, html)
end

task :serve => :compile do
  sh '(cd build; python2 -m SimpleHTTPServer)'
end

task :deploy => :compile do
  sh 's3_website push'
end

task :staging => :compile do
  sh 's3_website push --config-dir=staging'
end

task :clean do
  sh 'rm -rf build'
end

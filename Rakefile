# encoding: utf-8
require 'rbconfig'
require 'rubygems'
require 'rake'
require 'rake/clean'

JRUBY   = defined?(JRUBY_VERSION)
WINDOWS = Config::CONFIG['host_os'] =~ /mswin|mingw/

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "gherkin"
    gem.summary = %Q{Fast Gherkin lexer}
    gem.description = %Q{A fast Gherkin lexer in Ragel}
    gem.email = "cukes@googlegroups.com"
    gem.homepage = "http://github.com/aslakhellesoy/gherkin"
    gem.authors = ["Mike Sassak", "Gregory Hnatiuk", "Aslak Hellesøy"]
    gem.add_development_dependency "rspec", "1.2.9"
    gem.add_development_dependency "cucumber"
    
    # Jeweler only includes files in git by default. Add the generated ones.
    gem.files += FileList['lib/gherkin/rb_lexer/*.rb']

    if(JRUBY)
      gem.platform = Gem::Platform::CURRENT
      gem.files += FileList['lib/gherkin.jar']
    elsif(WINDOWS)
      gem.platform = Gem::Platform::CURRENT
      gem.files += FileList['lib/gherkin_lexer.dll']
    else
      gem.files += FileList['ext/gherkin_lexer/*.{c,h}']
      gem.extensions << 'ext/gherkin_lexer/extconf.rb'
    end
    
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

Dir['tasks/**/*.rake'].each { |rake| load rake }

task :default => [:spec, :cucumber]

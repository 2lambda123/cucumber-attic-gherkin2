namespace :release do
  desc 'Upload all packages and tag git'
  task :ALL => ['gems:sanity', :push_dll, :push_jar, :push_native_gems, :release]

  desc 'Push all gems to rubygems.org (gemcutter)'
  task :push_gems do
    Dir.chdir('release') do
      Dir['*.gem'].each do |gem_file|
        sh("gem push #{gem_file}")
      end
    end
  end

  desc 'Push dll to Github'
  task :push_dll => :ikvm do
    Dir.chdir('release') do
      # This requires aslakhellesoy's build of the github gem,
      # which has tekkub's upload command.
      begin
        sh("../github/github upload gherkin-#{Gherkin::VERSION}.dll")
      rescue => e
        # For some reason we're getting an error even if the upload is successful. Verify that here...
        head = `curl -I -X HEAD http://github.com/downloads/aslakhellesoy/gherkin/gherkin-#{Gherkin::VERSION}.dll`
        if !(head =~ /302 Found/in)
          e.message << "\n\nUpload of gherkin-#{Gherkin::VERSION}.dll failed:\n\n#{head}"
          raise e
        end
      end
    end
  end

  desc 'Push jar to cukes.info Maven repo'
  task :push_jar do
    Dir.chdir('java') do
      sh("mvn -Dmaven.wagon.provider.http=httpclient deploy")
    end
  end
end
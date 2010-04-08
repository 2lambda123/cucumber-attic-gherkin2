# To test out the pure Java main program on .NET, execute:
#
#   rake ikvm
#
# Just print dots:
#
#   [mono] pkg/gherkin.exe features
#
# Pretty print all to STDOUT:
#
#   [mono] pkg/gherkin.exe features pretty
#
# To test out the pure C# main program on .NET, execute:
#
#   rake ikvm (you need this to generate all the .dll files needed for the next step)
#
# Then build ikvm/Gherkin.sln. Then:
#
#   [mono] mono ikvm/Gherkin/bin/Debug/Gherkin.exe features/steps_parser.feature
#
namespace :ikvm do
  desc 'Make a .NET .exe'
  task :exe => 'pkg/gherkin.exe'

  desc 'Make a .NET .dll'
  task :dll => 'pkg/gherkin.dll'

  file 'pkg/gherkin.exe' => 'lib/gherkin.jar' do
    mkdir_p 'pkg' unless File.directory?('pkg')
    sh("mono /usr/local/ikvm/bin/ikvmc.exe -target:exe lib/gherkin.jar -out:pkg/gherkin.exe")
  end

  file 'pkg/gherkin.dll' => 'lib/gherkin.jar' do
    mkdir_p 'pkg' unless File.directory?('pkg')
    sh("mono /usr/local/ikvm/bin/ikvmc.exe -target:library lib/gherkin.jar -out:pkg/gherkin.dll")
  end

  desc 'Copy the IKVM .dll files over to the pkg dir'
  task :copy_ikvm_dlls do
    Dir['/usr/local/ikvm/bin/{IKVM.OpenJDK.Core,IKVM.OpenJDK.Text,IKVM.Runtime}.dll'].each do |dll|
      cp dll, 'pkg'
    end
  end
end

task :ikvm => ['ikvm:exe', 'ikvm:dll', 'ikvm:copy_ikvm_dlls']


include FileUtils::Verbose

namespace :test do
  task :prepare do
  end

  desc "Run the HAL Tests for iOS"
  task :ios => :prepare do
    run_tests('HALTests', 'iphonesimulator')
    tests_failed('iOS') unless $?.success?
  end
end

desc "Run the HAL Tests for iOS"
task :test do
  Rake::Task['test:ios'].invoke  
end

task :default => 'test'

private

def run_tests(scheme, sdk)
  sh("xcodebuild -project HAL.xcodeproj -scheme '#{scheme}' -sdk '#{sdk}' -configuration Release clean test | xcpretty -c ; exit ${PIPESTATUS[0]}") rescue nil
end

def tests_failed(platform)
  puts red("#{platform} unit tests failed")
  exit $?.exitstatus
end

def red(string)
 "\033[0;31m! #{string}"
end
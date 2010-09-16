task :default do
    ruby %{-Ilib -Itest 'test/unit/fretboarder_test.rb'}
end

task :pull do
    sh "git pull" do |ok, result|
        `git tag -f last-pull` if ok
    end
end

task :bundle do
    hostname = `hostname`.strip
    username = `whoami`.strip
    cmd = "git bundle create ~/Dropbox/Temp/fretboarder_#{username}@#{hostname}.bundle last-pull..HEAD"
    sh cmd
end

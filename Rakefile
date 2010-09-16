task :default do
    ruby %{-Ilib -Itest 'test/unit/fretboarder_test.rb'}
end

task :pull do
    sh "git pull" do |ok, result|
        `git tag -f last-pull` if ok
    end
end

task :bundle do
    `git bundle create ~/Dropbox/Temp/fretboarder.bundle last-pull..HEAD`
end

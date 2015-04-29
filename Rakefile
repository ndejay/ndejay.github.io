#############################################################################
#
# Modified version of mfenner/jekyll-travis Rakefile
# https://github.com/mfenner/jekyll-travis/blob/master/Rakefile
#
#############################################################################

require 'rake'
require 'date'
require 'yaml'

CONFIG = YAML.load(File.read('_config.yml'))
USERNAME = CONFIG['username'] || ENV['GIT_NAME']
REPO = CONFIG['repo'] || "#{USERNAME}.github.io"

# Determine source and destination branch
if REPO == "#{USERNAME}.github.io"
  SOURCE_BRANCH = CONFIG['branch'] || 'source'
  DESTINATION_BRANCH = 'master'
else
  SOURCE_BRANCH = 'master'
  DESTINATION_BRANCH = 'gh-pages'
end

#############################################################################
#
# Helper functions
#
#############################################################################

# If destination folder exists, sync it with the remote.  Otherwise, clone it
# from the remote.  Then, clear its contents.
def pull_destination
  if Dir.exist? CONFIG['destination']
    Dir.chdir CONFIG['destination'] { sh 'git pull --rebase' }
  else
    # Use GH_TOKEN environment variable only if in Travis CI
    if ENV['TRAVIS']
      sh "git clone https://#{USERNAME}:#{ENV['GH_TOKEN']}@github.com/#{USERNAME}/#{REPO}.git #{CONFIG['destination']}"
    else
      sh "git clone git@github.com:#{USERNAME}/#{REPO}.git #{CONFIG['destination']}"
    end
  end

  # Create destination branch if necessary.
  Dir.chdir CONFIG['destination'] do
    branches = `git branch -a --list | cut -c3-`.split("\n")

    # If remote destination branch exists, checkout to that branch.  Otherwise,
    # create an orphan branch.
    if branches.include? "remotes/origin/#{DESTINATION_BRANCH}"
      sh "git checkout -b #{DESTINATION_BRANCH} origin/#{DESTINATION_BRANCH}"
    else
      sh "git checkout --orphan #{DESTINATION_BRANCH}"
    end

    # Wipe the slate clean to ensure clean builds.
    sh 'git rm -fr .'
    sh 'rm -fr *'
  end
end

# Commit the contents of the destination folder into the destination branch and
# push the commit to the remote.
def push_destination
  sha = `git log`.match(/[a-z0-9]{40}/)[0]
  Dir.chdir CONFIG["destination"] do
    sh 'git add --all .'
    sh "git commit -m 'Update to #{USERNAME}/#{REPO}@#{sha}.'"
    sh "git push --quiet origin #{DESTINATION_BRANCH}"
    puts "Pushed updated branch #{DESTINATION_BRANCH} to GitHub Pages"
  end
end

#############################################################################
#
# Site tasks
#
#############################################################################

namespace :site do
  desc 'Generate the site'
  task :build do
    pull_destination
    sh 'bundle exec jekyll build'
  end

  desc 'Generate the site and serve locally'
  task :serve do
    pull_destination
    sh 'bundle exec jekyll serve'
  end

  desc 'Generate the site, serve locally and watch for changes'
  task :watch do
    pull_destination
    sh 'bundle exec jekyll serve --watch'
  end

  desc 'Generate the site and push changes to remote origin'
  task :deploy do
    # Detect pull request
    if ENV['TRAVIS_PULL_REQUEST'].to_s.to_i > 0
      puts 'Pull request detected. Not proceeding with deploy.'
      exit
    end

    # Configure git if this is run in Travis CI
    if ENV['TRAVIS']
      sh "git config --global user.name '#{ENV['GIT_NAME']}'"
      sh "git config --global user.email '#{ENV['GIT_EMAIL']}'"
      sh 'git config --global push.default simple'
    end

    sh "git checkout #{SOURCE_BRANCH}"

    # Pull and prepare destination folder
    pull_destination

    # Generate the site
    sh 'bundle exec jekyll build'

    # Push destination folder
    push_destination
  end
end

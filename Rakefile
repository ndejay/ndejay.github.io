#############################################################################
#
# Modified version of mfenner/jekyll-travis Rakefile
# https://github.com/mfenner/jekyll-travis/blob/master/Rakefile
#
#############################################################################

require 'rake'
require 'date'
require 'yaml'
require 'html/proofer'

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

# Print error and exit
def die (string)
  puts string
  exit
end

# Configure git
def configure_git
  sh "git config --global user.name '#{ENV['GIT_NAME']}'"
  sh "git config --global user.email '#{ENV['GIT_EMAIL']}'"
  sh 'git config --global push.default simple'
end

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

# Generate the site
def build_destination
  sh "git checkout #{SOURCE_BRANCH}"
  sh 'bundle exec jekyll build'

  # Write CNAME based on URL key in _config.yml
  File.open("#{CONFIG['destination']}/CNAME", 'w') do |f|
    f.write CONFIG['url'][/http:\/\/(.*\.com)/, 1]
  end
end

# HTML proof the site
def validate_destination
  HTML::Proofer.new(CONFIG['destination'], {disable_external: true}).run
end

# Commit the contents of the destination folder into the destination branch and
# push the commit to the remote.
def push_destination
  sha = `git log`.match(/[a-z0-9]{40}/)[0]
  Dir.chdir CONFIG["destination"] do
    sh 'git add --all .'
    sh "git commit -m 'Update to #{USERNAME}/#{REPO}@#{sha}'"
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
    build_destination
  end

  desc 'Generate the site and serve locally'
  task :serve do
    sh 'bundle exec jekyll serve'
  end

  desc 'Generate the site, serve locally and watch for changes'
  task :watch do
    sh 'bundle exec jekyll serve --watch'
  end

  desc 'Generate the site and validate HTML'
  task :validate do
    validate_destination
  end

  desc 'Generate the site, validate HTML and push to destination branch'
  task :deploy do
    die 'Pull request detected. Not proceeding with deploy.' if ENV['TRAVIS_PULL_REQUEST'].to_s.to_i > 0
    configure_git if ENV['TRAVIS']
    pull_destination
    build_destination
    validate_destination
    push_destination
  end
end

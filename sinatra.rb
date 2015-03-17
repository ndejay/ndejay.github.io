require 'sinatra'

set :public_folder, File.dirname(__FILE__) + '/_site'

get '/' do
  send_file File.join(settings.public_folder, 'index.html')
end

get /\/(.*)\/?/ do
  send_file File.join(settings.public_folder, params[:captures].first, 'index.html')
end

require_relative 'config/enviroment'

use Rack::RequestId
use Rack::Ougai::LogRequests, Application.logger

map '/ads' do
  run AdRoutes
end
module PocketAPI
  module Authentication
    class User < Grape::API
      
      version 'v1', :using => :path
      format :json
      
        get "/" do
          "Welcome to Pockit Server"
        end
    end
  end
end

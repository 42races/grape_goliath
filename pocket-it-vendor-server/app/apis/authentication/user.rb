require 'rack/oauth2/server'
require 'oauth2'
require 'mysql2'
require 'songkick/oauth2/provider'
module PocketAPI
  module Authentication
    class User < Grape::API
    	Songkick::OAuth2::Provider.realm = 'My OAuth app'
      version 'v1', :using => :path
      format :json		  	

         [:get, :post].each do |method|
		  __send__ method, '/oauth/authorize' do
		  	p "lllllllllll"
		    @owner  = Owner.find_by_id('2')
		    @oauth2 = Songkick::OAuth2::Provider.parse(@owner, env)
			    if @oauth2.redirect?
			      redirect_url = @oauth2.redirect_uri
			      redirect redirect_url
			    else
				    if body = @oauth2.response_body
				      body
				    elsif @oauth2.valid?
				    	p "login"
				    	@owner  = Owner.find_by_id('2')
				    	@auth = Songkick::OAuth2::Provider::Authorization.new(@owner, params)
						@oauth2_authorization_instance = Oauth2Authorization.new()
				    	@instance = @oauth2_authorization_instance.get_token(@auth.owner, @auth.client,
						            :response_type => @auth.params["response_type"],
						            :scope => nil,
						            :duration => nil)
				    	redirect_url = @auth.redirect_uri + 'code=' + @instance.code
				    	p redirect_url
				    	redirect redirect_url
				    else
				    	p "error"
				    end
				end
		  	end
		end
    end
  end
end

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
  		  __send__ method, '/oauth/request_token' do
		    @owner  = Owner.find_by_username(params.username)
		    if @owner.nil?
		    	@owner = Owner.create(:username => params.username)
		    end
		    @oauth2 = Songkick::OAuth2::Provider.parse(@owner, env)
			    if @oauth2.redirect?
			      redirect_url = @oauth2.redirect_uri + "&&access_token" + @oauth2.access_token
			      redirect redirect_url
			    else
				    if body = @oauth2.response_body
				      body
				    elsif @oauth2.valid?    
				    	@auth = Songkick::OAuth2::Provider::Authorization.new(@owner, params)
						@oauth2_authorization_instance = Oauth2Authorization.new()
				    	@instance = @oauth2_authorization_instance.get_token(@auth.owner, @auth.client,
						            :response_type => @auth.params["response_type"],
						            :scope => nil,
						            :duration => nil)
				    	redirect_url = @auth.redirect_uri + "&&code=" + @instance.code
				    	redirect redirect_url
				    else
				    	p "error"
				    end
				end
		  	end
		end

		[:get, :post].each do |method|
  		  __send__ method, 'oauth/access_token' do
			@owner  = Owner.find_by_username(params.username)
		    if @owner.nil?
		    	@owner = Owner.create(:username => params.username)
		    end
		    @oauth2 = Songkick::OAuth2::Provider.parse(@owner, env)
		    p @oauth2
			    if @oauth2.redirect?
			      redirect_url = @oauth2.redirect_uri + "&&access_token" + @oauth2.access_token
			    else
				    if body = @oauth2.response_body
				      body
				    elsif @oauth2.valid?    
				    	@auth = Songkick::OAuth2::Provider::Authorization.new(@owner, params)
						@oauth2_authorization_instance = Oauth2Authorization.new()
				    	@instance = @oauth2_authorization_instance.get_token(@auth.owner, @auth.client,
						            :response_type => @auth.params["response_type"],
						            :scope => nil,
						            :duration => nil)
				    	if @instance.access_token.nil?
				    		p "error"
				    		redirect @auth.redirect_uri
				    	else
				    		redirect_url = @auth.redirect_uri.to_s + "&&access_token=" + @instance.access_token.to_s 
				    		redirect redirect_url

				    		# headers @oauth2.response_headers
				    	end				    	
				    else
				    	p "error"
				    end
				end
		  	end
		 end
    end
  end
end

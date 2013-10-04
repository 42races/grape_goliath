class Owner < ActiveRecord::Base
	has_many :oauth2_authorizations
	def oauth2_authorization_for(client)
        Oauth2Authorization.find_by_oauth2_client_id(client.id)
    end
end
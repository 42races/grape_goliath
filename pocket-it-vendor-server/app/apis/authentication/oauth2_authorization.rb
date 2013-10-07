class Oauth2Authorization < ActiveRecord::Base

	def get_token(owner,client, attributes = {})
			return nil unless owner and client
          @instance = owner.oauth2_authorization_for(client) ||
                     Oauth2Authorization.new do |authorization|
                       authorization.oauth2_resource_owner_id  = owner.id
                       authorization.oauth2_client_id = client.id
                     end
          case attributes[:response_type]
            when 'code'
              @instance.code ||= create_code(client)
            when 'token'
              @instance.access_token  ||= create_access_token
              @instance.refresh_token ||= create_refresh_token(client)
          end

          if attributes[:duration]
            @instance.expires_at = Time.now + attributes[:duration].to_i
          else
            @instance.expires_at = nil
          end

          if attributes[:scope].nil?
          	@instance.scope = nil
          else
	          scopes = scopes + (attributes[:scope] || [])
	          scopes += attributes[:scope].split(/\s+/) if attributes[:scope]
	          @instance.scope = scopes.empty? ? nil : scopes.entries.join(' ')
	      end
          @instance.save 
          return @instance

        rescue Object => error
            raise error
		end

		def create_code(client)
			verified_client = Oauth2Client.find_by_client_id(client.client_id)
          	Songkick::OAuth2.generate_id do |code|
	          	if verified_client
	          		return code
	          	else
	          		return nil
	          	end
          	end
        end

	     def create_access_token
	      Songkick::OAuth2.generate_id do |token|
	        hash = Songkick::OAuth2.hashify(token)	        
	      end
	      return hash
	    end

	    def create_refresh_token(client)
	    	verified_client = Oauth2Client.find_by_client_id(client.client_id)
		    Songkick::OAuth2.generate_id do |refresh_token|
		    	if verified_client
		       		hash = Songkick::OAuth2.hashify(refresh_token)
		       	else
	          		hash = nil
	          	end
		    end
	      return hash
	    end

        def scopes
          scopes = scope ? scope.split(/\s+/) : []
          Set.new(scopes)
        end

        def in_scope?(request_scope)
          [*request_scope].all?(&scopes.method(:include?))
        end

        def expired?
          return false unless expires_at
          expires_at < Time.now
        end

        def generate_access_token
          self.access_token ||= self.create_access_token
          save && access_token
        end

end
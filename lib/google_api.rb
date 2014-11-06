require 'google/api_client'

# Wraps the Google Services API, which uses OAuth2
#
# https://developers.google.com/accounts/docs/OAuth2WebServer
class GoogleApi
  def initialize
    @client = Google::APIClient.new(application_name: "Windy City Pathfinder", application_version: "v1")
    @client.authorization.client_id = ENV["GOOGLE_CLIENT_ID"]
    @client.authorization.client_secret = ENV["GOOGLE_CLIENT_SECRET"]
    @client.authorization.scope = ['profile', 'email']
    @plus = @client.discovered_api('plus')
  end

  def profile(session)
    auth = @client.authorization.dup
    auth.update_token!(session)
    result = @client.execute(:api_method => @plus.people.get,
                            :parameters => {'userId' => 'me'},
                            :authorization => auth)
    result.data.to_hash
  end

  def email(session)
    auth = @client.authorization.dup
    auth.update_token!(session)
    result = @client.execute(:api_method => @plus.people.get,
                            :parameters => {'userId' => 'me'},
                            :authorization => auth)
    result.data.to_hash
  end

  def save_credentials(session, code)
    auth = @client.authorization.dup
    auth.code = code if code
    auth.fetch_access_token!
    session[:access_token] = auth.access_token
    session[:refresh_token] = auth.refresh_token
    session[:expires_in] = auth.expires_in
    session[:issued_at] = auth.issued_at
  end

  def auth_url(redirect_uri)
    @client.authorization.redirect_uri = redirect_uri
    @client.authorization.authorization_uri.to_s
  end
end

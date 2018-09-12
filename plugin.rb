# name: sebrae-login
# about: Plugin responsavel por realizar a autenticação via SebraeID
# version: 0.0.1
# authors: Vitor

require 'auth/oauth2_authenticator'
require 'omniauth-oauth2'

class HummingbirdAuthenticator < ::Auth::OAuth2Authenticator

  CCLIENT_ID = '167'
  CLIENT_SECRET = 'ZCjUMfi1-evtZolCuR9z'

  def register_middleware(omniauth)
    omniauth.provider :hummingbird, CLIENT_ID, CLIENT_SECRET
  end
end

class OmniAuth::Strategies::Hummingbird < OmniAuth::Strategies::OAuth2
  # Give your strategy a name.
  option :name, "SebraeID"

  # This is where you pass the options you would pass when
  # initializing your consumer from the OAuth gem.
  option :client_options, site: 'https://homolog.sebraeid.sebrae.com.br'

  # These are called after authentication has succeeded. If
  # possible, you should try to set the UID without making
  # additional calls (if the user id is returned with the token
  # or as a URI parameter). This may not be possible with all
  # providers.
  uid { raw_info['id'].to_s }

  info do
    {
      :name => raw_info['FirstName'],
      :email => raw_info['Email']
    }
  end

  extra do
    {
      'raw_info' => raw_info
    }
  end

  def raw_info
    @raw_info ||= access_token.get('/OAuth_API/api/Me').parsed
  end
end

auth_provider :title => 'Sign in with SebraeID account',
    :message => 'Log in using your SebraeID account. (Make sure your popup blocker is disabled.)',
    :frame_width => 920,
    :frame_height => 800,
    :authenticator => HummingbirdAuthenticator.new('hummingbird', trusted: true,
      auto_create_account: true)
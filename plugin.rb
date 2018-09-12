# name: sebrae-login
# about: Plugin responsavel por realizar a autenticação via SebraeID
# version: 0.0.1
# authors: Vitor

gem 'omniauth-sebraeid', 0.1


class SebraeIDAuthenticator < ::Auth::Authenticator

  CLIENT_ID = '167'
  CLIENT_SECRET = 'ZCjUMfi1-evtZolCuR9z'

  def name
    'SebraeID'
  end

  def after_authenticate(auth_token)
    result = Auth::Result.new

    # grap the info we need from omni auth
    data = auth_token[:info]
    name = data["FirstName"]
    mv_uid = auth_token["ID"]
    email = data['Email']

    # plugin specific data storage
    current_info = ::PluginStore.get("sID", "mv_uid_#{mv_uid}")

    result.user =
      if current_info
        User.where(id: current_info[:user_id]).first
      end

    result.name = name
    result.extra_data = { mv_uid: mv_uid }
    result.email = email

    result
  end

  def after_create_account(user, auth)
    data = auth[:extra_data]
    ::PluginStore.set("sID", "mv_uid_#{data[:mv_uid]}", {user_id: user.id })
  end

  def register_middleware(omniauth)
    omniauth.provider :SebraeID,
     CLIENT_ID,
     CLIENT_SECRET
  end
end


auth_provider :title => 'with SebraeID Accounts',
    :message => 'Login via SebraeID',
    :frame_width => 920,
    :frame_height => 800,
    :authenticator => SebraeIDAuthenticator.new


# We ship with zocial, it may have an icon you like http://zocial.smcllns.com/sample.html
#  in our current case we have an icon for vk
register_css <<CSS

.btn-social.vkontakte {
  background: #46698f;
}

.btn-social.vkontakte:before {
  content: "N";
}

CSS
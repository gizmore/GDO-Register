#
# Activation method.
# The IP checkup and stuff is done via events.
#
# @event :gdo_before_user_activation GDO_UserActivation
# @event :gdo_user_activation GDO_User, GDO_UserActivation
#
class GDO::Register::Method::Activate < GDO::Method::Base
  
  def paramters
    [
      ::GDO::DB::GDT_UInt.new(:id).not_null,
      ::GDO::DB::GDT_Token.new(:token).initial(nil).not_null,
    ]
  end
  
  def execute
    activate(param_var(:id), param_var(:token))
  end
  
  def activate(id, token)
    activation ::GDO::Register::GDO_UserActivation.table.find_where("ua_id=#{id} AND ua_token=#{quote(token)}")
  end
  
  def activation(activation)
    
    # Event
    publish(:gdo_before_user_activation, activation)
    
    # Make user
    user = ::GDO::User::GDO_User.blank({user_type:"member"}.merge(activation.get_vars)).insert
    
    # Delete activation
    activation.delete
    
    # Response
    success(t(:msg_activated))
    
    # Event
    publish(:gdo_user_activation, user, activation)
    
    # Autologin
    activation_autologin(user) if _module.cfg_activation_login

  end
  
  private

  #
  # @see 
  #  
  def activation_autologin(user)
    ::GDO::Core::Log.info("Autologin #{user.display_name}")
    ::GDO::User::GDO_User.current = user # login
    publish(:gdo_user_authenticated, user) # event
  end
  
end
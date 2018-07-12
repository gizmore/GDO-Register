#
# 
#
class GDO::Register::Method::Activate < GDO::Method::Base
  
  def paramters
    [
      ::GDO::DB::GDT_UInt.new(:id).not_null,
      ::GDO::DB::GDT_Token.new(:token).initial('').not_null,
    ]
  end
  
  def execute
    activate(param_var(:id), param_var(:token))
  end
  
  def activate(id, token)
    activation ::GDO::Register::GDO_UserActivation.table.find_where("ua_id=#{id} AND ua_token=#{quote(token)}")
  end
  
  def activation(activation)
    
    publish(:gdo_before_user_activate, activation)
    
    # Make user
    user = ::GDO::User::GDO_User.blank({user_type:"member"}.merge(activation.get_vars)).insert
    ::GDO::User::GDO_User.current = user
    
    # Delete activation
    activation.delete
    
    # Response
    success(t(:msg_activated))
    
    # Event
    publish(:gdo_user_activation, user, activation)

  end
  
end
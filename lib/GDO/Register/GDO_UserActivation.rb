#
#
#
class GDO::Register::GDO_UserActivation < GDO::Core::GDO
  
  def fields
    [
      ::GDO::DB::GDT_AutoInc.new(:ua_id),
      ::GDO::DB::GDT_Token.new(:ua_token),
      ::GDO::Date::GDT_CreatedAt.new(:ua_created),
      # We copy these to user table
      ::GDO::User::GDT_Username.new(:user_name).not_null,
      ::GDO::Crypto::GDT_PasswordHash.new(:user_password).not_null,
      ::GDO::Mail::GDT_Email.new(:user_email),
      ::GDO::Net::GDT_IP.new(:user_register_ip).not_null,
    ]
  end
  
  def _username
    get_value(:user_name)
  end
  
end
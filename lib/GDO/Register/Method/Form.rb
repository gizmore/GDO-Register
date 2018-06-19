#
# Login Form.
# Basic password authentification.
#
# @version 1.00
# @since 1.00
# @license MIT
# @author gizmore@wechall.net
#
class GDO::Login::Method::Form < ::GDO::Method::Form
  
  #
  # Decorate form for the method.
  # @see GDO::Method::Form
  #
  def form(form)
    form.add_field ::GDO::DB::GDT_String.make('login').not_null # login is either email or username
    form.add_field ::GDO::Form::GDT_Password.make('password').not_null
    form.add_field ::GDO::Form::GDT_Submit.make
    form.add_field ::GDO::Form::GDT_CSRF.make
  end
  
  #
  # Submit button handling
  # @see GDO::Method::Form
  #
  def execute_submit
    # Bruteforce protection!
    ban_check
    # Parameters
    login = parameter(:login)._var
    password = parameter(:password)._var
    # Unknown user?
    user = ::GDO::User::GDO_User.table.get_by_login(login)
    return login_failure(user) if user.nil?
    # Wrong password?
    return login_failure(user) unless user.column(:user_password).validate_password(password)
    # All fine!
    return login_success(user)
  end
  
  def login_success(user)
    ::GDO::User::GDO_User.current = user
    publish(:gdo_user_authenticated, user)
    ::GDO::Method::GDT_Response.make_with(
      ::GDO::UI::GDT_Success.make.text(t(:msg_authenticated))
    )
  end
  
  #################
  ### Ban Check ###
  #################
  def ban_cut; (::Time.now - ban_timeout).to_i; end
  def ban_tries; ::GDO::Login::Module.instance.cfg_tries; end
  def ban_timeout; ::GDO::Login::Module.instance.cfg_timeout; end
  def ban_check
    ban_data = self.ban_data
    num_tries = ban_data[1].to_i
    if num_tries >= ban_tries
      time_left = (Time.now - ban_data[0].to_i).to_i
      raise ::GDO::Login::LoginsExceededException.new(t(:err_login_tries_exceeded, ban_tries, tt(time_left)))
    end
  end
  def ban_data
    ip = ::GDO::Net::GDT_IP.current
    result = ::GDO::Login::GDO_LoginAttempts.table.
     select('UNIX_TIMESTAMP(MIN(la_created)), COUNT(*)').
     where("la_ip=#{quote(ip)} AND la_created>FROM_UNIXTIME(#{quote(ban_cut)})").
     execute.fetch_row
     
  end
  
  ###############
  ### Failure ###
  ###############
  def login_failure(user=nil)
    # insert attempt
    ::GDO::Login::GDO_LoginAttempts.table.login_failure(user)
    # raise exception
    raise ::GDO::Login::LoginException.new
  end
  
end

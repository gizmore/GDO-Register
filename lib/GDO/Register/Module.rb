#
# Register module for GDO.
#
# @version 1.00
# @since 1.00
# @author gizmore@wechall.net
# @license MIT
#
class GDO::Register::Module < GDO::Core::GDO_Module
  ##############
  ### Module ###
  ##############
  is_module __FILE__ # Register as GDO module
  def on_load_language; load_language('lang/register'); end # Load Trans file
  
  ##################
  ### GDO tables ###
  ##################
  #
  # Tables to install.
  #
  def tables
    [
      ::GDO::Register::GDO_UserActivation,
    ]
  end
  
  ##############
  ### Config ###
  ##############
  #
  # Module configuration vars
  # @return [GDT[]]
  #
  def module_config
    [
      ::GDO::DB::GDT_Boolean.new(:register_captcha).initial('0'),
      ::GDO::DB::GDT_Boolean.new(:register_guests).initial('1'),
      ::GDO::DB::GDT_Boolean.new(:email_activation).initial('1'),
      ::GDO::Date::GDT_Duration.new(:email_activation_timeout).initial('72600').min(0).max(31536000),
      ::GDO::DB::GDT_Boolean.new(:admin_activation).initial('0'),
      ::GDO::DB::GDT_UInt.new(:ip_signup_count).initial('1').min(0).max(100),
      ::GDO::Date::GDT_Duration.new(:ip_signup_duration).initial('72600').min(0).max(31536000),
      ::GDO::DB::GDT_Boolean.new(:register_tos).initial('1'),
      ::GDO::Net::GDT_Url.new(:register_tos_url).reachable.allow_local.initial(href('Register', 'TOS')),
      ::GDO::DB::GDT_Boolean.new(:activation_login).initial('1'),
    ]
  end
  def cfg_captcha; config_value(:register_captcha); end
  def cfg_email_activation; config_value(:email_activation); end
  def cfg_tos; config_value(:register_tos); end
  def cfg_ip_timeout; config_value(:ip_signup_duration); end
  def cfg_ip_signup_max; config_value(:ip_signup_count); end
  def cfg_tos_url; config_value(:register_tos_url); end

end

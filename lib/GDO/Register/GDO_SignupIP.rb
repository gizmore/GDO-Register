#
# Hold records of signup and activation IP.
# Uses GDO Events to hook into signup process.
#
# @version 1.00
# @since 1.00
# @author gizmore@wechall.net
# @license MIT
#
class GDO::Register::GDO_SignupIP < GDO::Core::GDO
  
  extend ::GDO::Core::WithEvents
  
  def fields
    [
      ::GDO::DB::GDT_AutoInc.new(:sip_id),
      ::GDO::User::GDT_User.new(:sip_uid).not_null,
      ::GDO::Net::GDT_IP.new(:sip_ip).not_null,
      ::GDO::Date::GDT_CreatedAt.new(:sip_created_at),
    ]
  end

  def self.max
    ::GDO::Register::Module.instance.cfg_ip_signup_max
  end
  
  def self.can_activate?
    mod = ::GDO::Register::Module.instance
    max = mod.cfg_ip_signup_max
    return true if max <= 0
    ip = quote(::GDO::Net::GDT_IP.current)
    cut = Time.new - mod.cfg_ip_timeout
    count = table.count_where("sip_ip=#{ip} AND sip_created_at>#{quote(cut)}")
    count < max
  end
  
  # Hook into activation
  subscribe(:gdo_user_activation, :gdo_activation_ip_collection) do |user, activation|
    ::GDO::Core::Log.info("Logged activation IP")
    blank(
      :sip_uid => user.id,
      :sip_ip => ::GDO::Net::GDT_IP.current,
    ).insert
  end
  
  # Subscription check
  subscribe(:gdo_before_user_activate, :gdo_activation_ip_check) do |activation|
    if !can_activate?
      raise ::GDO::Core::Exception.new(t(:err_ip_signup_max_reached, max))
    end
  end
  
end

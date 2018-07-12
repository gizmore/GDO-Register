#
# Basic on site registration
#
# @version 1.00
# @since 1.00
# @license MIT
# @author gizmore@wechall.net
#
class GDO::Register::Method::Form < ::GDO::Method::Form
  
  #
  # Decorate form for the method.
  # @see GDO::Method::Form
  #
  def form(form)
    mod = ::GDO::Register::Module.instance
    
    form.add_field(::GDO::User::GDT_Username.new(:user_name).not_null)
    form.add_field(::GDO::Form::GDT_Validator.new.validator(:user_name, self, 'validate_unique_ip'))
    form.add_field(::GDO::Form::GDT_Validator.new.validator(:user_name, self, 'validate_unique_username'))

    form.add_field(::GDO::Form::GDT_Password.new(:user_password).not_null)
    
    if mod.cfg_email_activation
      form.add_field(::GDO::Mail::GDT_Email.new(:user_email).not_null);
      form.add_field(::GDO::Form::GDT_Validator.new.validator(:user_email, self, 'validate_unique_email'))
    end
    
    if mod.cfg_tos
      form.add_field ::GDO::DB::GDT_Boolean.new(:tos).label(t(:tos_label, mod.cfg_tos_url)).not_null
      form.add_field(::GDO::Form::GDT_Validator.new.validator(:tos, self, 'validate_tos'))
    end
    
    if mod.cfg_captcha
      form.add_field ::GDO::Captcha::GDT_Captcha.new
    end
    
    form.add_field ::GDO::Form::GDT_Submit.new.label(t(:btn_register))
    form.add_field ::GDO::Form::GDT_CSRF.new

  end
  
  ##################
  ### Validators ###
  ##################
  def validate_unique_ip(form, gdt)
    sip = ::GDO::Register::GDO_SignupIP
    sip.can_activate? ? true : gdt.error(t(:err_ip_signup_max_reached, sip.max))
  end

  def validate_unique_username(form, gdt)
    user = ::GDO::User::GDO_User.table.find_by_name(gdt._var)
    user == nil ? true : gdt.error(t(:err_username_taken))
  end

  def validate_unique_email(form, gdt)
    count = ::GDO::User::GDO_User::table.count_where("user_email=#{quote(gdt._var)}")
    count == 0 ? true : gdt.error(t(:err_email_taken))
  end

  def validate_tos(form, gdt)
    gdt._value ? true : gdt.error(t(:err_tos_not_accepted))
  end
  
  ###############
  ### Actions ###
  ###############
  # Add extra message on errors
  def form_invalid(form)
    # error(t(:err_register_failure))
    super
  end

  #
  # Submit button handling
  # @see GDO::Method::Form
  #
  def execute_submit(form)
    mod = ::GDO::Register::Module.instance

    password = form.field(:user_password)
    password.var(GDO::Crypto::GDT_PasswordHash.hash(password._var))
    activation = ::GDO::Register::GDO_UserActivation.blank(form.get_vars)
    activation.set_var(:user_register_ip, ::GDO::Net::GDT_IP.current)
    activation.save
    
    publish(:gdo_user_signup, activation)

    if mod.cfg_admin_activation
      admin_activation(activation)
    elsif mod.cfg_email_activation
      email_activation(activation)
    else
      ::GDO::Register::Method::Activate.new.activation(activation)
    end
  end
  
  def email_activation(activation)
    mail = ::GDO::Mail::Envelope.new
    mail.subject(t(:mail_activate_title, sitename))
    mail.body(t(:mail_activate_body, activation._username, sitename, activation._url))
    mail.receiver(activation._email)
    mail.send_as_html
    success(t(:msg_activation_mail_sent))
  end
  
    def admin_activation(activation)
      byebug
    end

  
end

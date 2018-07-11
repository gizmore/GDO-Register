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
    mod = ::GDO::Register::Module.instance
    max = mod.cfg_ip_signup_max
    return true if max <= 0
    ip = quote(::GDO::Net::GDT_IP.current)
    cut = Time.new - mod.cfg_ip_timeout
    count = ::GDO::User::GDO_User.table.count_where("user_register_ip=#{$ip} AND user_register_time>#{$cut}")
    count < max ? true : gdt.error(t(:err_ip_signup_max_reached, max))
  end

  def validate_unique_username(form, gdt)
    user = ::GDO::User::GDO_User.find_by_name(gdt._var)
    user == nil ? true : gdt.error(t(:err_username_taken))
  end

  def validate_unique_email(form, gdt)
    count = ::GDO::User::GDO_User::table.count_where("user_email=#{quote(gdt._val)}")
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
    
    byebug
    # TODO: GDT_Password should know it comes from form for a save... b 
#    $password = $form->getField('user_password');
#    $password->val(BCrypt::create($password->getVar())->__toString());

    activation = ::GDO::Register::GDO::UserActivation.blank(form.get_form_data)
    activation.set_var(:user_register_ip, ::GDO::Net::GDT_IP.current)
    activation.save
    
    if mod.cfg_email_activation
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
  
end

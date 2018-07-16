require "byebug"
require "mysql2"
require "GDO/Register"

RSpec.describe ::GDO::Register do
  
 it "can switch to bot language" do
   ::GDO::Lang::Trans.instance.iso(:bot)
 end
  
  it "can connect to the database" do
      db = ::GDO::DB::Connection.new('localhost', 'rubygdo', 'rubygdo', 'rubygdo')
      expect(db.get_link).to be_truthy
  end
  
  it "can install the register module" do
    # Clear user table
    mod = ::GDO::User::Module.instance
   ::GDO::Core::ModuleInstaller.instance.drop_module mod
   ::GDO::Core::ModuleInstaller.instance.install_module mod
    # Flush install Register
    mod = ::GDO::Register::Module.instance
   ::GDO::Core::ModuleInstaller.instance.drop_module mod
   ::GDO::Core::ModuleInstaller.instance.install_module mod
  end

  it "can configure the register module" do
    mod = ::GDO::Register::Module.instance
    mod.save_config_var(:register_captcha, '0') # no captcha for tests :/
    mod.save_config_var(:email_activation, '0') #
    mod.save_config_var(:register_tos, '1') # Test TOS too
    expect(mod.cfg_captcha).to eq(false)
  end
  
  it "does display a register form" do
    code, headers, page = ::GDO::Test::Helper.first_gdo_request(mo: "Register", me: "Form")
    response = ::GDO::Core::Application.response
    expect(response._fields[0]).to be_a(::GDO::Form::GDT_Form) # the response is just a form
    expect(response._fields[0]._fields.length >= 4).to be_truthy # with at least 4 fields
    expect(code).to eq(200) # and has 200 response code
  end
  
  it "can succeed at registration" do
    code, headers, page = ::GDO::Test::Helper.next_gdo_request("POST", mo: "Register", me: "Form", user_name: "Lazer", user_password:"11111111", user_email: "lazer@gizmore.org", tos: "1", submit:"Submit")
    response = ::GDO::Core::Application.response
    expect(code).to eq(200)
    expect(response._fields[0]).to be_a(::GDO::UI::GDT_Success) # the response is a success message!
    expect(::GDO::User::GDO_User.table.count_where).to eq(2) # We have 2 users!
    expect(::GDO::User::GDO_User.current.display_name).to eq("Lazer") # And it's Lazer :)
    expect(::GDO::Register::GDO_SignupIP.table.count_where).to eq(1) # remembers IP
    expect(::GDO::Register::GDO_UserActivation.table.count_where).to eq(0) # was cleaned up
  end
  
  it "cannot register twice with the same data" do
    code, headers, page = ::GDO::Test::Helper.next_gdo_request("POST",
      mo: "Register",
      me: "Form",
      user_name: "Lazer",
      user_password:"11111111",
      user_email: "lazer@gizmore.org",
      tos: "1",
      submit:"Submit")
    response = ::GDO::Core::Application.response

    expect(code).to eq(200)
    form = response._fields[0]
    expect(form.has_errors?).to be(true)
  end
  
  it "can force accepting tos" do
    code, headers, page = ::GDO::Test::Helper.next_gdo_request("POST", mo: "Register", me: "Form", user_name: "Lazer2", user_password:"11111111", user_email: "lazer2@gizmore.org", tos: "0", submit:"Submit")
    response = ::GDO::Core::Application.response
    form = response._fields[0]
    expect(code).to eq(200)
    expect(form.has_errors?).to be(true)
    expect(form.field(:tos).has_error?).to be(true)
  end
  
  it "can exceed max signup ip count" do
    code, headers, page = ::GDO::Test::Helper.next_gdo_request("POST", mo: "Register", me: "Form", user_name: "Lazer2", user_password:"11111111", user_email: "lazer2@gizmore.org", tos: "0", submit:"Submit")
    response = ::GDO::Core::Application.response
    form = response._fields[0]
    expect(form.field(:user_name).has_error?).to be(true)
    expect(form.field(:user_name)._error).to eq("err_ip_signup_max_reached[1]")
  end

end

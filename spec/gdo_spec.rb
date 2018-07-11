require "byebug"
require "mysql2"
require "GDO/Register"

class Object
  # request helper
  def first_gdo_request(query={})
    cookie = ::GDO::User::GDO_Session::MAGIC_VALUE
    gdo_request(query, cookie)
  end
  def next_gdo_request(query={})
    cookie = ::GDO::Core::Application.cookie(::GDO::User::GDO_Session::COOKIE_NAME)
    gdo_request(query, cookie)
  end
  def gdo_request(query, cookie)
    query_string = ""
    query.each do |k,v|
      query_string += "&" unless query_string.empty?
      query_string += "#{k}=#{URI::encode(v)}"
    end
    env = {
      "QUERY_STRING" => query_string,
      'COOKIE' => cookie,
    }
    ::GDO::Core::Application.call(env)
  end
end

RSpec.describe ::GDO::Register do
  
#  it "can switch to bot language" do
#    ::GDO::Lang::Trans.instance.iso(:bot)
#  end
  
  it "can connect to the database" do
      db = ::GDO::DB::Connection.new('localhost', 'rubygdo', 'rubygdo', 'rubygdo')
      expect(db.get_link).to be_truthy
  end
  
  it "can install the register module" do
    mod = ::GDO::Register::Module.instance
   ::GDO::Core::ModuleInstaller.instance.drop_module mod
   ::GDO::Core::ModuleInstaller.instance.install_module mod
  end

  it "can configure the register module" do
    mod = ::GDO::Register::Module.instance
    mod.save_config_var(:register_captcha, '0') # no captcha for tests :/
    mod.save_config_var(:email_activation, '0') #
    expect(mod.cfg_captcha).to eq(false)
  end
  
  it "does display a register form" do
    code, headers, page = first_gdo_request(mo: "Register", me: "Form")
    response = ::GDO::Core::Application.response
    expect(response._fields[0]).to be_a(::GDO::Form::GDT_Form) # the response is just a form
    expect(response._fields[0]._fields.length >= 4).to be_truthy # with at least 4 fields
    expect(code).to eq(200) # and has 200 response code
  end
  
  it "can succeed at registration" do
    code, headers, page = next_gdo_request(mo: "Register", me: "Form")
    next_gdo_request

  end

end

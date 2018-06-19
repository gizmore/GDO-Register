require "byebug"
require "mysql2"
require "GDO/Register"

RSpec.describe ::GDO::Login do
  
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

end

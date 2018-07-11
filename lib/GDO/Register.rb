require "GDO"
#
# Provides basic authentification.
#
# @see GDO
# @author gizmore
#
module GDO::Register
  VERSION = 1.00    # GDO-1.00
  extend ::GDO::Autoloader # Own GDO Autoloader
end

# Autoload module
::GDO::Register::Module.instance

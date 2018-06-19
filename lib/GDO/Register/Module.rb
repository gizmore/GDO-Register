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
    ]
  end
      
end

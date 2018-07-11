#
#
#
class GDO::Register::Method::Activate < GDO::Method::Base
  
  def paramters
    [
      ::GDO::DB::GDT_UInt.new(:id).not_null,
      ::GDO::DB::GDT_Token.new(:token).initial('').not_null,
    ]
  end
  
  def execute
    activate(param_var(:id), param_var(:token))
  end
  
  def activate(id, token)
    activation ::GDO::Register::GDO_UserActivation.table.select.where("ua_id=#{id} AND ua_token=#{quote(token)}").first.execute.fetch_object
  end
  
  def activation(activation)
    
  end
  
end
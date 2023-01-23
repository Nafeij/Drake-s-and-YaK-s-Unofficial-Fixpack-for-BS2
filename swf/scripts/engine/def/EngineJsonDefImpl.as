package engine.def
{
   import engine.core.BoxString;
   import engine.core.logging.ILogger;
   import engine.core.util.StableJson;
   import flash.utils.Dictionary;
   import json.frigga.Frigga;
   import json.frigga.report.FriggaMessage;
   import json.frigga.report.FriggaReport;
   
   public class EngineJsonDefImpl
   {
      
      public static var friggas:Dictionary = new Dictionary();
       
      
      public function EngineJsonDefImpl()
      {
         super();
      }
      
      public static function validate(param1:Object, param2:Object, param3:ILogger, param4:BoxString) : FriggaReport
      {
         var _loc8_:FriggaMessage = null;
         if(!param2)
         {
            throw new ArgumentError("null schema");
         }
         var _loc5_:Frigga = getFrigga(param2);
         var _loc6_:String = _loc5_.schema.getHeader().name;
         if(!_loc6_)
         {
            throw new ArgumentError("All Schemas need names: " + StableJson.stringify(param2,null," "));
         }
         if(!param1)
         {
            _handleErrorMessage("JSON: " + _loc6_ + " null vars",param3,param4);
            return null;
         }
         var _loc7_:FriggaReport = _loc5_.validate(param1);
         if(!_loc7_.isValid())
         {
            for each(_loc8_ in _loc7_.getMessages())
            {
               _handleErrorMessage("JSON: " + _loc6_ + ":(" + param1.id + "):[" + _loc8_.property + "] " + _loc8_.message + " (" + _loc8_.actual + ")",param3,param4);
            }
         }
         return _loc7_;
      }
      
      private static function _handleErrorMessage(param1:String, param2:ILogger, param3:BoxString) : void
      {
         if(param2)
         {
            param2.error(param1);
         }
         if(param3)
         {
            if(!param3.value)
            {
               param3.value = "";
            }
            else
            {
               param3.value += "\n";
            }
            param3.value += param1;
         }
      }
      
      private static function getFrigga(param1:Object) : Frigga
      {
         var _loc2_:Frigga = friggas[param1] as Frigga;
         if(!_loc2_)
         {
            _loc2_ = Frigga.forSchema(param1);
            friggas[param1] = _loc2_;
         }
         return _loc2_;
      }
   }
}

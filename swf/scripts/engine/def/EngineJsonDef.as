package engine.def
{
   import engine.core.BoxString;
   import engine.core.logging.ILogger;
   import engine.core.util.StableJson;
   import engine.core.util.StringUtil;
   
   public class EngineJsonDef
   {
      
      public static var _validate:Function;
      
      private static var em:BoxString = new BoxString();
       
      
      public function EngineJsonDef()
      {
         super();
      }
      
      public static function validateThrow(param1:Object, param2:Object, param3:ILogger) : void
      {
         var _loc5_:String = null;
         if(_validate == null)
         {
            return;
         }
         em.value = null;
         var _loc4_:Object = _validate(param1,param2,param3,em);
         if(!_loc4_ || !_loc4_.isValid())
         {
            _loc5_ = StableJson.stringify(param1,null," ");
            _loc5_ = StringUtil.truncateLines(_loc5_,10,500);
            throw new ArgumentError("failed to parse " + param2.name + "\n" + em + "\n" + _loc5_);
         }
      }
   }
}

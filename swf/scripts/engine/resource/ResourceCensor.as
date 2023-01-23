package engine.resource
{
   import engine.core.logging.ILogger;
   import flash.utils.Dictionary;
   
   public class ResourceCensor
   {
       
      
      public var id:String;
      
      public var map:Dictionary;
      
      public function ResourceCensor(param1:String)
      {
         this.map = new Dictionary();
         super();
         this.id = param1;
      }
      
      public function appendJson(param1:Object, param2:ILogger) : ResourceCensor
      {
         var _loc3_:* = null;
         var _loc4_:String = null;
         for(_loc3_ in param1)
         {
            _loc4_ = param1[_loc3_];
            this.map[_loc3_] = _loc4_;
            if(param2.isDebugEnabled)
            {
               param2.d("CENS","mapping [" + _loc3_ + "] to [" + _loc4_ + "]");
            }
         }
         return this;
      }
      
      public function getCensoredUrl(param1:String) : String
      {
         var _loc2_:String = this.map[param1];
         return !!_loc2_ ? _loc2_ : param1;
      }
   }
}

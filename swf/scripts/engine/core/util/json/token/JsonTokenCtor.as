package engine.core.util.json.token
{
   import engine.core.util.json.JsonToken;
   
   public class JsonTokenCtor
   {
       
      
      public function JsonTokenCtor()
      {
         super();
      }
      
      public static function ctor(param1:String, param2:int, param3:int) : JsonToken
      {
         var _loc4_:JsonToken = _ctor(param1);
         _loc4_.setup(param1,param2,param3);
         return _loc4_;
      }
      
      private static function _ctor(param1:String) : JsonToken
      {
         switch(param1)
         {
            case "{":
               return new JsonToken_ScopeOpen();
            case "}":
               return new JsonToken_ScopeClose();
            default:
               return new JsonToken();
         }
      }
   }
}

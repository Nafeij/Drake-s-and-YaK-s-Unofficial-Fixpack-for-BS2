package engine.core.util.json
{
   public class JsonToken
   {
       
      
      public var value:String;
      
      public var pos:int;
      
      public var line:int;
      
      public function JsonToken()
      {
         super();
      }
      
      public function setup(param1:String, param2:int, param3:int) : JsonToken
      {
         this.value = param1;
         this.pos = param2;
         this.line = param3;
         return this;
      }
   }
}

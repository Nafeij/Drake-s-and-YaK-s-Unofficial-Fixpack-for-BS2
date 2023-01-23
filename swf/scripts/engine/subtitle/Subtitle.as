package engine.subtitle
{
   import engine.core.logging.ILogger;
   import engine.core.util.StringUtil;
   import engine.def.EngineJsonDef;
   
   public class Subtitle
   {
      
      public static const schema:Object = {
         "name":"Subtitle",
         "type":"object",
         "properties":{
            "text":{"type":"string"},
            "start":{"type":"number"},
            "end":{"type":"number"}
         }
      };
       
      
      public var start:int = 0;
      
      public var end:int = 0;
      
      public var text:String;
      
      public function Subtitle()
      {
         super();
      }
      
      public function toString() : String
      {
         return "[" + this.start + "," + this.end + "]: " + this.text.substr(0,10) + "...";
      }
      
      public function fromJson(param1:Object, param2:ILogger) : Subtitle
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.start = param1.start;
         this.end = param1.end;
         this.text = param1.text;
         this.text = StringUtil.trim(this.text);
         return this;
      }
      
      public function toJson() : Object
      {
         return {
            "start":this.start,
            "end":this.end,
            "text":this.text
         };
      }
   }
}

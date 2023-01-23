package engine.saga
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   import engine.expression.ISymbols;
   import engine.expression.Parser;
   
   public class SagaCreditsImageDef
   {
      
      public static const schema:Object = {
         "name":"SagaCreditsImageDef",
         "type":"object",
         "properties":{
            "url":{"type":"string"},
            "prereq":{
               "type":"string",
               "optional":true
            }
         }
      };
       
      
      public var url:String;
      
      public var prereq:String;
      
      public var json:Object;
      
      public function SagaCreditsImageDef()
      {
         super();
      }
      
      public function fromJson(param1:Object, param2:ILogger) : SagaCreditsImageDef
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.json = param1;
         this.url = param1.url;
         this.prereq = param1.prereq;
         return this;
      }
      
      public function toJson() : Object
      {
         return this.json;
      }
      
      public function checkPrereq(param1:ISymbols, param2:ILogger) : Boolean
      {
         if(!this.prereq || !param1)
         {
            return true;
         }
         var _loc3_:Parser = new Parser(this.prereq,null);
         if(!_loc3_.exp)
         {
            param2.error("SagaCreditsImageDef failed to parse expression [" + this.prereq + "]:\n" + _loc3_.printParseErrors());
            new Parser(this.prereq,null);
            return false;
         }
         var _loc4_:Number = _loc3_.evaluate(param1,false,param2);
         return _loc4_ != 0;
      }
   }
}

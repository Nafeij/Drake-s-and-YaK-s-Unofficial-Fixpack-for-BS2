package engine.landscape.travel.def
{
   import engine.core.logging.ILogger;
   
   public class LandscapeParamDef
   {
      
      public static const schema:Object = {
         "name":"TravelParamDef",
         "type":"object",
         "properties":{
            "controlId":{"type":"string"},
            "targetProperty":{"type":"string"}
         }
      };
       
      
      public var controlId:String;
      
      public var targetProperty:String;
      
      public function LandscapeParamDef()
      {
         super();
      }
      
      public function toString() : String
      {
         return "control [" + this.controlId + "] target [" + this.targetProperty + "]";
      }
      
      public function fromJson(param1:Object, param2:ILogger) : LandscapeParamDef
      {
         this.controlId = param1.controlId;
         this.targetProperty = param1.targetProperty;
         return this;
      }
      
      public function toJson() : Object
      {
         return {
            "controlId":this.controlId,
            "targetProperty":this.targetProperty
         };
      }
   }
}

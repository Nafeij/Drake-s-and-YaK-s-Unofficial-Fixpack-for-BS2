package engine.landscape.travel.def
{
   import engine.core.logging.ILogger;
   
   public class TravelParamControlDef
   {
      
      public static const schema:Object = {
         "name":"TravelParamControlDef",
         "type":"object",
         "properties":{
            "id":{"type":"string"},
            "boundPosStart":{"type":"number"},
            "boundPosEnd":{"type":"number"},
            "lerpPosStart":{"type":"number"},
            "lerpPosEnd":{"type":"number"},
            "valueStart":{"type":"number"},
            "valueEnd":{"type":"number"}
         }
      };
       
      
      public var boundPosStart:Number = 0;
      
      public var boundPosEnd:Number = 1;
      
      public var lerpPosStart:Number = 0.25;
      
      public var lerpPosEnd:Number = 0.75;
      
      public var valueStart:Number = 0;
      
      public var valueEnd:Number = 1;
      
      public var id:String;
      
      public function TravelParamControlDef()
      {
         super();
      }
      
      public function fromJson(param1:Object, param2:ILogger) : TravelParamControlDef
      {
         this.id = param1.id;
         this.boundPosStart = param1.boundPosStart;
         this.boundPosEnd = param1.boundPosEnd;
         this.lerpPosStart = param1.lerpPosStart;
         this.lerpPosEnd = param1.lerpPosEnd;
         this.valueStart = param1.valueStart;
         this.valueEnd = param1.valueEnd;
         return this;
      }
      
      public function toJson() : Object
      {
         return {
            "id":this.id,
            "boundPosStart":this.boundPosStart,
            "boundPosEnd":this.boundPosEnd,
            "lerpPosStart":this.lerpPosStart,
            "lerpPosEnd":this.lerpPosEnd,
            "valueStart":this.valueStart,
            "valueEnd":this.valueEnd
         };
      }
   }
}

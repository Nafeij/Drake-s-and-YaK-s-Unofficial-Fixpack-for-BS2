package engine.gui.tooltip
{
   import engine.core.logging.ILogger;
   
   public class SimpleTooltipStyleDisplayTripletDef
   {
      
      public static const schema:Object = {
         "name":"TooltipStyleDef",
         "type":"object",
         "properties":{
            "url_left":{"type":"string"},
            "url_right":{"type":"string"},
            "url_center":{"type":"string"},
            "offset_left":{"type":"number"},
            "offset_right":{"type":"number"},
            "offset_center":{"type":"number"}
         }
      };
       
      
      public var url_left:String;
      
      public var url_right:String;
      
      public var url_center:String;
      
      public var offset_left:int;
      
      public var offset_right:int;
      
      public var offset_center:int;
      
      public function SimpleTooltipStyleDisplayTripletDef()
      {
         super();
      }
      
      public function setup(param1:String, param2:String, param3:String, param4:int, param5:int, param6:int) : void
      {
         this.url_left = param1;
         this.url_center = param2;
         this.url_right = param3;
         this.offset_left = param4;
         this.offset_right = param6;
         this.offset_center = param5;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : SimpleTooltipStyleDisplayTripletDef
      {
         this.url_left = param1.url_left;
         this.url_right = param1.url_right;
         this.url_center = param1.url_center;
         this.offset_left = param1.offset_left;
         this.offset_right = param1.offset_right;
         this.offset_center = param1.offset_center;
         return this;
      }
      
      public function toJson() : Object
      {
         return {
            "url_left":(!!this.url_left ? this.url_left : ""),
            "url_right":(!!this.url_right ? this.url_right : ""),
            "url_center":(!!this.url_center ? this.url_center : ""),
            "offset_left":this.offset_left,
            "offset_right":this.offset_right,
            "offset_center":this.offset_center
         };
      }
   }
}

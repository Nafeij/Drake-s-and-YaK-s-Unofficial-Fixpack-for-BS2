package engine.landscape.def
{
   import engine.core.logging.ILogger;
   import engine.def.PointVars;
   import flash.geom.Point;
   
   public class LandscapeClickableTooltipDef
   {
      
      public static const schema:Object = {
         "name":"LandscapeClickableTooltipDef",
         "type":"object",
         "properties":{
            "text":{"type":"string"},
            "style":{
               "type":"string",
               "optional":true
            },
            "center":{
               "type":"string",
               "optional":true
            },
            "prereq_showall":{
               "type":"string",
               "optional":true
            }
         }
      };
       
      
      public var text:String;
      
      public var style:String;
      
      public var center:Point;
      
      public var sprite:LandscapeSpriteDef;
      
      public var prereq_showall:String;
      
      public function LandscapeClickableTooltipDef(param1:LandscapeSpriteDef)
      {
         super();
         this.sprite = param1;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : LandscapeClickableTooltipDef
      {
         this.text = param1.text;
         this.style = param1.style;
         this.center = PointVars.parseString(param1.center,null);
         this.prereq_showall = param1.prereq_showall;
         return this;
      }
      
      public function toJson() : Object
      {
         var _loc1_:Object = {"text":this.text};
         if(this.prereq_showall)
         {
            _loc1_.prereq_showall = this.prereq_showall;
         }
         if(this.sprite.layer.nameId == "dark_clicks")
         {
            if(!this.style)
            {
               this.style = "dark_small";
            }
            else if(this.style == "large")
            {
               this.style = "dark_large";
            }
         }
         if(this.style)
         {
            _loc1_.style = this.style;
         }
         if(this.center)
         {
            _loc1_.center = PointVars.saveString(this.center);
         }
         return _loc1_;
      }
      
      public function get tooltipX() : int
      {
         return !!this.center ? this.center.x : 0;
      }
      
      public function set tooltipX(param1:int) : void
      {
         var _loc2_:int = this.tooltipY;
         this.setTooltipPos(param1,_loc2_);
      }
      
      public function get tooltipY() : int
      {
         return !!this.center ? this.center.y : 0;
      }
      
      public function set tooltipY(param1:int) : void
      {
         var _loc2_:int = this.tooltipX;
         this.setTooltipPos(_loc2_,param1);
      }
      
      public function setTooltipPos(param1:int, param2:int) : void
      {
         var _loc3_:int = this.tooltipX;
         var _loc4_:int = this.tooltipY;
         if(_loc3_ == param1 && _loc4_ == param2)
         {
            return;
         }
         if(!this.center)
         {
            this.center = new Point(param1,param2);
         }
         else
         {
            this.center.setTo(param1,param2);
         }
         this.sprite.landscape.notifySpriteChanged_tooltip(this.sprite);
      }
   }
}

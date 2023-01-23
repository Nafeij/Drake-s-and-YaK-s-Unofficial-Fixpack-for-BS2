package engine.gui.tooltip
{
   import engine.core.logging.ILogger;
   
   public class SimpleTooltipStyleDef
   {
      
      public static var genericSmall_norm:SimpleTooltipStyleDef = ctorGenericSmall_norm();
      
      public static var genericLarge_norm:SimpleTooltipStyleDef = ctorGenericLarge_norm();
      
      public static var genericSmall_dark:SimpleTooltipStyleDef = ctorGenericSmall_dark();
      
      public static var genericLarge_dark:SimpleTooltipStyleDef = ctorGenericLarge_dark();
      
      private static var lastOrdinal:int = 0;
      
      public static const schema:Object = {
         "name":"TooltipStyleDef",
         "type":"object",
         "properties":{
            "id":{"type":"string"},
            "triplet_bg":{"type":SimpleTooltipStyleDisplayTripletDef.schema},
            "triplet_glow":{"type":SimpleTooltipStyleDisplayTripletDef.schema},
            "fontFamily":{"type":"string"},
            "fontSize":{"type":"number"},
            "fontColor":{"type":"string"},
            "fontGlow":{"type":"string"},
            "marginLeft":{"type":"number"},
            "marginTop":{"type":"number"},
            "marginRight":{"type":"number"}
         }
      };
       
      
      public var id:String;
      
      public var triplet_bg:SimpleTooltipStyleDisplayTripletDef;
      
      public var triplet_glow:SimpleTooltipStyleDisplayTripletDef;
      
      public var fontFamily:String;
      
      public var fontSize:int;
      
      public var fontColor:uint;
      
      public var fontGlow;
      
      public var marginLeft:int;
      
      public var marginTop:int;
      
      public var marginRight:int;
      
      public var ordinal:int;
      
      public function SimpleTooltipStyleDef()
      {
         this.triplet_bg = new SimpleTooltipStyleDisplayTripletDef();
         this.triplet_glow = new SimpleTooltipStyleDisplayTripletDef();
         super();
         this.ordinal = ++lastOrdinal;
      }
      
      public static function ctorGenericSmall_norm() : SimpleTooltipStyleDef
      {
         var _loc1_:SimpleTooltipStyleDef = new SimpleTooltipStyleDef();
         _loc1_.triplet_bg.setup("common/gui/tooltip/tab_sm/tooltip_left.png","common/gui/tooltip/tab_sm/tooltip_middle.png","common/gui/tooltip/tab_sm/tooltip_right.png",0,0,0);
         _loc1_.triplet_glow.setup("common/gui/tooltip/tab_sm/hover_left.png","common/gui/tooltip/tab_sm/hover_middle.png","common/gui/tooltip/tab_sm/hover_right.png",-3,-3,-3);
         _loc1_.id = "small";
         _loc1_.fontFamily = "Vinque";
         _loc1_.fontSize = 16;
         _loc1_.fontColor = 16777181;
         _loc1_.fontGlow = 2281701376;
         _loc1_.marginLeft = 10;
         _loc1_.marginTop = 0;
         _loc1_.marginRight = 10;
         return _loc1_;
      }
      
      public static function ctorGenericLarge_norm() : SimpleTooltipStyleDef
      {
         var _loc1_:SimpleTooltipStyleDef = new SimpleTooltipStyleDef();
         _loc1_.triplet_bg.setup("common/gui/tooltip/tab_lg/tooltip_left_lg.png","common/gui/tooltip/tab_lg/tooltip_middle_lg.png","common/gui/tooltip/tab_lg/tooltip_right_lg.png",0,0,0);
         _loc1_.triplet_glow.setup("common/gui/tooltip/tab_lg/hover_left_lg.png","common/gui/tooltip/tab_lg/hover_middle_lg.png","common/gui/tooltip/tab_lg/hover_right_lg.png",-3,-3,-3);
         _loc1_.id = "large";
         _loc1_.fontFamily = "Vinque";
         _loc1_.fontSize = 32;
         _loc1_.fontColor = 16777181;
         _loc1_.fontGlow = 2281701376;
         _loc1_.marginLeft = 50;
         _loc1_.marginTop = 10;
         _loc1_.marginRight = 50;
         return _loc1_;
      }
      
      public static function ctorGenericSmall_dark() : SimpleTooltipStyleDef
      {
         var _loc1_:SimpleTooltipStyleDef = new SimpleTooltipStyleDef();
         _loc1_.triplet_bg.setup("common/gui/tooltip/tab_dark_sm/tooltip_left.png","common/gui/tooltip/tab_dark_sm/tooltip_middle.png","common/gui/tooltip/tab_dark_sm/tooltip_right.png",0,0,0);
         _loc1_.triplet_glow.setup("common/gui/tooltip/tab_dark_sm/hover_left.png","common/gui/tooltip/tab_dark_sm/hover_middle.png","common/gui/tooltip/tab_dark_sm/hover_right.png",-3,-3,-3);
         _loc1_.id = "dark_small";
         _loc1_.fontFamily = "Vinque";
         _loc1_.fontSize = 16;
         _loc1_.fontColor = 16777181;
         _loc1_.fontGlow = 2281701376;
         _loc1_.marginLeft = 10;
         _loc1_.marginTop = 0;
         _loc1_.marginRight = 10;
         return _loc1_;
      }
      
      public static function ctorGenericLarge_dark() : SimpleTooltipStyleDef
      {
         var _loc1_:SimpleTooltipStyleDef = new SimpleTooltipStyleDef();
         _loc1_.triplet_bg.setup("common/gui/tooltip/tab_dark_lg/tooltip_left_lg.png","common/gui/tooltip/tab_dark_lg/tooltip_middle_lg.png","common/gui/tooltip/tab_dark_lg/tooltip_right_lg.png",0,0,0);
         _loc1_.triplet_glow.setup("common/gui/tooltip/tab_dark_lg/hover_left_lg.png","common/gui/tooltip/tab_dark_lg/hover_middle_lg.png","common/gui/tooltip/tab_dark_lg/hover_right_lg.png",-3,-3,-3);
         _loc1_.id = "dark_large";
         _loc1_.fontFamily = "Vinque";
         _loc1_.fontSize = 32;
         _loc1_.fontColor = 16777181;
         _loc1_.fontGlow = 2281701376;
         _loc1_.marginLeft = 50;
         _loc1_.marginTop = 10;
         _loc1_.marginRight = 50;
         return _loc1_;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : SimpleTooltipStyleDef
      {
         this.triplet_bg.fromJson(param1.triplet_bg,param2);
         this.triplet_glow.fromJson(param1.triplet_glow,param2);
         this.fontFamily = param1.fontSize;
         this.fontSize = param1.fontSize;
         this.fontColor = param1.fontColor;
         if(param1.fontGlow)
         {
            this.fontGlow = uint(param1.fontGlow);
         }
         this.marginLeft = param1.marginLeft;
         this.marginTop = param1.marginTop;
         this.marginRight = param1.marginRight;
         return this;
      }
      
      public function toJson() : Object
      {
         return {
            "triplet_bg":this.triplet_bg.toJson(),
            "triplet_glow":this.triplet_glow.toJson(),
            "fontFamily":this.fontFamily,
            "fontSize":this.fontSize,
            "fontColor":this.fontColor.toString(16),
            "fontGlow":(!!this.fontGlow ? this.fontGlow.toString(16) : ""),
            "marginLeft":this.marginLeft,
            "marginTop":this.marginTop,
            "marginRight":this.marginRight
         };
      }
   }
}

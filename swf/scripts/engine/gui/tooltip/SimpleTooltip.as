package engine.gui.tooltip
{
   import engine.core.locale.Locale;
   import engine.landscape.view.ISimpleTooltipsLayer;
   import engine.landscape.view.ISimpleTooltipsLayerHandle;
   import engine.scene.IDisplayObjectWrapperGenerator;
   import engine.scene.ITextBitmapGenerator;
   import flash.display.BitmapData;
   
   public class SimpleTooltip
   {
       
      
      public var style:SimpleTooltipStyle;
      
      public var tbg:ITextBitmapGenerator;
      
      public var token:String;
      
      public var text:String;
      
      public var locale:Locale;
      
      public var def:SimpleTooltipStyleDef;
      
      public var dowg:IDisplayObjectWrapperGenerator;
      
      public var triplet_bg:SimpleTooltipDisplayTriplet;
      
      public var triplet_glow:SimpleTooltipDisplayTriplet;
      
      public var qh_text:ISimpleTooltipsLayerHandle;
      
      public var layer:ISimpleTooltipsLayer;
      
      public var id:String;
      
      private var _visible:Boolean;
      
      public var suppressedByPrereq:Boolean;
      
      private var _glowing:Boolean;
      
      public var centerX:Number = 0;
      
      public function SimpleTooltip(param1:String, param2:SimpleTooltipStyle, param3:ITextBitmapGenerator, param4:IDisplayObjectWrapperGenerator, param5:ISimpleTooltipsLayer)
      {
         super();
         if(!param2)
         {
            throw new ArgumentError("null style");
         }
         if(!param3)
         {
            throw new ArgumentError("no ITextBitmapGenerator");
         }
         this.layer = param5;
         this.id = "tt_" + param1;
         this.style = param2;
         this.def = param2.def;
         this.tbg = param3;
         this.dowg = param4;
         this.triplet_bg = new SimpleTooltipDisplayTriplet(param2.def.ordinal * 2 + 0,param2.triplet_bg);
         this.triplet_glow = new SimpleTooltipDisplayTriplet(param2.def.ordinal * 2 + 1,param2.triplet_glow);
         param2.waitStyleLoaded(this.handleStyleLoaded);
      }
      
      public function set visible(param1:Boolean) : void
      {
         this._visible = param1;
         this.triplet_bg.visible = param1;
         this.triplet_glow.visible = param1 && this.triplet_glow.visible;
         if(this.qh_text)
         {
            this.qh_text.visible = this._visible;
         }
      }
      
      public function get visible() : Boolean
      {
         return this._visible;
      }
      
      private function handleStyleLoaded(param1:SimpleTooltipStyle) : void
      {
         this.triplet_bg.handleStyleLoaded(this.layer);
         this.triplet_glow.handleStyleLoaded(this.layer);
         this.triplet_glow.visible = false;
      }
      
      public function set glowing(param1:Boolean) : void
      {
         this._glowing = param1;
         this.updateGlowing();
      }
      
      public function get glowing() : Boolean
      {
         return this._glowing;
      }
      
      public function updateGlowing() : void
      {
         this.triplet_glow.visible = this._glowing;
      }
      
      public function cleanup() : void
      {
         this.release_textResources();
         this.triplet_bg.cleanup();
         this.triplet_bg = null;
         this.triplet_glow.cleanup();
         this.triplet_glow = null;
      }
      
      private function release_textResources() : void
      {
         if(this.qh_text)
         {
            this.qh_text.remove();
            this.qh_text = null;
         }
      }
      
      public function setPos(param1:Number, param2:Number, param3:Number, param4:Number) : void
      {
         this.triplet_bg && this.triplet_bg.setGroupPos(param1 + param3,param2 + param4);
         this.triplet_glow && this.triplet_glow.setGroupPos(param1 + param3,param2 + param4);
         this.qh_text && this.qh_text.setGroupPos(param1 + param3,param2 + param4);
      }
      
      public function setText(param1:Locale, param2:String) : void
      {
         if(param1 == this.locale && param2 == this.token)
         {
            return;
         }
         this.locale = param1;
         this.token = param2;
         if(param1)
         {
            this.text = param1.translateEncodedToken(param2,false);
         }
         else
         {
            this.text = "";
         }
         this.createTextBmpd();
      }
      
      private function createTextBmpd() : void
      {
         if(!this.text)
         {
            return;
         }
         this.release_textResources();
         var _loc1_:uint = this.def.fontColor;
         var _loc2_:* = this.def.fontGlow;
         var _loc3_:int = this.def.fontSize;
         var _loc4_:String = this.def.fontFamily;
         var _loc5_:BitmapData = this.tbg.generateTextBitmap(_loc4_,_loc3_,_loc1_,_loc2_,this.text,0);
         this.qh_text = this.layer.addQuad_BitmapData(this.id,_loc5_);
         if(this.qh_text)
         {
            this.qh_text.visible = this._visible;
         }
         this.arrangeBackground();
      }
      
      private function arrangeBackground() : void
      {
         if(!this.qh_text)
         {
            return;
         }
         var _loc1_:Number = this.qh_text.width;
         var _loc2_:Number = _loc1_ + this.def.marginLeft + this.def.marginRight;
         var _loc3_:Number = _loc2_ / 2;
         this.centerX = _loc3_;
         var _loc4_:Number = _loc2_;
         var _loc5_:Number = -_loc3_;
         this.qh_text.x = _loc5_ + this.def.marginLeft;
         this.triplet_bg.arrangeBackground(_loc2_);
         this.triplet_glow.arrangeOther(this.triplet_bg);
      }
      
      public function bringToFront() : void
      {
      }
   }
}

package engine.gui
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Linear;
   import engine.core.gp.GpBinder;
   import engine.math.MathUtil;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   
   public class GuiGpBitmap extends Sprite
   {
      
      public static var CAPTION_RIGHT:String = "CAPTION_RIGHT";
      
      public static var CAPTION_LEFT:String = "CAPTION_LEFT";
      
      private static var _hintsEnabled:Boolean;
      
      private static var bmps:Vector.<GuiGpBitmap> = new Vector.<GuiGpBitmap>();
       
      
      private var _gplayer:int;
      
      private var _canVisible:Boolean = true;
      
      public var caption:GuiCaption;
      
      private var _context:IEngineGuiContext;
      
      public var captionPlacement:String;
      
      private var _global:Boolean;
      
      private var _bmp:Bitmap;
      
      private var _alwaysHint:Boolean;
      
      private var _scale:Number = 1;
      
      private var _pulseT:Number = 0;
      
      private var _pulseScale:Number = 0.75;
      
      public function GuiGpBitmap(param1:BitmapData, param2:Boolean)
      {
         this._gplayer = GpBinder.gpbinder.topLayer;
         this._bmp = new Bitmap();
         super();
         GpBinder.gpbinder.addEventListener(GpBinder.EVENT_LAYER,this.binderLayerHandler);
         this._bmp.bitmapData = param1;
         this._bmp.smoothing = true;
         this.mouseEnabled = this.mouseChildren = false;
         this._alwaysHint = param2;
         addChild(this._bmp);
         bmps.push(this);
         this.checkVisible();
      }
      
      public static function get hintsEnabled() : Boolean
      {
         return _hintsEnabled;
      }
      
      public static function set hintsEnabled(param1:Boolean) : void
      {
         var _loc2_:GuiGpBitmap = null;
         if(_hintsEnabled == param1)
         {
            return;
         }
         _hintsEnabled = param1;
         for each(_loc2_ in bmps)
         {
            _loc2_.checkVisible();
         }
      }
      
      override public function get width() : Number
      {
         return (!!this._bmp.bitmapData ? this._bmp.bitmapData.width : 40) * this._scale;
      }
      
      override public function get height() : Number
      {
         return (!!this._bmp.bitmapData ? this._bmp.bitmapData.height : 40) * this._scale;
      }
      
      public function set scale(param1:Number) : void
      {
         super.scaleX = super.scaleY = this._scale = param1;
         if(this.caption)
         {
            this.caption.scale = param1;
         }
      }
      
      override public function set scaleX(param1:Number) : void
      {
         throw new IllegalOperationError("Use scale");
      }
      
      override public function set scaleY(param1:Number) : void
      {
         throw new IllegalOperationError("Use scale");
      }
      
      public function cleanup() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         if(this.caption)
         {
            this.caption.cleanup();
            this.caption = null;
         }
         var _loc1_:int = bmps.indexOf(this);
         bmps.splice(_loc1_,1);
         GpBinder.gpbinder.removeEventListener(GpBinder.EVENT_LAYER,this.binderLayerHandler);
      }
      
      public function createCaption(param1:IEngineGuiContext, param2:String) : GuiCaption
      {
         this.captionPlacement = param2;
         if(!this.caption)
         {
            this.caption = GuiCaption.ctor(param1,null);
            this.caption.scale = this.scaleX;
            this.caption.visible = super.visible;
            if(this.parent)
            {
               this.parent.addChild(this.caption);
            }
         }
         return this.caption;
      }
      
      public function updateCaptionPlacement() : void
      {
         if(!this.caption || !this.visible)
         {
            return;
         }
         switch(this.captionPlacement)
         {
            case CAPTION_LEFT:
               this.caption.x = int(this.x - this.caption.width);
               this.caption.setRightAligned(true);
               break;
            case CAPTION_RIGHT:
               this.caption.x = int(this.x + this.width);
               this.caption.setRightAligned(false);
         }
         this.caption.y = int(this.y + (this.height - this.caption.height) / 2);
         this.caption.visible = this.visible;
      }
      
      private function binderLayerHandler(param1:Event) : void
      {
         this.checkVisible();
      }
      
      override public function set visible(param1:Boolean) : void
      {
         if(param1 == this._canVisible)
         {
            return;
         }
         this._canVisible = param1;
         this.checkVisible();
      }
      
      public function set bitmapData(param1:BitmapData) : void
      {
         this._bmp.bitmapData = param1;
         this._bmp.smoothing = true;
         this.checkVisible();
      }
      
      private function checkVisible() : void
      {
         super.visible = this._bmp.bitmapData != null && this._canVisible && (this.alwaysHint || _hintsEnabled) && (this._global || this._gplayer >= GpBinder.gpbinder.topLayer);
         if(this.caption)
         {
            this.caption.visible = super.visible;
         }
      }
      
      public function get gplayer() : int
      {
         return this._gplayer;
      }
      
      public function set gplayer(param1:int) : void
      {
         if(this._gplayer != param1)
         {
            this._gplayer = param1;
            this.checkVisible();
         }
      }
      
      public function get global() : Boolean
      {
         return this._global;
      }
      
      public function set global(param1:Boolean) : void
      {
         this._global = param1;
         this.checkVisible();
      }
      
      public function set pulseT(param1:Number) : void
      {
         this._pulseT = param1;
         this._bmp.scaleX = this._bmp.scaleY = MathUtil.lerp(this._pulseScale,1,this._pulseT);
         if(this._bmp.bitmapData)
         {
            this._bmp.x = this._bmp.bitmapData.width * (1 - this._bmp.scaleX) / 2;
            this._bmp.y = this._bmp.bitmapData.height * (1 - this._bmp.scaleY) / 2;
         }
      }
      
      public function get pulseT() : Number
      {
         return this._pulseT;
      }
      
      public function pulse() : void
      {
         this.pulseT = 0;
         TweenMax.killTweensOf(this);
         TweenMax.to(this,0.25,{
            "pulseT":1,
            "ease":Linear.easeNone
         });
      }
      
      public function get alwaysHint() : Boolean
      {
         return this._alwaysHint;
      }
      
      public function set alwaysHint(param1:Boolean) : void
      {
         if(this._alwaysHint == param1)
         {
            return;
         }
         this._alwaysHint = param1;
         this.checkVisible();
      }
   }
}

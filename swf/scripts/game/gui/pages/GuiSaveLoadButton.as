package game.gui.pages
{
   import engine.core.locale.LocaleCategory;
   import engine.core.util.StringUtil;
   import engine.gui.GuiButtonState;
   import engine.saga.save.SagaSave;
   import engine.saga.save.SaveManager;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   import game.gui.ButtonWithIndex;
   import game.gui.IGuiContext;
   
   public class GuiSaveLoadButton extends ButtonWithIndex
   {
       
      
      public var _thumbnail:MovieClip;
      
      private var _bmp:Bitmap;
      
      private var _ss:SagaSave;
      
      public var bk:String;
      
      private var glowFilters:Array;
      
      private var _thumbSize:Point;
      
      public function GuiSaveLoadButton()
      {
         this._thumbSize = new Point(480,360);
         super();
      }
      
      override public function cleanup() : void
      {
         super.cleanup();
         this.bmp = null;
         this.ss = null;
      }
      
      public function init(param1:IGuiContext) : void
      {
         var _loc2_:MovieClip = null;
         super.guiButtonContext = param1;
         this._thumbnail = this.getChildByName("thumbnail") as MovieClip;
         this._thumbnail.visible = false;
         visible = false;
         _loc2_ = this._thumbnail.getChildByName("placeholder") as MovieClip;
         if(_loc2_)
         {
            this._thumbSize.setTo(_loc2_.width,_loc2_.height);
            _loc2_.visible = false;
            _loc2_.mouseChildren = _loc2_.mouseEnabled = false;
         }
         this.glowFilters = filters.concat();
         filters = [];
      }
      
      override public function set state(param1:GuiButtonState) : void
      {
         super.state = param1;
         if(!_context)
         {
            return;
         }
         if(isHovering)
         {
            this.filters = this.glowFilters;
         }
         else if(Boolean(this.filters) && this.filters.length > 0)
         {
            this.filters = [];
         }
      }
      
      public function setupStartButton(param1:String, param2:BitmapData) : void
      {
         buttonText = _context.translate("restart_from_beginning");
         this.bk = param1;
         this.ss = null;
         this.bmp = new Bitmap(param2);
         visible = true;
      }
      
      public function setupButton(param1:SagaSave) : void
      {
         var _loc3_:String = null;
         var _loc10_:String = null;
         this.ss = param1;
         if(!param1)
         {
            buttonText = "Empty Save";
            visible = true;
            return;
         }
         var _loc2_:int = param1.day;
         this.bmp = param1.thumbnailBmp;
         var _loc4_:Number = Number(param1.id);
         if(_loc4_.toString() != param1.id)
         {
            _loc10_ = SaveManager.fixupMigrateSaveId(param1.id);
            _loc3_ = _context.translateCategory(_loc10_,LocaleCategory.LOCATION);
         }
         else
         {
            _loc3_ = param1.id;
         }
         var _loc5_:String = _loc3_;
         var _loc6_:String = _context.translate("day");
         var _loc7_:* = "\n<font size=\'-5\'>" + _loc6_ + " " + _loc2_ + "</font>";
         var _loc8_:Date = param1.date;
         var _loc9_:* = "\n<font size=\'-15\'>" + StringUtil.dateStringSansTZ(_loc8_) + "</font>";
         buttonText = _loc5_ + _loc7_ + _loc9_;
         visible = true;
      }
      
      public function get bmp() : Bitmap
      {
         return this._bmp;
      }
      
      public function set bmp(param1:Bitmap) : void
      {
         if(this._bmp == param1)
         {
            return;
         }
         if(this._bmp)
         {
            if(this._bmp.parent == this)
            {
               removeChild(this._bmp);
            }
         }
         this._bmp = param1;
         if(this._bmp)
         {
            addChildAt(this._bmp,0);
            this._bmp.x = this._thumbnail.x;
            this._bmp.y = this._thumbnail.y;
            this._bmp.scaleX = this._bmp.scaleY = 1;
            this._bmp.smoothing = true;
            this._bmp.scaleX = this._thumbSize.x / this._bmp.width;
            this._bmp.scaleY = this._thumbSize.y / this._bmp.height;
         }
      }
      
      public function get ss() : SagaSave
      {
         return this._ss;
      }
      
      public function set ss(param1:SagaSave) : void
      {
         if(this._ss == param1)
         {
            return;
         }
         this.bmp = null;
         if(this._ss)
         {
            this._ss.removeEventListener(SagaSave.EVENT_THUMBNAIL_BITMAP,this.thumbnailBitmapHandler);
         }
         this._ss = param1;
         if(this._ss)
         {
            this._ss.addEventListener(SagaSave.EVENT_THUMBNAIL_BITMAP,this.thumbnailBitmapHandler);
            this.bmp = this._ss.thumbnailBmp;
         }
      }
      
      private function thumbnailBitmapHandler(param1:Event) : void
      {
         var _loc2_:SagaSave = param1.target as SagaSave;
         this.bmp = !!_loc2_ ? _loc2_.thumbnailBmp : null;
      }
   }
}

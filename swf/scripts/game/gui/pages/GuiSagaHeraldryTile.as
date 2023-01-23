package game.gui.pages
{
   import engine.heraldry.HeraldryLoader;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import game.gui.ButtonWithIndex;
   import game.gui.IGuiContext;
   
   public class GuiSagaHeraldryTile extends ButtonWithIndex
   {
      
      private static var _next_id:int;
      
      private static var zero:Point = new Point();
      
      private static var corner:Point = new Point();
       
      
      public var _placeholder:MovieClip;
      
      private var _loader:HeraldryLoader;
      
      private var _bmpd:BitmapData;
      
      private var bmp:Bitmap;
      
      private var placeholderSize:Point;
      
      public var id:int;
      
      public function GuiSagaHeraldryTile()
      {
         this.bmp = new Bitmap();
         this.placeholderSize = new Point();
         super();
      }
      
      public function init(param1:IGuiContext) : void
      {
         this.id = _next_id++;
         this.guiButtonContext = param1;
         this._placeholder = getChildByName("placeholder") as MovieClip;
         this.placeholderSize.setTo(this._placeholder.width,this._placeholder.height);
         if(this._placeholder.numChildren)
         {
            this._placeholder.removeChildren(0,this._placeholder.numChildren - 1);
         }
         this._placeholder.scaleX = this._placeholder.scaleY = 1;
         this._placeholder.addChild(this.bmp);
         visible = false;
      }
      
      public function get loader() : HeraldryLoader
      {
         return this._loader;
      }
      
      public function set loader(param1:HeraldryLoader) : void
      {
         if(this._loader == param1)
         {
            return;
         }
         if(this._loader)
         {
            this._loader.removeEventListener(Event.COMPLETE,this.loaderHandler);
            this._loader = null;
         }
         this._loader = param1;
         this.bmpd = null;
         if(this._loader)
         {
            if(this._loader.heraldry)
            {
               this.loaderHandler(null);
            }
            else
            {
               this._loader.addEventListener(Event.COMPLETE,this.loaderHandler);
            }
         }
         visible = this._loader != null;
      }
      
      private function loaderHandler(param1:Event) : void
      {
         this.bmpd = !!this._loader.heraldry ? this._loader.heraldry.smallCompositeBmpd : null;
         if(this.bmpd)
         {
            this._loader.removeEventListener(Event.COMPLETE,this.loaderHandler);
         }
      }
      
      public function get bmpd() : BitmapData
      {
         return this._bmpd;
      }
      
      public function set bmpd(param1:BitmapData) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         this._bmpd = param1;
         this.bmp.bitmapData = this._bmpd;
         if(this._bmpd)
         {
            _loc2_ = Math.min(1,this.placeholderSize.x / this._bmpd.width);
            _loc3_ = Math.min(1,this.placeholderSize.y / this._bmpd.height);
            _loc4_ = Math.min(_loc2_,_loc3_);
            this.bmp.scaleX = this.bmp.scaleY = _loc4_;
            this.bmp.smoothing = true;
            this.bmp.x = (this.placeholderSize.x - this.bmp.width) / 2;
            this.bmp.y = (this.placeholderSize.y - this.bmp.height) / 2;
         }
      }
      
      override public function getNavRectangle(param1:DisplayObject) : Rectangle
      {
         corner.setTo(this.placeholderSize.x,this.placeholderSize.y);
         var _loc2_:Point = this.localToGlobal(zero);
         var _loc3_:Point = this.localToGlobal(corner);
         if(param1)
         {
            _loc2_ = param1.globalToLocal(_loc2_);
            _loc3_ = param1.globalToLocal(_loc3_);
         }
         return new Rectangle(_loc2_.x,_loc2_.y,_loc3_.x - _loc2_.x,_loc3_.y - _loc2_.y);
      }
   }
}

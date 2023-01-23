package game.gui
{
   import engine.anim.view.XAnimClipSpriteFlash;
   import engine.core.util.MovieClipAdapter;
   import engine.gui.IReleasable;
   import engine.resource.BitmapResource;
   import engine.resource.IResource;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.PixelSnapping;
   import flash.display.Sprite;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class GuiIcon extends Sprite implements IReleasable
   {
       
      
      public var resource:IResource;
      
      private var targetSize:Point;
      
      public var display:DisplayObject;
      
      private var _layout:GuiIconLayoutType;
      
      private var _offsetX:int = 0;
      
      private var mcAdapter:MovieClipAdapter;
      
      private var _randomize:Boolean;
      
      private var context:IGuiContext;
      
      public var anim:XAnimClipSpriteFlash;
      
      private var _animRepeatLimit:int = 0;
      
      private var reductionScale:Point;
      
      private var ownsResource:Boolean = true;
      
      private var released:Boolean;
      
      public function GuiIcon(param1:IResource, param2:IGuiContext, param3:GuiIconLayoutType, param4:int = 0, param5:Boolean = false, param6:Boolean = true)
      {
         this.targetSize = new Point(100,100);
         this._layout = GuiIconLayoutType.ACTUAL;
         this.reductionScale = new Point(1,1);
         super();
         this.context = param2;
         this._offsetX = param4;
         this.resource = param1;
         this._randomize = param5;
         this.ownsResource = param6;
         param1.addResourceListener(this.resourceHandler);
      }
      
      public function get animRepeatLimit() : int
      {
         return this._animRepeatLimit;
      }
      
      public function set animRepeatLimit(param1:int) : void
      {
         this._animRepeatLimit = param1;
         if(Boolean(this.anim) && Boolean(this.anim.clip))
         {
            this.anim.clip.repeatLimit = this._animRepeatLimit;
         }
      }
      
      override public function toString() : String
      {
         return !!this.resource ? this.resource.url : "??";
      }
      
      public function release() : void
      {
         if(this.released)
         {
            throw new IllegalOperationError("Double-release of GuiIcon");
         }
         this.released = true;
         if(this.display)
         {
            removeChild(this.display);
            this.display = null;
         }
         if(this.mcAdapter)
         {
            this.mcAdapter.cleanup();
            this.mcAdapter = null;
         }
         if(this.resource)
         {
            this.resource.removeResourceListener(this.resourceHandler);
            if(this.ownsResource)
            {
               this.resource.release();
            }
            this.resource = null;
         }
      }
      
      public function update(param1:int) : void
      {
         if(this.anim)
         {
            this.anim.clip.advance(param1);
            this.anim.update();
         }
      }
      
      public function setTargetSize(param1:Number, param2:Number) : void
      {
         this.targetSize.setTo(param1,param2);
         this.handleLayout();
      }
      
      public function get targetWidth() : Number
      {
         return this.targetSize.x;
      }
      
      public function get targetHeight() : Number
      {
         return this.targetSize.y;
      }
      
      private function resourceHandler(param1:Event) : void
      {
         if(!this.resource)
         {
            return;
         }
         this.resource.removeResourceListener(this.resourceHandler);
         this.init();
      }
      
      private function init() : void
      {
         var _loc2_:Bitmap = null;
         var _loc3_:BitmapResource = null;
         var _loc1_:* = this.resource.resource;
         this.anim = _loc1_ as XAnimClipSpriteFlash;
         if(this.anim)
         {
            if(this.anim.clip)
            {
               this.anim.clip.repeatLimit = this.animRepeatLimit;
            }
            this.display = this.anim._sprite;
         }
         else
         {
            this.display = _loc1_ as DisplayObject;
            _loc2_ = this.display as Bitmap;
            if(_loc2_)
            {
               _loc3_ = this.resource as BitmapResource;
               _loc2_.pixelSnapping = PixelSnapping.NEVER;
               _loc2_.smoothing = true;
               this.reductionScale.setTo(_loc3_.scaleX,_loc3_.scaleY);
            }
         }
         if(this.display)
         {
            this.display.name = "display";
            addChild(this.display);
            this.handleLayout();
         }
      }
      
      private function handleLayout() : void
      {
         if(!this.display)
         {
            return;
         }
         switch(this._layout)
         {
            case GuiIconLayoutType.ACTUAL:
               this.layout_actual();
               break;
            case GuiIconLayoutType.CENTER:
               this.layout_center();
               break;
            case GuiIconLayoutType.CENTER_FIT:
               this.layout_centerAndFit();
               break;
            case GuiIconLayoutType.STRETCH:
               this.layout_stretch();
         }
         var _loc1_:Bitmap = this.display as Bitmap;
         if(_loc1_)
         {
            _loc1_.smoothing = true;
         }
         if(this.anim)
         {
            this.anim.smoothing = true;
         }
         this.display.x += this._offsetX;
      }
      
      private function layout_actual() : void
      {
         if(!this.display)
         {
            return;
         }
         this.display.x = 0;
         this.display.y = 0;
         this.display.scaleX = this.reductionScale.x;
         this.display.scaleY = this.reductionScale.y;
      }
      
      private function layout_centerAndFit() : void
      {
         if(!this.display)
         {
            return;
         }
         this.layout_actual();
         var _loc1_:Number = 1;
         if(this.display.width > this.display.height)
         {
            _loc1_ = this.targetSize.x / this.display.width;
         }
         else if(this.display.height > 0)
         {
            _loc1_ = this.targetSize.y / this.display.height;
         }
         this.display.scaleX = _loc1_ * this.reductionScale.x;
         this.display.scaleY = _loc1_ * this.reductionScale.y;
         this.display.x = (this.targetWidth - this.display.width) / 2;
         this.display.y = (this.targetHeight - this.display.height) / 2;
      }
      
      private function layout_center() : void
      {
         if(!this.display)
         {
            return;
         }
         this.layout_actual();
         this.display.x = (this.targetWidth - this.display.width) / 2;
         this.display.y = (this.targetHeight - this.display.height) / 2;
         this.display.scaleX = this.reductionScale.x;
         this.display.scaleY = this.reductionScale.y;
      }
      
      private function layout_stretch() : void
      {
         if(!this.display)
         {
            return;
         }
         this.layout_actual();
         this.display.x = 0;
         this.display.y = 0;
         this.display.scaleX = this.reductionScale.x * (!!this.display.width ? this.targetWidth / this.display.width : 1);
         this.display.scaleY = this.reductionScale.y * (!!this.display.height ? this.targetHeight / this.display.height : 1);
      }
      
      public function get layout() : GuiIconLayoutType
      {
         return this._layout;
      }
      
      public function set layout(param1:GuiIconLayoutType) : void
      {
         if(this._layout != param1)
         {
            this._layout = param1;
            this.handleLayout();
         }
      }
      
      public function clone(param1:DisplayObjectContainer) : GuiIcon
      {
         var _loc2_:GuiIcon = new GuiIcon(this.resource,this.context,this.layout,this._offsetX,this._randomize,this.ownsResource);
         if(this.ownsResource)
         {
            this.resource.addReference();
         }
         _loc2_.setTargetSize(this.targetWidth,this.targetHeight);
         _loc2_.layout = this.layout;
         var _loc3_:Point = this.getRealScale(param1);
         _loc2_.scaleX = _loc3_.x;
         _loc2_.scaleY = _loc3_.y;
         return _loc2_;
      }
      
      public function getRealScale(param1:DisplayObjectContainer) : Point
      {
         var _loc2_:Point = new Point(this.scaleX,this.scaleY);
         var _loc3_:DisplayObjectContainer = this.parent;
         while(_loc3_)
         {
            _loc2_.x *= _loc3_.scaleX;
            _loc2_.y *= _loc3_.scaleY;
            _loc3_ = _loc3_.parent;
            if(_loc3_ == param1)
            {
               break;
            }
         }
         return _loc2_;
      }
   }
}

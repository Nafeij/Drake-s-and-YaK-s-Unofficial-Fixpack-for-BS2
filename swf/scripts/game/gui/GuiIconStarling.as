package game.gui
{
   import engine.anim.view.XAnimClipSpriteStarling;
   import engine.gui.IReleasable;
   import engine.resource.AnimClipResource;
   import engine.resource.BitmapResource;
   import engine.resource.IResource;
   import flash.display.BitmapData;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.geom.Point;
   import starling.display.DisplayObject;
   import starling.display.DisplayObjectContainer;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.textures.Texture;
   
   public class GuiIconStarling extends Sprite implements IReleasable
   {
       
      
      public var resource:IResource;
      
      private var targetSize:Point;
      
      public var display:DisplayObject;
      
      private var _layout:GuiIconLayoutType;
      
      private var _offsetX:int = 0;
      
      private var _randomize:Boolean;
      
      public var anim:XAnimClipSpriteStarling;
      
      private var keepBmpd:Boolean;
      
      private var reductionScale:Point;
      
      private var released:Boolean;
      
      private var bmpd:BitmapData;
      
      private var texture:Texture;
      
      public function GuiIconStarling(param1:Boolean, param2:IResource, param3:GuiIconLayoutType, param4:int = 0, param5:Boolean = false)
      {
         this.targetSize = new Point(100,100);
         this._layout = GuiIconLayoutType.ACTUAL;
         this.reductionScale = new Point(1,1);
         super();
         this.keepBmpd = param1;
         this._offsetX = param4;
         this.resource = param2;
         this._randomize = param5;
         param2.addResourceListener(this.resourceHandler);
      }
      
      public function toString() : String
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
         if(this.anim)
         {
            this.anim.cleanup();
            this.anim = null;
         }
         if(this.display)
         {
            removeChild(this.display);
            this.display = null;
         }
         if(this.resource)
         {
            this.resource.removeResourceListener(this.resourceHandler);
            this.resource.release();
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
         var _loc1_:BitmapResource = null;
         if(this.resource is AnimClipResource)
         {
            this.anim = (this.resource as AnimClipResource)._animClipSpriteStarling;
            this.anim.smoothing = true;
            this.display = this.anim._sprite;
         }
         else if(this.resource is BitmapResource)
         {
            _loc1_ = this.resource as BitmapResource;
            if(_loc1_.bitmapData)
            {
               if(this.keepBmpd)
               {
                  this.bmpd = _loc1_.bitmapData;
                  this.texture = Texture.fromBitmapData(this,this.bmpd,false);
                  this.texture.root.onRestore = this.textureRestoreHandler;
                  this.display = new Image(this.texture);
               }
               else
               {
                  this.display = new Image(_loc1_.getTexture());
               }
               this.reductionScale.setTo(_loc1_.scaleX,_loc1_.scaleY);
            }
         }
         if(this.display)
         {
            this.display.name = "display";
            addChild(this.display);
            this.handleLayout();
         }
      }
      
      private function textureRestoreHandler() : void
      {
         if(Boolean(this.texture) && Boolean(this.bmpd))
         {
            this.texture.root.uploadBitmapData(this.bmpd);
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
      
      public function clone(param1:DisplayObjectContainer) : GuiIconStarling
      {
         var _loc2_:GuiIconStarling = new GuiIconStarling(this.keepBmpd,this.resource,this.layout);
         this.resource.addReference();
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

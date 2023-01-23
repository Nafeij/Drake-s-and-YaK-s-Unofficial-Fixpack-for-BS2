package engine.anim.view
{
   import engine.anim.def.AnimFrame;
   import engine.anim.def.AnimFrames;
   import engine.core.logging.ILogger;
   import engine.core.util.ColorUtil;
   import engine.landscape.view.DisplayObjectWrapperFlash;
   import engine.resource.AnimClipResource;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Graphics;
   import flash.display.PixelSnapping;
   import flash.display.Sprite;
   
   public class XAnimClipSpriteFlash extends XAnimClipSpriteBase
   {
       
      
      public var _sprite:Sprite;
      
      private var _ssBmp:Bitmap;
      
      private var _editorZoom:Number = 1;
      
      public function XAnimClipSpriteFlash(param1:AnimClipResource, param2:AnimClip, param3:ILogger, param4:Boolean, param5:Boolean = false)
      {
         this._sprite = new Sprite();
         displayObjectWrapper = new DisplayObjectWrapperFlash(this._sprite);
         this._sprite.mouseEnabled = false;
         this._sprite.mouseChildren = false;
         super(param1,param2,param3,param4,param5);
      }
      
      public function showTotalBounds() : void
      {
         var _loc2_:AnimFrames = null;
         var _loc1_:Graphics = this._sprite.graphics;
         _loc1_.clear();
         if(clip)
         {
            _loc2_ = clip.def.aframes;
            _loc1_.lineStyle(2,16777215,1);
            _loc1_.beginFill(16777215,0.5);
            _loc1_.drawRect(_loc2_.left,_loc2_.top,_loc2_.width,_loc2_.height);
            _loc1_.endFill();
            _loc1_.lineStyle(2,16777215,1);
            _loc1_.moveTo(-20,-20);
            _loc1_.lineTo(20,20);
            _loc1_.moveTo(20,-20);
            _loc1_.lineTo(-20,20);
         }
      }
      
      public function hideTotalBounds() : void
      {
         if(this._sprite)
         {
            this._sprite.graphics.clear();
         }
      }
      
      override public function get height() : Number
      {
         if(this._ssBmp)
         {
            return this._ssBmp.height;
         }
         return 0;
      }
      
      override protected function handleCreateSpriteChild(param1:AnimClip) : XAnimClipSpriteBase
      {
         return new XAnimClipSpriteFlash(null,param1,logger,smoothing,true);
      }
      
      override protected function handleCreateClipDisplay() : void
      {
         if(!this._ssBmp)
         {
            this._ssBmp = new Bitmap(null);
            this._ssBmp.smoothing = smoothing;
            if(DEBUG_RENDER_SPRITESHEET)
            {
               this._ssBmp.opaqueBackground = ColorUtil.randomColor();
            }
         }
         if(this._ssBmp.parent == null)
         {
            this._sprite.addChild(this._ssBmp);
         }
         if(SHOW_TOTAL_BOUNDS)
         {
            this.showTotalBounds();
         }
      }
      
      private function removeBitmapChild() : void
      {
         if(this._ssBmp)
         {
            if(this._ssBmp.parent == this._sprite)
            {
               this._sprite.removeChild(this._ssBmp);
            }
         }
      }
      
      override public function hitTestPoint(param1:Number, param2:Number, param3:Boolean = false) : Boolean
      {
         if(this._sprite)
         {
            return this._sprite.hitTestPoint(param1,param2,param3);
         }
         return false;
      }
      
      override public function set smoothing(param1:Boolean) : void
      {
         super.smoothing = param1;
         if(this._ssBmp)
         {
            this._ssBmp.smoothing = param1;
         }
      }
      
      override protected function handleReleaseFrameReference(param1:AnimFrame) : void
      {
         if(param1)
         {
            param1.releaseFrameReferenceBmpd();
         }
      }
      
      override protected function updateDisplayRenderable(param1:AnimFrame, param2:AnimFrame) : void
      {
         var _loc4_:Number = NaN;
         var _loc3_:BitmapData = param1.addFrameReferenceBmpd();
         if(_loc3_ != this._ssBmp.bitmapData)
         {
            this._ssBmp.bitmapData = _loc3_;
            this._ssBmp.smoothing = smoothing;
            this._ssBmp.pixelSnapping = PixelSnapping.NEVER;
            _loc4_ = clip.def.shrunkenScale;
            this._ssBmp.scaleX = param1.reductionScaleX * _loc4_;
            this._ssBmp.scaleY = param1.reductionScaleY * _loc4_;
            this._ssBmp.visible = _loc3_ != null;
         }
         if(param2)
         {
            param2.releaseFrameReferenceBmpd();
         }
      }
      
      override protected function updateDisplayAnimFrame(param1:AnimFrame) : void
      {
         var _loc2_:Number = NaN;
         if(!this._ssBmp || !param1)
         {
            return;
         }
         _loc2_ = clip.def.shrunkenScale;
         var _loc3_:Number = !!param1.offset ? param1.offset.x : 0;
         var _loc4_:Number = !!param1.offset ? param1.offset.y : 0;
         this._ssBmp.x = _loc3_ * _loc2_ + clip.def.offsetX * _loc2_;
         this._ssBmp.y = _loc4_ * _loc2_ + clip.def.offsetY * _loc2_;
         this._ssBmp.scaleX = param1.reductionScaleX * _loc2_;
         this._ssBmp.scaleY = param1.reductionScaleY * _loc2_;
         this._ssBmp.alpha = _alpha * clip._compositeAlpha;
         displayObjectWrapper.color = ColorUtil.multiply(_color,clip._compositeColor);
         if(isChild)
         {
            if(clip.transformMatrix)
            {
               this._sprite.transform.matrix = clip.transformMatrix;
            }
            else
            {
               this._sprite.x = clip.x;
               this._sprite.y = clip.y;
               this._sprite.rotation = clip.rotation;
               this._sprite.scaleX = clip.scaleX * _loc2_;
               this._sprite.scaleY = clip.scaleY * _loc2_;
            }
            if(clip.blendMode)
            {
               this._ssBmp.blendMode = clip.blendMode;
            }
            this._ssBmp.visible = clip.visible;
         }
      }
      
      public function get editorZoom() : Number
      {
         return this._editorZoom;
      }
      
      public function set editorZoom(param1:Number) : void
      {
         this._editorZoom = param1;
      }
      
      override protected function handleColorChange() : void
      {
         if(Boolean(displayObjectWrapper) && Boolean(clip))
         {
            displayObjectWrapper.color = ColorUtil.multiply(_color,clip._compositeColor);
         }
      }
      
      override protected function handleAlphaChange() : void
      {
         if(Boolean(this._ssBmp) && Boolean(clip))
         {
            this._ssBmp.alpha = _alpha * clip._compositeAlpha;
         }
      }
   }
}

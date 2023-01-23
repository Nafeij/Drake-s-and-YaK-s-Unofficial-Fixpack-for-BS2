package engine.anim.view
{
   import engine.anim.def.AnimFrame;
   import engine.core.logging.ILogger;
   import engine.core.util.ColorUtil;
   import engine.landscape.view.DisplayObjectWrapperStarling;
   import engine.resource.AnimClipResource;
   import flash.geom.Point;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.textures.Texture;
   import starling.textures.TextureSmoothing;
   
   public class XAnimClipSpriteStarling extends XAnimClipSpriteBase
   {
      
      private static var empty:Texture;
       
      
      public var _sprite:Sprite;
      
      private var _ssBmp:Image;
      
      private var _texture:Texture;
      
      public function XAnimClipSpriteStarling(param1:AnimClipResource, param2:AnimClip, param3:ILogger, param4:Boolean, param5:Boolean = false)
      {
         this._sprite = new Sprite();
         displayObjectWrapper = new DisplayObjectWrapperStarling(this._sprite);
         this._sprite.touchable = false;
         if(!empty)
         {
            empty = Texture.empty("XAnimClipSpriteStarling.empty",16,16,true,false);
            empty.root.clear(16711935,1);
         }
         super(param1,param2,param3,param4,param5);
         this._sprite.alpha = _alpha;
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
         return new XAnimClipSpriteStarling(null,param1,logger,smoothing,true);
      }
      
      override protected function handleCreateClipDisplay() : void
      {
         if(!this._ssBmp)
         {
            this._ssBmp = new Image(empty);
            this._ssBmp.visible = false;
            this._ssBmp.color = _color;
         }
         if(!this._ssBmp.parent)
         {
            this._sprite.addChild(this._ssBmp);
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
            return this._sprite.hitTest(new Point(param1,param2),true) != null;
         }
         return false;
      }
      
      override public function set smoothing(param1:Boolean) : void
      {
         super.smoothing = param1;
         if(this._ssBmp)
         {
            this._ssBmp.smoothing = smoothing ? TextureSmoothing.BILINEAR : TextureSmoothing.NONE;
         }
      }
      
      override protected function handleReleaseFrameReference(param1:AnimFrame) : void
      {
         if(param1)
         {
            param1.releaseFrameReferenceTexture();
         }
      }
      
      override protected function updateDisplayRenderable(param1:AnimFrame, param2:AnimFrame) : void
      {
         var _loc4_:Number = NaN;
         var _loc3_:Texture = !!param1 ? param1.addFrameReferenceTexture() : null;
         if(this._texture != _loc3_)
         {
            this._texture = _loc3_;
            if(this._texture)
            {
               this._ssBmp.texture = this._texture;
               this._ssBmp.smoothing = smoothing ? TextureSmoothing.BILINEAR : TextureSmoothing.NONE;
               this._ssBmp.readjustSize();
               _loc4_ = clip.def.shrunkenScale;
               this._ssBmp.scaleX = param1.reductionScaleX * _loc4_;
               this._ssBmp.scaleY = param1.reductionScaleY * _loc4_;
            }
            this._ssBmp.visible = Boolean(clip) && clip.visible && this._texture != null;
         }
         if(param2)
         {
            param2.releaseFrameReferenceTexture();
         }
      }
      
      override protected function updateDisplayAnimFrame(param1:AnimFrame) : void
      {
         if(!this._ssBmp || !param1)
         {
            return;
         }
         var _loc2_:Number = clip.def.shrunkenScale;
         var _loc3_:Number = !!param1.offset ? param1.offset.x : 0;
         var _loc4_:Number = !!param1.offset ? param1.offset.y : 0;
         this._ssBmp.x = _loc3_ * _loc2_ + clip.def.offsetX * _loc2_;
         this._ssBmp.y = _loc4_ * _loc2_ + clip.def.offsetY * _loc2_;
         this._ssBmp.scaleX = param1.reductionScaleX * _loc2_;
         this._ssBmp.scaleY = param1.reductionScaleY * _loc2_;
         this._sprite.alpha = _alpha * clip._compositeAlpha;
         this._ssBmp.color = ColorUtil.multiply(_color,clip._compositeColor);
         if(isChild)
         {
            if(clip.transformMatrix)
            {
               this._sprite.transformationMatrix = clip.transformMatrix;
            }
            else
            {
               this._sprite.x = clip.x;
               this._sprite.y = clip.y;
               this._sprite.rotation = clip.rotation * Math.PI / 180;
               this._sprite.scaleX = clip.scaleX * _loc2_;
               this._sprite.scaleY = clip.scaleY * _loc2_;
            }
            if(clip.blendMode)
            {
               this._ssBmp.blendMode = clip.blendMode;
            }
            this._ssBmp.visible = clip.visible && this._texture != null;
         }
      }
      
      override protected function handleColorChange() : void
      {
         if(Boolean(this._ssBmp) && Boolean(clip))
         {
            this._ssBmp.color = ColorUtil.multiply(_color,clip._compositeColor);
         }
      }
      
      override protected function handleAlphaChange() : void
      {
         if(Boolean(this._sprite) && Boolean(clip))
         {
            this._sprite.alpha = _alpha * clip._compositeAlpha;
         }
      }
   }
}

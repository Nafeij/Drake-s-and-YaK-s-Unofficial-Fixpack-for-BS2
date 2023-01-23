package engine.anim.view
{
   import engine.anim.def.AnimLibrary;
   import engine.anim.def.IAnimDef;
   import engine.anim.def.IAnimFacing;
   import engine.core.logging.ILogger;
   import engine.core.util.ColorUtil;
   import engine.landscape.view.DisplayObjectWrapper;
   import engine.resource.IResourceManager;
   import flash.errors.IllegalOperationError;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   
   public class AnimControllerSprite
   {
       
      
      private var _library:AnimLibrary;
      
      public var id:String;
      
      protected var logger:ILogger;
      
      private var _controller:AnimController;
      
      private var _animSprite:XAnimClipSpriteBase;
      
      private var _clip:AnimClip;
      
      private var _anim:IAnim;
      
      private var animSprites:Dictionary;
      
      protected var smoothing:Boolean;
      
      public var _offsetsByFacing:Dictionary;
      
      public var displayObjectWrapper:DisplayObjectWrapper;
      
      public function AnimControllerSprite(param1:String, param2:AnimController, param3:ILogger, param4:IResourceManager, param5:Boolean)
      {
         this.animSprites = new Dictionary();
         super();
         this.displayObjectWrapper.name = "anim_controller";
         this.id = param1;
         this.logger = param3;
         this.smoothing = param5;
         this.controller = param2;
      }
      
      public function get height() : Number
      {
         return !!this._animSprite ? this._animSprite.height : 0;
      }
      
      public function update() : void
      {
         this.anim = this._controller.anim;
         if(this._animSprite)
         {
            this._updateColor();
            this._animSprite.update();
         }
      }
      
      public function set anim(param1:IAnim) : void
      {
         if(this._anim == param1)
         {
            return;
         }
         if(this.id == "0+0+scathach")
         {
            if(Boolean(param1) && param1.def.name == "abl_trample_ne")
            {
               this.id = this.id;
            }
         }
         this._anim = param1;
         this.clip = !!this._anim ? this._anim.clip : null;
         this.checkFlip();
      }
      
      public function cleanup() : void
      {
         var _loc1_:XAnimClipSpriteBase = null;
         this.anim = null;
         for each(_loc1_ in this.animSprites)
         {
            _loc1_.cleanup();
         }
         this.animSprites = null;
         if(Boolean(this._clip) || Boolean(this._animSprite))
         {
            throw new IllegalOperationError("bad cleanup");
         }
         this.library = null;
         this.controller = null;
      }
      
      public function get library() : AnimLibrary
      {
         return this._library;
      }
      
      public function set library(param1:AnimLibrary) : void
      {
         if(this._library == param1)
         {
            return;
         }
         this.animSpriteFactoryReset();
         this._library = param1;
         this.controller.library = this._library;
         if(this._library)
         {
            this._offsetsByFacing = this._library.offsetsByFacing;
         }
      }
      
      public function get controller() : AnimController
      {
         return this._controller;
      }
      
      public function set controller(param1:AnimController) : void
      {
         if(this._controller == param1)
         {
            return;
         }
         if(this._controller)
         {
            this._controller.cleanup();
            this._controller = null;
         }
         this._controller = param1;
      }
      
      public function get clip() : AnimClip
      {
         return this._clip;
      }
      
      public function set clip(param1:AnimClip) : void
      {
         if(this._clip == param1)
         {
            return;
         }
         if(this._clip)
         {
            this._clip.stop();
         }
         this._clip = param1;
         if(this._clip)
         {
            this.animClipSprite = this.animSpriteFactoryGet(this._clip);
            this.checkFlip();
         }
         else
         {
            this.animClipSprite = null;
         }
      }
      
      final private function animSpriteFactoryGet(param1:AnimClip) : XAnimClipSpriteBase
      {
         if(param1 == null)
         {
            return null;
         }
         var _loc2_:XAnimClipSpriteBase = this.animSprites[param1.def];
         if(_loc2_ == null)
         {
            if(param1 != null)
            {
               _loc2_ = this.handleCreateXAnimClipSprite(param1);
               this.animSprites[param1.def] = _loc2_;
            }
         }
         _loc2_.clip = param1;
         if(!_loc2_.clip.playing)
         {
            if(this._controller)
            {
               if(Boolean(this._controller._current) && !this._controller._current.holding)
               {
                  _loc2_.clip.restart();
               }
            }
         }
         return _loc2_;
      }
      
      protected function handleCreateXAnimClipSprite(param1:AnimClip) : XAnimClipSpriteBase
      {
         return null;
      }
      
      private function animSpriteFactoryReset() : void
      {
         this.animSprites = new Dictionary();
      }
      
      public function get animClipSprite() : XAnimClipSpriteBase
      {
         return this._animSprite;
      }
      
      public function set animClipSprite(param1:XAnimClipSpriteBase) : void
      {
         if(this._animSprite == param1)
         {
            return;
         }
         if(this._animSprite)
         {
            this.displayObjectWrapper.removeChild(this._animSprite.displayObjectWrapper);
         }
         this._animSprite = param1;
         if(this._animSprite)
         {
            this.displayObjectWrapper.addChild(this._animSprite.displayObjectWrapper);
            this.checkFlip();
         }
      }
      
      public function handleOffsetsChanged() : void
      {
         this.checkFlip();
      }
      
      private function checkFlip() : void
      {
         var _loc4_:Point = null;
         if(!this._controller)
         {
            return;
         }
         var _loc1_:DisplayObjectWrapper = !!this._animSprite ? this._animSprite.displayObjectWrapper : null;
         var _loc2_:IAnimFacing = !!this._controller ? this._controller.facing : null;
         if(!_loc1_ || !_loc2_)
         {
            return;
         }
         _loc1_.x = _loc1_.y = 0;
         var _loc3_:IAnimDef = !!this._anim ? this._anim.def : null;
         if(_loc3_)
         {
            _loc4_ = _loc3_.offset;
            if(_loc4_)
            {
               _loc4_ = _loc4_;
            }
         }
         if(!_loc4_ && _loc1_ && Boolean(this._offsetsByFacing))
         {
            _loc4_ = this._offsetsByFacing[_loc2_];
         }
         if(_loc4_)
         {
            _loc1_.x = _loc4_.x;
            _loc1_.y = _loc4_.y;
         }
         var _loc5_:Number = !!this._library ? this._library._animsScale : 1;
         if(Boolean(this._anim) && this._anim.def.flip)
         {
            _loc1_.scaleX = -1 * _loc5_;
         }
         else
         {
            _loc1_.scaleX = 1 * _loc5_;
         }
         _loc1_.scaleY = _loc5_;
         if(_loc5_ != 1)
         {
            _loc1_.y -= 16 * (1 - _loc5_);
         }
         this._updateColor();
      }
      
      private function _updateColor() : void
      {
         if(!this._library || !this._controller)
         {
            return;
         }
         var _loc1_:uint = this._library.animsColor;
         var _loc2_:Number = this._library.animsAlpha;
         var _loc3_:uint = this._controller._color;
         var _loc4_:Number = this._controller.alpha;
         if(_loc1_ == 4294967295)
         {
            this._animSprite.color = _loc3_;
         }
         else if(_loc3_ == 4294967295)
         {
            this._animSprite.color = _loc1_;
         }
         else
         {
            this._animSprite.color = ColorUtil.multiply(_loc1_,_loc3_);
         }
         this._animSprite.alpha = _loc2_ * _loc4_;
      }
      
      public function get visualTop() : Number
      {
         return !!this._animSprite ? this._animSprite.visualTop : 0;
      }
      
      public function hitTestPoint(param1:Number, param2:Number, param3:Boolean = false) : Boolean
      {
         if(this._animSprite)
         {
            return this._animSprite.hitTestPoint(param1,param2,param3);
         }
         return false;
      }
   }
}

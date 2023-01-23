package engine.anim.view
{
   import engine.anim.def.AnimClipChildDef;
   import engine.anim.def.AnimFrame;
   import engine.anim.def.AnimFrames;
   import engine.core.logging.ILogger;
   import engine.landscape.view.DisplayObjectWrapper;
   import engine.resource.AnimClipResource;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   
   public class XAnimClipSpriteBase
   {
      
      public static var DEBUG_RENDER_SPRITESHEET:Boolean = false;
      
      public static var SHOW_TOTAL_BOUNDS:Boolean = false;
       
      
      public var _clip:AnimClip;
      
      public var logger:ILogger;
      
      public var visualTop:Number = 0;
      
      private var _smoothing:Boolean;
      
      public var isChild:Boolean;
      
      public var displayObjectWrapper:DisplayObjectWrapper;
      
      private var animResource:AnimClipResource;
      
      public var children:Vector.<XAnimClipSpriteBase>;
      
      protected var _color:uint = 4294967295;
      
      protected var _alpha:Number = 1;
      
      private var lastUpdate:int = 0;
      
      private var _lastFrameNumber:int = -1;
      
      public var _lastAnimFrame:AnimFrame;
      
      public function XAnimClipSpriteBase(param1:AnimClipResource, param2:AnimClip, param3:ILogger, param4:Boolean, param5:Boolean = false)
      {
         this.children = new Vector.<XAnimClipSpriteBase>();
         super();
         this.displayObjectWrapper.anim = this;
         this.displayObjectWrapper.name = "anim_clip";
         this.isChild = param5;
         this.logger = param3;
         this.smoothing = param4;
         this.clip = param2;
         this.animResource = param1;
         if(!this.clip && Boolean(param1))
         {
            param1.addReference();
            param1.addResourceListener(this.animResourceLoadedHandler);
         }
      }
      
      public function cleanup() : void
      {
         if(this.animResource)
         {
            this.animResource.removeResourceListener(this.animResourceLoadedHandler);
            this.animResource.release();
            this.animResource = null;
         }
         this.clip = null;
         this.logger = null;
      }
      
      public function get height() : Number
      {
         return 0;
      }
      
      public function get visible() : Boolean
      {
         return this.displayObjectWrapper.visible;
      }
      
      public function get name() : String
      {
         return this.displayObjectWrapper.name;
      }
      
      public function set name(param1:String) : void
      {
         this.displayObjectWrapper.name = param1;
      }
      
      public function get x() : Number
      {
         return this.displayObjectWrapper.x;
      }
      
      public function get y() : Number
      {
         return this.displayObjectWrapper.y;
      }
      
      public function set x(param1:Number) : void
      {
         this.displayObjectWrapper.x = param1;
      }
      
      public function set y(param1:Number) : void
      {
         this.displayObjectWrapper.y = param1;
      }
      
      public function get clip() : AnimClip
      {
         return this._clip;
      }
      
      public function set clip(param1:AnimClip) : void
      {
         if(param1 == this._clip)
         {
            return;
         }
         if(Boolean(param1) && !param1.def)
         {
            return;
         }
         this.removeAllChildren();
         if(this._lastAnimFrame)
         {
            this.handleReleaseFrameReference(this._lastAnimFrame);
            this._lastAnimFrame = null;
         }
         this._clip = param1;
         if(this._clip)
         {
            this.handleCreateClipDisplay();
            this.addAnimChildren(true);
            this.visualTop = this.clip.def.offsetY;
            this.updateDisplayFrameNumber(this.clip.frame);
         }
      }
      
      protected function handleCreateClipDisplay() : void
      {
      }
      
      private function removeAllChildren() : void
      {
         var _loc2_:XAnimClipSpriteBase = null;
         var _loc1_:int = 0;
         while(_loc1_ < this.children.length)
         {
            _loc2_ = this.children[_loc1_];
            if(_loc2_.clip)
            {
               _loc2_.clip.cleanup();
            }
            _loc2_.cleanup();
            _loc1_++;
         }
         this.displayObjectWrapper.removeAllChildren();
      }
      
      private function addAnimChildren(param1:Boolean) : void
      {
         var _loc3_:AnimClip = null;
         var _loc4_:AnimClipChildDef = null;
         var _loc5_:XAnimClipSpriteBase = null;
         var _loc2_:int = 0;
         while(_loc2_ < this.clip.numChildren)
         {
            _loc3_ = this.clip.getClipChild(_loc2_);
            _loc4_ = _loc3_.childDef;
            if(!_loc4_)
            {
               this.logger.error("Anim [" + this.clip.def.url + "] child defless [" + _loc3_.def.url + "]");
            }
            else if(!_loc4_.clip)
            {
               this.logger.error("Anim [" + this.clip.def.url + "] child unresolved [" + _loc3_.def.url + "]");
            }
            else
            {
               if(_loc4_.front != param1)
               {
               }
               _loc5_ = this.handleCreateSpriteChild(_loc3_);
               this.children.push(_loc5_);
               this.displayObjectWrapper.addChild(_loc5_.displayObjectWrapper);
            }
            _loc2_++;
         }
      }
      
      protected function handleCreateSpriteChild(param1:AnimClip) : XAnimClipSpriteBase
      {
         throw new IllegalOperationError("pure virtual");
      }
      
      public function set visible(param1:Boolean) : void
      {
         var _loc2_:Boolean = this.displayObjectWrapper.visible;
         if(_loc2_ == param1)
         {
            return;
         }
         if(this.clip)
         {
            if(!param1)
            {
               this.clip.stop();
            }
            else
            {
               this.clip.start(this.clip.frame);
            }
         }
         this.displayObjectWrapper.visible = param1;
      }
      
      public function get smoothing() : Boolean
      {
         return this._smoothing;
      }
      
      public function set smoothing(param1:Boolean) : void
      {
         var _loc3_:XAnimClipSpriteBase = null;
         if(this._smoothing == param1)
         {
            return;
         }
         this._smoothing = param1;
         var _loc2_:int = 0;
         while(_loc2_ < this.children.length)
         {
            _loc3_ = this.children[_loc2_];
            _loc3_.smoothing = this._smoothing;
            _loc2_++;
         }
      }
      
      protected function handleReleaseFrameReference(param1:AnimFrame) : void
      {
      }
      
      public function toString() : String
      {
         return "AnimClipSprite [clip=" + this.clip + "]";
      }
      
      private function updateDisplayFrameNumber(param1:int) : void
      {
         var _loc5_:XAnimClipSpriteBase = null;
         if(!this._clip || !this._clip._def)
         {
            return;
         }
         param1 = Math.max(0,param1);
         var _loc2_:AnimFrames = this._clip.def.aframes;
         if(!_loc2_)
         {
            return;
         }
         var _loc3_:AnimFrame = _loc2_.getFrame(param1);
         if(_loc3_ != this._lastAnimFrame)
         {
            this.updateDisplayRenderable(_loc3_,this._lastAnimFrame);
            this._lastAnimFrame = _loc3_;
         }
         this.updateDisplayAnimFrame(_loc3_);
         this._lastFrameNumber = param1;
         var _loc4_:int = 0;
         while(_loc4_ < this.children.length)
         {
            _loc5_ = this.children[_loc4_];
            _loc5_.update();
            _loc4_++;
         }
      }
      
      protected function updateDisplayRenderable(param1:AnimFrame, param2:AnimFrame) : void
      {
      }
      
      protected function updateDisplayAnimFrame(param1:AnimFrame) : void
      {
      }
      
      protected function animResourceLoadedHandler(param1:Event) : void
      {
         this.animResource.removeResourceListener(this.animResourceLoadedHandler);
         this.clip = this.animResource.clip;
         if(this.clip)
         {
            this.clip.start(0);
         }
      }
      
      public function update() : void
      {
         if(this._clip)
         {
            this.updateDisplayFrameNumber(this._clip._currentFrameNumber);
         }
      }
      
      public function hitTestPoint(param1:Number, param2:Number, param3:Boolean = false) : Boolean
      {
         return false;
      }
      
      public function get url() : String
      {
         return !!this.animResource ? this.animResource.url : null;
      }
      
      public function get color() : uint
      {
         return this._color;
      }
      
      public function set color(param1:uint) : void
      {
         if(this._color != param1)
         {
            this._color = param1;
            this.handleColorChange();
         }
      }
      
      protected function handleColorChange() : void
      {
      }
      
      public function get alpha() : Number
      {
         return this._alpha;
      }
      
      public function set alpha(param1:Number) : void
      {
         if(this._alpha != param1)
         {
            this._alpha = param1;
            this.handleAlphaChange();
         }
      }
      
      protected function handleAlphaChange() : void
      {
      }
   }
}

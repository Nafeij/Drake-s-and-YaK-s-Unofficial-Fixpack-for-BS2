package engine.gui.core
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class GuiSprite extends Sprite
   {
       
      
      private var _guiSpriteSize:Point;
      
      internal var _anchor:GuiSpriteAnchorPolicy;
      
      private var _debugRender = null;
      
      private var _maxWidth;
      
      private var _maxHeight;
      
      private var _minWidth;
      
      private var _minHeight;
      
      private var _suppressLayout:Boolean;
      
      private var _layoutDirty:Boolean;
      
      private var _enabled:Boolean = true;
      
      private var dirtySize:Boolean;
      
      public function GuiSprite()
      {
         this._guiSpriteSize = new Point();
         super();
         this.updateState();
      }
      
      private static function bringAllSpritesToFront(param1:DisplayObject) : void
      {
         if(param1.parent)
         {
            param1.parent.setChildIndex(param1,param1.parent.numChildren - 1);
            if(param1.parent is GuiSprite)
            {
               (param1.parent as GuiSprite).layoutChildren();
            }
            bringAllSpritesToFront(param1.parent);
         }
      }
      
      public static function centerChild(param1:DisplayObject) : void
      {
         if(Boolean(param1) && Boolean(param1.parent))
         {
            param1.x = (param1.parent.width - param1.width) / 2;
            param1.y = (param1.parent.height - param1.height) / 2;
         }
      }
      
      public static function MathUtil_inRect(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number) : Boolean
      {
         if(param1 >= param3 && param2 >= param4)
         {
            if(param1 <= param3 + param5 && param2 <= param4 + param6)
            {
               return true;
            }
         }
         return false;
      }
      
      public function cleanup() : void
      {
         this.anchor = null;
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         if(this._enabled != param1)
         {
            this._enabled = param1;
            this.updateState();
         }
      }
      
      protected function updateState() : void
      {
      }
      
      public function get suppressLayout() : Boolean
      {
         return this._suppressLayout;
      }
      
      public function set suppressLayout(param1:Boolean) : void
      {
         if(this._suppressLayout != param1)
         {
            this._suppressLayout = param1;
            if(!this._suppressLayout)
            {
               if(this._layoutDirty)
               {
                  this.layoutGuiSprite();
               }
            }
         }
      }
      
      public function get maxHeight() : *
      {
         return this._maxHeight;
      }
      
      public function set maxHeight(param1:*) : void
      {
         if(this._maxHeight != param1)
         {
            this._maxHeight = param1;
            this.layoutGuiSprite();
         }
      }
      
      public function get maxWidth() : *
      {
         return this._maxWidth;
      }
      
      public function set maxWidth(param1:*) : void
      {
         if(this._maxWidth != param1)
         {
            this._maxWidth = param1;
            this.layoutGuiSprite();
         }
      }
      
      public function get debugRender() : *
      {
         return this._debugRender;
      }
      
      public function set debugRender(param1:*) : void
      {
         if(this._debugRender != param1)
         {
            this._debugRender = param1;
            this.doDebugRender();
            if(this._debugRender == null)
            {
               this.graphics.clear();
            }
         }
      }
      
      public function get anchor() : GuiSpriteAnchorPolicy
      {
         return !!this._anchor ? this._anchor : (this._anchor = new GuiSpriteAnchorPolicy(this));
      }
      
      public function set anchor(param1:GuiSpriteAnchorPolicy) : void
      {
         if(this._anchor != param1)
         {
            if(this._anchor)
            {
               this._anchor.cleanup();
            }
            this._anchor = param1;
            if(this._anchor)
            {
               this._anchor.child = this;
            }
            this.layoutGuiSprite();
         }
      }
      
      override public function get width() : Number
      {
         return this._guiSpriteSize.x;
      }
      
      override public function get height() : Number
      {
         return this._guiSpriteSize.y;
      }
      
      internal function get internalWidth() : Number
      {
         return this._guiSpriteSize.x;
      }
      
      internal function get internalHeight() : Number
      {
         return this._guiSpriteSize.y;
      }
      
      internal function set internalWidth(param1:Number) : void
      {
         if(this._maxWidth != null)
         {
            param1 = Math.min(this._maxWidth,param1);
         }
         if(this._minWidth != null)
         {
            param1 = Math.max(this._minWidth,param1);
         }
         if(this._guiSpriteSize.x != param1)
         {
            this._guiSpriteSize.x = param1;
            this.dirtySize = true;
         }
      }
      
      internal function checkDirtySize() : void
      {
         if(this.dirtySize)
         {
            this.dirtySize = false;
            this.layoutChildren();
            this.resizeHandler();
         }
      }
      
      internal function set internalHeight(param1:Number) : void
      {
         if(this._maxHeight != null)
         {
            param1 = Math.min(this._maxHeight,param1);
         }
         if(this._minHeight != null)
         {
            param1 = Math.max(this._minHeight,param1);
         }
         if(this._guiSpriteSize.y != param1)
         {
            this._guiSpriteSize.y = param1;
            this.dirtySize = true;
         }
      }
      
      override public function set width(param1:Number) : void
      {
         if(this._guiSpriteSize.x == param1)
         {
            return;
         }
         if(this._anchor)
         {
            this._anchor.percentWidth = null;
         }
         this.internalWidth = param1;
         this.checkDirtySize();
      }
      
      override public function set height(param1:Number) : void
      {
         if(this._guiSpriteSize.y == param1)
         {
            return;
         }
         if(this._anchor)
         {
            this._anchor.percentHeight = null;
         }
         this.internalHeight = param1;
         this.checkDirtySize();
      }
      
      override public function addChildAt(param1:DisplayObject, param2:int) : DisplayObject
      {
         if(param1.name.indexOf("instance") >= 0)
         {
            param1 = param1;
         }
         super.addChildAt(param1,param2);
         this.layoutChildren();
         return param1;
      }
      
      override public function addChild(param1:DisplayObject) : DisplayObject
      {
         if(!param1)
         {
            throw new ArgumentError("null child added");
         }
         if(param1.name.indexOf("instance") >= 0)
         {
            param1 = param1;
         }
         super.addChild(param1);
         this.layoutChildren();
         return param1;
      }
      
      public function setSize(param1:Number, param2:Number) : void
      {
         var _loc3_:Boolean = false;
         if(this._guiSpriteSize.x != param1)
         {
            this._guiSpriteSize.x = param1;
            _loc3_ = true;
         }
         if(this._guiSpriteSize.y != param2)
         {
            this._guiSpriteSize.y = param2;
            _loc3_ = true;
         }
         if(_loc3_)
         {
            this.layoutChildren();
            this.resizeHandler();
         }
      }
      
      public function setPosition(param1:Number, param2:Number) : void
      {
         this.x = param1;
         this.y = param2;
      }
      
      public function makeAllDirty() : void
      {
         var _loc2_:GuiSprite = null;
         this.dirtySize = true;
         var _loc1_:int = 0;
         while(_loc1_ < numChildren)
         {
            _loc2_ = getChildAt(_loc1_) as GuiSprite;
            if(_loc2_)
            {
               _loc2_.makeAllDirty();
            }
            _loc1_++;
         }
      }
      
      public function performResizeEventNow() : void
      {
         var _loc2_:GuiSprite = null;
         this.resizeHandler();
         var _loc1_:int = 0;
         while(_loc1_ < numChildren)
         {
            _loc2_ = getChildAt(_loc1_) as GuiSprite;
            if(_loc2_)
            {
               _loc2_.performResizeEventNow();
            }
            _loc1_++;
         }
      }
      
      protected function resizeHandler() : void
      {
         this.doDebugRender();
         dispatchEvent(new GuiSpriteEvent(GuiSpriteEvent.RESIZE));
      }
      
      public function layoutChildren() : void
      {
         var _loc2_:GuiSprite = null;
         var _loc1_:int = 0;
         while(_loc1_ < numChildren)
         {
            _loc2_ = getChildAt(_loc1_) as GuiSprite;
            if(_loc2_)
            {
               _loc2_.layoutGuiSprite();
            }
            _loc1_++;
         }
      }
      
      public function layoutGuiSprite() : void
      {
         if(this._suppressLayout)
         {
            this._layoutDirty = true;
            return;
         }
         this._layoutDirty = false;
         if(this._anchor)
         {
            this._anchor.layoutGuiSprite();
         }
         this.layoutChildren();
      }
      
      public function bringChildToFront(param1:DisplayObject) : void
      {
         if(null == parent)
         {
            return;
         }
         this.setChildIndex(param1,this.numChildren - 1);
         this.layoutChildren();
      }
      
      public function bringToFront() : void
      {
         if(null == parent)
         {
            return;
         }
         parent.setChildIndex(this,parent.numChildren - 1);
         if(parent is GuiSprite)
         {
            (parent as GuiSprite).layoutChildren();
         }
      }
      
      public function bringAllToFront() : void
      {
         bringAllSpritesToFront(this);
      }
      
      public function findLeafGuiSprite_s(param1:Number, param2:Number) : GuiSprite
      {
         var _loc3_:Point = this.globalToLocal(new Point(param1,param2));
         return this.findLeafGuiSprite(_loc3_.x,_loc3_.y);
      }
      
      public function findLeafGuiSprite(param1:Number, param2:Number) : GuiSprite
      {
         var _loc3_:int = 0;
         var _loc4_:GuiSprite = null;
         var _loc5_:GuiSprite = null;
         if(MathUtil_inRect(param1,param2,0,0,this.width,this.height))
         {
            _loc3_ = 0;
            while(_loc3_ < numChildren)
            {
               _loc4_ = getChildAt(numChildren - 1 - _loc3_) as GuiSprite;
               if(_loc4_)
               {
                  _loc5_ = _loc4_.findLeafGuiSprite(param1 - _loc4_.x * _loc4_.scaleX,param2 - _loc4_.y * _loc4_.scaleY);
                  if(_loc5_)
                  {
                     return _loc5_;
                  }
               }
               _loc3_++;
            }
            return this;
         }
         return null;
      }
      
      public function intersectsGuiSprite_s(param1:Number, param2:Number) : Boolean
      {
         var _loc3_:Point = this.globalToLocal(new Point(param1,param2));
         return this.intersectsGuiSprite(_loc3_.x,_loc3_.y);
      }
      
      public function intersectsGuiSprite(param1:Number, param2:Number) : Boolean
      {
         return MathUtil_inRect(param1,param2,0,0,this.width,this.height);
      }
      
      public function removeAllChildren() : void
      {
         while(numChildren)
         {
            removeChildAt(numChildren - 1);
         }
      }
      
      private function doDebugRender() : void
      {
         if(this._debugRender == null)
         {
            return;
         }
         var _loc1_:uint = this._debugRender is Boolean ? 1727987712 : this._debugRender;
         var _loc2_:Number = ((_loc1_ & 4278190080) >>> 24) / 255;
         var _loc3_:Point = localToGlobal(new Point(0,0));
         this.graphics.clear();
         this.graphics.lineStyle(1,_loc1_);
         this.graphics.beginFill(_loc1_,_loc2_);
         this.graphics.drawRect(0,0,this.width,this.height);
         this.graphics.endFill();
      }
      
      public function center() : void
      {
         centerChild(this);
      }
      
      public function sizeToPlaceholder(param1:Sprite) : void
      {
         var _loc2_:Rectangle = param1.getBounds(this);
         this.setPosition(_loc2_.x,_loc2_.y);
         this.setSize(_loc2_.width,_loc2_.height);
      }
   }
}

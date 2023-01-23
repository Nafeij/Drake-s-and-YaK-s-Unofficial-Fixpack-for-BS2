package engine.gui.core
{
   import flash.display.DisplayObjectContainer;
   
   public class GuiSpriteAnchorPolicy
   {
       
      
      private var _left;
      
      private var _right;
      
      private var _top;
      
      private var _bottom;
      
      private var _horizontalCenter;
      
      private var _verticalCenter;
      
      private var _percentWidth;
      
      private var _percentHeight;
      
      internal var child:GuiSprite;
      
      public function GuiSpriteAnchorPolicy(param1:GuiSprite)
      {
         super();
         this.child = param1;
      }
      
      public function cleanup() : void
      {
         this.child = null;
      }
      
      public function get percentHeight() : *
      {
         return this._percentHeight;
      }
      
      public function set percentHeight(param1:*) : void
      {
         if(this._percentHeight != param1)
         {
            this._percentHeight = param1;
            this.layoutGuiSprite();
         }
      }
      
      public function get percentWidth() : *
      {
         return this._percentWidth;
      }
      
      public function set percentWidth(param1:*) : void
      {
         if(this._percentWidth != param1)
         {
            this._percentWidth = param1;
            this.layoutGuiSprite();
         }
      }
      
      public function get verticalCenter() : *
      {
         return this._verticalCenter;
      }
      
      public function set verticalCenter(param1:*) : void
      {
         if(this._verticalCenter != param1)
         {
            this._verticalCenter = param1;
            this.layoutGuiSprite();
         }
      }
      
      public function get horizontalCenter() : *
      {
         return this._horizontalCenter;
      }
      
      public function set horizontalCenter(param1:*) : void
      {
         if(this._horizontalCenter != param1)
         {
            this._horizontalCenter = param1;
            this.layoutGuiSprite();
         }
      }
      
      public function get bottom() : *
      {
         return this._bottom;
      }
      
      public function set bottom(param1:*) : void
      {
         if(this._bottom != param1)
         {
            this._bottom = param1;
            this.layoutGuiSprite();
         }
      }
      
      public function get top() : *
      {
         return this._top;
      }
      
      public function set top(param1:*) : void
      {
         if(this._top != param1)
         {
            this._top = param1;
            this.layoutGuiSprite();
         }
      }
      
      public function get right() : *
      {
         return this._right;
      }
      
      public function set right(param1:*) : void
      {
         if(this._right != param1)
         {
            this._right = param1;
            this.layoutGuiSprite();
         }
      }
      
      public function get left() : *
      {
         return this._left;
      }
      
      public function set left(param1:*) : void
      {
         if(this._left != param1)
         {
            this._left = param1;
            this.layoutGuiSprite();
         }
      }
      
      public function layoutGuiSprite() : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc1_:DisplayObjectContainer = this.child.parent;
         if(!_loc1_)
         {
            return;
         }
         if(this.percentWidth != null)
         {
            _loc2_ = _loc1_.width * this.percentWidth / 100;
            this.child.internalWidth = _loc2_;
         }
         if(this.percentHeight != null)
         {
            _loc3_ = _loc1_.height * this.percentHeight / 100;
            this.child.internalHeight = _loc3_;
         }
         if(this.horizontalCenter != null)
         {
            this.child.x = (_loc1_.width - this.child.internalWidth) / 2 + this.horizontalCenter;
         }
         else if(this.left != null)
         {
            this.child.x = this.left;
            if(this.right != null)
            {
               this.child.internalWidth = _loc1_.width - this.right - this.left;
            }
         }
         else if(this.right != null)
         {
            this.child.x = _loc1_.width - this.right - this.child.internalWidth;
         }
         if(this.verticalCenter != null)
         {
            this.child.y = (_loc1_.height - this.child.internalHeight) / 2 + this.verticalCenter;
         }
         else if(this.top != null)
         {
            this.child.y = this.top;
            if(this.bottom != null)
            {
               this.child.internalHeight = _loc1_.height - this.bottom - this.top;
            }
         }
         else if(this.bottom != null)
         {
            this.child.y = _loc1_.height - this.bottom - this.child.internalHeight;
         }
         this.child.checkDirtySize();
      }
   }
}

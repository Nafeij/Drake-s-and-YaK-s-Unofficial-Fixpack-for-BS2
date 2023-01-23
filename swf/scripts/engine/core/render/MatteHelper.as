package engine.core.render
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObjectContainer;
   import flash.events.Event;
   
   public class MatteHelper
   {
      
      public static var DEBUG_RENDER:Boolean = false;
      
      private static var matteBitmapData:BitmapData;
       
      
      public var boundedCamera:BoundedCamera;
      
      public var owner:DisplayObjectContainer;
      
      public var topMatte:Bitmap;
      
      public var bottomMatte:Bitmap;
      
      public var leftMatte:Bitmap;
      
      public var rightMatte:Bitmap;
      
      private var _visible:Boolean = false;
      
      private var _enabled:Boolean = true;
      
      public function MatteHelper(param1:DisplayObjectContainer, param2:BoundedCamera)
      {
         super();
         if(!matteBitmapData)
         {
            if(DEBUG_RENDER)
            {
               matteBitmapData = new BitmapData(1,1,true,1727987712);
            }
            else
            {
               matteBitmapData = new BitmapData(1,1,false,0);
            }
         }
         this.boundedCamera = param2;
         param2.addEventListener(BoundedCamera.EVENT_MATTE_CHANGED,this.matteChangedHandler);
         this.owner = param1;
         this.topMatte = new Bitmap(matteBitmapData);
         this.topMatte.name = "matte_top";
         param1.addChild(this.topMatte);
         this.bottomMatte = new Bitmap(matteBitmapData);
         this.bottomMatte.name = "matte_bottom";
         param1.addChild(this.bottomMatte);
         this.leftMatte = new Bitmap(matteBitmapData);
         this.leftMatte.name = "matte_left";
         param1.addChild(this.leftMatte);
         this.rightMatte = new Bitmap(matteBitmapData);
         this.rightMatte.name = "matte_right";
         param1.addChild(this.rightMatte);
         this.checkVisible();
      }
      
      public function cleanup() : void
      {
         this.boundedCamera.removeEventListener(BoundedCamera.EVENT_MATTE_CHANGED,this.matteChangedHandler);
         if(this.owner == this.topMatte.parent)
         {
            this.owner.removeChild(this.topMatte);
         }
         if(this.owner == this.topMatte.parent)
         {
            this.owner.removeChild(this.bottomMatte);
         }
         if(this.owner == this.topMatte.parent)
         {
            this.owner.removeChild(this.leftMatte);
         }
         if(this.owner == this.topMatte.parent)
         {
            this.owner.removeChild(this.rightMatte);
         }
         this.boundedCamera = null;
         this.owner = null;
      }
      
      public function get visible() : Boolean
      {
         return this._visible;
      }
      
      public function set visible(param1:Boolean) : void
      {
         if(this._visible != param1)
         {
            this._visible = param1;
            this.checkVisible();
         }
      }
      
      private function checkVisible() : void
      {
         var _loc1_:Boolean = this._visible && this._enabled;
         this.topMatte.visible = this.bottomMatte.visible = this.boundedCamera.hbar != 0 && _loc1_;
         this.leftMatte.visible = this.rightMatte.visible = this.boundedCamera.vbar != 0 && _loc1_;
         if(!_loc1_)
         {
            if(this.rightMatte.parent)
            {
               this.rightMatte.parent.removeChild(this.rightMatte);
            }
            if(this.leftMatte.parent)
            {
               this.leftMatte.parent.removeChild(this.leftMatte);
            }
            if(this.topMatte.parent)
            {
               this.topMatte.parent.removeChild(this.topMatte);
            }
            if(this.bottomMatte.parent)
            {
               this.bottomMatte.parent.removeChild(this.bottomMatte);
            }
         }
         else
         {
            if(!this.topMatte.parent)
            {
               this.owner.addChild(this.topMatte);
            }
            if(!this.bottomMatte.parent)
            {
               this.owner.addChild(this.bottomMatte);
            }
            if(!this.leftMatte.parent)
            {
               this.owner.addChild(this.leftMatte);
            }
            if(!this.rightMatte.parent)
            {
               this.owner.addChild(this.rightMatte);
            }
            this.renderMatte();
         }
      }
      
      public function bringToFront() : void
      {
         if(this._visible && this._enabled)
         {
            this.owner.setChildIndex(this.rightMatte,this.owner.numChildren - 1);
            this.owner.setChildIndex(this.leftMatte,this.owner.numChildren - 2);
            this.owner.setChildIndex(this.bottomMatte,this.owner.numChildren - 3);
            this.owner.setChildIndex(this.topMatte,this.owner.numChildren - 4);
         }
      }
      
      private function renderMatte() : void
      {
         if(!this._visible || !this._enabled)
         {
            return;
         }
         var _loc1_:int = this.boundedCamera.hbar;
         var _loc2_:int = this.boundedCamera.vbar;
         if(_loc1_)
         {
            this.topMatte.x = 0;
            this.topMatte.y = 0;
            this.topMatte.width = this.owner.width;
            this.topMatte.height = _loc1_;
            this.bottomMatte.x = 0;
            this.bottomMatte.y = this.owner.height - _loc1_;
            this.bottomMatte.width = this.owner.width;
            this.bottomMatte.height = _loc1_;
         }
         if(_loc2_)
         {
            this.leftMatte.x = 0;
            this.leftMatte.y = _loc1_;
            this.leftMatte.width = _loc2_;
            this.leftMatte.height = this.owner.height - _loc1_ * 2;
            this.rightMatte.x = this.owner.width - _loc2_;
            this.rightMatte.y = _loc1_;
            this.rightMatte.width = _loc2_;
            this.rightMatte.height = this.owner.height - _loc1_ * 2;
         }
      }
      
      public function matteChangedHandler(param1:Event) : void
      {
         this.checkVisible();
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         this._enabled = param1;
         this.checkVisible();
      }
   }
}

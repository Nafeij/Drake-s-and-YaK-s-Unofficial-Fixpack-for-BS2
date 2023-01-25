package com.sociodox.theminer.window
{
   import com.sociodox.theminer.manager.Analytics;
   import com.sociodox.theminer.manager.Commands;
   import com.sociodox.theminer.manager.SkinManager;
   import com.sociodox.theminer.manager.Stage2D;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.InteractiveObject;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.utils.getTimer;
   
   public class MouseListeners extends Sprite implements IWindow
   {
      
      private static const COLOR_ALPHA:Number = 0.3;
       
      
      private var mRenderTargetData:BitmapData = null;
      
      private var mRenderTarget:Bitmap = null;
      
      private var mRenderTargetDataRect:Rectangle = null;
      
      private var currentRenderTarget:Sprite;
      
      private var mEnterTime:int = 0;
      
      public function MouseListeners()
      {
         this.currentRenderTarget = new Sprite();
         super();
         this.Init();
         this.mEnterTime = getTimer();
         Analytics.Track("Tab","MouseProfiler","MouseProfiler Enter");
      }
      
      private function Init() : void
      {
         this.mouseChildren = false;
         this.mouseEnabled = false;
         this.mRenderTargetData = new BitmapData(Stage2D.stageWidth,Stage2D.stageHeight,false,0);
         this.mRenderTargetDataRect = this.mRenderTargetData.rect;
         this.mRenderTarget = new Bitmap();
         this.mRenderTarget.bitmapData = this.mRenderTargetData;
         this.addChild(this.mRenderTarget);
      }
      
      public function Dispose() : void
      {
         Analytics.Track("Tab","MouseProfiler","MouseProfiler Enter",int((getTimer() - this.mEnterTime) / 1000));
         if(this.mRenderTarget != null)
         {
            this.mRenderTarget.bitmapData = null;
            this.mRenderTarget = null;
         }
         if(this.mRenderTargetData != null)
         {
            this.mRenderTargetData.dispose();
            this.mRenderTargetData = null;
         }
         this.mRenderTargetDataRect = null;
         while(this.numChildren > 0)
         {
            this.removeChildAt(0);
         }
         this.currentRenderTarget = null;
      }
      
      public function Update() : void
      {
         this.alpha = Commands.Opacity / 10;
         this.mRenderTargetData.fillRect(this.mRenderTargetData.rect,SkinManager.COLOR_GLOBAL_BG);
         this.mRenderTargetData.lock();
         this.ParseStage(Stage2D);
         this.mRenderTargetData.unlock();
      }
      
      protected function ParseStage(param1:DisplayObjectContainer) : void
      {
         var _loc3_:DisplayObject = null;
         var _loc4_:InteractiveObject = null;
         var _loc5_:Rectangle = null;
         if(param1 == null || param1 == parent)
         {
            return;
         }
         if(param1.mouseChildren == false)
         {
            return;
         }
         var _loc2_:int = 0;
         while(_loc2_ < param1.numChildren)
         {
            _loc3_ = param1.getChildAt(_loc2_);
            if(_loc3_ != null)
            {
               _loc4_ = _loc3_ as InteractiveObject;
               if(_loc4_ != null)
               {
                  if(_loc4_.mouseEnabled == true)
                  {
                     _loc5_ = _loc3_.getRect(Stage2D);
                     _loc5_ = _loc5_.intersection(this.mRenderTargetDataRect);
                     this.currentRenderTarget.graphics.clear();
                     if(_loc4_.hasEventListener(MouseEvent.CLICK) || _loc4_.hasEventListener(MouseEvent.MOUSE_DOWN) || _loc4_.hasEventListener(MouseEvent.MOUSE_UP))
                     {
                        this.currentRenderTarget.graphics.beginFill(SkinManager.COLOR_MOUSE_CLICK,COLOR_ALPHA / 2);
                     }
                     else if(_loc4_.hasEventListener(MouseEvent.MOUSE_MOVE) || _loc4_.hasEventListener(MouseEvent.MOUSE_OVER) || _loc4_.hasEventListener(MouseEvent.MOUSE_OUT))
                     {
                        this.currentRenderTarget.graphics.beginFill(SkinManager.COLOR_MOUSE_MOVE,COLOR_ALPHA / 2);
                     }
                     else
                     {
                        this.currentRenderTarget.graphics.beginFill(SkinManager.COLOR_MOUSE_ENABLED,COLOR_ALPHA / 2);
                     }
                     this.currentRenderTarget.graphics.drawRect(_loc5_.x,_loc5_.y,_loc5_.width,_loc5_.height);
                     this.currentRenderTarget.graphics.endFill();
                     this.mRenderTargetData.draw(this.currentRenderTarget);
                  }
                  this.ParseStage(_loc3_ as DisplayObjectContainer);
               }
            }
            _loc2_++;
         }
      }
      
      public function Unlink() : void
      {
         if(this.parent != null)
         {
            this.parent.removeChild(this);
         }
      }
      
      public function Link(param1:DisplayObjectContainer, param2:int) : void
      {
         param1.addChildAt(this,param2);
      }
   }
}

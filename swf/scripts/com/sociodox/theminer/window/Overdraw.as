package com.sociodox.theminer.window
{
   import com.sociodox.theminer.manager.Analytics;
   import com.sociodox.theminer.manager.Localization;
   import com.sociodox.theminer.manager.SkinManager;
   import com.sociodox.theminer.manager.Stage2D;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.filters.GlowFilter;
   import flash.geom.ColorTransform;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   
   public class Overdraw extends Sprite implements IWindow
   {
      
      private static const COLOR_ALPHA:Number = 0.3;
       
      
      private var mRenderTargetData:BitmapData = null;
      
      private var mRenderTargetDataAlpha:BitmapData = null;
      
      private var mRenderTargetDataAlphaNotVisible:BitmapData = null;
      
      private var mRenderTargetDataRect:Rectangle = null;
      
      private var mRenderTarget:Bitmap = null;
      
      private var currentRenderTarget:Sprite;
      
      private var mInfos:TextField;
      
      private var mTimer:Timer;
      
      private var mDOTotal:int = 0;
      
      private var mMaxDepth:int = 0;
      
      private var mEnterTime:int = 0;
      
      private var mLastTick:int = 0;
      
      public function Overdraw()
      {
         this.currentRenderTarget = new Sprite();
         super();
         this.Init();
         this.mEnterTime = getTimer();
         Analytics.Track("Tab","OverdrawProfiler","OverdrawProfiler Enter");
      }
      
      private function Init() : void
      {
         var _loc2_:Sprite = null;
         this.mouseChildren = false;
         this.mouseEnabled = false;
         this.mRenderTargetData = new BitmapData(Stage2D.stageWidth,Stage2D.stageHeight,true,0);
         this.mRenderTargetDataAlpha = new BitmapData(Stage2D.stageWidth,Stage2D.stageHeight,true,0);
         this.mRenderTargetDataAlphaNotVisible = new BitmapData(Stage2D.stageWidth,Stage2D.stageHeight,true,0);
         this.mRenderTargetDataAlpha.fillRect(this.mRenderTargetDataAlpha.rect,150994943);
         this.mRenderTargetDataAlphaNotVisible.fillRect(this.mRenderTargetDataAlpha.rect,671088640 + (SkinManager.COLOR_OVERDRAW_NOTVISIBLE & 16777215));
         this.mRenderTargetDataRect = this.mRenderTargetData.rect;
         this.mRenderTarget = new Bitmap();
         this.mRenderTarget.bitmapData = this.mRenderTargetData;
         this.addChild(this.mRenderTarget);
         var _loc1_:int = int(Stage2D.stageWidth);
         _loc2_ = new Sprite();
         _loc2_.graphics.beginFill(SkinManager.COLOR_GLOBAL_BG,0.4);
         _loc2_.graphics.drawRect(0,0,_loc1_,17);
         _loc2_.graphics.endFill();
         _loc2_.graphics.beginFill(SkinManager.COLOR_GLOBAL_LINE_DARK,0.6);
         _loc2_.graphics.drawRect(0,1,_loc1_,1);
         _loc2_.graphics.endFill();
         _loc2_.graphics.beginFill(SkinManager.COLOR_GLOBAL_LINE,0.8);
         _loc2_.graphics.drawRect(0,0,_loc1_,1);
         _loc2_.graphics.endFill();
         addChild(_loc2_);
         _loc2_.y = Stage2D.stageHeight - _loc2_.height;
         var _loc3_:TextFormat = new TextFormat("_sans",11,SkinManager.COLOR_GLOBAL_TEXT,false);
         var _loc4_:GlowFilter = new GlowFilter(SkinManager.COLOR_GLOBAL_TEXT_GLOW,1,2,2,3,2,false,false);
         this.mInfos = new TextField();
         this.mInfos.autoSize = TextFieldAutoSize.LEFT;
         this.mInfos.defaultTextFormat = _loc3_;
         this.mInfos.selectable = false;
         this.mInfos.text = "";
         this.mInfos.filters = [_loc4_];
         this.mInfos.x = 2;
         addChild(this.mInfos);
         this.mInfos.y = Stage2D.stageHeight - _loc2_.height;
      }
      
      public function Dispose() : void
      {
         this.mInfos = null;
         Analytics.Track("Tab","OverdrawProfiler","OverdrawProfiler Exit",int((getTimer() - this.mEnterTime) / 1000));
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
         var _loc1_:* = null;
         if(getTimer() - this.mLastTick >= 1000)
         {
            this.mLastTick = getTimer();
            _loc1_ = Localization.Lbl_O_DisplayObjectOnStage + "[ " + this.mDOTotal + " ]\t" + Localization.Lbl_O_MaxDepth + "[ " + this.mMaxDepth + " ]";
            this.mInfos.text = _loc1_;
         }
         this.mRenderTargetData.fillRect(this.mRenderTargetData.rect,SkinManager.COLOR_GLOBAL_BG | 4278190080);
         this.mMaxDepth = 0;
         this.mDOTotal = 0;
         this.mRenderTargetData.lock();
         this.ParseStage(Stage2D);
         this.mRenderTargetData.unlock();
      }
      
      private function ParseStage(param1:DisplayObjectContainer, param2:int = 1) : void
      {
         var _loc6_:DisplayObject = null;
         var _loc7_:Rectangle = null;
         if(param1 == null || param1 == parent)
         {
            return;
         }
         if(this.mMaxDepth < param2)
         {
            this.mMaxDepth = param2;
         }
         var _loc3_:ColorTransform = new ColorTransform(1,1,1,1,12,12,12,12);
         var _loc4_:Point = new Point();
         var _loc5_:int = 0;
         while(_loc5_ < param1.numChildren)
         {
            ++this.mDOTotal;
            _loc6_ = param1.getChildAt(_loc5_);
            if(_loc6_ != null)
            {
               _loc7_ = _loc6_.getRect(Stage2D);
               _loc4_.x = _loc7_.x;
               _loc4_.y = _loc7_.y;
               if(_loc6_.visible == false || _loc6_.alpha == 0)
               {
                  this.mRenderTargetData.copyPixels(this.mRenderTargetDataAlphaNotVisible,_loc7_,_loc4_,null,null,true);
               }
               else
               {
                  this.mRenderTargetData.copyPixels(this.mRenderTargetDataAlpha,_loc7_,_loc4_,null,null,true);
               }
               this.ParseStage(_loc6_ as DisplayObjectContainer,param2 + 1);
            }
            _loc5_++;
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

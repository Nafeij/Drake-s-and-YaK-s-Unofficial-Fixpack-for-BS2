package com.sociodox.theminer.window
{
   import com.sociodox.theminer.data.InternalEventsStatsHolder;
   import com.sociodox.theminer.manager.Analytics;
   import com.sociodox.theminer.manager.Commands;
   import com.sociodox.theminer.manager.Localization;
   import com.sociodox.theminer.manager.SampleAnalyzer;
   import com.sociodox.theminer.manager.SkinManager;
   import com.sociodox.theminer.manager.Stage2D;
   import com.sociodox.theminer.ui.button.MenuButton;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.filters.GlowFilter;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import flash.utils.getTimer;
   
   public class InternalEventsProfiler extends Sprite implements IWindow
   {
       
      
      private var mInternalEventsLabels:TextField;
      
      private var mFrameDivisionData:BitmapData = null;
      
      private var mFrameDivision:Bitmap = null;
      
      private var mInterface:Sprite = null;
      
      private var mBitmapBackgroundData:BitmapData = null;
      
      private var mBitmapBackground:Bitmap = null;
      
      private var mPauseButton:MenuButton;
      
      private var frameCount:int = 0;
      
      private var mEnterTime:int = 0;
      
      private var mBitmapCanvas:Bitmap;
      
      private var mLastTime:int = 0;
      
      private var mProfilerWasActive:Boolean = false;
      
      public function InternalEventsProfiler()
      {
         super();
         this.mProfilerWasActive = Configuration.PROFILE_INTERNAL_EVENTS;
         Configuration.PROFILE_INTERNAL_EVENTS = true;
         this.Init();
         this.mEnterTime = getTimer();
         Analytics.Track("Tab","EventProfiler","EventProfiler Enter");
      }
      
      private function Init() : void
      {
         var _loc6_:TextField = null;
         var _loc8_:BitmapData = null;
         this.mInterface = new Sprite();
         this.mouseEnabled = false;
         this.mBitmapBackgroundData = new BitmapData(Stage2D.stageWidth,Stage2D.stageHeight,true,0);
         this.mBitmapCanvas = new Bitmap(this.mBitmapBackgroundData);
         addChild(this.mBitmapCanvas);
         var _loc1_:int = int(Stage2D.stageWidth);
         var _loc2_:Sprite = new Sprite();
         this.mInterface.graphics.beginFill(SkinManager.COLOR_GLOBAL_BG,1);
         this.mInterface.graphics.drawRect(0,16,_loc1_,Number(Stage2D.stageHeight) - 18);
         this.mInterface.graphics.endFill();
         this.mInterface.graphics.beginFill(SkinManager.COLOR_GLOBAL_LINE_DARK,1);
         this.mInterface.graphics.drawRect(0,17,_loc1_,1);
         this.mInterface.graphics.endFill();
         this.mInterface.graphics.beginFill(SkinManager.COLOR_GLOBAL_LINE,1);
         this.mInterface.graphics.drawRect(0,16,_loc1_,1);
         this.mInterface.graphics.endFill();
         var _loc3_:TextFormat = new TextFormat("_sans",11,SkinManager.COLOR_GLOBAL_TEXT,false);
         var _loc4_:TextFormat = new TextFormat("_sans",11,SkinManager.COLOR_GLOBAL_TEXT,false,null,null,null,null,TextFormatAlign.RIGHT);
         var _loc5_:GlowFilter = new GlowFilter(SkinManager.COLOR_GLOBAL_TEXT_GLOW,1,2,2,3,2,false,false);
         var _loc7_:int = 20;
         this.mFrameDivisionData = new BitmapData(Stage2D.stageWidth,Number(Stage2D.stageHeight) - 50 - 20,false,0);
         this.mFrameDivision = new Bitmap(this.mFrameDivisionData);
         this.mInterface.addChild(this.mFrameDivision);
         this.mFrameDivision.x = 0;
         this.mFrameDivision.y = Number(Stage2D.stageHeight) - this.mFrameDivisionData.height;
         _loc8_ = new BitmapData(Stage2D.stageWidth,50,false,0);
         var _loc9_:Bitmap = new Bitmap(_loc8_);
         _loc9_.y = 20;
         this.mInterface.addChild(_loc9_);
         var _loc10_:Rectangle = new Rectangle();
         _loc10_.width = _loc10_.height = 10;
         this.mInternalEventsLabels = new TextField();
         this.mInternalEventsLabels.autoSize = TextFieldAutoSize.LEFT;
         this.mInternalEventsLabels.defaultTextFormat = _loc3_;
         this.mInternalEventsLabels.selectable = false;
         this.mInternalEventsLabels.filters = [_loc5_];
         var _loc11_:Matrix = new Matrix();
         _loc11_.identity();
         _loc10_.x = 4;
         _loc10_.y = 2;
         _loc8_.fillRect(_loc10_,SkinManager.COLOR_INTERNAL_VERIFY);
         _loc11_.tx = _loc10_.x + 12;
         _loc11_.ty = _loc10_.y - 4;
         this.mInternalEventsLabels.text = Localization.Lbl_IE_VERIFY;
         _loc8_.draw(this.mInternalEventsLabels,_loc11_);
         _loc10_.x = 4 + 1 * 100;
         _loc10_.y = 2;
         _loc8_.fillRect(_loc10_,SkinManager.COLOR_INTERNAL_MARK);
         _loc11_.tx = _loc10_.x + 12;
         _loc11_.ty = _loc10_.y - 4;
         this.mInternalEventsLabels.text = Localization.Lbl_IE_MARK;
         _loc8_.draw(this.mInternalEventsLabels,_loc11_);
         _loc10_.x = 4 + 2 * 100;
         _loc10_.y = 2;
         _loc8_.fillRect(_loc10_,SkinManager.COLOR_INTERNAL_REAP);
         _loc11_.tx = _loc10_.x + 12;
         _loc11_.ty = _loc10_.y - 4;
         this.mInternalEventsLabels.text = Localization.Lbl_IE_REAP;
         _loc8_.draw(this.mInternalEventsLabels,_loc11_);
         _loc10_.x = 4 + 3 * 100;
         _loc10_.y = 2;
         _loc8_.fillRect(_loc10_,SkinManager.COLOR_INTERNAL_SWEEP);
         _loc11_.tx = _loc10_.x + 12;
         _loc11_.ty = _loc10_.y - 4;
         this.mInternalEventsLabels.text = Localization.Lbl_IE_SWEEP;
         _loc8_.draw(this.mInternalEventsLabels,_loc11_);
         _loc10_.x = 4;
         _loc10_.y = 2 + 1 * 14;
         _loc8_.fillRect(_loc10_,SkinManager.COLOR_INTERNAL_ENTERFRAME);
         _loc11_.tx = _loc10_.x + 12;
         _loc11_.ty = _loc10_.y - 4;
         this.mInternalEventsLabels.text = Localization.Lbl_IE_ENTERFRAME;
         _loc8_.draw(this.mInternalEventsLabels,_loc11_);
         _loc10_.x = 4 + 1 * 100;
         _loc10_.y = 2 + 1 * 14;
         _loc8_.fillRect(_loc10_,SkinManager.COLOR_INTERNAL_TIMER);
         _loc11_.tx = _loc10_.x + 12;
         _loc11_.ty = _loc10_.y - 4;
         this.mInternalEventsLabels.text = Localization.Lbl_IE_TIMERS;
         _loc8_.draw(this.mInternalEventsLabels,_loc11_);
         _loc10_.x = 4 + 2 * 100;
         _loc10_.y = 2 + 1 * 14;
         _loc8_.fillRect(_loc10_,SkinManager.COLOR_INTERNAL_PRERENDER);
         _loc11_.tx = _loc10_.x + 12;
         _loc11_.ty = _loc10_.y - 4;
         this.mInternalEventsLabels.text = Localization.Lbl_IE_PRERENDER;
         _loc8_.draw(this.mInternalEventsLabels,_loc11_);
         _loc10_.x = 4 + 3 * 100;
         _loc10_.y = 2 + 1 * 14;
         _loc8_.fillRect(_loc10_,SkinManager.COLOR_INTERNAL_RENDER);
         _loc11_.tx = _loc10_.x + 12;
         _loc11_.ty = _loc10_.y - 4;
         this.mInternalEventsLabels.text = Localization.Lbl_IE_RENDER;
         _loc8_.draw(this.mInternalEventsLabels,_loc11_);
         _loc10_.x = 4 + 0 * 100;
         _loc10_.y = 2 + 2 * 14;
         _loc8_.fillRect(_loc10_,SkinManager.COLOR_INTERNAL_AVM1);
         _loc11_.tx = _loc10_.x + 12;
         _loc11_.ty = _loc10_.y - 4;
         this.mInternalEventsLabels.text = Localization.Lbl_IE_AVM1;
         _loc8_.draw(this.mInternalEventsLabels,_loc11_);
         _loc10_.x = 4 + 1 * 100;
         _loc10_.y = 2 + 2 * 14;
         _loc8_.fillRect(_loc10_,SkinManager.COLOR_INTERNAL_IO);
         _loc11_.tx = _loc10_.x + 12;
         _loc11_.ty = _loc10_.y - 4;
         this.mInternalEventsLabels.text = Localization.Lbl_IE_IO;
         _loc8_.draw(this.mInternalEventsLabels,_loc11_);
         _loc10_.x = 4 + 2 * 100;
         _loc10_.y = 2 + 2 * 14;
         _loc8_.fillRect(_loc10_,SkinManager.COLOR_INTERNAL_MOUSE);
         _loc11_.tx = _loc10_.x + 12;
         _loc11_.ty = _loc10_.y - 4;
         this.mInternalEventsLabels.text = Localization.Lbl_IE_MOUSE;
         _loc8_.draw(this.mInternalEventsLabels,_loc11_);
         _loc10_.x = 4 + 3 * 100;
         _loc10_.y = 2 + 2 * 14;
         _loc8_.fillRect(_loc10_,SkinManager.COLOR_INTERNAL_FREE);
         _loc11_.tx = _loc10_.x + 12;
         _loc11_.ty = _loc10_.y - 4;
         this.mInternalEventsLabels.text = Localization.Lbl_IE_FREE;
         _loc8_.draw(this.mInternalEventsLabels,_loc11_);
         _loc10_.x = 0;
         _loc10_.y = _loc8_.height - 5;
         _loc10_.width = _loc8_.width;
         _loc10_.height = 3;
         _loc8_.fillRect(_loc10_,SkinManager.COLOR_GLOBAL_LINE_DARK);
         _loc10_.x = 0;
         _loc10_.y = _loc8_.height - 4;
         _loc10_.width = _loc8_.width;
         _loc10_.height = 1;
         _loc8_.fillRect(_loc10_,SkinManager.COLOR_GLOBAL_LINE);
         this.mPauseButton = new MenuButton(Number(Stage2D.stage.stageWidth) - 16,_loc8_.height,MenuButton.ICON_PAUSE,null,-1,Localization.Lbl_MFP_PauseRefresh,true,Localization.Lbl_MFP_ResumeRefresh);
         addChild(this.mPauseButton);
      }
      
      public function Update() : void
      {
         if(this.mPauseButton.mIsSelected)
         {
            return;
         }
         var _loc1_:int = getTimer() - this.mLastTime;
         if(_loc1_ < 1000 / Number(Commands.RefreshRate))
         {
            return;
         }
         this.mLastTime = getTimer();
         var _loc2_:InternalEventsStatsHolder = SampleAnalyzer.GetInternalsEvents();
         var _loc3_:Number = _loc2_.FrameTime;
         var _loc4_:uint = 0;
         var _loc5_:uint = 0;
         this.mFrameDivisionData.scroll(0,4);
         _loc5_ = Math.ceil(_loc2_.mVerify.entryTime / _loc3_ * this.mFrameDivisionData.width);
         this.mFrameDivisionData.fillRect(new Rectangle(_loc4_,0,_loc5_,2),SkinManager.COLOR_INTERNAL_VERIFY);
         _loc4_ += _loc5_;
         _loc5_ = Math.ceil(_loc2_.mMark.entryTime / _loc3_ * this.mFrameDivisionData.width);
         this.mFrameDivisionData.fillRect(new Rectangle(_loc4_,0,_loc5_,2),SkinManager.COLOR_INTERNAL_MARK);
         _loc4_ += _loc5_;
         _loc5_ = Math.ceil(_loc2_.mReap.entryTime / _loc3_ * this.mFrameDivisionData.width);
         this.mFrameDivisionData.fillRect(new Rectangle(_loc4_,0,_loc5_,2),SkinManager.COLOR_INTERNAL_REAP);
         _loc4_ += _loc5_;
         _loc5_ = Math.ceil(_loc2_.mSweep.entryTime / _loc3_ * this.mFrameDivisionData.width);
         this.mFrameDivisionData.fillRect(new Rectangle(_loc4_,0,_loc5_,2),SkinManager.COLOR_INTERNAL_SWEEP);
         _loc4_ += _loc5_;
         _loc5_ = Math.ceil(_loc2_.mEnterFrame.entryTime / _loc3_ * this.mFrameDivisionData.width);
         this.mFrameDivisionData.fillRect(new Rectangle(_loc4_,0,_loc5_,2),SkinManager.COLOR_INTERNAL_ENTERFRAME);
         _loc4_ += _loc5_;
         _loc5_ = Math.ceil(_loc2_.mTimers.entryTime / _loc3_ * this.mFrameDivisionData.width);
         this.mFrameDivisionData.fillRect(new Rectangle(_loc4_,0,_loc5_,2),SkinManager.COLOR_INTERNAL_TIMER);
         _loc4_ += _loc5_;
         _loc5_ = Math.ceil(_loc2_.mPreRender.entryTime / _loc3_ * this.mFrameDivisionData.width);
         this.mFrameDivisionData.fillRect(new Rectangle(_loc4_,0,_loc5_,2),SkinManager.COLOR_INTERNAL_PRERENDER);
         _loc4_ += _loc5_;
         _loc5_ = Math.ceil(_loc2_.mRender.entryTime / _loc3_ * this.mFrameDivisionData.width);
         this.mFrameDivisionData.fillRect(new Rectangle(_loc4_,0,_loc5_,2),SkinManager.COLOR_INTERNAL_RENDER);
         _loc4_ += _loc5_;
         _loc5_ = Math.ceil(_loc2_.mFree.entryTime / _loc3_ * this.mFrameDivisionData.width);
         this.mFrameDivisionData.fillRect(new Rectangle(_loc4_,0,_loc5_,2),SkinManager.COLOR_INTERNAL_FREE);
         _loc4_ += _loc5_;
         _loc5_ = Math.ceil(_loc2_.mFree.entryCount * 33 / _loc3_ * this.mFrameDivisionData.width);
         this.mFrameDivisionData.fillRect(new Rectangle(_loc4_,0,1,2),SkinManager.COLOR_GLOBAL_BG);
         this.mFrameDivisionData.fillRect(new Rectangle(_loc4_ + 1,0,1,2),SkinManager.COLOR_GLOBAL_LINE);
         this.mFrameDivisionData.fillRect(new Rectangle(_loc4_ + 2,0,1,2),SkinManager.COLOR_GLOBAL_BG);
         _loc2_.ResetFrame();
         this.Render();
      }
      
      private function Render() : void
      {
         this.mBitmapBackgroundData.lock();
         this.mBitmapBackgroundData.floodFill(0,0,0);
         this.mBitmapBackgroundData.draw(this.mInterface,null);
         this.mBitmapBackgroundData.unlock(this.mBitmapBackgroundData.rect);
         this.alpha = Number(Commands.Opacity) / 10;
      }
      
      public function Dispose() : void
      {
         Configuration.PROFILE_INTERNAL_EVENTS = this.mProfilerWasActive;
         Analytics.Track("Tab","EventProfiler","EventProfiler Exit",int((getTimer() - this.mEnterTime) / 1000));
         this.mInterface.graphics.clear();
         this.mInternalEventsLabels = null;
         this.mFrameDivisionData = null;
         this.mFrameDivision = null;
         this.mBitmapCanvas = null;
         this.mInterface = null;
         if(this.mBitmapBackgroundData != null)
         {
            this.mBitmapBackgroundData.dispose();
            this.mBitmapBackgroundData = null;
         }
         this.mPauseButton.Dispose();
         this.mPauseButton = null;
         this.mBitmapBackground = null;
         if(this.mFrameDivisionData != null)
         {
            this.mFrameDivisionData.dispose();
            this.mFrameDivisionData = null;
         }
         this.mFrameDivision = null;
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

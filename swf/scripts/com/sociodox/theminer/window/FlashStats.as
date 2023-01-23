package com.sociodox.theminer.window
{
   import com.sociodox.theminer.data.FrameStatistics;
   import com.sociodox.theminer.manager.Analytics;
   import com.sociodox.theminer.manager.Commands;
   import com.sociodox.theminer.manager.Localization;
   import com.sociodox.theminer.manager.SkinManager;
   import com.sociodox.theminer.manager.Stage2D;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.filters.GlowFilter;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.system.Capabilities;
   import flash.system.System;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import flash.utils.getTimer;
   
   public class FlashStats extends Bitmap implements IWindow
   {
      
      public static var stats:FrameStatistics = new FrameStatistics();
      
      public static var mMemoryValues:Vector.<int> = null;
      
      public static var mMemoryMaxValues:Vector.<int> = null;
      
      public static var mMemoryGC:Vector.<int> = null;
      
      public static var mSamplingCount:int = 300;
      
      public static var mSamplingStartIdx:int = 0;
      
      public static var IsStaticInitialized:Boolean = InitStatic();
      
      public static var HasGC:Boolean = false;
       
      
      private var mMemoryUseBitmapData:BitmapData = null;
      
      private var mBitmapBackgroundData:BitmapData = null;
      
      private var mBitmapBackground:Bitmap = null;
      
      private var mGridLine:Rectangle = null;
      
      private var mTypeColumnStartPos:int = 2;
      
      private var mCurrentColumnStartPos:int = 120;
      
      private var mMinColumnStartPos:int = 190;
      
      private var mMaxColumnStartPos:int = 240;
      
      private var mBlittingTextField:TextField;
      
      private var mBlittingTextFieldARight:TextField;
      
      private var mTextFieldMaxMemGraphARight:TextField;
      
      private var mBlittingTextFieldMatrix:Matrix = null;
      
      private var frameCount:int = 0;
      
      private var mLastTime:int = 0;
      
      private var statsLastFrame:FrameStatistics;
      
      private var timer:int;
      
      private var ms_prev:int;
      
      private var fps:int = 0;
      
      private var mDrawGraphics:Sprite;
      
      private var mDrawGraphicsMatrix:Matrix;
      
      private var mGraphPos:Point;
      
      private var mCurrentMaxMemGraph:int = 0;
      
      private var mEnterTime:int = 0;
      
      private var lastGraphHeight:int = 0;
      
      private var mProfilerWasActive:Boolean = false;
      
      public function FlashStats()
      {
         super();
         this.mProfilerWasActive = Configuration.PROFILE_MEMGRAPH;
         Configuration.PROFILE_MEMGRAPH = true;
         this.Init();
         this.mEnterTime = getTimer();
      }
      
      private static function InitStatic() : Boolean
      {
         mMemoryValues = new Vector.<int>(mSamplingCount);
         mMemoryMaxValues = new Vector.<int>(mSamplingCount);
         mMemoryGC = new Vector.<int>(mSamplingCount);
         var _loc1_:int = 0;
         while(_loc1_ < mSamplingCount)
         {
            mMemoryValues[_loc1_] = -1;
            mMemoryMaxValues[_loc1_] = -1;
            mMemoryGC[_loc1_] = -1;
            _loc1_++;
         }
         return true;
      }
      
      private function Init() : void
      {
         Analytics.Track("Tab","FlashStats","FlashStats Enter");
         this.statsLastFrame = new FrameStatistics();
         this.mGridLine = new Rectangle();
         var _loc1_:int = 15;
         var _loc2_:int = 0;
         while(_loc2_ < mSamplingCount)
         {
            if(!this.mProfilerWasActive)
            {
               mMemoryMaxValues[_loc2_] = -1;
               mMemoryValues[_loc2_] = -1;
            }
            if(mMemoryMaxValues[_loc2_] > stats.MemoryMax)
            {
               stats.MemoryMax = mMemoryMaxValues[_loc2_];
            }
            _loc2_++;
         }
         this.mBitmapBackgroundData = new BitmapData(Stage2D.stageWidth,Stage2D.stageHeight,true,0);
         this.mMemoryUseBitmapData = new BitmapData(Stage2D.stageWidth,128,false,SkinManager.COLOR_STATS_BG);
         this.mGraphPos = new Point(0,Number(Stage2D.stageHeight) - 128);
         this.mDrawGraphics = new Sprite();
         this.mDrawGraphicsMatrix = new Matrix(1,0,0,1,Number(Stage2D.stageWidth) - 5);
         this.mDrawGraphics.graphics.lineStyle(3,4294901760);
         this.mGridLine.width = Stage2D.stageWidth;
         this.mGridLine.height = 1;
         this.bitmapData = this.mBitmapBackgroundData;
         var _loc3_:int = int(Stage2D.stageWidth);
         var _loc4_:TextFormat = new TextFormat("_sans",11,SkinManager.COLOR_GLOBAL_TEXT,false);
         var _loc5_:TextFormat = new TextFormat("_sans",11,SkinManager.COLOR_GLOBAL_TEXT,false,null,null,null,null,TextFormatAlign.RIGHT);
         var _loc6_:GlowFilter = new GlowFilter(SkinManager.COLOR_GLOBAL_TEXT_GLOW,1,2,2,3,2,false,false);
         this.mBlittingTextField = new TextField();
         this.mBlittingTextField.autoSize = TextFieldAutoSize.LEFT;
         this.mBlittingTextField.defaultTextFormat = _loc4_;
         this.mBlittingTextField.selectable = false;
         this.mBlittingTextField.filters = [_loc6_];
         this.mBlittingTextFieldARight = new TextField();
         this.mBlittingTextFieldARight.autoSize = TextFieldAutoSize.RIGHT;
         this.mBlittingTextFieldARight.defaultTextFormat = _loc5_;
         this.mBlittingTextFieldARight.selectable = false;
         this.mBlittingTextFieldARight.filters = [_loc6_];
         this.mTextFieldMaxMemGraphARight = new TextField();
         this.mTextFieldMaxMemGraphARight.autoSize = TextFieldAutoSize.LEFT;
         this.mTextFieldMaxMemGraphARight.defaultTextFormat = _loc4_;
         this.mTextFieldMaxMemGraphARight.selectable = false;
         this.mTextFieldMaxMemGraphARight.filters = [_loc6_];
         this.mBlittingTextFieldMatrix = new Matrix();
         this.fps = Stage2D.frameRate;
         stats.MemoryFree = System.freeMemory / 1024;
         stats.MemoryPrivate = System.privateMemory / 1024;
         stats.MemoryCurrent = System.totalMemory / 1024;
         this.statsLastFrame.Copy(stats);
         this.mCurrentMaxMemGraph = stats.MemoryCurrent;
      }
      
      public function Update() : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         this.timer = getTimer();
         var _loc1_:int = this.timer - this.mLastTime;
         ++this.fps;
         if(_loc1_ < 1000 / Number(Commands.RefreshRate))
         {
            return;
         }
         stats.FpsCurrent = this.fps * (1000 / _loc1_);
         this.mLastTime = this.timer;
         this.mBitmapBackgroundData.fillRect(this.mBitmapBackgroundData.rect,SkinManager.COLOR_GLOBAL_BG);
         stats.MemoryFree = System.freeMemory / 1024;
         stats.MemoryPrivate = System.privateMemory / 1024;
         stats.MemoryCurrent = System.totalMemory / 1024;
         this.mTextFieldMaxMemGraphARight.text = stats.MemoryMax.toString();
         if(stats.MemoryCurrent < stats.MemoryMin)
         {
            stats.MemoryMin = stats.MemoryCurrent;
         }
         if(stats.MemoryCurrent > stats.MemoryMax)
         {
            stats.MemoryMax = stats.MemoryCurrent;
         }
         if(stats.FpsCurrent < stats.FpsMin)
         {
            stats.FpsMin = stats.FpsCurrent;
         }
         if(stats.FpsCurrent > stats.FpsMax)
         {
            stats.FpsMax = stats.FpsCurrent;
         }
         this.mBlittingTextFieldMatrix.identity();
         this.mBlittingTextFieldMatrix.ty = 20;
         if(Configuration.PROFILE_MEMGRAPH)
         {
            this.mDrawGraphics.graphics.clear();
            _loc2_ = stage.stageWidth / mSamplingCount;
            _loc3_ = 0;
            _loc4_ = 0;
            _loc5_ = 0;
            this.mDrawGraphics.graphics.lineStyle(5,4294901760);
            _loc6_ = mSamplingStartIdx;
            _loc7_ = mSamplingCount * _loc2_;
            this.mDrawGraphics.graphics.moveTo(_loc7_,0);
            _loc3_ = 0;
            while(_loc3_ < mSamplingCount)
            {
               _loc4_ = mMemoryMaxValues[_loc6_ % mSamplingCount];
               _loc6_++;
               if(_loc4_ != -1)
               {
                  _loc5_ = 127 - _loc4_ / stats.MemoryMax * 148;
                  if(_loc5_ < 0)
                  {
                     _loc5_ = 0;
                  }
                  if(_loc5_ > 127)
                  {
                     _loc5_ = 127;
                  }
                  this.mDrawGraphics.graphics.lineTo(_loc7_,_loc5_);
                  _loc7_ -= _loc2_;
               }
               _loc3_++;
            }
            this.mDrawGraphics.graphics.lineStyle(1,4294967295);
            _loc6_ = mSamplingStartIdx;
            _loc7_ = mSamplingCount * _loc2_;
            _loc3_ = 0;
            while(_loc3_ < mSamplingCount)
            {
               _loc4_ = mMemoryGC[_loc6_ % mSamplingCount];
               _loc6_++;
               _loc7_ -= _loc2_;
               if(_loc4_ != -1)
               {
                  _loc5_ = _loc4_ / stats.MemoryMax * 128;
                  this.mDrawGraphics.graphics.moveTo(_loc7_,64 - (_loc5_ / 2 + 1));
                  this.mDrawGraphics.graphics.lineTo(_loc7_,64 + (_loc5_ / 2 + 1));
               }
               _loc3_++;
            }
            this.mDrawGraphics.graphics.lineStyle(3,SkinManager.COLOR_STATS_CURRENT);
            _loc6_ = mSamplingStartIdx;
            _loc7_ = mSamplingCount * _loc2_;
            this.mDrawGraphics.graphics.moveTo(_loc7_,128);
            _loc3_ = 0;
            while(_loc3_ < mSamplingCount)
            {
               _loc4_ = mMemoryValues[_loc6_ % mSamplingCount];
               _loc6_++;
               if(_loc4_ != -1)
               {
                  _loc5_ = 128 - _loc4_ / stats.MemoryMax * 126;
                  this.mDrawGraphics.graphics.lineTo(_loc7_,_loc5_);
                  _loc7_ -= _loc2_;
               }
               _loc3_++;
            }
            this.mMemoryUseBitmapData.fillRect(this.mMemoryUseBitmapData.rect,SkinManager.COLOR_STATS_BG);
            this.mMemoryUseBitmapData.draw(this.mDrawGraphics);
         }
         this.mBlittingTextFieldMatrix.tx = this.mCurrentColumnStartPos;
         this.mBlittingTextFieldARight.text = Localization.Lbl_FS_Current;
         this.bitmapData.draw(this.mBlittingTextFieldARight,this.mBlittingTextFieldMatrix);
         this.mBlittingTextFieldMatrix.tx = this.mMinColumnStartPos;
         this.mBlittingTextFieldARight.text = Localization.Lbl_FS_Min;
         this.bitmapData.draw(this.mBlittingTextFieldARight,this.mBlittingTextFieldMatrix);
         this.mBlittingTextFieldMatrix.tx = this.mMaxColumnStartPos;
         this.mBlittingTextFieldARight.text = Localization.Lbl_FS_Max;
         this.bitmapData.draw(this.mBlittingTextFieldARight,this.mBlittingTextFieldMatrix);
         this.mBlittingTextFieldMatrix.ty += 14;
         this.mGridLine.y = this.mBlittingTextFieldMatrix.ty + 2;
         this.bitmapData.fillRect(this.mGridLine,SkinManager.COLOR_GLOBAL_LINE);
         this.mBlittingTextFieldMatrix.tx = this.mTypeColumnStartPos;
         this.mBlittingTextField.text = Localization.Lbl_FS_fps;
         this.bitmapData.draw(this.mBlittingTextField,this.mBlittingTextFieldMatrix);
         this.mBlittingTextFieldMatrix.tx = this.mCurrentColumnStartPos;
         this.mBlittingTextFieldARight.text = stats.FpsCurrent.toString() + " / " + Stage2D.frameRate;
         this.bitmapData.draw(this.mBlittingTextFieldARight,this.mBlittingTextFieldMatrix);
         this.mBlittingTextFieldMatrix.tx = this.mMinColumnStartPos;
         this.mBlittingTextFieldARight.text = stats.FpsMin.toString();
         this.bitmapData.draw(this.mBlittingTextFieldARight,this.mBlittingTextFieldMatrix);
         this.mBlittingTextFieldMatrix.tx = this.mMaxColumnStartPos;
         this.mBlittingTextFieldARight.text = stats.FpsMax.toString();
         this.bitmapData.draw(this.mBlittingTextFieldARight,this.mBlittingTextFieldMatrix);
         this.mBlittingTextFieldMatrix.ty += 14;
         this.mGridLine.y = this.mBlittingTextFieldMatrix.ty + 2;
         this.bitmapData.fillRect(this.mGridLine,SkinManager.COLOR_GLOBAL_LINE);
         this.mBlittingTextFieldMatrix.tx = this.mTypeColumnStartPos;
         this.mBlittingTextField.text = Localization.Lbl_FS_TotalMemoryKo;
         this.bitmapData.draw(this.mBlittingTextField,this.mBlittingTextFieldMatrix);
         this.mBlittingTextFieldMatrix.tx = this.mCurrentColumnStartPos;
         this.mBlittingTextFieldARight.text = stats.MemoryCurrent.toString();
         this.bitmapData.draw(this.mBlittingTextFieldARight,this.mBlittingTextFieldMatrix);
         this.mBlittingTextFieldMatrix.tx = this.mMinColumnStartPos;
         this.mBlittingTextFieldARight.text = stats.MemoryMin.toString();
         this.bitmapData.draw(this.mBlittingTextFieldARight,this.mBlittingTextFieldMatrix);
         this.mBlittingTextFieldMatrix.tx = this.mMaxColumnStartPos;
         this.mBlittingTextFieldARight.text = stats.MemoryMax.toString();
         this.bitmapData.draw(this.mBlittingTextFieldARight,this.mBlittingTextFieldMatrix);
         this.mBlittingTextFieldMatrix.ty += 14;
         this.mGridLine.y = this.mBlittingTextFieldMatrix.ty + 2;
         this.bitmapData.fillRect(this.mGridLine,SkinManager.COLOR_GLOBAL_LINE);
         this.mBlittingTextFieldMatrix.tx = this.mTypeColumnStartPos;
         this.mBlittingTextField.text = Localization.Lbl_FS_FreeMemoryKo;
         this.bitmapData.draw(this.mBlittingTextField,this.mBlittingTextFieldMatrix);
         this.mBlittingTextFieldMatrix.tx = this.mCurrentColumnStartPos;
         this.mBlittingTextFieldARight.text = stats.MemoryFree.toString();
         this.bitmapData.draw(this.mBlittingTextFieldARight,this.mBlittingTextFieldMatrix);
         this.mBlittingTextFieldMatrix.ty += 14;
         this.mGridLine.y = this.mBlittingTextFieldMatrix.ty + 2;
         this.bitmapData.fillRect(this.mGridLine,SkinManager.COLOR_GLOBAL_LINE);
         this.mBlittingTextFieldMatrix.tx = this.mTypeColumnStartPos;
         this.mBlittingTextField.text = Localization.Lbl_FS_PrivateMemoryKo;
         this.bitmapData.draw(this.mBlittingTextField,this.mBlittingTextFieldMatrix);
         this.mBlittingTextFieldMatrix.tx = this.mCurrentColumnStartPos;
         this.mBlittingTextFieldARight.text = stats.MemoryPrivate.toString();
         this.bitmapData.draw(this.mBlittingTextFieldARight,this.mBlittingTextFieldMatrix);
         this.mBlittingTextFieldMatrix.ty += 14;
         this.mGridLine.y = this.mBlittingTextFieldMatrix.ty + 2;
         this.bitmapData.fillRect(this.mGridLine,SkinManager.COLOR_GLOBAL_LINE);
         this.mBlittingTextFieldMatrix.tx = this.mTypeColumnStartPos;
         this.mBlittingTextField.text = Localization.Lbl_FS_FlashVersion;
         this.bitmapData.draw(this.mBlittingTextField,this.mBlittingTextFieldMatrix);
         this.mBlittingTextFieldMatrix.tx = this.mCurrentColumnStartPos;
         this.mBlittingTextFieldARight.text = Capabilities.version;
         this.bitmapData.draw(this.mBlittingTextFieldARight,this.mBlittingTextFieldMatrix);
         this.mBlittingTextFieldMatrix.tx = this.mMinColumnStartPos;
         this.mBlittingTextFieldARight.text = Capabilities.isDebugger ? Localization.Lbl_FS_Debug : Localization.Lbl_FS_Release;
         this.bitmapData.draw(this.mBlittingTextFieldARight,this.mBlittingTextFieldMatrix);
         this.mBlittingTextFieldMatrix.ty += 14;
         this.mGridLine.y = this.mBlittingTextFieldMatrix.ty + 2;
         this.bitmapData.fillRect(this.mGridLine,SkinManager.COLOR_GLOBAL_LINE);
         this.mBlittingTextFieldMatrix.tx = this.mTypeColumnStartPos;
         this.mBlittingTextField.text = Localization.Lbl_FS_AVMVersion;
         this.bitmapData.draw(this.mBlittingTextField,this.mBlittingTextFieldMatrix);
         this.mBlittingTextFieldMatrix.tx = this.mCurrentColumnStartPos;
         this.mBlittingTextFieldARight.text = System.vmVersion;
         this.bitmapData.draw(this.mBlittingTextFieldARight,this.mBlittingTextFieldMatrix);
         this.mBlittingTextFieldMatrix.ty += 14;
         this.mGridLine.y = this.mBlittingTextFieldMatrix.ty + 2;
         this.bitmapData.fillRect(this.mGridLine,SkinManager.COLOR_GLOBAL_LINE);
         this.mBlittingTextFieldMatrix.tx = this.mTypeColumnStartPos;
         this.mBlittingTextField.text = Localization.Lbl_FS_TheMinerVersion;
         this.bitmapData.draw(this.mBlittingTextField,this.mBlittingTextFieldMatrix);
         this.mBlittingTextFieldMatrix.tx = this.mCurrentColumnStartPos;
         this.mBlittingTextFieldARight.text = "1.4.01";
         this.bitmapData.draw(this.mBlittingTextFieldARight,this.mBlittingTextFieldMatrix);
         this.mBlittingTextFieldMatrix.tx = this.mMinColumnStartPos;
         this.mBlittingTextFieldARight.text = "Pro";
         this.bitmapData.draw(this.mBlittingTextFieldARight,this.mBlittingTextFieldMatrix);
         this.mBlittingTextFieldMatrix.ty += 14;
         this.mGridLine.y = this.mBlittingTextFieldMatrix.ty + 2;
         this.bitmapData.fillRect(this.mGridLine,SkinManager.COLOR_GLOBAL_LINE);
         this.mBlittingTextFieldMatrix.tx = this.mTypeColumnStartPos;
         this.mBlittingTextField.text = Localization.Lbl_FS_StageSize;
         this.bitmapData.draw(this.mBlittingTextField,this.mBlittingTextFieldMatrix);
         this.mBlittingTextFieldMatrix.tx = this.mCurrentColumnStartPos;
         this.mBlittingTextFieldARight.text = this.stage.stageWidth + " x " + this.stage.stageHeight;
         this.bitmapData.draw(this.mBlittingTextFieldARight,this.mBlittingTextFieldMatrix);
         this.mBlittingTextFieldMatrix.ty += 14;
         this.mGridLine.y = this.mBlittingTextFieldMatrix.ty + 2;
         this.bitmapData.fillRect(this.mGridLine,SkinManager.COLOR_GLOBAL_LINE);
         this.Render();
         this.statsLastFrame.Copy(stats);
         this.fps = 0;
      }
      
      private function Render() : void
      {
         this.bitmapData.copyPixels(this.mMemoryUseBitmapData,this.mMemoryUseBitmapData.rect,this.mGraphPos);
         this.mBitmapBackgroundData.copyPixels(SkinManager.mSkinBitmapData,SkinManager.mDebugGraphScrollRect,this.mGraphPos);
         this.mBlittingTextFieldMatrix.tx = Number(Stage2D.stageWidth) - this.mTextFieldMaxMemGraphARight.textWidth - 5;
         this.mBlittingTextFieldMatrix.ty = Number(Stage2D.stageHeight) - this.mMemoryUseBitmapData.rect.height - 15;
         this.bitmapData.draw(this.mTextFieldMaxMemGraphARight,this.mBlittingTextFieldMatrix);
         this.alpha = Number(Commands.Opacity) / 10;
      }
      
      public function Dispose() : void
      {
         Configuration.PROFILE_MEMGRAPH = this.mProfilerWasActive;
         Analytics.Track("Tab","FlashStats","FlashStats Exit",int((getTimer() - this.mEnterTime) / 1000));
         this.mMemoryUseBitmapData.dispose();
         this.mMemoryUseBitmapData = null;
         this.mBitmapBackgroundData.dispose();
         this.mBitmapBackgroundData = null;
         this.mBitmapBackground = null;
         this.mGridLine = null;
         this.mBlittingTextField = null;
         this.mBlittingTextFieldARight = null;
         this.mBlittingTextFieldMatrix = null;
         this.mTextFieldMaxMemGraphARight = null;
         this.statsLastFrame = null;
         this.mDrawGraphics = null;
         this.mDrawGraphicsMatrix = null;
         this.mGraphPos = null;
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

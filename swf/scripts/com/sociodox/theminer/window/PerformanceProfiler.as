package com.sociodox.theminer.window
{
   import com.sociodox.theminer.data.InternalEventEntry;
   import com.sociodox.theminer.manager.Analytics;
   import com.sociodox.theminer.manager.Commands;
   import com.sociodox.theminer.manager.Localization;
   import com.sociodox.theminer.manager.SampleAnalyzer;
   import com.sociodox.theminer.manager.SkinManager;
   import com.sociodox.theminer.manager.Stage2D;
   import com.sociodox.theminer.ui.ToolTip;
   import com.sociodox.theminer.ui.button.MenuButton;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.sampler.pauseSampling;
   import flash.sampler.startSampling;
   import flash.system.System;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFieldType;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import flash.ui.Keyboard;
   import flash.utils.getTimer;
   
   public class PerformanceProfiler extends Sprite implements IWindow
   {
      
      public static const SAVE_SNAPSHOT_EVENT:String = "saveSnapshotEvent";
      
      public static const SAVE_FUNCTION_STACK_EVENT:String = "saveFunctionStackEvent";
      
      private static const ENTRY_TIME_PROPERTY:String = "entryTime";
      
      private static const ENTRY_TIME_TOTAL_PROPERTY:String = "entryTimeTotal";
      
      private static const ZERO_PERCENT:String = "0.00";
      
      private static const COLUMN_HEADER_FUNCTION_NAME:String = "[" + Localization.Lbl_FP_FunctionName + "]";
      
      private static const COLUMN_HEADER_PERCENTAGE:String = "(%)";
      
      private static const COLUMN_HEADER_SELF:String = "[" + Localization.Lbl_FP_Self + "] (µs)";
      
      private static const COLUMN_HEADER_TOTAL:String = "[" + Localization.Lbl_FP_Total + "] (µs)";
      
      private static const CLICK_COPY:String = "// " + Localization.Lbl_FP_ClickCopyToClipboard + "\n";
       
      
      private var mBitmapBackgroundData:BitmapData = null;
      
      private var mBitmapLineData:BitmapData = null;
      
      private var mBitmapBackground:Bitmap = null;
      
      private var mBitmapLine:Bitmap = null;
      
      private var mGridLine:Rectangle = null;
      
      private var mClassPathColumnStartPos:int = 2;
      
      private var mAddedColumnStartPos:int = 250;
      
      private var mDeletedColumnStartPos:int = 280;
      
      private var mCurrentColumnStartPos:int = 370;
      
      private var mCumulColumnStartPos:int = 430;
      
      private var mBlittingTextField:TextField;
      
      private var mBlittingTextFieldARight:TextField;
      
      private var mBlittingTextFieldMatrix:Matrix = null;
      
      private var frameCount:int = 0;
      
      private var mLastTime:int = 0;
      
      private var mStackButtonArray:Array;
      
      private var mSelfSortButton:MenuButton;
      
      private var mTotalSortButton:MenuButton;
      
      private var mSaveSnapshotButton:MenuButton;
      
      private var mClearButton:MenuButton;
      
      private var mPerFrame:MenuButton;
      
      private var mPauseButton:MenuButton;
      
      private var mLastLen:int = 0;
      
      private var mUseSelfSort:Boolean = true;
      
      private var mProfilerWasActive:Boolean = false;
      
      private var mEnterTime:int = 0;
      
      private var mFilterText:TextField;
      
      private var mTempWidthTextfield:TextField;
      
      public function PerformanceProfiler()
      {
         this.mTempWidthTextfield = new TextField();
         super();
         this.mProfilerWasActive = Configuration.PROFILE_FUNCTION;
         Configuration.PROFILE_FUNCTION = true;
         this.Init();
         this.mEnterTime = getTimer();
         Analytics.Track("Tab","FunctionProfiler","FunctionProfiler Enter");
      }
      
      private function OnFilterMouseMove(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         param1.stopImmediatePropagation();
         ToolTip.SetPosition(param1.stageX + 12,param1.stageY + 6);
      }
      
      public function OnFilterMouseOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         param1.stopImmediatePropagation();
         ToolTip.Text = Localization.Lbl_FP_FunctionNameFilter;
         ToolTip.Visible = true;
      }
      
      public function OnFilterMouseOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         param1.stopImmediatePropagation();
         ToolTip.Visible = false;
      }
      
      private function Init() : void
      {
         var _loc11_:MenuButton = null;
         this.mGridLine = new Rectangle();
         var _loc1_:int = 15;
         this.mBitmapBackgroundData = new BitmapData(Stage2D.stageWidth,Stage2D.stageHeight,true,0);
         this.mBitmapBackground = new Bitmap(this.mBitmapBackgroundData);
         this.mBitmapLineData = new BitmapData(Stage2D.stageWidth,13,true,SkinManager.COLOR_SELECTION_OVERLAY);
         this.mBitmapLine = new Bitmap(this.mBitmapLineData);
         this.mBitmapLine.alpha = 0.7;
         this.mBitmapLine.y = -20;
         addChild(this.mBitmapBackground);
         addChild(this.mBitmapLine);
         this.mouseEnabled = false;
         this.mGridLine.width = Stage2D.stageWidth;
         this.mGridLine.height = 1;
         this.mCumulColumnStartPos = Stage2D.stageWidth - 110;
         this.mCurrentColumnStartPos = this.mCumulColumnStartPos - 40;
         this.mDeletedColumnStartPos = this.mCurrentColumnStartPos - 100;
         this.mAddedColumnStartPos = this.mDeletedColumnStartPos - 40;
         var _loc2_:int = int(Stage2D.stageWidth);
         var _loc3_:TextFormat = new TextFormat("_sans",11,SkinManager.COLOR_GLOBAL_TEXT,false);
         var _loc4_:TextFormat = new TextFormat("_sans",11,SkinManager.COLOR_GLOBAL_TEXT,true);
         var _loc5_:TextFormat = new TextFormat("_sans",11,SkinManager.COLOR_GLOBAL_TEXT,false,null,null,null,null,TextFormatAlign.RIGHT);
         var _loc6_:GlowFilter = new GlowFilter(SkinManager.COLOR_GLOBAL_TEXT_GLOW,1,2,2,3,2,false,false);
         this.mBlittingTextField = new TextField();
         this.mBlittingTextField.autoSize = TextFieldAutoSize.LEFT;
         this.mBlittingTextField.defaultTextFormat = _loc3_;
         this.mBlittingTextField.selectable = false;
         this.mBlittingTextField.filters = [_loc6_];
         this.mBlittingTextField.mouseEnabled = false;
         this.mBlittingTextFieldARight = new TextField();
         this.mBlittingTextFieldARight.autoSize = TextFieldAutoSize.RIGHT;
         this.mBlittingTextFieldARight.defaultTextFormat = _loc5_;
         this.mBlittingTextFieldARight.selectable = false;
         this.mBlittingTextFieldARight.filters = [_loc6_];
         this.mBlittingTextFieldARight.mouseEnabled = false;
         this.mBlittingTextFieldMatrix = new Matrix();
         var _loc7_:int = (Stage2D.stageHeight - 25) / 15;
         this.mStackButtonArray = new Array();
         var _loc8_:int = 0;
         while(_loc8_ < _loc7_)
         {
            _loc11_ = new MenuButton(3,37 + _loc8_ * 14,MenuButton.ICON_STACK,SAVE_FUNCTION_STACK_EVENT,-1,"",true,Localization.Lbl_MFP_Saved);
            this.mStackButtonArray.push(_loc11_);
            addChild(_loc11_);
            _loc11_.visible = false;
            _loc8_++;
         }
         addEventListener(SAVE_FUNCTION_STACK_EVENT,this.OnSaveStack);
         var _loc9_:int = 23;
         var _loc10_:int = 16;
         this.mPauseButton = new MenuButton(this.mDeletedColumnStartPos - 14 - _loc10_,_loc9_,MenuButton.ICON_PAUSE,null,-1,Localization.Lbl_MFP_PauseRefresh,true,Localization.Lbl_MFP_ResumeRefresh);
         addChild(this.mPauseButton);
         _loc10_ += 16;
         this.mClearButton = new MenuButton(this.mDeletedColumnStartPos - 14 - _loc10_,_loc9_,MenuButton.ICON_CLEAR,null,-1,Localization.Lbl_MFP_ClearCurrentData,true,Localization.Lbl_MFP_DataCleared);
         addChild(this.mClearButton);
         _loc10_ += 16;
         this.mSaveSnapshotButton = new MenuButton(this.mDeletedColumnStartPos - 14 - _loc10_,_loc9_,MenuButton.ICON_CAMERA,SAVE_SNAPSHOT_EVENT,-1,Localization.Lbl_MFP_SaveALLCurrentProfilerData,true,Localization.Lbl_MFP_Saved);
         addChild(this.mSaveSnapshotButton);
         _loc10_ += 16;
         addEventListener(SAVE_SNAPSHOT_EVENT,this.OnSaveSnapshot);
         this.mPerFrame = new MenuButton(this.mDeletedColumnStartPos - 14 - _loc10_,_loc9_,MenuButton.ICON_PERFORMANCE,null,-1,Localization.Lbl_MFP_AvgPerFrame,true,Localization.Lbl_FP_Self);
         addChild(this.mPerFrame);
         _loc10_ += 16;
         this.mSelfSortButton = new MenuButton(this.mDeletedColumnStartPos - 14,_loc9_,MenuButton.ICON_ARROW_DOWN,null,-1,Localization.Lbl_FP_SortSelfTime,true,"");
         addChild(this.mSelfSortButton);
         this.mTotalSortButton = new MenuButton(this.mCumulColumnStartPos - 14,_loc9_,MenuButton.ICON_ARROW_DOWN,null,-1,Localization.Lbl_FP_SortTotalTime,true,"");
         addChild(this.mTotalSortButton);
         this.mBlittingTextField.text = Localization.Lbl_FP_FunctionName;
         this.mBlittingTextFieldMatrix.ty = 20;
         this.mBlittingTextFieldMatrix.tx = this.mClassPathColumnStartPos;
         this.mFilterText = new TextField();
         this.mFilterText.addEventListener(MouseEvent.MOUSE_MOVE,this.OnFilterMouseMove,false,0,true);
         this.mFilterText.addEventListener(MouseEvent.MOUSE_OVER,this.OnFilterMouseOver,false,0,true);
         this.mFilterText.addEventListener(MouseEvent.MOUSE_OUT,this.OnFilterMouseOut,false,0,true);
         this.mFilterText.selectable = true;
         this.mFilterText.backgroundColor = 4282664004;
         this.mFilterText.background = true;
         this.mFilterText.x = this.mBlittingTextFieldMatrix.tx + this.mBlittingTextField.textWidth + 10;
         this.mFilterText.y = this.mBlittingTextFieldMatrix.ty - 2;
         this.mFilterText.text = "";
         if(Configuration.SAVE_FILTERS)
         {
            if(Configuration.SAVED_FILTER_PERFORMANCE)
            {
               this.mFilterText.text = Configuration.SAVED_FILTER_PERFORMANCE;
            }
         }
         this.mFilterText.height = 17;
         this.mFilterText.type = TextFieldType.INPUT;
         this.mFilterText.textColor = SkinManager.COLOR_GLOBAL_TEXT;
         this.mFilterText.addEventListener(KeyboardEvent.KEY_DOWN,this.OnFilterExit,false,0,true);
         this.mFilterText.addEventListener(Event.CHANGE,this.OnFilterComplete,false,0,true);
         this.mFilterText.defaultTextFormat = _loc4_;
         this.mFilterText.filters = [_loc6_];
         this.mFilterText.border = true;
         this.mFilterText.borderColor = SkinManager.COLOR_GLOBAL_LINE_DARK;
         addChild(this.mFilterText);
         this.mSelfSortButton.OnClick(null);
         this.mUseSelfSort = true;
      }
      
      private function OnFilterExit(param1:KeyboardEvent) : void
      {
         param1.stopPropagation();
         param1.stopImmediatePropagation();
         if(param1.keyCode == Keyboard.ENTER)
         {
            stage.focus = stage;
         }
      }
      
      private function OnFilterComplete(param1:Event) : void
      {
         param1.stopPropagation();
         param1.stopImmediatePropagation();
         if(Configuration.SAVE_FILTERS)
         {
            Configuration.SAVED_FILTER_PERFORMANCE = this.mFilterText.text;
            Configuration.Save();
         }
      }
      
      private function OnSaveSnapshot(param1:Event) : void
      {
         pauseSampling();
         if(this.mSaveSnapshotButton.mIsSelected)
         {
            Commands.SavePerformanceSnapshot(true);
            this.mSaveSnapshotButton.Reset();
         }
         startSampling();
      }
      
      private function OnSaveStack(param1:Event) : void
      {
         var _loc4_:MenuButton = null;
         var _loc5_:String = null;
         var _loc2_:int = int(this.mStackButtonArray.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc4_ = this.mStackButtonArray[_loc3_];
            if(_loc4_ != null && _loc4_.mIsSelected)
            {
               _loc5_ = String(_loc4_.mInternalEvent.mStackFrame);
               while(_loc5_.indexOf(",") != -1)
               {
                  _loc5_ = _loc5_.replace(",","\n");
               }
               System.setClipboard(_loc5_);
            }
            if(_loc4_ != null)
            {
               _loc4_.Reset();
            }
            _loc3_++;
         }
      }
      
      private function OnCopyStack(param1:Event) : void
      {
         System.setClipboard(param1.target.mInternalEvent.mStackFrame);
      }
      
      public function Update() : void
      {
         var _loc10_:MenuButton = null;
         var _loc11_:Number = NaN;
         var _loc12_:String = null;
         if(this.mClearButton.mIsSelected)
         {
            SampleAnalyzer.ResetPerformanceStats();
            this.mClearButton.Reset();
         }
         if(this.mUseSelfSort && this.mTotalSortButton.mIsSelected)
         {
            this.mUseSelfSort = false;
            this.mSelfSortButton.Reset();
         }
         else if(!this.mUseSelfSort && this.mSelfSortButton.mIsSelected)
         {
            this.mUseSelfSort = true;
            this.mTotalSortButton.Reset();
         }
         if(mouseY >= 38 && mouseY < 38 + this.mLastLen * 14)
         {
            this.mBitmapLine.y = mouseY - (mouseY + 5) % 14;
         }
         else
         {
            this.mBitmapLine.y = -20;
         }
         var _loc1_:int = getTimer() - this.mLastTime;
         if(_loc1_ < 1000 / Commands.RefreshRate || this.mPauseButton.mIsSelected)
         {
            return;
         }
         this.mLastTime = getTimer();
         this.mBitmapBackgroundData.fillRect(this.mBitmapBackgroundData.rect,SkinManager.COLOR_GLOBAL_BG);
         var _loc2_:Array = SampleAnalyzer.GetFunctionTimes();
         if(this.mUseSelfSort)
         {
            _loc2_.sortOn(ENTRY_TIME_PROPERTY,Array.NUMERIC | Array.DESCENDING);
         }
         else
         {
            _loc2_.sortOn(ENTRY_TIME_TOTAL_PROPERTY,Array.NUMERIC | Array.DESCENDING);
         }
         var _loc3_:int = int(this.mStackButtonArray.length);
         var _loc4_:int = int(_loc2_.length);
         var _loc5_:int = 0;
         var _loc6_:InternalEventEntry = null;
         _loc3_ = int(_loc2_.length);
         var _loc7_:int = 0;
         this.mLastLen = _loc3_;
         _loc5_ = 0;
         while(_loc5_ < _loc3_)
         {
            _loc6_ = _loc2_[_loc5_];
            if(!_loc6_.needSkip)
            {
               _loc7_ += _loc6_.entryTime;
            }
            _loc5_++;
         }
         var _loc8_:int = (stage.stageHeight - 25) / 15;
         if(_loc3_ > _loc8_)
         {
            _loc3_ = _loc8_;
         }
         this.mBlittingTextFieldMatrix.identity();
         this.mBlittingTextFieldMatrix.ty = 20;
         this.mBlittingTextFieldMatrix.tx = this.mClassPathColumnStartPos;
         this.mBlittingTextField.text = COLUMN_HEADER_FUNCTION_NAME;
         this.mBitmapBackgroundData.draw(this.mBlittingTextField,this.mBlittingTextFieldMatrix);
         this.mBlittingTextFieldMatrix.tx = this.mDeletedColumnStartPos;
         this.mBlittingTextFieldARight.text = COLUMN_HEADER_PERCENTAGE;
         this.mBitmapBackgroundData.draw(this.mBlittingTextFieldARight,this.mBlittingTextFieldMatrix);
         this.mBlittingTextFieldMatrix.tx = this.mAddedColumnStartPos;
         this.mBlittingTextFieldARight.text = COLUMN_HEADER_SELF;
         this.mBitmapBackgroundData.draw(this.mBlittingTextFieldARight,this.mBlittingTextFieldMatrix);
         this.mTempWidthTextfield.text = COLUMN_HEADER_SELF;
         this.mSelfSortButton.x = this.mDeletedColumnStartPos - 18;
         this.mPauseButton.x = this.mSelfSortButton.x - 15;
         this.mClearButton.x = this.mPauseButton.x - 15;
         this.mSaveSnapshotButton.x = this.mClearButton.x - 15;
         this.mBlittingTextFieldMatrix.tx = this.mCurrentColumnStartPos;
         this.mBlittingTextFieldARight.text = COLUMN_HEADER_TOTAL;
         this.mBitmapBackgroundData.draw(this.mBlittingTextFieldARight,this.mBlittingTextFieldMatrix);
         this.mBlittingTextFieldMatrix.tx = this.mCumulColumnStartPos;
         this.mBlittingTextFieldARight.text = COLUMN_HEADER_PERCENTAGE;
         this.mBitmapBackgroundData.draw(this.mBlittingTextFieldARight,this.mBlittingTextFieldMatrix);
         this.mTotalSortButton.x = this.mCumulColumnStartPos - 18;
         this.mBlittingTextFieldMatrix.ty += 14;
         this.mGridLine.y = this.mBlittingTextFieldMatrix.ty + 2;
         this.mBitmapBackgroundData.fillRect(this.mGridLine,SkinManager.COLOR_GLOBAL_LINE);
         _loc5_ = 0;
         while(_loc5_ < _loc3_)
         {
            if(_loc5_ >= this.mStackButtonArray.length)
            {
               _loc10_ = new MenuButton(3,37 + _loc5_ * 14,MenuButton.ICON_STACK,SAVE_FUNCTION_STACK_EVENT,-1,"",true,Localization.Lbl_MFP_Saved);
               this.mStackButtonArray.push(_loc10_);
               addChild(_loc10_);
               _loc10_.visible = false;
            }
            else
            {
               this.mStackButtonArray[_loc5_].visible = false;
            }
            _loc5_++;
         }
         var _loc9_:int = -1;
         _loc5_ = 0;
         for(; _loc5_ < _loc3_; _loc5_++)
         {
            _loc9_++;
            if(_loc9_ >= _loc4_)
            {
               break;
            }
            _loc6_ = _loc2_[_loc9_];
            if(_loc6_.needSkip)
            {
               _loc5_--;
            }
            else
            {
               if(this.mFilterText.text != "")
               {
                  this.mFilterText.backgroundColor = 4278207488;
                  _loc12_ = this.mFilterText.text.toLowerCase();
                  if(_loc6_.qName.toLowerCase().indexOf(_loc12_) == -1)
                  {
                     _loc5_--;
                     continue;
                  }
               }
               else
               {
                  this.mFilterText.backgroundColor = 4282664004;
               }
               this.mStackButtonArray[_loc5_].visible = true;
               if(this.mStackButtonArray[_loc5_].mInternalEvent != _loc6_)
               {
                  this.mStackButtonArray[_loc5_].SetToolTipText(CLICK_COPY + _loc6_.mStack);
                  this.mStackButtonArray[_loc5_].mInternalEvent = _loc6_;
               }
               this.mBlittingTextFieldMatrix.tx = this.mClassPathColumnStartPos + 16;
               this.mBlittingTextField.text = _loc6_.qName;
               this.mBitmapBackgroundData.draw(this.mBlittingTextField,this.mBlittingTextFieldMatrix);
               this.mBlittingTextFieldMatrix.tx = this.mDeletedColumnStartPos;
               _loc11_ = int(_loc6_.entryTime / _loc7_ * 10000) / 100;
               if(_loc11_ == 0)
               {
                  this.mBlittingTextFieldARight.text = ZERO_PERCENT;
               }
               else
               {
                  this.mBlittingTextFieldARight.text = String(_loc11_);
               }
               this.mBitmapBackgroundData.draw(this.mBlittingTextFieldARight,this.mBlittingTextFieldMatrix);
               this.mBlittingTextFieldMatrix.tx = this.mAddedColumnStartPos;
               if(!this.mPerFrame.mIsSelected)
               {
                  this.mBlittingTextFieldARight.text = _loc6_.entryTime.toString();
               }
               else
               {
                  this.mBlittingTextFieldARight.text = (int(1000 * _loc6_.entryTime / SampleAnalyzer.mFrameCounter) / 1000).toString();
               }
               this.mBitmapBackgroundData.draw(this.mBlittingTextFieldARight,this.mBlittingTextFieldMatrix);
               this.mBlittingTextFieldMatrix.tx = this.mCurrentColumnStartPos;
               this.mBlittingTextFieldARight.text = _loc6_.entryTimeTotal.toString();
               this.mBitmapBackgroundData.draw(this.mBlittingTextFieldARight,this.mBlittingTextFieldMatrix);
               this.mBlittingTextFieldMatrix.tx = this.mCumulColumnStartPos;
               _loc11_ = int(_loc6_.entryTimeTotal / _loc7_ * 10000) / 100;
               if(_loc11_ == 0)
               {
                  this.mBlittingTextFieldARight.text = ZERO_PERCENT;
               }
               else
               {
                  this.mBlittingTextFieldARight.text = String(_loc11_);
               }
               this.mBitmapBackgroundData.draw(this.mBlittingTextFieldARight,this.mBlittingTextFieldMatrix);
               this.mBlittingTextFieldMatrix.ty += 14;
               this.mGridLine.y = this.mBlittingTextFieldMatrix.ty + 2;
               this.mBitmapBackgroundData.fillRect(this.mGridLine,SkinManager.COLOR_GLOBAL_LINE);
            }
         }
         this.Render();
      }
      
      private function Render() : void
      {
         if(this.alpha != Commands.Opacity / 10)
         {
            this.alpha = Commands.Opacity / 10;
         }
      }
      
      public function Dispose() : void
      {
         var _loc1_:MenuButton = null;
         if(this.mFilterText)
         {
            this.mFilterText.removeEventListener(Event.CHANGE,this.OnFilterComplete);
            this.mFilterText.removeEventListener(KeyboardEvent.KEY_DOWN,this.OnFilterExit);
         }
         Configuration.PROFILE_FUNCTION = this.mProfilerWasActive;
         Analytics.Track("Tab","FunctionProfiler","FunctionProfiler Exit",int((getTimer() - this.mEnterTime) / 1000));
         if(!this.mProfilerWasActive)
         {
            SampleAnalyzer.ResetPerformanceStats();
         }
         for each(_loc1_ in this.mStackButtonArray)
         {
            _loc1_.Dispose();
         }
         this.mPerFrame.Dispose();
         this.mClearButton.Dispose();
         this.mSaveSnapshotButton.Dispose();
         removeChild(this.mClearButton);
         removeChild(this.mSaveSnapshotButton);
         this.mStackButtonArray = null;
         this.mGridLine = null;
         this.mBlittingTextField = null;
         this.mBlittingTextFieldARight = null;
         this.mBlittingTextFieldMatrix = null;
         this.mBitmapBackgroundData.dispose();
         this.mBitmapBackgroundData = null;
         this.mBitmapBackground = null;
         this.mBitmapLineData.dispose();
         this.mBitmapLineData = null;
         this.mBitmapLine = null;
         this.mSelfSortButton.Dispose();
         this.mSelfSortButton = null;
         this.mTotalSortButton.Dispose();
         this.mTotalSortButton = null;
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

package com.sociodox.theminer.window
{
   import com.sociodox.theminer.data.ClassTypeStatsHolder;
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
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFieldType;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import flash.ui.Keyboard;
   import flash.utils.getTimer;
   
   public class SamplerProfiler extends Sprite implements IWindow
   {
      
      public static const SAVE_SNAPSHOT_EVENT:String = "saveSnapshotEvent";
       
      
      private var mBitmapBackgroundData:BitmapData = null;
      
      private var mBitmapLineData:BitmapData = null;
      
      private var mBitmapBackground:Bitmap = null;
      
      private var mBitmapLine:Bitmap = null;
      
      private var mGridLine:Rectangle = null;
      
      private var mClassPathColumnStartPos:int = 2;
      
      private var mAddedColumnStartPos:int = 250;
      
      private var mDeletedColumnStartPos:int = 300;
      
      private var mCurrentColumnStartPos:int = 370;
      
      private var mCumulColumnStartPos:int = 430;
      
      private var mBlittingTextField:TextField;
      
      private var mBlittingTextFieldARight:TextField;
      
      private var mBlittingTextFieldMatrix:Matrix = null;
      
      private var frameCount:int = 0;
      
      private var mLastTime:int = 0;
      
      private var mProfilerWasActive:Boolean = false;
      
      private var mEnterTime:int = 0;
      
      private var mPerFrame:MenuButton;
      
      private var mSaveSnapshotButton:MenuButton;
      
      private var mClearButton:MenuButton;
      
      private var mPauseButton:MenuButton;
      
      private var mCurrentSortButton:MenuButton;
      
      private var mCumulSortButton:MenuButton;
      
      private var mUseCumulSort:Boolean = true;
      
      private var mTempWidthTextfield:TextField;
      
      private var mFilterText:TextField;
      
      private var mLastLen:int = 0;
      
      private const SORT_ON_CUMUL:String = "Cumul";
      
      private const SORT_ON_CURRENT:String = "Current";
      
      private var mLastAlloc:int = 0;
      
      private var mLastCollect:int = 0;
      
      private var mLastGain:int = 0;
      
      private var mLastLost:int = 0;
      
      private var mLastDiff:int = 0;
      
      private var mLastHolder:ClassTypeStatsHolder;
      
      private var mLastHolders:Array;
      
      public function SamplerProfiler()
      {
         this.mLastHolders = new Array();
         super();
         this.mProfilerWasActive = Configuration.PROFILE_MEMORY;
         Configuration.PROFILE_MEMORY = true;
         this.mTempWidthTextfield = new TextField();
         this.Init();
         this.mEnterTime = getTimer();
         Analytics.Track("Tab","MemoryProfiler","MemoryProfiler Enter");
      }
      
      private function Init() : void
      {
         this.mGridLine = new Rectangle();
         this.mouseEnabled = false;
         this.mBitmapBackgroundData = new BitmapData(Stage2D.stageWidth,Stage2D.stageHeight,true,0);
         this.mBitmapBackground = new Bitmap(this.mBitmapBackgroundData);
         this.mGridLine.width = Stage2D.stageWidth;
         this.mGridLine.height = 1;
         this.mBitmapLineData = new BitmapData(Stage2D.stageWidth,13,true,SkinManager.COLOR_SELECTION_OVERLAY);
         this.mBitmapLine = new Bitmap(this.mBitmapLineData);
         this.mBitmapLine.alpha = 0.7;
         this.mBitmapLine.y = -20;
         addChild(this.mBitmapBackground);
         addChild(this.mBitmapLine);
         this.mCumulColumnStartPos = Number(Stage2D.stageWidth) - 110;
         this.mCurrentColumnStartPos = this.mCumulColumnStartPos - 80;
         this.mDeletedColumnStartPos = this.mCurrentColumnStartPos - 80;
         this.mAddedColumnStartPos = this.mDeletedColumnStartPos - 80;
         var _loc1_:int = 23;
         var _loc2_:int = 16;
         this.mPauseButton = new MenuButton(this.mDeletedColumnStartPos - 14 - _loc2_,_loc1_,MenuButton.ICON_PAUSE,null,-1,Localization.Lbl_MFP_PauseRefresh,true,Localization.Lbl_MFP_ResumeRefresh);
         addChild(this.mPauseButton);
         _loc2_ += 16;
         this.mClearButton = new MenuButton(this.mDeletedColumnStartPos - 14 - _loc2_,_loc1_,MenuButton.ICON_CLEAR,null,-1,Localization.Lbl_MFP_ClearCurrentData,true,Localization.Lbl_MFP_DataCleared);
         addChild(this.mClearButton);
         _loc2_ += 16;
         this.mSaveSnapshotButton = new MenuButton(this.mDeletedColumnStartPos - 14 - _loc2_,_loc1_,MenuButton.ICON_CAMERA,SAVE_SNAPSHOT_EVENT,-1,Localization.Lbl_MFP_SaveALLCurrentProfilerData,true,Localization.Lbl_MFP_Saved);
         addChild(this.mSaveSnapshotButton);
         addEventListener(SAVE_SNAPSHOT_EVENT,this.OnSaveSnapshot,false,0,true);
         _loc2_ += 9;
         this.mPerFrame = new MenuButton(this.mDeletedColumnStartPos - 14 - _loc2_,_loc1_,MenuButton.ICON_MEMORY,null,-1,Localization.Lbl_MFP_AvgPerFrame,true,Localization.Lbl_MFP_AvgPerFrame);
         addChild(this.mPerFrame);
         _loc2_ += 16;
         var _loc3_:int = int(Stage2D.stageWidth);
         var _loc4_:TextFormat = new TextFormat("_sans",11,SkinManager.COLOR_GLOBAL_TEXT,false);
         var _loc5_:TextFormat = new TextFormat("_sans",11,SkinManager.COLOR_GLOBAL_TEXT,true);
         var _loc6_:TextFormat = new TextFormat("_sans",11,SkinManager.COLOR_GLOBAL_TEXT,false,null,null,null,null,TextFormatAlign.RIGHT);
         var _loc7_:GlowFilter = new GlowFilter(SkinManager.COLOR_GLOBAL_TEXT_GLOW,1,2,2,3,2,false,false);
         this.mTempWidthTextfield.defaultTextFormat = _loc4_;
         this.mTempWidthTextfield.filters = [_loc7_];
         this.mTempWidthTextfield.text = Localization.Lbl_MP_HEADERS_CURRENT;
         this.mCurrentSortButton = new MenuButton(this.mCumulColumnStartPos - this.mTempWidthTextfield.textWidth,_loc1_,MenuButton.ICON_ARROW_DOWN,null,-1,Localization.Lbl_MFP_Sort,true,"");
         addChild(this.mCurrentSortButton);
         this.mTempWidthTextfield.text = Localization.Lbl_MP_HEADERS_CUMUL;
         this.mCumulSortButton = new MenuButton(Number(Stage2D.stageWidth) - this.mTempWidthTextfield.textWidth - 30,_loc1_,MenuButton.ICON_ARROW_DOWN,null,-1,Localization.Lbl_MFP_Sort,true,"");
         addChild(this.mCumulSortButton);
         this.mBlittingTextField = new TextField();
         this.mBlittingTextField.autoSize = TextFieldAutoSize.LEFT;
         this.mBlittingTextField.defaultTextFormat = _loc4_;
         this.mBlittingTextField.selectable = false;
         this.mBlittingTextField.filters = [_loc7_];
         this.mBlittingTextField.mouseEnabled = false;
         this.mBlittingTextFieldARight = new TextField();
         this.mBlittingTextFieldARight.autoSize = TextFieldAutoSize.RIGHT;
         this.mBlittingTextFieldARight.defaultTextFormat = _loc6_;
         this.mBlittingTextFieldARight.selectable = false;
         this.mBlittingTextFieldARight.filters = [_loc7_];
         this.mBlittingTextFieldARight.mouseEnabled = false;
         this.mBlittingTextFieldMatrix = new Matrix();
         this.mBlittingTextField.text = Localization.Lbl_MP_HEADERS_QNAME;
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
            if(Configuration.SAVED_FILTER_MEMORY != null)
            {
               this.mFilterText.text = Configuration.SAVED_FILTER_MEMORY;
            }
         }
         this.mFilterText.height = 17;
         this.mFilterText.type = TextFieldType.INPUT;
         this.mFilterText.textColor = SkinManager.COLOR_GLOBAL_TEXT;
         this.mFilterText.defaultTextFormat = _loc5_;
         this.mFilterText.filters = [_loc7_];
         this.mFilterText.border = true;
         this.mFilterText.backgroundColor = 4282664004;
         this.mFilterText.background = true;
         this.mFilterText.borderColor = SkinManager.COLOR_GLOBAL_LINE_DARK;
         this.mFilterText.addEventListener(Event.CHANGE,this.OnFilterComplete,false,0,true);
         this.mFilterText.addEventListener(KeyboardEvent.KEY_DOWN,this.OnFilterExit,false,0,true);
         addChild(this.mFilterText);
         this.mCumulSortButton.OnClick(null);
         this.mUseCumulSort = true;
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
            Configuration.SAVED_FILTER_MEMORY = this.mFilterText.text;
            Configuration.Save();
         }
      }
      
      private function OnFilterMouseMove(param1:MouseEvent) : void
      {
         ToolTip.SetPosition(param1.stageX + 12,param1.stageY + 6);
         param1.stopPropagation();
         param1.stopImmediatePropagation();
      }
      
      public function OnFilterMouseOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         param1.stopImmediatePropagation();
         ToolTip.Text = Localization.Lbl_MP_QNameFilter;
         ToolTip.Visible = true;
      }
      
      public function OnFilterMouseOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         param1.stopImmediatePropagation();
         ToolTip.Visible = false;
      }
      
      public function Update() : void
      {
         var _loc2_:ClassTypeStatsHolder = null;
         var _loc11_:String = null;
         if(this.mClearButton != null && this.mClearButton.mIsSelected)
         {
            SampleAnalyzer.ResetMemoryStats();
            this.mClearButton.Reset();
         }
         if(this.mUseCumulSort && this.mCurrentSortButton.mIsSelected)
         {
            this.mUseCumulSort = false;
            this.mCumulSortButton.Reset();
         }
         else if(!this.mUseCumulSort && this.mCumulSortButton.mIsSelected)
         {
            this.mUseCumulSort = true;
            this.mCurrentSortButton.Reset();
         }
         var _loc1_:int = -1;
         if(mouseY >= 38 && mouseY < 38 + this.mLastLen * 14)
         {
            _loc1_ = mouseY - (mouseY + 5) % 14;
            this.mBitmapLine.y = _loc1_;
         }
         else
         {
            this.mBitmapLine.y = -20;
         }
         _loc1_ -= 25;
         _loc1_ /= 14;
         var _loc3_:int = getTimer() - this.mLastTime;
         if(_loc3_ < 1000 / Number(Commands.RefreshRate) || this.mPauseButton.mIsSelected)
         {
            return;
         }
         this.mLastHolders.length = 0;
         this.mLastTime = getTimer();
         if(_loc2_ != null)
         {
            this.mLastGain = _loc2_.AllocSize - this.mLastAlloc;
            this.mLastLost = _loc2_.CollectSize - this.mLastCollect;
            this.mLastAlloc = _loc2_.AllocSize;
            this.mLastCollect = _loc2_.CollectSize;
            this.mLastDiff = this.mLastAlloc - this.mLastCollect;
         }
         this.mBitmapBackgroundData.fillRect(this.mBitmapBackgroundData.rect,SkinManager.COLOR_GLOBAL_BG);
         var _loc4_:Array = SampleAnalyzer.GetClassInstanciationStats();
         if(this.mUseCumulSort)
         {
            _loc4_.sortOn(this.SORT_ON_CUMUL,Array.NUMERIC | Array.DESCENDING);
         }
         else
         {
            _loc4_.sortOn(this.SORT_ON_CURRENT,Array.NUMERIC | Array.DESCENDING);
         }
         var _loc5_:ClassTypeStatsHolder = null;
         var _loc6_:int = _loc4_.length;
         var _loc7_:int = _loc4_.length;
         var _loc8_:int = (stage.stageHeight - 25) / 15;
         if(_loc6_ > _loc8_)
         {
            _loc6_ = _loc8_;
         }
         this.mBlittingTextFieldMatrix.identity();
         this.mBlittingTextFieldMatrix.ty = 20;
         this.mLastLen = _loc6_;
         this.mBlittingTextFieldMatrix.tx = this.mClassPathColumnStartPos;
         this.mBlittingTextField.text = Localization.Lbl_MP_HEADERS_QNAME;
         this.mBitmapBackgroundData.draw(this.mBlittingTextField,this.mBlittingTextFieldMatrix);
         this.mBlittingTextFieldMatrix.tx = this.mAddedColumnStartPos;
         this.mBlittingTextFieldARight.text = Localization.Lbl_MP_HEADERS_ADD;
         this.mBitmapBackgroundData.draw(this.mBlittingTextFieldARight,this.mBlittingTextFieldMatrix);
         this.mPauseButton.x = this.mDeletedColumnStartPos - this.mBlittingTextFieldARight.textWidth;
         this.mClearButton.x = this.mPauseButton.x - 15;
         this.mSaveSnapshotButton.x = this.mClearButton.x - 15;
         this.mBlittingTextFieldMatrix.tx = this.mDeletedColumnStartPos;
         this.mBlittingTextFieldARight.text = Localization.Lbl_MP_HEADERS_DEL;
         this.mBitmapBackgroundData.draw(this.mBlittingTextFieldARight,this.mBlittingTextFieldMatrix);
         this.mBlittingTextFieldMatrix.tx = this.mCurrentColumnStartPos;
         this.mBlittingTextFieldARight.text = Localization.Lbl_MP_HEADERS_CURRENT;
         this.mBitmapBackgroundData.draw(this.mBlittingTextFieldARight,this.mBlittingTextFieldMatrix);
         this.mBlittingTextFieldMatrix.tx = this.mCumulColumnStartPos;
         this.mBlittingTextFieldARight.text = Localization.Lbl_MP_HEADERS_CUMUL;
         this.mBitmapBackgroundData.draw(this.mBlittingTextFieldARight,this.mBlittingTextFieldMatrix);
         this.mBlittingTextFieldMatrix.ty += 14;
         this.mGridLine.y = this.mBlittingTextFieldMatrix.ty + 2;
         this.mBitmapBackgroundData.fillRect(this.mGridLine,SkinManager.COLOR_GLOBAL_LINE);
         var _loc9_:int = -1;
         var _loc10_:int = 0;
         for(; _loc10_ < _loc6_; _loc10_++)
         {
            _loc9_++;
            if(_loc9_ >= _loc7_)
            {
               break;
            }
            _loc5_ = _loc4_[_loc9_];
            if(_loc5_.Cumul == 0)
            {
               _loc10_--;
            }
            else
            {
               if(this.mFilterText.text != "")
               {
                  this.mFilterText.backgroundColor = 4278207488;
                  _loc11_ = this.mFilterText.text.toLowerCase();
                  if(_loc5_.TypeName.toLowerCase().indexOf(_loc11_) == -1)
                  {
                     _loc10_--;
                     continue;
                  }
               }
               else
               {
                  this.mFilterText.backgroundColor = 4282664004;
               }
               this.mLastHolders[_loc10_] = _loc5_;
               this.mBlittingTextFieldMatrix.tx = this.mClassPathColumnStartPos;
               this.mBlittingTextField.text = _loc5_.TypeName;
               this.mBitmapBackgroundData.draw(this.mBlittingTextField,this.mBlittingTextFieldMatrix);
               this.mBlittingTextFieldMatrix.tx = this.mAddedColumnStartPos;
               if(this.mPerFrame.mIsSelected)
               {
                  this.mBlittingTextFieldARight.text = (int(100 * _loc5_.Added / Number(SampleAnalyzer.mSamplerFrameCounter)) / 100).toString();
               }
               else
               {
                  this.mBlittingTextFieldARight.text = _loc5_.Added.toString();
               }
               this.mBitmapBackgroundData.draw(this.mBlittingTextFieldARight,this.mBlittingTextFieldMatrix);
               this.mBlittingTextFieldMatrix.tx = this.mDeletedColumnStartPos;
               if(this.mPerFrame.mIsSelected)
               {
                  this.mBlittingTextFieldARight.text = (int(100 * _loc5_.Removed / Number(SampleAnalyzer.mSamplerFrameCounter)) / 100).toString();
               }
               else
               {
                  this.mBlittingTextFieldARight.text = _loc5_.Removed.toString();
               }
               this.mBitmapBackgroundData.draw(this.mBlittingTextFieldARight,this.mBlittingTextFieldMatrix);
               this.mBlittingTextFieldMatrix.tx = this.mCurrentColumnStartPos;
               this.mBlittingTextFieldARight.text = _loc5_.Current.toString();
               this.mBitmapBackgroundData.draw(this.mBlittingTextFieldARight,this.mBlittingTextFieldMatrix);
               this.mBlittingTextFieldMatrix.tx = this.mCumulColumnStartPos;
               this.mBlittingTextFieldARight.text = _loc5_.Cumul.toString();
               this.mBitmapBackgroundData.draw(this.mBlittingTextFieldARight,this.mBlittingTextFieldMatrix);
               _loc5_.Added = 0;
               _loc5_.Removed = 0;
               _loc5_.AllocSize = 0;
               _loc5_.CollectSize = 0;
               this.mBlittingTextFieldMatrix.ty += 14;
               this.mGridLine.y = this.mBlittingTextFieldMatrix.ty + 2;
               this.mBitmapBackgroundData.fillRect(this.mGridLine,SkinManager.COLOR_GLOBAL_LINE);
            }
         }
         SampleAnalyzer.mSamplerFrameCounter = 0;
         this.Render();
      }
      
      private function OnSaveSnapshot(param1:Event) : void
      {
         pauseSampling();
         if(this.mSaveSnapshotButton.mIsSelected)
         {
            Commands.SaveMemorySnapshot(true);
            this.mSaveSnapshotButton.Reset();
         }
         startSampling();
      }
      
      private function Render() : void
      {
         this.alpha = Number(Commands.Opacity) / 10;
      }
      
      public function Dispose() : void
      {
         if(this.mFilterText)
         {
            this.mFilterText.removeEventListener(KeyboardEvent.KEY_DOWN,this.OnFilterExit);
            this.mFilterText.removeEventListener(Event.CHANGE,this.OnFilterComplete);
         }
         Configuration.PROFILE_MEMORY = this.mProfilerWasActive;
         if(!this.mProfilerWasActive)
         {
            SampleAnalyzer.ResetMemoryStats();
         }
         Analytics.Track("Tab","MemoryProfiler","MemoryProfiler Exit",int((getTimer() - this.mEnterTime) / 1000));
         this.mGridLine = null;
         this.mBlittingTextField = null;
         this.mBlittingTextFieldARight = null;
         this.mBlittingTextFieldMatrix = null;
         this.mBitmapBackgroundData.dispose();
         this.mBitmapBackgroundData = null;
         this.mBitmapBackground = null;
         this.mPerFrame.Dispose();
         this.mPerFrame = null;
         this.mCurrentSortButton.Dispose();
         this.mCurrentSortButton = null;
         this.mCumulSortButton.Dispose();
         this.mCumulSortButton = null;
         this.mBitmapLineData.dispose();
         this.mBitmapLineData = null;
         this.mBitmapLine = null;
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

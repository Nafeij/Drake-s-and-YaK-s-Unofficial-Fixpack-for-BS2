package com.sociodox.theminer.window
{
   import com.sociodox.theminer.data.UserEventEntry;
   import com.sociodox.theminer.manager.Analytics;
   import com.sociodox.theminer.manager.Commands;
   import com.sociodox.theminer.manager.Localization;
   import com.sociodox.theminer.manager.SkinManager;
   import com.sociodox.theminer.manager.Stage2D;
   import com.sociodox.theminer.manager.UserEventManager;
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
   import flash.utils.ByteArray;
   import flash.utils.getTimer;
   
   public class UserEvent extends Sprite implements IWindow
   {
      
      public static const SAVE_SNAPSHOT_EVENT:String = "saveSnapshotEvent";
      
      public static const LOADER_STREAM:String = Localization.Lbl_L_URLStream;
      
      public static const LOADER_URLLOADER:String = Localization.Lbl_L_URLLoader;
      
      public static const LOADER_DISPLAY_LOADER:String = Localization.Lbl_L_Loader;
      
      public static const LOADER_COMPLETED:String = Localization.Lbl_L_Success;
      
      public static const LOADER_NOT_COMPLETED:String = Localization.Lbl_L_Failed;
      
      private static const DEFAULT_TEXT:String = "-";
      
      public static const SAVE_FUNCTION_STACK_EVENT:String = "saveFunctionStackEvent";
      
      private static const ZERO_PERCENT:String = "0.00";
      
      private static const COLUMN_HEADER_PROGRESS:String = Localization.Lbl_UserEvents_Status;
      
      private static const COLUMN_HEADER_URL:String = Localization.Lbl_UserEvents_Info;
      
      private static const COLUMN_HEADER_STATUS:String = Localization.Lbl_UserEvents_Value1;
      
      private static const COLUMN_HEADER_SIZE:String = Localization.Lbl_UserEvents_Value2;
      
      private static const NEW_LINE:String = "\n";
       
      
      private var mBitmapBackgroundData:BitmapData = null;
      
      private var mBitmapLineData:BitmapData = null;
      
      private var mBitmapBackground:Bitmap = null;
      
      private var mBitmapLine:Bitmap = null;
      
      private var mGridLine:Rectangle = null;
      
      private var mProgressCenterPosition:int = 2;
      
      private var mAddedColumnStartPos:int = 250;
      
      private var mTextColumn:int = 280;
      
      private var mUserData2Column:int = 280;
      
      private var mCurrentColumnStartPos:int = 370;
      
      private var mUserData1Column:int = 430;
      
      private var mBlittingTextField:TextField;
      
      private var mBlittingTextFieldCenter:TextField;
      
      private var mBlittingTextFieldARight:TextField;
      
      private var mBlittingTextFieldMatrix:Matrix = null;
      
      private var mSaveSnapshotButton:MenuButton;
      
      private var mActivateFilterButton:MenuButton;
      
      private var frameCount:int = 0;
      
      private var mLastTime:int = 0;
      
      private var mStackButtonArray:Array;
      
      private var mEnterTime:int = 0;
      
      private var mFilterText:TextField;
      
      private var mEventMgr:UserEventManager = null;
      
      private var mLastLen:int = 0;
      
      private var mLastAlpha:Number = 1;
      
      private var mProgressBarRect:Rectangle;
      
      public function UserEvent()
      {
         this.mProgressBarRect = new Rectangle(20,0,100,11);
         super();
         this.Init();
         this.mEnterTime = getTimer();
         Analytics.Track("Tab","UserEvent","UserEvent Enter");
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
         this.mBitmapLine.y = -20;
         addChild(this.mBitmapBackground);
         addChild(this.mBitmapLine);
         this.mouseEnabled = false;
         this.mGridLine.width = Stage2D.stageWidth;
         this.mGridLine.height = 1;
         this.mProgressCenterPosition = 20;
         this.mUserData1Column = 70;
         this.mUserData2Column = 130;
         this.mTextColumn = 235;
         this.mAddedColumnStartPos = 100;
         var _loc2_:int = int(Stage2D.stageWidth);
         var _loc3_:TextFormat = new TextFormat("_sans",11,SkinManager.COLOR_GLOBAL_TEXT,false);
         var _loc4_:TextFormat = new TextFormat("_sans",11,SkinManager.COLOR_GLOBAL_TEXT,true);
         var _loc5_:TextFormat = new TextFormat("_sans",11,SkinManager.COLOR_GLOBAL_TEXT,false,null,null,null,null,TextFormatAlign.RIGHT);
         var _loc6_:TextFormat = new TextFormat("_sans",11,SkinManager.COLOR_GLOBAL_TEXT,false,null,null,null,null,TextFormatAlign.CENTER);
         var _loc7_:GlowFilter = new GlowFilter(SkinManager.COLOR_GLOBAL_TEXT_GLOW,1,2,2,3,2,false,false);
         this.mBlittingTextField = new TextField();
         this.mBlittingTextField.autoSize = TextFieldAutoSize.LEFT;
         this.mBlittingTextField.defaultTextFormat = _loc3_;
         this.mBlittingTextField.selectable = false;
         this.mBlittingTextField.filters = [_loc7_];
         this.mBlittingTextFieldARight = new TextField();
         this.mBlittingTextFieldARight.autoSize = TextFieldAutoSize.RIGHT;
         this.mBlittingTextFieldARight.defaultTextFormat = _loc5_;
         this.mBlittingTextFieldARight.selectable = false;
         this.mBlittingTextFieldARight.filters = [_loc7_];
         this.mBlittingTextFieldCenter = new TextField();
         this.mBlittingTextFieldCenter.autoSize = TextFieldAutoSize.CENTER;
         this.mBlittingTextFieldCenter.defaultTextFormat = _loc6_;
         this.mBlittingTextFieldCenter.selectable = false;
         this.mBlittingTextFieldCenter.filters = [_loc7_];
         this.mBlittingTextFieldMatrix = new Matrix();
         var _loc8_:int = 21;
         this.mSaveSnapshotButton = new MenuButton(16,_loc8_,MenuButton.ICON_CAMERA,SAVE_SNAPSHOT_EVENT,-1,Localization.Lbl_MFP_SaveALLCurrentProfilerData,true,Localization.Lbl_MFP_Saved);
         addChild(this.mSaveSnapshotButton);
         addEventListener(SAVE_SNAPSHOT_EVENT,this.OnSaveSnapshot);
         this.mActivateFilterButton = new MenuButton(16 + 15,_loc8_,MenuButton.ICON_FILTER,null,-1,Localization.Lbl_L_ShowLoadersWithErrors,true,Localization.Lbl_Done);
         addChild(this.mActivateFilterButton);
         var _loc9_:int = (Stage2D.stageHeight - 25) / 15;
         this.mStackButtonArray = new Array();
         var _loc10_:int = 0;
         while(_loc10_ < _loc9_)
         {
            _loc11_ = new MenuButton(3,37 + _loc10_ * 14,MenuButton.ICON_CLIPBOARD,SAVE_FUNCTION_STACK_EVENT,-1,"",true,Localization.Lbl_MFP_Saved);
            this.mStackButtonArray.push(_loc11_);
            addChild(_loc11_);
            _loc11_.visible = false;
            _loc10_++;
         }
         addEventListener(SAVE_FUNCTION_STACK_EVENT,this.OnSaveStack);
         this.mBlittingTextField.text = Localization.Lbl_LP_FileNameFilter;
         this.mBlittingTextFieldMatrix.ty = 20;
         this.mBlittingTextFieldMatrix.tx = this.mTextColumn;
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
            if(Configuration.SAVED_FILTER_USEREVENT)
            {
               this.mFilterText.text = Configuration.SAVED_FILTER_USEREVENT;
            }
         }
         this.mFilterText.height = 17;
         this.mFilterText.type = TextFieldType.INPUT;
         this.mFilterText.textColor = SkinManager.COLOR_GLOBAL_TEXT;
         this.mFilterText.defaultTextFormat = _loc4_;
         this.mFilterText.filters = [_loc7_];
         this.mFilterText.border = true;
         this.mFilterText.addEventListener(KeyboardEvent.KEY_DOWN,this.OnFilterComplete,false,0,true);
         this.mFilterText.borderColor = SkinManager.COLOR_GLOBAL_LINE;
         addChild(this.mFilterText);
      }
      
      public function SetManager(param1:UserEventManager) : void
      {
         this.mEventMgr = param1;
      }
      
      private function OnFilterComplete(param1:KeyboardEvent) : void
      {
         param1.stopPropagation();
         param1.stopImmediatePropagation();
         if(param1.keyCode == Keyboard.ENTER)
         {
            stage.focus = stage;
         }
         if(Configuration.SAVE_FILTERS)
         {
            Configuration.SAVED_FILTER_USEREVENT = this.mFilterText.text;
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
         ToolTip.Text = Localization.Lbl_LP_FileNameFilter;
         ToolTip.Visible = true;
      }
      
      public function OnFilterMouseOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         param1.stopImmediatePropagation();
         ToolTip.Visible = false;
      }
      
      private function OnSaveSnapshot(param1:Event) : void
      {
         pauseSampling();
         if(this.mSaveSnapshotButton.mIsSelected)
         {
            this.SaveLoaderSnapshot();
            this.mSaveSnapshotButton.Reset();
         }
         startSampling();
      }
      
      private function SaveLoaderSnapshot() : void
      {
         var _loc4_:UserEventEntry = null;
         var _loc5_:* = null;
         var _loc1_:Vector.<UserEventEntry> = this.mEventMgr.GetUserEvents();
         _loc1_.sort(this.EventSort);
         var _loc2_:ByteArray = new ByteArray();
         var _loc3_:int = int(_loc1_.length);
         _loc5_ = "Name";
         _loc5_ += "\tValue1";
         _loc5_ += "\tValue2";
         _loc5_ += "\tInfo";
         _loc5_ += "\tStatus";
         _loc5_ += "\tProgress";
         _loc5_ += "\tError\n";
         _loc2_.writeUTFBytes(_loc5_);
         for each(_loc4_ in _loc1_)
         {
            if(_loc4_ != null)
            {
               _loc5_ = _loc4_.Name;
               _loc5_ += "\t" + _loc4_.Value1;
               _loc5_ += "\t" + _loc4_.Value1;
               _loc5_ += "\t" + _loc4_.Info;
               _loc5_ += "\t" + _loc4_.StatusLabel;
               _loc5_ += "\t" + _loc4_.StatusProgress;
               _loc5_ += "\t" + _loc4_.IsError + "\n";
               _loc2_.writeUTFBytes(_loc5_);
            }
         }
         _loc2_.position = 0;
         System.setClipboard(_loc2_.readUTFBytes(_loc2_.length));
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
               if(_loc4_.mUserEvent != null)
               {
                  _loc4_.mUserEvent;
                  _loc5_ = "";
                  _loc5_ += "UserEvent::\tName: " + _loc4_.mUserEvent.Name;
                  _loc5_ += ",\t Value1: " + _loc4_.mUserEvent.Value1;
                  _loc5_ += ",\t Value2: " + _loc4_.mUserEvent.Value1;
                  _loc5_ += ",\t mEventInfo: " + _loc4_.mUserEvent.Info;
                  _loc5_ += ",\t StatusLabel: " + _loc4_.mUserEvent.StatusLabel;
                  _loc5_ += ",\t StatusProgress: " + (int(_loc4_.mUserEvent.StatusProgress * 10000) / 100).toString() + Localization.Lbl_LA_Percent;
                  System.setClipboard(_loc5_);
               }
            }
            if(_loc4_ != null)
            {
               _loc4_.Reset();
            }
            _loc3_++;
         }
      }
      
      public function Update() : void
      {
         var _loc9_:String = null;
         if(mouseY >= 40 && mouseY < 40 + this.mLastLen * 14)
         {
            this.mBitmapLine.y = mouseY - mouseY % 14 - 3;
         }
         else
         {
            this.mBitmapLine.y = -20;
         }
         var _loc1_:int = getTimer() - this.mLastTime;
         if(_loc1_ < 1000 / Commands.RefreshRate)
         {
            return;
         }
         this.mLastTime = getTimer();
         this.mBitmapBackgroundData.fillRect(this.mBitmapBackgroundData.rect,SkinManager.COLOR_GLOBAL_BG);
         var _loc2_:int = int(this.mStackButtonArray.length);
         var _loc3_:int = 0;
         var _loc4_:Vector.<UserEventEntry> = this.mEventMgr.GetUserEvents();
         _loc4_.sort(this.EventSort);
         var _loc5_:int = int(_loc4_.length);
         _loc2_ = int(_loc4_.length);
         var _loc6_:int = (stage.stageHeight - 25) / 15;
         this.mBlittingTextFieldMatrix.identity();
         this.mBlittingTextFieldMatrix.ty = 20;
         this.mBlittingTextFieldMatrix.tx = this.mProgressCenterPosition;
         this.mBlittingTextFieldCenter.text = COLUMN_HEADER_PROGRESS;
         this.mBitmapBackgroundData.draw(this.mBlittingTextFieldCenter,this.mBlittingTextFieldMatrix);
         this.mBlittingTextFieldMatrix.tx = this.mTextColumn;
         this.mBlittingTextField.text = COLUMN_HEADER_URL;
         this.mBitmapBackgroundData.draw(this.mBlittingTextField,this.mBlittingTextFieldMatrix);
         this.mBlittingTextFieldMatrix.tx = this.mUserData1Column;
         this.mBlittingTextFieldARight.text = COLUMN_HEADER_STATUS;
         this.mBitmapBackgroundData.draw(this.mBlittingTextFieldARight,this.mBlittingTextFieldMatrix);
         this.mBlittingTextFieldMatrix.tx = this.mUserData2Column;
         this.mBlittingTextFieldARight.text = COLUMN_HEADER_SIZE;
         this.mBitmapBackgroundData.draw(this.mBlittingTextFieldARight,this.mBlittingTextFieldMatrix);
         this.mBlittingTextFieldMatrix.ty += 14;
         this.mGridLine.y = this.mBlittingTextFieldMatrix.ty + 2;
         this.mBitmapBackgroundData.fillRect(this.mGridLine,SkinManager.COLOR_GLOBAL_LINE);
         var _loc7_:UserEventEntry = null;
         var _loc8_:int = -1;
         _loc6_ = Math.min(_loc6_,this.mStackButtonArray.length);
         _loc3_ = 0;
         while(_loc3_ < _loc6_)
         {
            this.mStackButtonArray[_loc3_].visible = false;
            _loc3_++;
         }
         _loc3_ = 0;
         for(; _loc3_ < _loc6_; _loc3_++)
         {
            _loc8_++;
            if(_loc8_ >= _loc5_)
            {
               break;
            }
            _loc7_ = _loc4_[_loc8_];
            if(_loc7_.Visible == false)
            {
               _loc3_--;
            }
            else
            {
               if(this.mFilterText.text != "")
               {
                  _loc9_ = this.mFilterText.text.toLowerCase();
                  if((_loc7_.Name == null || _loc7_.Name.toLowerCase().indexOf(_loc9_) == -1) && (_loc7_.Info == null || _loc7_.Info.toLowerCase().indexOf(_loc9_) == -1))
                  {
                     _loc3_--;
                     continue;
                  }
               }
               if(_loc7_.Id != -1)
               {
                  if(this.mActivateFilterButton.mIsSelected)
                  {
                     if(!_loc7_.IsError)
                     {
                        _loc3_--;
                        continue;
                     }
                  }
                  this.mStackButtonArray[_loc3_].visible = true;
                  this.DrawProgress(_loc4_[_loc8_],38 + _loc3_ * 14);
                  if(this.mStackButtonArray[_loc3_].mUrl != _loc7_.Name)
                  {
                     this.mStackButtonArray[_loc3_].SetToolTipText(Localization.Lbl_FP_ClickCopyToClipboard);
                     this.mStackButtonArray[_loc3_].mUrl = _loc7_.Name;
                     this.mStackButtonArray[_loc3_].mUserEvent = _loc7_;
                  }
                  else if(_loc7_.IsError)
                  {
                     this.mStackButtonArray[_loc3_].mUserEvent = _loc7_;
                     this.mStackButtonArray[_loc3_].mUrl = _loc7_.Name;
                     this.mStackButtonArray[_loc3_].SetToolTipText(Localization.Lbl_FP_ClickCopyToClipboard + NEW_LINE + _loc7_.Name);
                  }
                  this.mBlittingTextFieldMatrix.tx = this.mProgressCenterPosition;
                  if(_loc7_.IsError)
                  {
                     this.mBlittingTextFieldCenter.text = "X";
                  }
                  else if(_loc7_.StatusLabel != null)
                  {
                     this.mBlittingTextFieldCenter.text = _loc7_.StatusLabel;
                  }
                  else if(_loc7_.StatusProgress == -1)
                  {
                     this.mBlittingTextFieldCenter.text = "";
                  }
                  else
                  {
                     this.mBlittingTextFieldCenter.text = (int(_loc7_.StatusProgress * 10000) / 100).toString() + Localization.Lbl_LA_Percent;
                  }
                  this.mBitmapBackgroundData.draw(this.mBlittingTextFieldCenter,this.mBlittingTextFieldMatrix);
                  this.mBlittingTextFieldMatrix.tx = this.mUserData1Column;
                  if(_loc7_.Value1 == null)
                  {
                     this.mBlittingTextFieldARight.text = "";
                  }
                  else
                  {
                     this.mBlittingTextFieldARight.text = _loc7_.Value1;
                  }
                  this.mBitmapBackgroundData.draw(this.mBlittingTextFieldARight,this.mBlittingTextFieldMatrix);
                  this.mBlittingTextFieldMatrix.tx = this.mUserData2Column;
                  if(_loc7_.Value2 == null)
                  {
                     this.mBlittingTextFieldARight.text = "";
                  }
                  else
                  {
                     this.mBlittingTextFieldARight.text = _loc7_.Value2;
                  }
                  this.mBitmapBackgroundData.draw(this.mBlittingTextFieldARight,this.mBlittingTextFieldMatrix);
                  this.mBlittingTextFieldMatrix.tx = this.mTextColumn;
                  if(_loc7_.Name == null)
                  {
                     this.mBlittingTextField.text = UserEvent.DEFAULT_TEXT;
                  }
                  else if(_loc7_.Info)
                  {
                     this.mBlittingTextField.text = _loc7_.Name + " :: " + _loc7_.Info;
                  }
                  else
                  {
                     this.mBlittingTextField.text = _loc7_.Name;
                  }
                  this.mBitmapBackgroundData.draw(this.mBlittingTextField,this.mBlittingTextFieldMatrix);
                  this.mBlittingTextFieldMatrix.ty += 14;
                  this.mGridLine.y = this.mBlittingTextFieldMatrix.ty + 2;
                  this.mBitmapBackgroundData.fillRect(this.mGridLine,SkinManager.COLOR_GLOBAL_LINE);
               }
            }
         }
         this.Render();
      }
      
      private function EventSort(param1:UserEventEntry, param2:UserEventEntry) : int
      {
         if(param1.Priority > param2.Priority)
         {
            return -1;
         }
         if(param1.Priority < param2.Priority)
         {
            return 1;
         }
         if(param1.Id > param2.Id)
         {
            return -1;
         }
         if(param1.Id < param2.Id)
         {
            return 1;
         }
         return 0;
      }
      
      private function Render() : void
      {
         var _loc1_:Number = Commands.Opacity / 10;
         if(_loc1_ != this.mLastAlpha)
         {
            this.mLastAlpha = _loc1_;
            this.alpha = _loc1_;
         }
      }
      
      private function DrawProgress(param1:UserEventEntry, param2:int) : void
      {
         var _loc4_:Number = NaN;
         this.mProgressBarRect.y = param2;
         this.mProgressBarRect.width = 100;
         var _loc3_:uint = SkinManager.COLOR_LOADER_DISPLAYLOADER_COMPLETED;
         if(param1.IsError)
         {
            _loc3_ = SkinManager.COLOR_LOADER_FALIED;
         }
         else if(param1.StatusProgress == -1)
         {
            _loc3_ = param1.StatusColor;
            this.mProgressBarRect.width = 100;
         }
         else
         {
            _loc3_ = param1.StatusColor;
            _loc4_ = param1.StatusProgress;
            if(_loc4_ > 1)
            {
               _loc4_ = 1;
            }
            this.mProgressBarRect.width = 100 * _loc4_;
         }
         this.mBitmapBackgroundData.fillRect(this.mProgressBarRect,_loc3_);
      }
      
      public function Dispose() : void
      {
         var _loc1_:MenuButton = null;
         if(this.mFilterText)
         {
            this.mFilterText.removeEventListener(KeyboardEvent.KEY_DOWN,this.OnFilterComplete);
         }
         for each(_loc1_ in this.mStackButtonArray)
         {
            _loc1_.Dispose();
         }
         Analytics.Track("Tab","UserEvent","UserEvent Exit",int((getTimer() - this.mEnterTime) / 1000));
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
         this.mBitmapBackground = null;
         this.mBitmapLine = null;
         this.mGridLine = null;
         this.mBlittingTextFieldCenter = null;
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

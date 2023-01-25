package com.sociodox.theminer.window
{
   import com.sociodox.theminer.data.LoaderData;
   import com.sociodox.theminer.manager.Analytics;
   import com.sociodox.theminer.manager.Commands;
   import com.sociodox.theminer.manager.LoaderAnalyser;
   import com.sociodox.theminer.manager.Localization;
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
   import flash.net.FileReference;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
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
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   
   public class LoaderProfiler extends Sprite implements IWindow
   {
      
      public static const SAVE_SNAPSHOT_EVENT:String = "saveSnapshotEvent";
      
      public static const LOADER_STREAM:String = Localization.Lbl_L_URLStream;
      
      public static const LOADER_URLLOADER:String = Localization.Lbl_L_URLLoader;
      
      public static const LOADER_DISPLAY_LOADER:String = Localization.Lbl_L_Loader;
      
      public static const LOADER_COMPLETED:String = Localization.Lbl_L_Success;
      
      public static const LOADER_NOT_COMPLETED:String = Localization.Lbl_L_Failed;
      
      private static const FIRST_EVENT_PROPERTY:String = "mFirstEvent";
      
      public static const SAVE_FUNCTION_STACK_EVENT:String = "saveFunctionStackEvent";
      
      public static const SAVE_FILE_EVENT:String = "saveFileEvent";
      
      public static const GO_TO_LINK:String = "GoToLink";
      
      private static const ZERO_PERCENT:String = "0.00";
      
      private static const SORT_ON_KEY:String = "mFirstEvent";
      
      private static const COLUMN_HEADER_PROGRESS:String = Localization.Lbl_L_Progress;
      
      private static const COLUMN_HEADER_URL:String = Localization.Lbl_L_Url;
      
      private static const COLUMN_HEADER_STATUS:String = Localization.Lbl_L_Status;
      
      private static const COLUMN_HEADER_SIZE:String = Localization.Lbl_L_Size;
      
      private static const NEW_LINE:String = "\n";
       
      
      private var mBitmapBackgroundData:BitmapData = null;
      
      private var mBitmapLineData:BitmapData = null;
      
      private var mBitmapBackground:Bitmap = null;
      
      private var mBitmapLine:Bitmap = null;
      
      private var mGridLine:Rectangle = null;
      
      private var mProgressCenterPosition:int = 18;
      
      private var mAddedColumnStartPos:int = 266;
      
      private var mURLColPosition:int = 296;
      
      private var mSizeColPosition:int = 296;
      
      private var mCurrentColumnStartPos:int = 386;
      
      private var mHTTPStatusColPosition:int = 446;
      
      private var mBlittingTextField:TextField;
      
      private var mBlittingTextFieldCenter:TextField;
      
      private var mBlittingTextFieldARight:TextField;
      
      private var mBlittingTextFieldMatrix:Matrix = null;
      
      private var mSaveSnapshotButton:MenuButton;
      
      private var mActivateFilterButton:MenuButton;
      
      private var frameCount:int = 0;
      
      private var mLastTime:int = 0;
      
      private var mStackButtonArray:Array;
      
      private var mSaveButtonArray:Array;
      
      private var mLinkButtonArray:Array;
      
      private var mLoaderDict:Dictionary;
      
      private var mEnterTime:int = 0;
      
      private var mFilterText:TextField;
      
      private var mLastLen:int = 0;
      
      private var mProgressBarRect:Rectangle;
      
      public function LoaderProfiler()
      {
         this.mProgressBarRect = new Rectangle(20 + 16,0,100,11);
         super();
         this.Init();
         this.mEnterTime = getTimer();
         Analytics.Track("Tab","LoaderProfiler","LoaderProfiler Enter");
      }
      
      private function Init() : void
      {
         var _loc11_:MenuButton = null;
         var _loc12_:MenuButton = null;
         var _loc13_:MenuButton = null;
         this.mGridLine = new Rectangle();
         var _loc1_:int = 15;
         this.mLoaderDict = new Dictionary(true);
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
         this.mProgressCenterPosition = 20 + 16;
         this.mHTTPStatusColPosition = 70 + 16;
         this.mSizeColPosition = 130 + 16;
         this.mURLColPosition = 235 + 16;
         this.mAddedColumnStartPos = 100 + 16;
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
         this.mSaveButtonArray = new Array();
         this.mLinkButtonArray = new Array();
         var _loc10_:int = 0;
         while(_loc10_ < _loc9_)
         {
            _loc11_ = new MenuButton(3,37 + _loc10_ * 14,MenuButton.ICON_CLIPBOARD,SAVE_FUNCTION_STACK_EVENT,-1,"",true,Localization.Lbl_MFP_Saved);
            this.mStackButtonArray.push(_loc11_);
            addChild(_loc11_);
            _loc11_.visible = false;
            _loc12_ = new MenuButton(3 + 16,37 + _loc10_ * 14,MenuButton.ICON_FLOPPY,SAVE_FILE_EVENT,-1,"",true,Localization.Lbl_MFP_Saved);
            this.mSaveButtonArray.push(_loc12_);
            addChild(_loc12_);
            _loc12_.visible = false;
            _loc13_ = new MenuButton(3 + 16,37 + _loc10_ * 14,MenuButton.ICON_LINK,GO_TO_LINK,-1,"",true,Localization.Lbl_LD_GoToLink);
            this.mLinkButtonArray.push(_loc13_);
            addChild(_loc13_);
            _loc13_.visible = false;
            _loc10_++;
         }
         addEventListener(SAVE_FUNCTION_STACK_EVENT,this.OnSaveStack);
         addEventListener(SAVE_FILE_EVENT,this.OnFileSave);
         addEventListener(GO_TO_LINK,this.OnGoTo);
         this.mBlittingTextField.text = Localization.Lbl_LP_FileNameFilter;
         this.mBlittingTextFieldMatrix.ty = 20;
         this.mBlittingTextFieldMatrix.tx = this.mURLColPosition;
         this.mFilterText = new TextField();
         this.mFilterText.addEventListener(MouseEvent.MOUSE_MOVE,this.OnFilterMouseMove,false,0,true);
         this.mFilterText.addEventListener(MouseEvent.MOUSE_OVER,this.OnFilterMouseOver,false,0,true);
         this.mFilterText.addEventListener(MouseEvent.MOUSE_OUT,this.OnFilterMouseOut,false,0,true);
         this.mFilterText.selectable = true;
         this.mFilterText.x = this.mBlittingTextFieldMatrix.tx + this.mBlittingTextField.textWidth + 10;
         this.mFilterText.y = this.mBlittingTextFieldMatrix.ty - 2;
         this.mFilterText.text = "";
         if(Configuration.SAVE_FILTERS)
         {
            if(Configuration.SAVED_FILTER_LOADER)
            {
               this.mFilterText.text = Configuration.SAVED_FILTER_LOADER;
            }
         }
         this.mFilterText.height = 17;
         this.mFilterText.type = TextFieldType.INPUT;
         this.mFilterText.textColor = SkinManager.COLOR_GLOBAL_TEXT;
         this.mFilterText.defaultTextFormat = _loc4_;
         this.mFilterText.filters = [_loc7_];
         this.mFilterText.border = true;
         this.mFilterText.addEventListener(KeyboardEvent.KEY_DOWN,this.OnFilterExit,false,0,true);
         this.mFilterText.addEventListener(Event.CHANGE,this.OnFilterComplete,false,0,true);
         this.mFilterText.borderColor = SkinManager.COLOR_GLOBAL_LINE_DARK;
         this.mFilterText.backgroundColor = 4282664004;
         this.mFilterText.background = true;
         addChild(this.mFilterText);
      }
      
      private function OnGoTo(param1:Event) : void
      {
         var mbt:MenuButton = null;
         var name:String = null;
         var e:Event = param1;
         var len:int = int(this.mLinkButtonArray.length);
         var i:int = 0;
         while(i < len)
         {
            mbt = this.mLinkButtonArray[i];
            if(mbt != null && mbt.mIsSelected && Boolean(mbt.mLD))
            {
               try
               {
                  Analytics.Track("Action","Go To URL");
                  name = "";
                  if(mbt.mLD.mUrl != null && mbt.mLD.mUrl != Localization.Lbl_LA_NoUrlLoader)
                  {
                     navigateToURL(new URLRequest(mbt.mLD.mUrl),"_blank");
                  }
               }
               catch(err:Error)
               {
                  ToolTip.Text = "Error:" + err.message;
                  ToolTip.Visible = true;
                  continue;
               }
            }
            if(mbt != null)
            {
               mbt.Reset();
            }
            i++;
         }
      }
      
      private function OnFileSave(param1:Event) : void
      {
         var mbt:MenuButton = null;
         var mScreenCaptureFile:FileReference = null;
         var ba:ByteArray = null;
         var name:String = null;
         var date:Date = null;
         var e:Event = param1;
         var len:int = int(this.mSaveButtonArray.length);
         var i:int = 0;
         while(i < len)
         {
            mbt = this.mSaveButtonArray[i];
            if(mbt != null && mbt.mIsSelected && mbt.mLD && Boolean(mbt.mLD.mLoadedData))
            {
               try
               {
                  Analytics.Track("Action","Save Loader File");
                  mScreenCaptureFile = new FileReference();
                  ba = mbt.mLD.mLoadedData;
                  name = "";
                  if(mbt.mLD.mUrl != null && mbt.mLD.mUrl != Localization.Lbl_LA_NoUrlLoader)
                  {
                     name = escape(mbt.mLD.mUrl);
                     while(name.indexOf(":") != -1)
                     {
                        name = name.replace(":","_");
                     }
                     while(name.indexOf("/") != -1)
                     {
                        name = name.replace("/","_");
                     }
                     while(name.indexOf("@") != -1)
                     {
                        name = name.replace("@","_");
                     }
                     while(name.indexOf("?") != -1)
                     {
                        name = name.replace("?","_");
                     }
                     while(name.indexOf("=") != -1)
                     {
                        name = name.replace("=","_");
                     }
                     while(name.indexOf("&") != -1)
                     {
                        name = name.replace("&","_");
                     }
                     while(name.indexOf("%") != -1)
                     {
                        name = name.replace("%","_");
                     }
                     while(name.indexOf("*") != -1)
                     {
                        name = name.replace("*","_");
                     }
                     name = name.substr(0,100);
                  }
                  else
                  {
                     date = new Date();
                     name = "FileSave - " + date.fullYear.toString() + date.month.toString() + date.day.toString() + date.hours.toString() + "_" + date.minutes + date.seconds + ".dat";
                  }
                  mScreenCaptureFile.save(ba,name);
               }
               catch(err:Error)
               {
                  ToolTip.Text = "Error:" + err.message;
                  ToolTip.Visible = true;
               }
            }
            if(mbt != null)
            {
               mbt.Reset();
            }
            i++;
         }
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
            Configuration.SAVED_FILTER_LOADER = this.mFilterText.text;
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
         var _loc4_:LoaderData = null;
         var _loc1_:Array = LoaderAnalyser.GetInstance().GetLoadersData();
         _loc1_.sortOn(FIRST_EVENT_PROPERTY,Array.NUMERIC | Array.DESCENDING);
         var _loc2_:ByteArray = new ByteArray();
         var _loc3_:int = int(_loc1_.length);
         for each(_loc4_ in _loc1_)
         {
            if(_loc4_.mFirstEvent != -1)
            {
               if(_loc4_.mType == LoaderData.DISPLAY_LOADER)
               {
                  _loc2_.writeUTFBytes(LOADER_DISPLAY_LOADER);
               }
               else if(_loc4_.mType == LoaderData.URL_STREAM)
               {
                  _loc2_.writeUTFBytes(LOADER_STREAM);
               }
               else if(_loc4_.mType == LoaderData.URL_LOADER)
               {
                  _loc2_.writeUTFBytes(LOADER_URLLOADER);
               }
               _loc2_.writeByte(9);
               _loc2_.writeUTFBytes(_loc4_.mLoadedBytes.toString());
               _loc2_.writeByte(9);
               if(_loc4_.mIsFinished)
               {
                  _loc2_.writeUTFBytes(LOADER_COMPLETED);
               }
               else
               {
                  _loc2_.writeUTFBytes(LOADER_NOT_COMPLETED);
               }
               _loc2_.writeByte(9);
               if(_loc4_.mUrl == null)
               {
                  _loc2_.writeUTFBytes(Localization.Lbl_L_NoUrlFound);
               }
               else
               {
                  _loc2_.writeUTFBytes(_loc4_.mUrl);
               }
               _loc2_.writeByte(9);
               if(_loc4_.mIOError)
               {
                  _loc2_.writeByte(9);
                  _loc2_.writeUTFBytes(_loc4_.mIOError.toString());
               }
               if(_loc4_.mSecurityError)
               {
                  _loc2_.writeByte(9);
                  _loc2_.writeUTFBytes(_loc4_.mSecurityError.toString());
               }
               _loc2_.writeByte(13);
               _loc2_.writeByte(10);
            }
         }
         _loc2_.position = 0;
         System.setClipboard(_loc2_.readUTFBytes(_loc2_.length));
      }
      
      private function OnSaveStack(param1:Event) : void
      {
         var _loc4_:MenuButton = null;
         var _loc2_:int = int(this.mStackButtonArray.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc4_ = this.mStackButtonArray[_loc3_];
            if(_loc4_ != null && _loc4_.mIsSelected)
            {
               if(_loc4_.mUrl != null && _loc4_.mUrl != "")
               {
                  System.setClipboard(_loc4_.mUrl);
               }
               else if(_loc4_.mLD != null && Boolean(_loc4_.mLD.mIOError))
               {
                  System.setClipboard(_loc4_.mLD.mIOError.toString());
               }
               else if(_loc4_.mLD != null && Boolean(_loc4_.mLD.mSecurityError))
               {
                  System.setClipboard(_loc4_.mLD.mSecurityError.toString());
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
         var _loc4_:Array = LoaderAnalyser.GetInstance().GetLoadersData();
         _loc4_.sortOn(SORT_ON_KEY,Array.NUMERIC | Array.DESCENDING);
         var _loc5_:int = int(_loc4_.length);
         _loc2_ = int(_loc4_.length);
         var _loc6_:int = (stage.stageHeight - 25) / 15;
         this.mBlittingTextFieldMatrix.identity();
         this.mBlittingTextFieldMatrix.ty = 20;
         this.mBlittingTextFieldMatrix.tx = this.mProgressCenterPosition;
         this.mBlittingTextFieldCenter.text = COLUMN_HEADER_PROGRESS;
         this.mBitmapBackgroundData.draw(this.mBlittingTextFieldCenter,this.mBlittingTextFieldMatrix);
         this.mBlittingTextFieldMatrix.tx = this.mURLColPosition;
         this.mBlittingTextField.text = COLUMN_HEADER_URL;
         this.mBitmapBackgroundData.draw(this.mBlittingTextField,this.mBlittingTextFieldMatrix);
         this.mBlittingTextFieldMatrix.tx = this.mHTTPStatusColPosition;
         this.mBlittingTextFieldARight.text = COLUMN_HEADER_STATUS;
         this.mBitmapBackgroundData.draw(this.mBlittingTextFieldARight,this.mBlittingTextFieldMatrix);
         this.mBlittingTextFieldMatrix.tx = this.mSizeColPosition;
         this.mBlittingTextFieldARight.text = COLUMN_HEADER_SIZE;
         this.mBitmapBackgroundData.draw(this.mBlittingTextFieldARight,this.mBlittingTextFieldMatrix);
         this.mBlittingTextFieldMatrix.ty += 14;
         this.mGridLine.y = this.mBlittingTextFieldMatrix.ty + 2;
         this.mBitmapBackgroundData.fillRect(this.mGridLine,SkinManager.COLOR_GLOBAL_LINE);
         var _loc7_:LoaderData = null;
         var _loc8_:int = -1;
         _loc3_ = 0;
         while(_loc3_ < _loc6_)
         {
            this.mStackButtonArray[_loc3_].visible = false;
            this.mSaveButtonArray[_loc3_].visible = false;
            this.mLinkButtonArray[_loc3_].visible = false;
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
            if(this.mFilterText.text != "")
            {
               this.mFilterText.backgroundColor = 4278207488;
               _loc9_ = this.mFilterText.text.toLowerCase();
               if(_loc7_.mUrl == null || _loc7_.mUrl.toLowerCase().indexOf(_loc9_) == -1)
               {
                  _loc3_--;
                  continue;
               }
            }
            else
            {
               this.mFilterText.backgroundColor = 4282664004;
            }
            if(_loc7_.mFirstEvent != -1)
            {
               if(this.mActivateFilterButton.mIsSelected)
               {
                  if(_loc7_.mIOError == null && _loc7_.mSecurityError == null)
                  {
                     _loc3_--;
                     continue;
                  }
               }
               this.mStackButtonArray[_loc3_].visible = true;
               if(_loc7_.mLoadedData)
               {
                  this.mSaveButtonArray[_loc3_].visible = true;
                  this.mSaveButtonArray[_loc3_].SetToolTipText(Localization.Lbl_LD_SaveEncriptionFreeSWF);
               }
               else if(_loc7_.mUrl != null && _loc7_.mIOError == null && _loc7_.mUrl != Localization.Lbl_LA_NoUrlStream && _loc7_.mUrl != Localization.Lbl_L_NoUrlFound && _loc7_.mUrl != Localization.Lbl_LA_NoUrlLoader)
               {
                  this.mLinkButtonArray[_loc3_].visible = true;
                  this.mLinkButtonArray[_loc3_].SetToolTipText(Localization.Lbl_LD_GoToLink);
               }
               this.DrawProgress(_loc4_[_loc8_],38 + _loc3_ * 14);
               if(this.mStackButtonArray[_loc3_].mUrl != _loc7_.mUrl)
               {
                  this.mStackButtonArray[_loc3_].SetToolTipText(Localization.Lbl_FP_ClickCopyToClipboard + " " + _loc7_.mUrl);
                  this.mStackButtonArray[_loc3_].mUrl = _loc7_.mUrl;
                  this.mStackButtonArray[_loc3_].mLD = _loc7_;
                  this.mSaveButtonArray[_loc3_].mLD = _loc7_;
                  this.mLinkButtonArray[_loc3_].mLD = _loc7_;
               }
               else if(_loc7_.mIOError)
               {
                  this.mStackButtonArray[_loc3_].mLD = _loc7_;
                  this.mSaveButtonArray[_loc3_].mLD = _loc7_;
                  this.mLinkButtonArray[_loc3_].mLD = _loc7_;
                  this.mStackButtonArray[_loc3_].mUrl = _loc7_.mUrl;
                  this.mStackButtonArray[_loc3_].SetToolTipText(Localization.Lbl_FP_ClickCopyToClipboard + NEW_LINE + _loc7_.mIOError.text + NEW_LINE + _loc7_.mIOError);
               }
               else if(_loc7_.mSecurityError)
               {
                  this.mStackButtonArray[_loc3_].SetToolTipText(Localization.Lbl_FP_ClickCopyToClipboard + _loc7_.mSecurityError.text + NEW_LINE + _loc7_.mSecurityError);
               }
               this.mBlittingTextFieldMatrix.tx = this.mProgressCenterPosition;
               this.mBlittingTextFieldCenter.text = _loc7_.mProgressText;
               this.mBitmapBackgroundData.draw(this.mBlittingTextFieldCenter,this.mBlittingTextFieldMatrix);
               this.mBlittingTextFieldMatrix.tx = this.mHTTPStatusColPosition;
               if(_loc7_.mHTTPStatusText == null)
               {
                  this.mBlittingTextFieldARight.text = LoaderData.LOADER_DEFAULT_HTTP_STATUS;
               }
               else
               {
                  this.mBlittingTextFieldARight.text = _loc7_.mHTTPStatusText;
               }
               this.mBitmapBackgroundData.draw(this.mBlittingTextFieldARight,this.mBlittingTextFieldMatrix);
               this.mBlittingTextFieldMatrix.tx = this.mSizeColPosition;
               this.mBlittingTextFieldARight.text = _loc7_.mLoadedBytesText;
               this.mBitmapBackgroundData.draw(this.mBlittingTextFieldARight,this.mBlittingTextFieldMatrix);
               this.mBlittingTextFieldMatrix.tx = this.mURLColPosition;
               if(_loc7_.mUrl == null)
               {
                  this.mBlittingTextField.text = LoaderData.LOADER_DEFAULT_URL;
               }
               else
               {
                  this.mBlittingTextField.text = _loc7_.mUrl;
               }
               this.mBitmapBackgroundData.draw(this.mBlittingTextField,this.mBlittingTextFieldMatrix);
               this.mBlittingTextFieldMatrix.ty += 14;
               this.mGridLine.y = this.mBlittingTextFieldMatrix.ty + 2;
               this.mBitmapBackgroundData.fillRect(this.mGridLine,SkinManager.COLOR_GLOBAL_LINE);
            }
         }
         this.Render();
      }
      
      private function Render() : void
      {
         this.alpha = Commands.Opacity / 10;
      }
      
      private function DrawProgress(param1:LoaderData, param2:int) : void
      {
         this.mProgressBarRect.y = param2;
         this.mProgressBarRect.width = 100;
         var _loc3_:uint = SkinManager.COLOR_LOADER_DISPLAYLOADER_COMPLETED;
         if(param1.mType == LoaderData.SWF_LOADED)
         {
            _loc3_ = SkinManager.COLOR_LOADER_SWF;
         }
         else if(param1.mIOError != null || param1.mSecurityError != null)
         {
            _loc3_ = SkinManager.COLOR_LOADER_FALIED;
         }
         else if(param1.mProgress == 0)
         {
            _loc3_ = SkinManager.COLOR_LOADER_PROGRESS;
         }
         else if(param1.mType == LoaderData.DISPLAY_LOADER)
         {
            this.mProgressBarRect.width = 100 * param1.mProgress;
         }
         else if(param1.mType == LoaderData.URL_STREAM)
         {
            _loc3_ = SkinManager.COLOR_LOADER_URLSTREAM_COMPLETED;
         }
         else
         {
            _loc3_ = SkinManager.COLOR_LOADER_URLLOADER_COMPLETED;
         }
         this.mBitmapBackgroundData.fillRect(this.mProgressBarRect,_loc3_);
      }
      
      public function Dispose() : void
      {
         var _loc1_:MenuButton = null;
         var _loc2_:MenuButton = null;
         var _loc3_:MenuButton = null;
         if(this.mFilterText)
         {
            this.mFilterText.removeEventListener(KeyboardEvent.KEY_DOWN,this.OnFilterExit);
            this.mFilterText.removeEventListener(Event.CHANGE,this.OnFilterComplete);
         }
         for each(_loc1_ in this.mStackButtonArray)
         {
            _loc1_.Dispose();
         }
         for each(_loc2_ in this.mSaveButtonArray)
         {
            _loc2_.Dispose();
         }
         for each(_loc3_ in this.mLinkButtonArray)
         {
            _loc3_.Dispose();
         }
         Analytics.Track("Tab","LoaderProfiler","LoaderProfiler Exit",int((getTimer() - this.mEnterTime) / 1000));
         this.mStackButtonArray = null;
         this.mSaveButtonArray = null;
         this.mLinkButtonArray = null;
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
         this.mLoaderDict = null;
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

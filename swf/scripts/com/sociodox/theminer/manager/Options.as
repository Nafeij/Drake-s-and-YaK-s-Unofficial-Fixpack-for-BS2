package com.sociodox.theminer.manager
{
   import com.sociodox.theminer.TheMinerActionEnum;
   import com.sociodox.theminer.event.ChangeToolEvent;
   import com.sociodox.theminer.ui.ToolTip;
   import com.sociodox.theminer.ui.button.MenuButton;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.system.Capabilities;
   import flash.system.System;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import flash.utils.Dictionary;
   
   public class Options extends Sprite
   {
      
      public static const SAVE_SWF_EVENT:String = "SaveSWFEvent";
      
      public static const SAVE_RECORDING_EVENT:String = "SaveRecordingEvent";
      
      public static const SAVE_RECORDING_TRACE_EVENT:String = "SaveRecordingTraceEvent";
      
      public static const TOGGLE_MINIMIZE:String = "ToggleMinimizeEvent";
      
      public static const TOGGLE_QUIT:String = "ToggleQuitEvent";
      
      public static const SAVE_SNAPSHOT_EVENT:String = "saveSnapshotEvent";
      
      public static const SCREEN_CAPTURE_EVENT:String = "screenCaptureEvent";
       
      
      private var mAutoStatButton:Sprite;
      
      private var mShowOverdraw:Sprite;
      
      private var mShowInstanciator:Sprite;
      
      private var mShowProfiler:Sprite;
      
      private var mShowInternalEvents:Sprite;
      
      private var mShowConfig:Sprite;
      
      private var mMinimizeButton:MenuButton;
      
      public var mFoldButton:MenuButton;
      
      private var mMouseListenerButton:MenuButton;
      
      private var mStatsButton:MenuButton;
      
      private var mOverdrawButton:MenuButton;
      
      private var mInstanciationButton:MenuButton;
      
      private var mMemoryProfilerButton:MenuButton;
      
      private var mInternalEventButton:MenuButton;
      
      private var mFunctionTimeButton:MenuButton;
      
      private var mLoaderProfilerButton:MenuButton;
      
      private var mUserEventButton:MenuButton;
      
      private var mConfigButton:MenuButton;
      
      public var mQuitButton:MenuButton;
      
      private var mSaveDiskButton:MenuButton;
      
      private var mSaveTraceButton:MenuButton;
      
      private var mGCButton:MenuButton;
      
      private var mMonsterHideBar:Sprite;
      
      private var debuggerIcon:DisplayObject = null;
      
      private var mLastSelected:Sprite = null;
      
      private var mToolTip:ToolTip;
      
      private var mButtonDict:Dictionary;
      
      private var mLastFps:int = 0;
      
      private var mLastMem:int = 0;
      
      private var mFPSTextField:TextField;
      
      private var mMemTextField:TextField;
      
      private var mFPSValueTextField:TextField;
      
      private var mMemValueTextField:TextField;
      
      public var mFps:int = 0;
      
      private var mFoldButtonWasSelected:Boolean = false;
      
      private var barWidth:int = 400;
      
      private var myformat:TextFormat = null;
      
      private var myformatRight:TextFormat = null;
      
      private var myglow:GlowFilter = null;
      
      private var mTextDisplayX:int = 0;
      
      private var mIsHidden:Boolean = false;
      
      private var mConsoleButton:MenuButton;
      
      private var mScreenCapture:MenuButton;
      
      private var mMonsterStatus:int = 1;
      
      public function Options()
      {
         this.mMonsterHideBar = new Sprite();
         this.mButtonDict = new Dictionary(true);
         super();
      }
      
      public function Init() : void
      {
         if(Stage2D)
         {
            this.OnAddedToStage();
         }
         else
         {
            addEventListener(Event.ADDED_TO_STAGE,this.OnAddedToStage);
         }
      }
      
      private function OnAddedToStage(param1:Event = null) : void
      {
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc6_:String = null;
         if(param1 == null || param1.target == this)
         {
            removeEventListener(Event.ADDED_TO_STAGE,this.OnAddedToStage);
            this.myformat = new TextFormat("_sans",11,SkinManager.COLOR_GLOBAL_TEXT,false);
            this.myformatRight = new TextFormat("_sans",11,SkinManager.COLOR_GLOBAL_TEXT,false,null,null,null,null,TextFormatAlign.RIGHT);
            this.myglow = new GlowFilter(SkinManager.COLOR_GLOBAL_TEXT_GLOW,1,2,2,3,2,false,false);
            this.UpdateSkin();
            this.mToolTip = new ToolTip();
            var _loc2_:int = 2;
            var _loc3_:int = 16;
            _loc4_ = 2;
            if(Capabilities.isDebugger)
            {
               this.mFoldButton = new MenuButton(_loc2_,_loc4_,MenuButton.ICON_MINIMIZE,TOGGLE_MINIMIZE,-1,Localization.Lbl_Minimize,true);
               addChild(this.mFoldButton);
               _loc2_ += 16;
               this.mStatsButton = new MenuButton(_loc2_,_loc4_,MenuButton.ICON_STATS,ChangeToolEvent.CHANGE_TOOL_EVENT,TheMinerActionEnum.TOGGLE_INTERFACE_FLASH_RUNTIME_STATISTICS,Localization.Lbl_RuntimeStatistics);
               addChild(this.mStatsButton);
               this.mButtonDict[this.mStatsButton] = this.mStatsButton;
               this.mQuitButton = new MenuButton(_loc2_,_loc4_,MenuButton.ICON_CLEAR,TOGGLE_QUIT,-1,Localization.Lbl_Quit);
               addChild(this.mQuitButton);
               this.mButtonDict[this.mQuitButton] = this.mQuitButton;
               this.mQuitButton.visible = false;
               _loc2_ += 16;
               this.mMouseListenerButton = new MenuButton(_loc2_,_loc4_,MenuButton.ICON_MOUSE,ChangeToolEvent.CHANGE_TOOL_EVENT,TheMinerActionEnum.TOGGLE_INTERFACE_MOUSE_LISTENERS,Localization.Lbl_MouseListeners);
               addChild(this.mMouseListenerButton);
               this.mButtonDict[this.mMouseListenerButton] = this.mMouseListenerButton;
               _loc2_ += 16;
               this.mOverdrawButton = new MenuButton(_loc2_,_loc4_,MenuButton.ICON_OVERDRAW,ChangeToolEvent.CHANGE_TOOL_EVENT,TheMinerActionEnum.TOGGLE_INTERFACE_OVERDRAW,Localization.Lbl_Overdraw);
               addChild(this.mOverdrawButton);
               this.mButtonDict[this.mOverdrawButton] = this.mOverdrawButton;
               _loc2_ += 16;
               this.mInstanciationButton = new MenuButton(_loc2_,_loc4_,MenuButton.ICON_LIFE_CYCLE,ChangeToolEvent.CHANGE_TOOL_EVENT,TheMinerActionEnum.TOGGLE_INTERFACE_DISPLAYOBJECT_LIFECYCLE,Localization.Lbl_DisplayObjectsLifeCycle);
               addChild(this.mInstanciationButton);
               this.mButtonDict[this.mInstanciationButton] = this.mInstanciationButton;
               _loc2_ += 16;
               if(Capabilities.isDebugger)
               {
                  this.mMemoryProfilerButton = new MenuButton(_loc2_,_loc4_,MenuButton.ICON_MEMORY,ChangeToolEvent.CHANGE_TOOL_EVENT,TheMinerActionEnum.TOGGLE_INTERFACE_MEMORY_PROFILER,Localization.Lbl_MemoryProfiler);
                  this.mButtonDict[this.mMemoryProfilerButton] = this.mMemoryProfilerButton;
               }
               else
               {
                  this.mMemoryProfilerButton = new MenuButton(_loc2_,_loc4_,MenuButton.ICON_MEMORY,null,TheMinerActionEnum.TOGGLE_INTERFACE_MEMORY_PROFILER,Localization.Lbl_ThisFeatureRequireDebugPlayer);
               }
               addChild(this.mMemoryProfilerButton);
               _loc2_ += 16;
               if(Capabilities.isDebugger)
               {
                  this.mInternalEventButton = new MenuButton(_loc2_,_loc4_,MenuButton.ICON_EVENTS,ChangeToolEvent.CHANGE_TOOL_EVENT,TheMinerActionEnum.TOGGLE_INTERFACE_INTERNAL_EVENTS,Localization.Lbl_InternalEventsProfiler);
                  this.mButtonDict[this.mInternalEventButton] = this.mInternalEventButton;
               }
               else
               {
                  this.mInternalEventButton = new MenuButton(_loc2_,_loc4_,MenuButton.ICON_EVENTS,null,TheMinerActionEnum.TOGGLE_INTERFACE_INTERNAL_EVENTS,Localization.Lbl_ThisFeatureRequireDebugPlayer);
               }
               addChild(this.mInternalEventButton);
               _loc2_ += 16;
               if(Capabilities.isDebugger)
               {
                  this.mFunctionTimeButton = new MenuButton(_loc2_,_loc4_,MenuButton.ICON_PERFORMANCE,ChangeToolEvent.CHANGE_TOOL_EVENT,TheMinerActionEnum.TOGGLE_INTERFACE_FUNCTION_PERFORMANCES,Localization.Lbl_PerformanceProfiler);
                  this.mButtonDict[this.mFunctionTimeButton] = this.mFunctionTimeButton;
               }
               else
               {
                  this.mFunctionTimeButton = new MenuButton(_loc2_,_loc4_,MenuButton.ICON_PERFORMANCE,null,TheMinerActionEnum.TOGGLE_INTERFACE_FUNCTION_PERFORMANCES,Localization.Lbl_ThisFeatureRequireDebugPlayer);
               }
               addChild(this.mFunctionTimeButton);
               _loc2_ += 16;
               if(Capabilities.isDebugger)
               {
                  this.mLoaderProfilerButton = new MenuButton(_loc2_,_loc4_,MenuButton.ICON_LOADER,ChangeToolEvent.CHANGE_TOOL_EVENT,TheMinerActionEnum.TOGGLE_INTERFACE_LOADERS_PROFILER,Localization.Lbl_LoadersProfiler);
                  this.mButtonDict[this.mLoaderProfilerButton] = this.mLoaderProfilerButton;
               }
               else
               {
                  this.mLoaderProfilerButton = new MenuButton(_loc2_,_loc4_,MenuButton.ICON_LOADER,null,TheMinerActionEnum.TOGGLE_INTERFACE_LOADERS_PROFILER,Localization.Lbl_ThisFeatureRequireDebugPlayer);
               }
               addChild(this.mLoaderProfilerButton);
            }
            _loc2_ += 16;
            this.mUserEventButton = new MenuButton(_loc2_,_loc4_,MenuButton.ICON_LINK,ChangeToolEvent.CHANGE_TOOL_EVENT,TheMinerActionEnum.TOGGLE_INTERFACE_USER_EVENTS,Localization.Lbl_UserEvents);
            this.mButtonDict[this.mUserEventButton] = this.mUserEventButton;
            addChild(this.mUserEventButton);
            _loc2_ += 16;
            this.mConsoleButton = new MenuButton(_loc2_,_loc4_,MenuButton.ICON_PROMPT,ChangeToolEvent.CHANGE_TOOL_EVENT,TheMinerActionEnum.TOGGLE_INTERFACE_CONSOLE,Localization.Lbl_Console_Console);
            addChild(this.mConsoleButton);
            this.mButtonDict[this.mConsoleButton] = this.mConsoleButton;
            _loc2_ += 16;
            this.mConfigButton = new MenuButton(_loc2_,_loc4_,MenuButton.ICON_CONFIG,ChangeToolEvent.CHANGE_TOOL_EVENT,TheMinerActionEnum.TOGGLE_INTERFACE_CONFIGURATION,Localization.Lbl_Configs);
            addChild(this.mConfigButton);
            this.mButtonDict[this.mConfigButton] = this.mConfigButton;
            _loc2_ += 16;
            this.mScreenCapture = new MenuButton(_loc2_,_loc4_,MenuButton.ICON_CAMERA,SCREEN_CAPTURE_EVENT,-1,Localization.Lbl_ScreenCapture,true,Localization.Lbl_MFP_Saved);
            addChild(this.mScreenCapture);
            addEventListener(SCREEN_CAPTURE_EVENT,this.OnSaveSnapshot);
            this.mButtonDict[this.mScreenCapture] = this.mScreenCapture;
            _loc2_ += 16;
            this.mGCButton = new MenuButton(_loc2_,_loc4_,MenuButton.ICON_GC,null,-1,Localization.Lbl_ForceSyncGarbageCollector,true,Localization.Lbl_Done);
            addChild(this.mGCButton);
            _loc2_ += 16;
            if(Capabilities.isDebugger)
            {
               _loc5_ = Localization.Lbl_SaveSamples;
               this.mSaveDiskButton = new MenuButton(_loc2_,_loc4_,MenuButton.ICON_SAVEDISK,SAVE_RECORDING_EVENT,-1,Localization.Lbl_StartRecordingSamples,true,_loc5_);
               addChild(this.mSaveDiskButton);
               addEventListener(SAVE_RECORDING_EVENT,this.OnSaveRecording);
               _loc2_ += 16;
               _loc6_ = Localization.Lbl_SaveTraces;
               this.mSaveTraceButton = new MenuButton(_loc2_,_loc4_,MenuButton.ICON_MAGNIFY,SAVE_RECORDING_TRACE_EVENT,-1,Localization.Lbl_StartRecordingExecutionTrace,true,_loc6_);
               addChild(this.mSaveTraceButton);
               addEventListener(SAVE_RECORDING_TRACE_EVENT,this.OnSaveRecordingTrace);
               _loc2_ += 16;
            }
            SkinManager.IMAGE_OPTIONS_MONSTERS.x = _loc2_;
            SkinManager.IMAGE_OPTIONS_MONSTERS.y = -1;
            SkinManager.IMAGE_OPTIONS_MONSTERS.addEventListener(MouseEvent.MOUSE_MOVE,this.OnMonsterMouseMove,false,0,true);
            SkinManager.IMAGE_OPTIONS_MONSTERS.addEventListener(MouseEvent.MOUSE_OVER,this.OnMonsterMouseOver,false,0,true);
            SkinManager.IMAGE_OPTIONS_MONSTERS.addEventListener(MouseEvent.MOUSE_OUT,this.OnMonsterMouseOut,false,0,true);
            addChild(SkinManager.IMAGE_OPTIONS_MONSTERS);
            SkinManager.IMAGE_OPTIONS_MONSTERS.scrollRect = SkinManager.IMAGE_OPTIONS_MONSTERS_DISABLED;
            this.mMonsterStatus = 1;
            _loc2_ += 50;
            this.mTextDisplayX = _loc2_;
            this.mFPSTextField = new TextField();
            this.mFPSTextField.x = _loc2_;
            this.mFPSTextField.y = _loc4_ - 2;
            this.mFPSTextField.autoSize = TextFieldAutoSize.LEFT;
            this.mFPSTextField.defaultTextFormat = this.myformat;
            this.mFPSTextField.selectable = false;
            this.mFPSTextField.filters = [this.myglow];
            this.mFPSTextField.mouseEnabled = false;
            this.mFPSTextField.text = Localization.Lbl_FPS;
            addChild(this.mFPSTextField);
            _loc2_ += 24;
            this.mFPSValueTextField = new TextField();
            this.mFPSValueTextField.x = _loc2_;
            this.mFPSValueTextField.y = _loc4_ - 2;
            this.mFPSValueTextField.autoSize = TextFieldAutoSize.LEFT;
            this.mFPSValueTextField.defaultTextFormat = this.myformat;
            this.mFPSValueTextField.selectable = false;
            this.mFPSValueTextField.filters = [this.myglow];
            this.mFPSValueTextField.mouseEnabled = false;
            this.mFPSValueTextField.text = "";
            addChild(this.mFPSValueTextField);
            _loc2_ += 18;
            this.mMemTextField = new TextField();
            this.mMemTextField.x = _loc2_;
            this.mMemTextField.y = _loc4_ - 2;
            this.mMemTextField.autoSize = TextFieldAutoSize.LEFT;
            this.mMemTextField.defaultTextFormat = this.myformat;
            this.mMemTextField.selectable = false;
            this.mMemTextField.filters = [this.myglow];
            this.mMemTextField.mouseEnabled = false;
            this.mMemTextField.text = Localization.Lbl_Mb;
            addChild(this.mMemTextField);
            _loc2_ += 23;
            this.mMemValueTextField = new TextField();
            this.mMemValueTextField.x = _loc2_;
            this.mMemValueTextField.y = _loc4_ - 2;
            this.mMemValueTextField.autoSize = TextFieldAutoSize.LEFT;
            this.mMemValueTextField.defaultTextFormat = this.myformat;
            this.mMemValueTextField.selectable = false;
            this.mMemValueTextField.filters = [this.myglow];
            this.mMemValueTextField.mouseEnabled = false;
            this.mMemValueTextField.text = "";
            addChild(this.mMemValueTextField);
            _loc2_ += 30;
            addChild(this.mToolTip);
            addEventListener(ChangeToolEvent.CHANGE_TOOL_EVENT,this.OnChangeTool);
            this.ResetColors();
            return;
         }
      }
      
      private function OnSaveRecording(param1:Event) : void
      {
         this.mSaveTraceButton.Reset();
         this.mSaveDiskButton.Reset();
         Commands.StopRecordingSamples(true);
      }
      
      private function OnSaveRecordingTrace(param1:Event) : void
      {
         this.mSaveTraceButton.Reset();
         this.mSaveDiskButton.Reset();
         Commands.StopRecordingTraces(true);
      }
      
      private function OnMonsterMouseMove(param1:MouseEvent) : void
      {
         ToolTip.SetPosition(param1.stageX + 12,param1.stageY + 6);
         param1.stopPropagation();
         param1.stopImmediatePropagation();
      }
      
      public function OnMonsterMouseOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         param1.stopImmediatePropagation();
         if(this.mMonsterStatus == 0)
         {
            ToolTip.Text = Localization.Lbl_Cfg_MonsterIconDisabled;
         }
         else if(this.mMonsterStatus == 1)
         {
            ToolTip.Text = Localization.Lbl_Cfg_MonsterIconNotActive;
         }
         else if(this.mMonsterStatus == 2)
         {
            ToolTip.Text = Localization.Lbl_Cfg_MonsterIconActive;
         }
         ToolTip.Visible = true;
      }
      
      public function OnMonsterMouseOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         param1.stopImmediatePropagation();
         ToolTip.Visible = false;
      }
      
      private function OnSaveSnapshot(param1:Event) : void
      {
         Commands.SaveSnapshot();
         this.mScreenCapture.mIsSelected = false;
      }
      
      public function UpdateSkin() : void
      {
         this.myformat.color = SkinManager.COLOR_GLOBAL_TEXT;
         this.myformatRight.color = SkinManager.COLOR_GLOBAL_TEXT;
         this.myglow.color = SkinManager.COLOR_GLOBAL_TEXT_GLOW;
         if(this.mFPSTextField != null)
         {
            this.mFPSTextField.defaultTextFormat = this.myformat;
            this.mFPSValueTextField.defaultTextFormat = this.myformat;
            this.mMemTextField.defaultTextFormat = this.myformat;
            this.mMemValueTextField.defaultTextFormat = this.myformat;
            this.mFPSTextField.filters = [this.myglow];
            this.mFPSValueTextField.filters = [this.myglow];
            this.mMemTextField.filters = [this.myglow];
            this.mMemValueTextField.filters = [this.myglow];
         }
         graphics.clear();
         graphics.beginFill(SkinManager.COLOR_GLOBAL_BG,0.4);
         graphics.drawRect(0,0,this.barWidth,18);
         graphics.endFill();
         graphics.beginFill(SkinManager.COLOR_GLOBAL_LINE_DARK,0.8);
         graphics.drawRect(0,15,this.barWidth,1);
         graphics.endFill();
         graphics.beginFill(SkinManager.COLOR_GLOBAL_LINE,0.9);
         graphics.drawRect(0,16,this.barWidth,1);
         graphics.endFill();
      }
      
      private function OnSaveSWF(param1:Event) : void
      {
      }
      
      private function OnChangeTool(param1:ChangeToolEvent) : void
      {
         var _loc2_:MenuButton = null;
         for each(_loc2_ in this.mButtonDict)
         {
            if(param1.target != _loc2_)
            {
               _loc2_.Reset();
            }
         }
      }
      
      public function ToggleMinimize() : void
      {
         if(this.mIsHidden)
         {
            this.Show();
         }
         else
         {
            this.Hide();
         }
      }
      
      public function Hide() : void
      {
         this.mIsHidden = true;
         var _loc1_:Boolean = false;
         this.mQuitButton.visible = !_loc1_;
         this.mMouseListenerButton.visible = _loc1_;
         this.mStatsButton.visible = _loc1_;
         this.mOverdrawButton.visible = _loc1_;
         this.mInstanciationButton.visible = _loc1_;
         this.mMemoryProfilerButton.visible = _loc1_;
         this.mInternalEventButton.visible = _loc1_;
         this.mFunctionTimeButton.visible = _loc1_;
         this.mLoaderProfilerButton.visible = _loc1_;
         this.mConfigButton.visible = _loc1_;
         this.mUserEventButton.visible = _loc1_;
         this.mScreenCapture.visible = _loc1_;
         this.mConsoleButton.visible = _loc1_;
         this.mSaveDiskButton.visible = _loc1_;
         this.mSaveTraceButton.visible = _loc1_;
         this.mGCButton.visible = _loc1_;
         SkinManager.IMAGE_OPTIONS_MONSTERS.visible = _loc1_;
         this.mMonsterHideBar.visible = _loc1_;
         this.mFPSTextField.x = 32;
         this.mFPSValueTextField.x = this.mFPSTextField.x + 24;
         this.mMemTextField.x = this.mFPSValueTextField.x + 18;
         this.mMemValueTextField.x = this.mMemTextField.x + 23;
         this.graphics.clear();
         this.graphics.beginFill(SkinManager.COLOR_GLOBAL_BG,0.4);
         this.graphics.drawRect(0,0,120,18);
         this.graphics.endFill();
         this.graphics.beginFill(SkinManager.COLOR_GLOBAL_LINE_DARK,0.8);
         this.graphics.drawRect(0,15,120,1);
         this.graphics.endFill();
         this.graphics.beginFill(SkinManager.COLOR_GLOBAL_LINE,0.9);
         this.graphics.drawRect(0,16,120,1);
         this.graphics.endFill();
      }
      
      private function Show() : void
      {
         this.mIsHidden = false;
         var _loc1_:Boolean = true;
         this.mQuitButton.visible = !_loc1_;
         this.mMouseListenerButton.visible = _loc1_;
         this.mStatsButton.visible = _loc1_;
         this.mOverdrawButton.visible = _loc1_;
         this.mInstanciationButton.visible = _loc1_;
         this.mMemoryProfilerButton.visible = _loc1_;
         this.mInternalEventButton.visible = _loc1_;
         this.mFunctionTimeButton.visible = _loc1_;
         this.mLoaderProfilerButton.visible = _loc1_;
         this.mConfigButton.visible = _loc1_;
         this.mUserEventButton.visible = _loc1_;
         this.mScreenCapture.visible = _loc1_;
         this.mConsoleButton.visible = _loc1_;
         this.mSaveDiskButton.visible = _loc1_;
         this.mSaveTraceButton.visible = _loc1_;
         this.mGCButton.visible = _loc1_;
         SkinManager.IMAGE_OPTIONS_MONSTERS.visible = _loc1_;
         this.mMonsterHideBar.visible = _loc1_;
         this.mFPSTextField.x = this.mTextDisplayX;
         this.mFPSValueTextField.x = this.mFPSTextField.x + 24;
         this.mMemTextField.x = this.mFPSValueTextField.x + 18;
         this.mMemValueTextField.x = this.mMemTextField.x + 23;
         this.graphics.clear();
         this.graphics.beginFill(SkinManager.COLOR_GLOBAL_BG,0.4);
         this.graphics.drawRect(0,0,this.barWidth,18);
         this.graphics.endFill();
         this.graphics.beginFill(SkinManager.COLOR_GLOBAL_LINE_DARK,0.8);
         this.graphics.drawRect(0,15,this.barWidth,1);
         this.graphics.endFill();
         this.graphics.beginFill(SkinManager.COLOR_GLOBAL_LINE,0.9);
         this.graphics.drawRect(0,16,this.barWidth,1);
         this.graphics.endFill();
      }
      
      public function Update() : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         if(this.mLastFps != this.mFps)
         {
            _loc2_ = String(SampleAnalyzer.mLineString[this.mFps]);
            if(_loc2_ == null)
            {
               SampleAnalyzer.mLineString[this.mFps] = _loc2_ = String(this.mFps);
            }
            this.mLastFps = this.mFps;
            this.mFPSValueTextField.text = _loc2_;
         }
         var _loc1_:int = int(System.totalMemory / 1024 / 1024);
         if(this.mLastMem != _loc1_)
         {
            _loc3_ = String(SampleAnalyzer.mLineString[_loc1_]);
            if(_loc3_ == null)
            {
               SampleAnalyzer.mLineString[_loc1_] = _loc3_ = String(_loc1_);
            }
            this.mLastMem = _loc1_;
            this.mMemValueTextField.text = _loc3_;
         }
         if(this.mFoldButton.mIsSelected)
         {
            if(this.mFoldButtonWasSelected)
            {
               this.Hide();
               this.mFoldButtonWasSelected = false;
            }
         }
         else if(!this.mFoldButtonWasSelected)
         {
            this.Show();
            this.mFoldButtonWasSelected = true;
         }
         if(!Commands.IsRecordingSamples && this.mSaveDiskButton != null && this.mSaveDiskButton.mIsSelected)
         {
            Commands.StartRecordingSamples();
         }
         if(!Commands.IsRecordingTraces && this.mSaveTraceButton != null && this.mSaveTraceButton.mIsSelected)
         {
            Commands.StartRecordingTraces();
         }
         if(this.mGCButton.mIsSelected)
         {
            Analytics.Track("Action","ForceGC");
            SampleAnalyzer.ForceGC();
            this.mGCButton.Reset();
         }
      }
      
      public function SetMonsterDisabled() : void
      {
         this.mMonsterHideBar.graphics.beginFill(SkinManager.COLOR_GLOBAL_BG,1);
         this.mMonsterHideBar.graphics.drawRect(SkinManager.IMAGE_OPTIONS_MONSTERS.x - 2,9,SkinManager.IMAGE_OPTIONS_MONSTERS.scrollRect.width + 4,1);
         this.mMonsterHideBar.graphics.endFill();
         this.mMonsterHideBar.graphics.beginFill(SkinManager.COLOR_GLOBAL_LINE,1);
         this.mMonsterHideBar.graphics.drawRect(SkinManager.IMAGE_OPTIONS_MONSTERS.x - 2,10,SkinManager.IMAGE_OPTIONS_MONSTERS.scrollRect.width + 4,2);
         this.mMonsterHideBar.graphics.endFill();
         this.mMonsterHideBar.graphics.beginFill(SkinManager.COLOR_GLOBAL_LINE_DARK,1);
         this.mMonsterHideBar.graphics.drawRect(SkinManager.IMAGE_OPTIONS_MONSTERS.x - 2,12,SkinManager.IMAGE_OPTIONS_MONSTERS.scrollRect.width + 4,1);
         this.mMonsterHideBar.graphics.endFill();
         addChild(this.mMonsterHideBar);
         this.mMonsterStatus = 0;
      }
      
      public function Dispose() : void
      {
      }
      
      private function ResetColors(param1:Sprite = null) : void
      {
         if(this.mLastSelected != this.mShowInstanciator)
         {
            (this.mShowInstanciator as MenuButton).Reset();
         }
         if(this.mLastSelected != this.mMouseListenerButton)
         {
            (this.mMouseListenerButton as MenuButton).Reset();
         }
         if(this.mLastSelected != this.mAutoStatButton)
         {
            (this.mAutoStatButton as MenuButton).Reset();
         }
         if(this.mLastSelected != this.mShowOverdraw)
         {
            (this.mShowOverdraw as MenuButton).Reset();
         }
         if(this.mLastSelected != this.mShowProfiler)
         {
            (this.mShowProfiler as MenuButton).Reset();
         }
         if(this.mLastSelected != this.mShowInternalEvents)
         {
            (this.mShowInternalEvents as MenuButton).Reset();
         }
         if(this.mLastSelected != this.mShowConfig)
         {
            (this.mShowConfig as MenuButton).Reset();
         }
         if(this.mLastSelected != this.mMinimizeButton)
         {
            (this.mMinimizeButton as MenuButton).Reset();
         }
         if(param1 != null)
         {
            param1.getChildAt(1).visible = true;
         }
      }
      
      public function OnDebuggerConnect(param1:Event) : void
      {
         SkinManager.IMAGE_OPTIONS_MONSTERS.scrollRect = SkinManager.IMAGE_OPTIONS_MONSTERS_ACTIVE;
         this.mMonsterStatus = 2;
      }
      
      public function OnDebuggerDisconnect(param1:Event) : void
      {
         SkinManager.IMAGE_OPTIONS_MONSTERS.scrollRect = SkinManager.IMAGE_OPTIONS_MONSTERS_DISABLED;
         this.mMonsterStatus = 1;
      }
      
      public function ResetMenu(param1:MenuButton) : void
      {
         var _loc2_:MenuButton = null;
         for each(_loc2_ in this.mButtonDict)
         {
            if(param1 != _loc2_)
            {
               _loc2_.Reset();
            }
         }
      }
   }
}

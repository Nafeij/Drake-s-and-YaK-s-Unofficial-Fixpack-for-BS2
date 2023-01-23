package com.sociodox.theminer.window
{
   import com.sociodox.theminer.manager.Analytics;
   import com.sociodox.theminer.manager.Commands;
   import com.sociodox.theminer.manager.Localization;
   import com.sociodox.theminer.manager.SkinManager;
   import com.sociodox.theminer.manager.Stage2D;
   import com.sociodox.theminer.ui.ToolTip;
   import com.sociodox.theminer.ui.button.MenuButton;
   import flash.display.Bitmap;
   import flash.display.BlendMode;
   import flash.display.DisplayObjectContainer;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.net.FileFilter;
   import flash.net.FileReference;
   import flash.net.SharedObject;
   import flash.net.URLRequest;
   import flash.net.URLStream;
   import flash.net.navigateToURL;
   import flash.sampler.pauseSampling;
   import flash.sampler.startSampling;
   import flash.system.Capabilities;
   import flash.system.Security;
   import flash.system.System;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   
   public class Configuration extends Sprite implements IWindow
   {
      
      public static const SETUP_START_MINIMIZED:String = "SETUP_START_MINIMIZED";
      
      public static const SETUP_MEMORY_PROFILING_ENABLED:String = "SETUP_MEMORY_PROFILING_ENABLED";
      
      public static const SETUP_INTERNALEVENT_PROFILING_ENABLED:String = "SETUP_INTERNALEVENT_PROFILING_ENABLED";
      
      public static const SETUP_FUNCTION_PROFILING_ENABLED:String = "SETUP_FUNCTION_PROFILING_ENABLED";
      
      public static const SETUP_LOADERS_PROFILING_ENABLED:String = "SETUP_LOADERS_PROFILING_ENABLED";
      
      public static const SETUP_LOADERS_SAVE_FILTERS:String = "SETUP_LOADERS_SAVE_FILTERS";
      
      public static const SETUP_SOCKETS_PROFILING_ENABLED:String = "SETUP_SOCKETS_PROFILING_ENABLED";
      
      public static const SETUP_MEMGRAPH_PROFILING_ENABLED:String = "SETUP_MEMGRAPH_PROFILING_ENABLED";
      
      public static const SETUP_MONSTER_DEBUGGER:String = "SETUP_MONSTER_DEBUGGER";
      
      public static const SETUP_ANALYTICS_ENABLED:String = "SETUP_ANALYTICS_ENABLED";
      
      public static const SETUP_FRAME_UPDATE:String = "SETUP_FRAME_UPDATE";
      
      public static const SETUP_OPACITY:String = "SETUP_OPACITY";
      
      public static var SAVED_FILTER_MEMORY:String = "";
      
      public static var SAVED_FILTER_PERFORMANCE:String = "";
      
      public static var SAVED_FILTER_LOADER:String = "";
      
      public static var SAVED_FILTER_USEREVENT:String = "";
      
      public static var _PROFILE_MEMORY:Boolean = false;
      
      public static var _PROFILE_FUNCTION:Boolean = false;
      
      public static var _SAVE_FILTERS:Boolean = false;
      
      public static var _PROFILE_INTERNAL_EVENTS:Boolean = false;
      
      public static var _PROFILE_LOADERS:Boolean = false;
      
      private static var _PROFILE_SOCKETS:Boolean = false;
      
      private static var _PROFILE_MEMGRAPH:Boolean = false;
      
      private static var _START_MINIMIZED:Boolean = false;
      
      private static var _PROFILE_MONSTER:Boolean = false;
      
      private static var _ANALYTICS_ENABLED:Boolean = true;
      
      private static var _FRAME_UPDATE_SPEED:int = 1;
      
      private static var _INTERFACE_OPACITY:int = 6;
      
      public static var mSaveObj:SharedObject;
      
      private static var mInstance:Configuration = null;
      
      public static const LOAD_SKIN_EVENT:String = "LoadSkinEvent";
      
      public static const SAVE_LOCALIZATION_EVENT:String = "SaveLocalizationEvent";
      
      public static const PASTE_LOCALIZATION_EVENT:String = "PasteLocalizationEvent";
      
      public static var COMMAND_LINE_SAMPLING_LSTENER:Boolean = false;
       
      
      private var mInfos:TextField;
      
      private var mVersionUpdate:TextField;
      
      private var mRefreshFPS:TextField;
      
      private var mMinimieButton:MenuButton;
      
      private var mStatsButton:MenuButton;
      
      private var mMemoryProfilerButton:MenuButton;
      
      private var mInternalEventButton:MenuButton;
      
      private var mFunctionTimeButton:MenuButton;
      
      private var mLoaderProfilerButton:MenuButton;
      
      private var mMonsters:MenuButton;
      
      private var mSaveFilters:MenuButton;
      
      private var mAnalyticsButton:MenuButton;
      
      private var mSaveLocalizationButton:MenuButton;
      
      private var mPasteLocalizationButton:MenuButton;
      
      private var mUpdateVersionButton:MenuButton;
      
      private var mOpacityDown:MenuButton;
      
      private var mOpacitySymbol:MenuButton;
      
      private var mOpacityUp:MenuButton;
      
      private var mRefreshDown:MenuButton;
      
      private var mRefreshSymbol:MenuButton;
      
      private var mRefreshUp:MenuButton;
      
      private var mButtonDict:Dictionary;
      
      private var mEnterTime:int = 0;
      
      private var myformat:TextFormat = null;
      
      private var myglow:GlowFilter = null;
      
      private var _loadFile:FileReference;
      
      private var mSWFListOutput:FileReference;
      
      private var mBlend:Boolean = false;
      
      private var mLastTime:int;
      
      public function Configuration()
      {
         this.mButtonDict = new Dictionary(true);
         this.mSWFListOutput = new FileReference();
         super();
         mInstance = this;
         this.Init();
         this.mEnterTime = getTimer();
         Analytics.Track("Tab","Config","Config Enter");
      }
      
      private static function loadBytesHandler(param1:Event) : void
      {
         var _loc2_:LoaderInfo = param1.target as LoaderInfo;
         _loc2_.removeEventListener(Event.COMPLETE,loadBytesHandler);
         var _loc3_:Bitmap = _loc2_.content as Bitmap;
         SkinManager.SetSkin(_loc3_.bitmapData);
         if(mInstance != null)
         {
            mInstance.UpdateSkin();
         }
      }
      
      public static function IsSamplingRequired() : Boolean
      {
         if(Configuration._PROFILE_MEMORY || Configuration._PROFILE_FUNCTION || Configuration._PROFILE_LOADERS || Configuration._PROFILE_INTERNAL_EVENTS || Configuration.COMMAND_LINE_SAMPLING_LSTENER)
         {
            return true;
         }
         if(Commands.mIsCollectingSamplesData)
         {
            return true;
         }
         return false;
      }
      
      public static function Load() : void
      {
         var _loc2_:ByteArray = null;
         var _loc3_:Loader = null;
         trace("TheMiner : Loading configs...");
         var _loc1_:SharedObject = SharedObject.getLocal("Skin");
         if(_loc1_ != null)
         {
            if(_loc1_.data["skin"] != undefined)
            {
               _loc2_ = _loc1_.data["skin"] as ByteArray;
               if(_loc2_ != null)
               {
                  _loc3_ = new Loader();
                  _loc3_.contentLoaderInfo.addEventListener(Event.COMPLETE,loadBytesHandler);
                  _loc3_.loadBytes(_loc2_);
               }
            }
         }
         PROFILE_MEMORY = false;
         PROFILE_INTERNAL_EVENTS = false;
         PROFILE_FUNCTION = false;
         PROFILE_LOADERS = false;
         SAVE_FILTERS = false;
         PROFILE_SOCKETS = false;
         PROFILE_MEMGRAPH = false;
         PROFILE_MONSTER = false;
         ANALYTICS_ENABLED = true;
         if(!mSaveObj)
         {
            return;
         }
         if(mSaveObj.data["SAVED_FILTER_MEMORY"] != undefined)
         {
            SAVED_FILTER_MEMORY = mSaveObj.data["SAVED_FILTER_MEMORY"];
         }
         if(mSaveObj.data["SAVED_FILTER_PERFORMANCE"] != undefined)
         {
            SAVED_FILTER_PERFORMANCE = mSaveObj.data["SAVED_FILTER_PERFORMANCE"];
         }
         if(mSaveObj.data["SAVED_FILTER_LOADER"] != undefined)
         {
            SAVED_FILTER_LOADER = mSaveObj.data["SAVED_FILTER_LOADER"];
         }
         if(mSaveObj.data["SAVED_FILTER_USEREVENT"] != undefined)
         {
            SAVED_FILTER_USEREVENT = mSaveObj.data["SAVED_FILTER_USEREVENT"];
         }
         if(mSaveObj.data[SETUP_START_MINIMIZED] != undefined)
         {
            START_MINIMIZED = mSaveObj.data[SETUP_START_MINIMIZED];
         }
         if(mSaveObj.data[SETUP_MEMORY_PROFILING_ENABLED] != undefined)
         {
            PROFILE_MEMORY = mSaveObj.data[SETUP_MEMORY_PROFILING_ENABLED];
         }
         if(mSaveObj.data[SETUP_INTERNALEVENT_PROFILING_ENABLED] != undefined)
         {
            PROFILE_INTERNAL_EVENTS = mSaveObj.data[SETUP_INTERNALEVENT_PROFILING_ENABLED];
         }
         if(mSaveObj.data[SETUP_FUNCTION_PROFILING_ENABLED] != undefined)
         {
            PROFILE_FUNCTION = mSaveObj.data[SETUP_FUNCTION_PROFILING_ENABLED];
         }
         if(mSaveObj.data[SETUP_LOADERS_PROFILING_ENABLED] != undefined)
         {
            PROFILE_LOADERS = mSaveObj.data[SETUP_LOADERS_PROFILING_ENABLED];
         }
         if(mSaveObj.data[SETUP_LOADERS_SAVE_FILTERS] != undefined)
         {
            SAVE_FILTERS = mSaveObj.data[SETUP_LOADERS_SAVE_FILTERS];
         }
         if(mSaveObj.data[SETUP_SOCKETS_PROFILING_ENABLED] != undefined)
         {
            PROFILE_SOCKETS = mSaveObj.data[SETUP_SOCKETS_PROFILING_ENABLED];
         }
         if(mSaveObj.data[SETUP_MEMGRAPH_PROFILING_ENABLED] != undefined)
         {
            PROFILE_MEMGRAPH = mSaveObj.data[SETUP_MEMGRAPH_PROFILING_ENABLED];
         }
         if(mSaveObj.data[SETUP_MONSTER_DEBUGGER] != undefined)
         {
            PROFILE_MONSTER = mSaveObj.data[SETUP_MONSTER_DEBUGGER];
         }
         if(mSaveObj.data[SETUP_ANALYTICS_ENABLED] != undefined)
         {
            ANALYTICS_ENABLED = mSaveObj.data[SETUP_ANALYTICS_ENABLED];
         }
         if(mSaveObj.data[SETUP_FRAME_UPDATE] != undefined)
         {
            FRAME_UPDATE_SPEED = mSaveObj.data[SETUP_FRAME_UPDATE];
         }
         if(mSaveObj.data[SETUP_OPACITY] != undefined)
         {
            INTERFACE_OPACITY = mSaveObj.data[SETUP_OPACITY];
         }
      }
      
      internal static function Save() : void
      {
         trace("TheMiner : Saving!");
         if(!mSaveObj)
         {
            try
            {
               mSaveObj = SharedObject.getLocal("TheMinerConfig");
            }
            catch(err:Error)
            {
            }
         }
         if(!mSaveObj)
         {
            return;
         }
         mSaveObj.clear();
         mSaveObj.setProperty(SETUP_START_MINIMIZED,START_MINIMIZED);
         mSaveObj.setProperty(SETUP_MEMORY_PROFILING_ENABLED,PROFILE_MEMORY);
         mSaveObj.setProperty(SETUP_INTERNALEVENT_PROFILING_ENABLED,PROFILE_INTERNAL_EVENTS);
         mSaveObj.setProperty(SETUP_FUNCTION_PROFILING_ENABLED,PROFILE_FUNCTION);
         mSaveObj.setProperty(SETUP_LOADERS_PROFILING_ENABLED,PROFILE_LOADERS);
         mSaveObj.setProperty(SETUP_LOADERS_SAVE_FILTERS,SAVE_FILTERS);
         mSaveObj.setProperty(SETUP_SOCKETS_PROFILING_ENABLED,PROFILE_SOCKETS);
         mSaveObj.setProperty(SETUP_MEMGRAPH_PROFILING_ENABLED,PROFILE_MEMGRAPH);
         mSaveObj.setProperty(SETUP_MONSTER_DEBUGGER,PROFILE_MONSTER);
         mSaveObj.setProperty(SETUP_ANALYTICS_ENABLED,ANALYTICS_ENABLED);
         mSaveObj.setProperty(SETUP_FRAME_UPDATE,FRAME_UPDATE_SPEED);
         mSaveObj.setProperty(SETUP_OPACITY,INTERFACE_OPACITY);
         if(SAVE_FILTERS)
         {
            mSaveObj.setProperty("SAVED_FILTER_MEMORY",SAVED_FILTER_MEMORY);
            mSaveObj.setProperty("SAVED_FILTER_PERFORMANCE",SAVED_FILTER_PERFORMANCE);
            mSaveObj.setProperty("SAVED_FILTER_LOADER",SAVED_FILTER_LOADER);
            mSaveObj.setProperty("SAVED_FILTER_USEREVENT",SAVED_FILTER_USEREVENT);
         }
         else
         {
            mSaveObj.setProperty("SAVED_FILTER_MEMORY","");
            mSaveObj.setProperty("SAVED_FILTER_PERFORMANCE","");
            mSaveObj.setProperty("SAVED_FILTER_LOADER","");
            mSaveObj.setProperty("SAVED_FILTER_USEREVENT","");
         }
         var _loc1_:* = "";
         if(START_MINIMIZED)
         {
            _loc1_ += "_";
         }
         if(PROFILE_MEMORY)
         {
            _loc1_ += "M";
         }
         if(PROFILE_INTERNAL_EVENTS)
         {
            _loc1_ += "E";
         }
         if(PROFILE_FUNCTION)
         {
            _loc1_ += "F";
         }
         if(PROFILE_LOADERS)
         {
            _loc1_ += "L";
         }
         if(PROFILE_SOCKETS)
         {
            _loc1_ += "S";
         }
         if(PROFILE_MEMGRAPH)
         {
            _loc1_ += "G";
         }
         Analytics.Track("Action","SaveConfig","Save:" + _loc1_);
         mSaveObj.flush();
      }
      
      public static function get INTERFACE_OPACITY() : int
      {
         return _INTERFACE_OPACITY;
      }
      
      public static function set INTERFACE_OPACITY(param1:int) : void
      {
         _INTERFACE_OPACITY = param1;
      }
      
      public static function get FRAME_UPDATE_SPEED() : int
      {
         return _FRAME_UPDATE_SPEED;
      }
      
      public static function set FRAME_UPDATE_SPEED(param1:int) : void
      {
         _FRAME_UPDATE_SPEED = param1;
      }
      
      public static function get ANALYTICS_ENABLED() : Boolean
      {
         return _ANALYTICS_ENABLED;
      }
      
      public static function set ANALYTICS_ENABLED(param1:Boolean) : void
      {
         _ANALYTICS_ENABLED = param1;
      }
      
      public static function get PROFILE_MEMORY() : Boolean
      {
         return _PROFILE_MEMORY;
      }
      
      public static function set PROFILE_MEMORY(param1:Boolean) : void
      {
         _PROFILE_MEMORY = param1;
      }
      
      public static function get PROFILE_FUNCTION() : Boolean
      {
         return _PROFILE_FUNCTION;
      }
      
      public static function set PROFILE_FUNCTION(param1:Boolean) : void
      {
         _PROFILE_FUNCTION = param1;
      }
      
      public static function get SAVE_FILTERS() : Boolean
      {
         return _SAVE_FILTERS;
      }
      
      public static function set SAVE_FILTERS(param1:Boolean) : void
      {
         _SAVE_FILTERS = param1;
      }
      
      public static function get PROFILE_INTERNAL_EVENTS() : Boolean
      {
         return _PROFILE_INTERNAL_EVENTS;
      }
      
      public static function set PROFILE_INTERNAL_EVENTS(param1:Boolean) : void
      {
         _PROFILE_INTERNAL_EVENTS = param1;
      }
      
      public static function get PROFILE_LOADERS() : Boolean
      {
         return _PROFILE_LOADERS;
      }
      
      public static function set PROFILE_LOADERS(param1:Boolean) : void
      {
         _PROFILE_LOADERS = param1;
      }
      
      public static function get PROFILE_SOCKETS() : Boolean
      {
         return _PROFILE_SOCKETS;
      }
      
      public static function set PROFILE_SOCKETS(param1:Boolean) : void
      {
         _PROFILE_SOCKETS = param1;
      }
      
      public static function get START_MINIMIZED() : Boolean
      {
         return _START_MINIMIZED;
      }
      
      public static function set START_MINIMIZED(param1:Boolean) : void
      {
         _START_MINIMIZED = param1;
      }
      
      public static function get PROFILE_MEMGRAPH() : Boolean
      {
         return _PROFILE_MEMGRAPH;
      }
      
      public static function set PROFILE_MEMGRAPH(param1:Boolean) : void
      {
         _PROFILE_MEMGRAPH = param1;
      }
      
      public static function get PROFILE_MONSTER() : Boolean
      {
         return _PROFILE_MONSTER;
      }
      
      public static function set PROFILE_MONSTER(param1:Boolean) : void
      {
         _PROFILE_MONSTER = param1;
      }
      
      public function UpdateSkin() : void
      {
         var _loc2_:TextFormat = null;
         var _loc1_:int = int(Stage2D.stage.stageWidth);
         this.graphics.clear();
         this.graphics.beginFill(SkinManager.COLOR_GLOBAL_BG,1);
         this.graphics.drawRect(0,16,_loc1_,Number(Stage2D.stage.stageHeight) - 18);
         this.graphics.endFill();
         this.graphics.beginFill(SkinManager.COLOR_GLOBAL_LINE_DARK,0.6);
         this.graphics.drawRect(0,17,_loc1_,1);
         this.graphics.endFill();
         this.graphics.beginFill(SkinManager.COLOR_GLOBAL_LINE,0.8);
         this.graphics.drawRect(0,16,_loc1_,1);
         this.graphics.endFill();
         if(this.mRefreshFPS != null)
         {
            this.myformat.color = SkinManager.COLOR_GLOBAL_TEXT;
            this.myglow.color = SkinManager.COLOR_GLOBAL_TEXT_GLOW;
            this.mRefreshFPS.defaultTextFormat = this.myformat;
            this.mInfos.defaultTextFormat = this.myformat;
            this.mRefreshFPS.filters = [this.myglow];
            this.mInfos.filters = [this.myglow];
            this.mVersionUpdate.filters = [this.myglow];
            _loc2_ = new TextFormat("_sans",14,SkinManager.COLOR_GLOBAL_TEXT,true);
            this.mVersionUpdate.defaultTextFormat = _loc2_;
            this.mVersionUpdate.textColor = SkinManager.COLOR_SELECTION_OVERLAY;
            this.mVersionUpdate.text = "";
            this.mVersionUpdate.visible = false;
         }
      }
      
      private function Init() : void
      {
         this.alpha = Number(Commands.Opacity) / 10;
         this.mouseEnabled = false;
         var _loc1_:int = int(Stage2D.stage.stageWidth);
         var _loc2_:Sprite = new Sprite();
         this.myformat = new TextFormat("_sans",11,SkinManager.COLOR_GLOBAL_TEXT,false);
         this.myglow = new GlowFilter(SkinManager.COLOR_GLOBAL_TEXT_GLOW,1,2,2,3,2,false,false);
         this.mRefreshFPS = new TextField();
         this.mRefreshFPS.mouseEnabled = false;
         this.mRefreshFPS.autoSize = TextFieldAutoSize.LEFT;
         this.mRefreshFPS.defaultTextFormat = this.myformat;
         this.mRefreshFPS.selectable = false;
         this.mRefreshFPS.x = 135;
         this.mRefreshFPS.y = 20 + 14;
         this.mRefreshFPS.text = Commands.RefreshRate.toString();
         this.mRefreshFPS.filters = [this.myglow];
         addChild(this.mRefreshFPS);
         this.mVersionUpdate = new TextField();
         this.mVersionUpdate.mouseEnabled = false;
         this.mVersionUpdate.selectable = false;
         this.mVersionUpdate.width = 200;
         this.mVersionUpdate.x = 2;
         addChild(this.mVersionUpdate);
         this.mVersionUpdate.visible = false;
         var _loc3_:TextField = new TextField();
         this.mInfos = new TextField();
         this.mInfos.mouseEnabled = false;
         this.mInfos.autoSize = TextFieldAutoSize.LEFT;
         this.mInfos.defaultTextFormat = this.myformat;
         this.mInfos.selectable = false;
         _loc3_.defaultTextFormat = this.myformat;
         this.mInfos.x = 2;
         this.mInfos.y = 20;
         this.mInfos.appendText(Localization.Lbl_Cfg_Opacity + ":\n");
         _loc3_.text = Localization.Lbl_Cfg_Opacity;
         var _loc4_:int = _loc3_.textWidth + 10;
         var _loc5_:int = this.mInfos.y + 3;
         this.mOpacityDown = new MenuButton(_loc4_,_loc5_,MenuButton.ICON_ARROW_DOWN,null,-1,Localization.Lbl_Cfg_ClickTransparent,true);
         addChild(this.mOpacityDown);
         _loc4_ += 16;
         this.mOpacitySymbol = new MenuButton(_loc4_,_loc5_,MenuButton.ICON_GRADIENT,null,-1,"",false,null,false);
         addChild(this.mOpacitySymbol);
         _loc4_ += 16;
         this.mOpacityUp = new MenuButton(_loc4_,_loc5_,MenuButton.ICON_ARROW_UP,null,-1,Localization.Lbl_Cfg_ClickOpaque,true);
         addChild(this.mOpacityUp);
         _loc3_.text = Localization.Lbl_Cfg_RefreshSpeed + "(" + Localization.Lbl_Cfg_Fps + "):";
         this.mInfos.appendText(_loc3_.text + "\n");
         _loc4_ = _loc3_.textWidth + 23;
         this.mRefreshFPS.x = _loc4_ - 18;
         _loc5_ += 14;
         this.mRefreshDown = new MenuButton(_loc4_,_loc5_,MenuButton.ICON_ARROW_DOWN,null,-1,Localization.Lbl_Cfg_ClickRefreshLess,true);
         addChild(this.mRefreshDown);
         _loc4_ += 16;
         this.mRefreshSymbol = new MenuButton(_loc4_,_loc5_,MenuButton.ICON_PERFORMANCE,null,-1,"",false,null,false);
         addChild(this.mRefreshSymbol);
         _loc4_ += 16;
         this.mRefreshUp = new MenuButton(_loc4_,_loc5_,MenuButton.ICON_ARROW_UP,null,-1,Localization.Lbl_Cfg_ClickRefreshMore,true);
         addChild(this.mRefreshUp);
         _loc5_ += 14;
         this.mInfos.appendText(Localization.Lbl_Cfg_SelectTheProfilers);
         _loc5_ += 14;
         this.mInfos.filters = [this.myglow];
         addChild(this.mInfos);
         var _loc6_:int = 4;
         this.mMinimieButton = new MenuButton(_loc6_,_loc5_,MenuButton.ICON_MINIMIZE,null,-1,Localization.Lbl_Cfg_IfActivatedMinimized,true,Localization.Lbl_Cfg_ToggleSeeWholeMenu);
         addChild(this.mMinimieButton);
         this.mButtonDict[this.mMinimieButton] = this.mMinimieButton;
         _loc6_ += 16;
         if(START_MINIMIZED)
         {
            this.mMinimieButton.OnClick(null);
         }
         this.mStatsButton = new MenuButton(_loc6_,_loc5_,MenuButton.ICON_STATS,null,-1,Localization.Lbl_Cfg_ToggleGraphEnabled,true,Localization.Lbl_Cfg_ToggleGraphDisabled);
         addChild(this.mStatsButton);
         this.mButtonDict[this.mStatsButton] = this.mStatsButton;
         _loc6_ += 16;
         if(PROFILE_MEMGRAPH)
         {
            this.mStatsButton.OnClick(null);
         }
         this.mMemoryProfilerButton = new MenuButton(_loc6_,_loc5_,MenuButton.ICON_MEMORY,null,-1,Localization.Lbl_Cfg_ToggleMemoryEnabled,true,Localization.Lbl_Cfg_ToggleMemoryDisabled);
         addChild(this.mMemoryProfilerButton);
         this.mButtonDict[this.mMemoryProfilerButton] = this.mMemoryProfilerButton;
         _loc6_ += 16;
         if(PROFILE_MEMORY)
         {
            this.mMemoryProfilerButton.OnClick(null);
         }
         this.mInternalEventButton = new MenuButton(_loc6_,_loc5_,MenuButton.ICON_EVENTS,null,-1,Localization.Lbl_Cfg_ToggleInternalEnabled,true,Localization.Lbl_Cfg_ToggleInternalDisabled);
         addChild(this.mInternalEventButton);
         this.mButtonDict[this.mInternalEventButton] = this.mInternalEventButton;
         _loc6_ += 16;
         if(PROFILE_INTERNAL_EVENTS)
         {
            this.mInternalEventButton.OnClick(null);
         }
         this.mFunctionTimeButton = new MenuButton(_loc6_,_loc5_,MenuButton.ICON_PERFORMANCE,null,-1,Localization.Lbl_Cfg_TogglePerformanceEnabled,true,Localization.Lbl_Cfg_TogglePerformanceDisabled);
         addChild(this.mFunctionTimeButton);
         this.mButtonDict[this.mFunctionTimeButton] = this.mFunctionTimeButton;
         _loc6_ += 16;
         if(PROFILE_FUNCTION)
         {
            this.mFunctionTimeButton.OnClick(null);
         }
         this.mLoaderProfilerButton = new MenuButton(_loc6_,_loc5_,MenuButton.ICON_LOADER,null,-1,Localization.Lbl_Cfg_ToggleLoaderEnabled,true,Localization.Lbl_Cfg_ToggleLoaderDisabled);
         addChild(this.mLoaderProfilerButton);
         this.mButtonDict[this.mLoaderProfilerButton] = this.mLoaderProfilerButton;
         _loc6_ += 16;
         if(PROFILE_LOADERS)
         {
            this.mLoaderProfilerButton.OnClick(null);
         }
         this.mMonsters = new MenuButton(_loc6_,_loc5_,MenuButton.ICON_MONSTER,null,-1,Localization.Lbl_Cfg_ToggleMonsterEnabled,true,Localization.Lbl_Cfg_ToggleMonsterDisabled);
         addChild(this.mMonsters);
         this.mButtonDict[this.mMonsters] = this.mMonsters;
         _loc6_ += 16;
         if(_PROFILE_MONSTER)
         {
            this.mMonsters.OnClick(null);
         }
         this.mSaveFilters = new MenuButton(_loc6_,_loc5_,MenuButton.ICON_FILTER,null,-1,Localization.Lbl_Cfg_SaveFilters,true,Localization.Lbl_Cfg_SaveFilters);
         addChild(this.mSaveFilters);
         this.mButtonDict[this.mSaveFilters] = this.mSaveFilters;
         _loc6_ += 16;
         if(_SAVE_FILTERS)
         {
            this.mSaveFilters.OnClick(null);
         }
         _loc5_ += 17;
         this.mInfos = new TextField();
         this.mInfos.mouseEnabled = false;
         this.mInfos.autoSize = TextFieldAutoSize.LEFT;
         this.mInfos.defaultTextFormat = this.myformat;
         this.mInfos.selectable = false;
         this.mInfos.appendText(Localization.Lbl_Cfg_InfoSelfAnalytics);
         this.mInfos.filters = [this.myglow];
         this.mInfos.x = 2;
         this.mInfos.y = _loc5_;
         addChild(this.mInfos);
         _loc3_.text = Localization.Lbl_Cfg_InfoSelfAnalytics;
         _loc4_ = _loc3_.textWidth + 8;
         this.mAnalyticsButton = new MenuButton(_loc4_,this.mInfos.y + 4,MenuButton.ICON_CLIPBOARD,null,-1,Localization.Lbl_Cfg_ToggleAnalyticsEnabled,true,Localization.Lbl_Cfg_ToggleAnalyticsDisabled);
         addChild(this.mAnalyticsButton);
         this.mButtonDict[this.mAnalyticsButton] = this.mAnalyticsButton;
         this.mInfos.appendText("\t\t" + Localization.Lbl_Cfg_InfoSelfAnalyticsMore);
         _loc6_ += 16;
         if(_ANALYTICS_ENABLED)
         {
            this.mAnalyticsButton.OnClick(null);
         }
         ToolTip.Text = Localization.Lbl_Configs;
         _loc5_ += 17;
         _loc3_.text = Localization.Lbl_Cfg_InfoLoadSkin;
         _loc6_ = _loc3_.textWidth + 10;
         _loc5_ += 15;
         this.mUpdateVersionButton = new MenuButton(7,_loc5_,MenuButton.ICON_LINK,null,-1,"http://www.sociodox.com/theminer/",true,"");
         addChild(this.mUpdateVersionButton);
         this.mUpdateVersionButton.visible = false;
         Security.loadPolicyFile("http://www.sociodox.com/crossdomain.xml");
         var _loc7_:URLStream = new URLStream();
         _loc7_.addEventListener(Event.COMPLETE,this.OnVersionCompleted);
         _loc7_.load(new URLRequest("http://www.sociodox.com/theminer/version.txt?" + Math.random() * int.MAX_VALUE));
         this.UpdateSkin();
      }
      
      private function startLoadingFile() : void
      {
         this._loadFile = new FileReference();
         this._loadFile.addEventListener(Event.SELECT,this.selectHandler);
         var _loc1_:FileFilter = new FileFilter("Images: (*.jpeg, *.jpg, *.gif, *.png)","*.jpeg; *.jpg; *.gif; *.png");
         this._loadFile.browse([_loc1_]);
      }
      
      private function selectHandler(param1:Event) : void
      {
         this._loadFile.removeEventListener(Event.SELECT,this.selectHandler);
         this._loadFile.addEventListener(Event.COMPLETE,this.loadCompleteHandler);
         this._loadFile.load();
      }
      
      private function loadCompleteHandler(param1:Event) : void
      {
         this._loadFile.removeEventListener(Event.COMPLETE,this.loadCompleteHandler);
         var _loc2_:Loader = new Loader();
         _loc2_.contentLoaderInfo.addEventListener(Event.COMPLETE,loadBytesHandler);
         var _loc3_:SharedObject = SharedObject.getLocal("Skin");
         _loc3_.setProperty("skin",this._loadFile.data);
         _loc3_.flush();
         _loc2_.loadBytes(this._loadFile.data);
      }
      
      private function OnSaveLocalization(param1:Event) : void
      {
         var _loc3_:* = undefined;
         var _loc2_:String = "";
         for(_loc3_ in Object(Localization))
         {
            _loc2_ += _loc3_ + "\n";
         }
         System.setClipboard(_loc2_);
         param1.stopImmediatePropagation();
         param1.stopPropagation();
      }
      
      private function OnPasteLocalization(param1:Event) : void
      {
         param1.stopImmediatePropagation();
         param1.stopPropagation();
      }
      
      private function OnLoadSkin(param1:Event) : void
      {
         this.startLoadingFile();
         trace("LoadSkin");
      }
      
      private function OnDonateOut(param1:MouseEvent) : void
      {
      }
      
      private function OnDonateOver(param1:MouseEvent) : void
      {
      }
      
      private function OnDonate(param1:MouseEvent) : void
      {
      }
      
      public function Update() : void
      {
         var _loc1_:URLRequest = null;
         if(this.mOpacityDown.mIsSelected)
         {
            if(Commands.Opacity > 3)
            {
               --Commands.Opacity;
            }
            this.alpha = Number(Commands.Opacity) / 10;
            this.mOpacityDown.Reset();
            Configuration.INTERFACE_OPACITY = Commands.Opacity;
            Save();
         }
         if(this.mOpacityUp.mIsSelected)
         {
            if(Commands.Opacity <= 9)
            {
               ++Commands.Opacity;
            }
            this.alpha = Number(Commands.Opacity) / 10;
            this.mOpacityUp.Reset();
            Configuration.INTERFACE_OPACITY = Commands.Opacity;
            Save();
         }
         if(this.mRefreshDown.mIsSelected)
         {
            if(Commands.RefreshRate > 1)
            {
               --Commands.RefreshRate;
            }
            this.mRefreshFPS.text = Commands.RefreshRate.toString();
            this.mRefreshDown.Reset();
            Configuration.FRAME_UPDATE_SPEED = Commands.RefreshRate;
            Save();
         }
         if(this.mRefreshUp.mIsSelected)
         {
            if(Commands.RefreshRate < 60)
            {
               ++Commands.RefreshRate;
            }
            this.mRefreshFPS.text = Commands.RefreshRate.toString();
            this.mRefreshUp.Reset();
            Configuration.FRAME_UPDATE_SPEED = Commands.RefreshRate;
            Save();
         }
         if(this.mMemoryProfilerButton.mIsSelected != Configuration.PROFILE_MEMORY)
         {
            Configuration.PROFILE_MEMORY = this.mMemoryProfilerButton.mIsSelected;
            Save();
         }
         if(this.mMinimieButton.mIsSelected != Configuration.START_MINIMIZED)
         {
            Configuration.START_MINIMIZED = this.mMinimieButton.mIsSelected;
            Save();
         }
         if(this.mStatsButton.mIsSelected != Configuration.PROFILE_MEMGRAPH)
         {
            Configuration.PROFILE_MEMGRAPH = this.mStatsButton.mIsSelected;
            Save();
         }
         if(this.mInternalEventButton.mIsSelected != Configuration.PROFILE_INTERNAL_EVENTS)
         {
            Configuration.PROFILE_INTERNAL_EVENTS = this.mInternalEventButton.mIsSelected;
            Save();
         }
         if(this.mFunctionTimeButton.mIsSelected != Configuration.PROFILE_FUNCTION)
         {
            Configuration.PROFILE_FUNCTION = this.mFunctionTimeButton.mIsSelected;
            Save();
         }
         if(this.mSaveFilters.mIsSelected != Configuration.SAVE_FILTERS)
         {
            Configuration.SAVE_FILTERS = this.mSaveFilters.mIsSelected;
            Save();
         }
         if(this.mLoaderProfilerButton.mIsSelected != Configuration.PROFILE_LOADERS)
         {
            Configuration.PROFILE_LOADERS = this.mLoaderProfilerButton.mIsSelected;
            Save();
         }
         if(this.mMonsters.mIsSelected != Configuration.PROFILE_MONSTER)
         {
            Configuration.PROFILE_MONSTER = this.mMonsters.mIsSelected;
            Save();
         }
         if(this.mAnalyticsButton.mIsSelected != Configuration.ANALYTICS_ENABLED)
         {
            Configuration.ANALYTICS_ENABLED = this.mAnalyticsButton.mIsSelected;
            if(this.mAnalyticsButton.mIsSelected)
            {
               Analytics.Track("Process","PlayerInfo","vmVersion: " + System.vmVersion);
               Analytics.Track("Process","PlayerInfo","language: " + Capabilities.language);
               Analytics.Track("Process","PlayerInfo","os: " + Capabilities.os);
               Analytics.Track("Process","PlayerInfo","version: " + Capabilities.version);
               Analytics.Track("Process","PlayerInfo","screenResolution: " + Capabilities.screenResolutionX + "x" + Capabilities.screenResolutionY);
            }
            Save();
         }
         if(this.mVersionUpdate.visible)
         {
            this.mUpdateVersionButton.visible = true;
            this.mUpdateVersionButton.x = this.mVersionUpdate.x + this.mVersionUpdate.textWidth + 5;
            if(this.mUpdateVersionButton.mIsSelected)
            {
               Analytics.Track("Process","Update");
               _loc1_ = new URLRequest(this.mUpdateVersionButton.mToolTipText);
               navigateToURL(_loc1_,"_self");
               this.mUpdateVersionButton.mIsSelected = false;
            }
         }
         if(this.mVersionUpdate != null)
         {
            this.mVersionUpdate.y = this.mInfos.y + this.mInfos.textHeight + 15;
            this.mUpdateVersionButton.y = this.mVersionUpdate.y + 5;
         }
         if(getTimer() > this.mLastTime + 250)
         {
            this.mLastTime = getTimer();
            if(this.mBlend)
            {
               this.mUpdateVersionButton.blendMode = BlendMode.HARDLIGHT;
            }
            else
            {
               this.mUpdateVersionButton.blendMode = BlendMode.NORMAL;
            }
            this.mBlend = !this.mBlend;
         }
      }
      
      public function Dispose() : void
      {
         this.graphics.clear();
         this.mInfos = null;
         var _loc1_:int = int((getTimer() - this.mEnterTime) / 1000) * 1000;
         Analytics.Track("Tab","Config","Config Exit",_loc1_);
         this.mStatsButton.Dispose();
         this.mStatsButton = null;
         this.mMemoryProfilerButton.Dispose();
         this.mMemoryProfilerButton = null;
         this.mInternalEventButton.Dispose();
         this.mInternalEventButton = null;
         this.mFunctionTimeButton.Dispose();
         this.mFunctionTimeButton = null;
         this.mLoaderProfilerButton.Dispose();
         this.mLoaderProfilerButton = null;
         this.mMonsters.Dispose();
         this.mMonsters = null;
         this.mAnalyticsButton.Dispose();
         this.mAnalyticsButton = null;
         this.mButtonDict = null;
      }
      
      private function OnVersionCompleted(param1:Event) : void
      {
         var _loc3_:URLStream = null;
         var _loc4_:String = null;
         var _loc5_:Array = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:Array = null;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:Boolean = false;
         var _loc2_:Boolean = Configuration.IsSamplingRequired();
         pauseSampling();
         try
         {
            _loc3_ = param1.target as URLStream;
            if(_loc3_ != null)
            {
               _loc4_ = _loc3_.readUTFBytes(_loc3_.bytesAvailable);
               _loc5_ = _loc4_.split(".");
               _loc6_ = int(_loc5_[0]);
               _loc7_ = int(_loc5_[1]);
               _loc8_ = int(_loc5_[2]);
               _loc9_ = "1.4.01".split(".");
               _loc10_ = int(_loc9_[0]);
               _loc11_ = int(_loc9_[1]);
               _loc12_ = int(_loc9_[2]);
               _loc13_ = false;
               if(_loc6_ > _loc10_)
               {
                  _loc13_ = true;
               }
               else if(_loc6_ == _loc10_)
               {
                  if(_loc7_ > _loc11_)
                  {
                     _loc13_ = true;
                  }
                  else if(_loc7_ == _loc11_)
                  {
                     if(_loc8_ > _loc12_)
                     {
                        _loc13_ = true;
                     }
                  }
               }
               if(_loc13_)
               {
                  this.mVersionUpdate.visible = true;
                  this.mVersionUpdate.text = Localization.Lbl_Cfg_NewVersionAvailable + "(" + _loc6_ + "." + _loc7_ + "." + _loc8_ + "):";
                  this.mVersionUpdate.width = this.mVersionUpdate.textWidth;
               }
            }
         }
         catch(err:Error)
         {
         }
         if(_loc2_)
         {
            startSampling();
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

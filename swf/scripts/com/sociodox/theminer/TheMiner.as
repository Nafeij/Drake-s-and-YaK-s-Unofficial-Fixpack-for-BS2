package com.sociodox.theminer
{
   import com.demonsters.debugger.MonsterDebugger;
   import com.junkbyte.console.Cc;
   import com.sociodox.theminer.data.SWFEntry;
   import com.sociodox.theminer.data.UserEventEntry;
   import com.sociodox.theminer.event.ChangeToolEvent;
   import com.sociodox.theminer.manager.Analytics;
   import com.sociodox.theminer.manager.Commands;
   import com.sociodox.theminer.manager.LoaderAnalyser;
   import com.sociodox.theminer.manager.Localization;
   import com.sociodox.theminer.manager.OptionInterface;
   import com.sociodox.theminer.manager.Options;
   import com.sociodox.theminer.manager.SampleAnalyzer;
   import com.sociodox.theminer.manager.SkinManager;
   import com.sociodox.theminer.manager.Stage2D;
   import com.sociodox.theminer.manager.UserEventManager;
   import com.sociodox.theminer.window.Configuration;
   import com.sociodox.theminer.window.ConsoleContainer;
   import com.sociodox.theminer.window.FlashStats;
   import com.sociodox.theminer.window.IWindow;
   import com.sociodox.theminer.window.InstancesLifeCycle;
   import com.sociodox.theminer.window.InternalEventsProfiler;
   import com.sociodox.theminer.window.LoaderProfiler;
   import com.sociodox.theminer.window.MouseListeners;
   import com.sociodox.theminer.window.Overdraw;
   import com.sociodox.theminer.window.PerformanceProfiler;
   import com.sociodox.theminer.window.SamplerProfiler;
   import com.sociodox.theminer.window.UserEvent;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.LoaderInfo;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.ContextMenuEvent;
   import flash.events.Event;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.net.FileReference;
   import flash.net.LocalConnection;
   import flash.net.SharedObject;
   import flash.sampler.clearSamples;
   import flash.sampler.pauseSampling;
   import flash.sampler.setSamplerCallback;
   import flash.sampler.startSampling;
   import flash.sampler.stopSampling;
   import flash.system.Capabilities;
   import flash.system.System;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.trace.Trace;
   import flash.ui.Mouse;
   import flash.utils.Timer;
   import flash.utils.getQualifiedClassName;
   import flash.utils.getTimer;
   
   public class TheMiner extends Sprite
   {
      
      internal static var mInstance:TheMiner;
      
      private static var mUsrEventMgr:UserEventManager = new UserEventManager();
       
      
      internal var mIsPreloadSWFLaunched:Boolean;
      
      private var MainSprite:Sprite = null;
      
      private var mInitialized:Boolean = false;
      
      private var mHookClass:String = "";
      
      private var mTraceFiles:Boolean = false;
      
      private var _frames:int = 0;
      
      private var _startTime:int = 0;
      
      private var mLastMemoryVal:int = 0;
      
      private var mAddChildFrameCounter:int = 0;
      
      private var MAX__ONTOP_ATTEMPS:int = 20;
      
      private var mSWFList:Array;
      
      private var mSWFListOutput:FileReference;
      
      private var mSavingIndex:int = 0;
      
      private var mKeepOnTopTimer:Timer;
      
      private var mNextTool:Class = null;
      
      private var mMinimize:Boolean = false;
      
      private var ms_prev:int;
      
      private var mCurrentTool:Class = null;
      
      private var mCurrentWindow:IWindow;
      
      public function TheMiner()
      {
         this.mSWFList = new Array();
         this.mSWFListOutput = new FileReference();
         super();
         mInstance = this;
         trace("TheMiner : Starting TheMiner " + "1.4.01");
         SampleAnalyzer.Init(this);
         addEventListener(Event.ADDED_TO_STAGE,this.init);
      }
      
      public static function AddBasicUserEvent(param1:String = null, param2:* = null) : UserEventEntry
      {
         return mUsrEventMgr.AddCustomUserEvent(param1,null,String(param2),null,null,-1,4278190080,0,true,false);
      }
      
      public static function AddCustomUserEvent(param1:String = null, param2:String = null, param3:* = null, param4:* = null, param5:String = null, param6:Number = -1, param7:uint = 4278190080, param8:int = 0, param9:Boolean = true, param10:Boolean = false) : UserEventEntry
      {
         return mUsrEventMgr.AddCustomUserEvent(param1,param2,String(param3),String(param4),param5,param6,param7,param8,param9,param10);
      }
      
      public static function Log(param1:String, param2:String = null) : void
      {
         if(param2 == null)
         {
            Cc.log(param1);
         }
         else
         {
            Cc.logch(param2,param1);
         }
      }
      
      public static function Do(param1:int = -1) : *
      {
         switch(param1)
         {
            case -1:
               mInstance.AsynchChangeTool(null);
               break;
            case TheMinerActionEnum.TOGGLE_INTERFACE_CONFIGURATION:
               mInstance.AsynchChangeTool(Configuration);
               break;
            case TheMinerActionEnum.TOGGLE_INTERFACE_DISPLAYOBJECT_LIFECYCLE:
               mInstance.AsynchChangeTool(InstancesLifeCycle);
               break;
            case TheMinerActionEnum.TOGGLE_INTERFACE_FLASH_RUNTIME_STATISTICS:
               mInstance.AsynchChangeTool(FlashStats);
               break;
            case TheMinerActionEnum.TOGGLE_INTERFACE_FUNCTION_PERFORMANCES:
               mInstance.AsynchChangeTool(PerformanceProfiler);
               break;
            case TheMinerActionEnum.TOGGLE_INTERFACE_INTERNAL_EVENTS:
               mInstance.AsynchChangeTool(InternalEventsProfiler);
               break;
            case TheMinerActionEnum.TOGGLE_INTERFACE_LOADERS_PROFILER:
               mInstance.AsynchChangeTool(LoaderProfiler);
               break;
            case TheMinerActionEnum.TOGGLE_INTERFACE_USER_EVENTS:
               mInstance.AsynchChangeTool(UserEvent);
               break;
            case TheMinerActionEnum.TOGGLE_INTERFACE_MEMORY_PROFILER:
               mInstance.AsynchChangeTool(SamplerProfiler);
               break;
            case TheMinerActionEnum.TOGGLE_INTERFACE_MOUSE_LISTENERS:
               mInstance.AsynchChangeTool(MouseListeners);
               break;
            case TheMinerActionEnum.TOGGLE_INTERFACE_OVERDRAW:
               mInstance.AsynchChangeTool(Overdraw);
               break;
            case TheMinerActionEnum.CLOSE_PROFILERS:
               mInstance.ClearTools();
               mInstance.mCurrentTool = null;
               break;
            case TheMinerActionEnum.TOGGLE_MINIMIZE:
               mInstance.AsynchChangeTool(null);
               OptionInterface.ToggleMinimize();
               break;
            case TheMinerActionEnum.HIDE:
               mInstance.visible = false;
               break;
            case TheMinerActionEnum.SHOW:
               mInstance.visible = true;
               break;
            case TheMinerActionEnum.QUIT:
               mInstance.Dispose();
               break;
            case TheMinerActionEnum.LISTEN_SAMPLES_START:
               Configuration.COMMAND_LINE_SAMPLING_LSTENER = true;
               break;
            case TheMinerActionEnum.LISTEN_SAMPLES_STOP:
               Configuration.COMMAND_LINE_SAMPLING_LSTENER = false;
               break;
            case TheMinerActionEnum.LISTEN_SAMPLES_RESET:
               SampleAnalyzer.ResetMemoryStats();
               SampleAnalyzer.ResetPerformanceStats();
               break;
            case TheMinerActionEnum.TAKE_MEMORY_SNAPSHOT:
               return Commands.SaveMemorySnapshot();
            case TheMinerActionEnum.TAKE_PERFORMANCE_SNAPSHOT:
               return Commands.SavePerformanceSnapshot();
            case TheMinerActionEnum.FORCE_GC:
               try
               {
                  System.gc();
               }
               catch(e:Error)
               {
               }
               try
               {
                  new LocalConnection().connect("Force GC!");
                  new LocalConnection().connect("Force GC!");
               }
               catch(e:Error)
               {
               }
               break;
            case TheMinerActionEnum.DUMP_SAMPLES_START:
               Commands.StartRecordingSamples();
               break;
            case TheMinerActionEnum.DUMP_SAMPLES_STOP:
               return Commands.StopRecordingSamples(false);
            case TheMinerActionEnum.DUMP_TRACES_START:
               Commands.StartRecordingTraces();
               break;
            case TheMinerActionEnum.DUMP_TRACES_STOP:
               return Commands.StopRecordingTraces(false);
            case TheMinerActionEnum.TAKE_SCREEN_CAPTURE:
               Commands.SaveSnapshot();
               return;
            default:
               if(param1 == TheMinerActionEnum.TOGGLE_INTERFACE_CONSOLE)
               {
                  mInstance.AsynchChangeTool(ConsoleContainer);
               }
         }
      }
      
      public static function InspectObject(param1:*, param2:String = null) : void
      {
         Cc.inspectch(param2,param1);
      }
      
      private function init(param1:Event = null) : void
      {
         var p:Stage = null;
         var so:* = undefined;
         var o:* = undefined;
         var myformat:TextFormat = null;
         var myglow:GlowFilter = null;
         var needDebugPlayer:TextField = null;
         var sprite:Sprite = null;
         var event:Event = param1;
         try
         {
            so = SharedObject.getLocal("TheMinerConfig",this.loaderInfo.loaderURL);
            Configuration.mSaveObj = so;
            trace("TheMiner : valid object",Configuration.mSaveObj.data);
            for(o in Configuration.mSaveObj.data)
            {
               trace("TheMiner : ",o,Configuration.mSaveObj.data[o]);
            }
         }
         catch(e:Error)
         {
         }
         Configuration.Load();
         p = this.stage as Stage;
         this.InitHandlers(this.root);
         setSamplerCallback(function(param1:Event):void
         {
            SampleAnalyzer.ProcessSampling();
         });
         if(!Capabilities.isDebugger)
         {
            myformat = new TextFormat("_sans",11,4294967295,false);
            myglow = new GlowFilter(3355443,1,2,2,3,2,false,false);
            needDebugPlayer = new TextField();
            needDebugPlayer.x = 5;
            needDebugPlayer.y = 5;
            needDebugPlayer.autoSize = TextFieldAutoSize.LEFT;
            needDebugPlayer.defaultTextFormat = myformat;
            needDebugPlayer.selectable = false;
            needDebugPlayer.filters = [myglow];
            needDebugPlayer.mouseEnabled = false;
            needDebugPlayer.text = Localization.Lbl_TheMinerNeedFlashPlayerDebug;
            p.addChild(needDebugPlayer);
            return;
         }
         removeEventListener(Event.ADDED_TO_STAGE,this.init);
         SkinManager.LoadColors();
         this.mouseEnabled = false;
         Cc.start(null);
         Cc.logch("TM","TheMiner " + "1.4.01");
         Cc.instance.commandLine = true;
         Cc.config.alwaysOnTop = false;
         Cc.config.sharedObjectName = null;
         Cc.config.sharedObjectPath = null;
         OptionInterface = new Options();
         OptionInterface.Init();
         addChild(OptionInterface);
         Commands.RefreshRate = Configuration.FRAME_UPDATE_SPEED;
         Commands.Opacity = Configuration.INTERFACE_OPACITY;
         if(Configuration.START_MINIMIZED)
         {
            OptionInterface.mFoldButton.OnClick(null);
         }
         if(!this.mIsPreloadSWFLaunched)
         {
            trace("TheMiner : Direct (embeded) profiler launch");
            sprite = new Sprite();
            this.SetRoot(this);
            clearSamples();
            SampleAnalyzer.ResetMemoryStats();
            SampleAnalyzer.ResetPerformanceStats();
         }
         if(this.loaderInfo.parameters["HookClass"] != undefined)
         {
            this.mHookClass = this.loaderInfo.parameters["HookClass"];
            trace("TheMiner : Trying to hook to class:",this.mHookClass);
         }
         if(this.loaderInfo.parameters["TraceFiles"] != undefined)
         {
            if(this.loaderInfo.parameters["TraceFiles"] == "true")
            {
               this.mTraceFiles = true;
            }
            trace("TheMiner : Tracing files loaded...");
         }
         if(this.loaderInfo.parameters["MonsterDebugger"] != undefined)
         {
            if(this.loaderInfo.parameters["MonsterDebugger"] == "true")
            {
               MonsterDebugger.initialize(this.stage,"127.0.0.1",this.OnConnectMonster);
            }
            trace("TheMiner : Monster debugger enabled");
         }
      }
      
      private function allCompleteHandler(param1:Event) : void
      {
         var loaderInfo:LoaderInfo = null;
         var event:Event = param1;
         try
         {
            loaderInfo = LoaderInfo(event.target);
            if(this.mTraceFiles)
            {
               trace("TheMiner : File loaded:",loaderInfo.url,"Class:",getQualifiedClassName(loaderInfo.content));
            }
            if(this.mInitialized)
            {
               return;
            }
            if(loaderInfo.content.root.stage == null)
            {
               trace("TheMiner : File loaded but no stage:",loaderInfo.url);
               return;
            }
            if(this.mHookClass != "" && this.mHookClass != getQualifiedClassName(loaderInfo.content))
            {
               trace("TheMiner : File loaded with stage but wrong class:",loaderInfo.url,getQualifiedClassName(loaderInfo.content));
               return;
            }
            trace("TheMiner : File loaded with stage:",loaderInfo.url,"Class:",getQualifiedClassName(loaderInfo.content));
            this.SetRoot(loaderInfo.content.root as Sprite);
         }
         catch(e:Error)
         {
            trace("TheMiner : ",e);
         }
      }
      
      private function Dispose() : void
      {
         OptionInterface.ResetMenu(null);
         this.ClearTools();
         stopSampling();
         clearSamples();
         try
         {
            Stage2D.removeEventListener("DebuggerDisconnected",OptionInterface.OnDebuggerDisconnect);
         }
         catch(e:Error)
         {
         }
         try
         {
            Stage2D.removeEventListener("DebuggerConnected",OptionInterface.OnDebuggerConnect);
         }
         catch(e:Error)
         {
         }
         try
         {
            this.mSWFListOutput.removeEventListener(Event.COMPLETE,this.OnSaveComplete);
         }
         catch(e:Error)
         {
         }
         try
         {
            root.removeEventListener("allComplete",this.allCompleteHandler);
         }
         catch(e:Error)
         {
         }
         try
         {
            root.removeEventListener("allComplete",this.SWFReferecesHandler);
         }
         catch(e:Error)
         {
         }
         try
         {
            this.removeEventListener(Event.ENTER_FRAME,this.OnEnterFrame);
         }
         catch(e:Error)
         {
         }
         OptionInterface.Dispose();
         removeChild(OptionInterface);
         try
         {
            this.parent.removeChild(this);
         }
         catch(e:Error)
         {
         }
      }
      
      private function OnEnterFrame(param1:Event) : void
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         if(Stage2D == null)
         {
            return;
         }
         if(Commands.IsRecordingTraces)
         {
            Trace.setLevel(Trace.OFF,Trace.LISTENER);
            Trace.setListener(null);
         }
         var _loc2_:Boolean = false;
         if(Configuration._PROFILE_MEMORY || Configuration._PROFILE_FUNCTION || Configuration._PROFILE_LOADERS || Configuration._PROFILE_INTERNAL_EVENTS || Configuration.COMMAND_LINE_SAMPLING_LSTENER)
         {
            _loc2_ = true;
         }
         else if(Commands.mIsCollectingSamplesData)
         {
            _loc2_ = true;
         }
         if(_loc2_)
         {
            pauseSampling();
         }
         Mouse.show();
         if(Stage2D != null && this.MAX__ONTOP_ATTEMPS > 0 && this.mAddChildFrameCounter++ > 30)
         {
            --this.MAX__ONTOP_ATTEMPS;
            this.mAddChildFrameCounter = 0;
            Stage2D.addChildAt(this,Stage2D.numChildren - 1);
         }
         ++this._frames;
         var _loc3_:int = getTimer();
         var _loc4_:int = _loc3_ - this._startTime;
         if(_loc4_ >= 1000 / Number(Commands.RefreshRate))
         {
            OptionInterface.mFps = Math.round(this._frames * (1000 / _loc4_));
            this._frames = 0;
            this._startTime = _loc3_;
         }
         if(_loc2_)
         {
            SampleAnalyzer.ProcessSampling();
         }
         LoaderAnalyser.GetInstance().Update();
         if(Configuration.PROFILE_MEMGRAPH)
         {
            _loc5_ = getTimer();
            if(_loc5_ >= this.ms_prev + 300)
            {
               _loc6_ = System.totalMemory;
               --FlashStats.mSamplingStartIdx;
               if(FlashStats.mSamplingStartIdx < 0)
               {
                  FlashStats.mSamplingStartIdx = FlashStats.mSamplingCount - 1;
               }
               this.ms_prev = _loc5_;
               if(_loc6_ < this.mLastMemoryVal)
               {
                  FlashStats.mMemoryGC[FlashStats.mSamplingStartIdx % FlashStats.mSamplingCount] = (this.mLastMemoryVal - _loc6_) / 1000;
               }
               FlashStats.mMemoryValues[FlashStats.mSamplingStartIdx % FlashStats.mSamplingCount] = _loc6_ / 1024;
               if(_loc6_ / 1024 > FlashStats.stats.MemoryMax)
               {
                  FlashStats.stats.MemoryMax = _loc6_ / 1024;
               }
               FlashStats.mMemoryMaxValues[FlashStats.mSamplingStartIdx % FlashStats.mSamplingCount] = FlashStats.stats.MemoryMax;
               this.mLastMemoryVal = _loc6_;
            }
         }
         if(this.mCurrentWindow)
         {
            this.mCurrentWindow.Update();
         }
         if(OptionInterface != null)
         {
            OptionInterface.Update();
         }
         if(OptionInterface.mQuitButton.mIsSelected)
         {
            Analytics.Track("Process","Quit","Quit");
            this.Dispose();
            return;
         }
         if(this.mMinimize)
         {
            Analytics.Track("Process","Minimize");
            OptionInterface.ResetMenu(null);
            this.ClearTools();
            this.mMinimize = false;
         }
         if(this.mNextTool != null)
         {
            this.ChangeTool(this.mNextTool);
            this.mNextTool = null;
         }
         if(_loc2_)
         {
            startSampling();
            clearSamples();
         }
         if(Commands.mIsCollectingTracesData)
         {
            Trace.setLevel(Trace.METHODS_AND_LINES_WITH_ARGS,Trace.LISTENER);
            Trace.setListener(Commands.OnTraceReceive);
         }
      }
      
      internal function InitHandlers(param1:DisplayObject) : void
      {
         trace("TheMiner : Indirect profilier launch (waiting for main SWF to load)");
         param1.addEventListener("allComplete",this.allCompleteHandler);
         param1.addEventListener("allComplete",this.SWFReferecesHandler);
      }
      
      private function OnConnectMonster() : void
      {
         Analytics.Track("Process","ConnectMD","MonsterDebugger");
      }
      
      private function SWFReferecesHandler(param1:Event) : void
      {
         var _loc3_:LoaderInfo = null;
         var _loc2_:Boolean = Configuration.IsSamplingRequired();
         pauseSampling();
         _loc3_ = LoaderInfo(param1.target);
         var _loc4_:int = this.mSWFList.length;
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            if(_loc3_ == this.mSWFList[_loc5_].mLoaderInfo)
            {
               if(_loc2_)
               {
                  startSampling();
               }
               return;
            }
            _loc5_++;
         }
         var _loc6_:SWFEntry = new SWFEntry();
         _loc6_.mBytes = _loc3_.bytes;
         _loc6_.mUrl = _loc3_.url;
         _loc6_.mFromURL = _loc3_.loaderURL;
         _loc6_.mLoaderInfo = _loc3_;
         this.mSWFList.push(_loc6_);
         if(_loc3_.content is Sprite)
         {
            LoaderAnalyser.GetInstance().PushLoader(_loc6_);
         }
         if(_loc2_)
         {
            startSampling();
         }
      }
      
      public function SaveSWFReferecesHandler() : void
      {
         var _loc1_:SWFEntry = null;
         if(this.mSavingIndex >= this.mSWFList.length)
         {
            return;
         }
         _loc1_ = this.mSWFList[this.mSavingIndex];
         this.mSWFListOutput.addEventListener(Event.COMPLETE,this.OnSaveComplete);
         this.mSWFListOutput.save(_loc1_.mBytes,this.mSavingIndex.toString() + ".swf");
         trace("SavingIndex",this.mSavingIndex,new Error().getStackTrace());
         ++this.mSavingIndex;
      }
      
      private function OnSaveComplete(param1:Event) : void
      {
         this.SaveSWFReferecesHandler();
      }
      
      private function SetRoot(param1:Sprite) : void
      {
         var buildType:String = null;
         var contract:String = null;
         var aSprite:Sprite = param1;
         this._startTime = getTimer();
         try
         {
            trace("The Miner: SetRoot");
            this.MainSprite = aSprite;
            Stage2D = this.MainSprite.stage;
            Analytics.Init();
            this.root.loaderInfo.sharedEvents.addEventListener(UserEventEntry.USER_EVENT,mUsrEventMgr.OnSharedEvent,false,0,true);
            buildType = null;
            if(this.mIsPreloadSWFLaunched)
            {
               buildType = "F";
            }
            else
            {
               buildType = "C";
            }
            contract = "Pro";
            Analytics.Track("Process","Launch","Launch/" + contract + "/" + buildType + "/" + "1.4.01" + "/" + Localization.LangCode);
            Analytics.Report("/Launch");
            this.addEventListener(Event.ENTER_FRAME,this.OnEnterFrame);
            Commands.Init(Stage2D);
            Stage2D.addChild(this);
            this.TraceLocalParameters(Stage2D.loaderInfo);
            if(Configuration.PROFILE_MONSTER)
            {
               Stage2D.addEventListener("DebuggerDisconnected",OptionInterface.OnDebuggerDisconnect);
               Stage2D.addEventListener("DebuggerConnected",OptionInterface.OnDebuggerConnect);
               MonsterDebugger.initialize(Stage2D,"127.0.0.1",this.OnConnectMonster);
               MonsterDebugger.trace(Stage2D,"Connected from TheMiner!");
            }
            else
            {
               OptionInterface.SetMonsterDisabled();
            }
            this.mInitialized = true;
            clearSamples();
         }
         catch(e:Error)
         {
            trace("TheMiner : ",e);
         }
      }
      
      private function AsynchChangeTool(param1:Class) : void
      {
         if(param1 == null)
         {
            this.mMinimize = true;
            return;
         }
         this.mMinimize = false;
         this.mNextTool = param1;
      }
      
      private function OnChangeTool(param1:ChangeToolEvent) : void
      {
         this.ChangeTool(param1.mTool);
      }
      
      private function TraceLocalParameters(param1:LoaderInfo) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:* = null;
         Cc.debugch("TM","Tracing Flash vars...");
         for(_loc4_ in param1.parameters)
         {
            Cc.logch("FlashVar","FlashVar: " + _loc4_ + " = " + param1.parameters[_loc4_]);
         }
      }
      
      private function ShowBar(param1:ContextMenuEvent) : void
      {
         this.visible = !this.visible;
      }
      
      public function ClearTools() : void
      {
         if(this.mCurrentWindow != null)
         {
            this.mCurrentWindow.Dispose();
            if(this.mCurrentWindow != null)
            {
               this.mCurrentWindow.Unlink();
            }
            this.mCurrentWindow = null;
         }
         while(this.numChildren > 0)
         {
            this.removeChildAt(0);
         }
         this.addChild(OptionInterface);
      }
      
      private function ChangeTool(param1:Class) : void
      {
         if(this.mCurrentTool == param1)
         {
            this.ClearTools();
            this.mCurrentTool = null;
            return;
         }
         this.ClearTools();
         this.mCurrentTool = param1;
         this.mCurrentWindow = new param1() as IWindow;
         if(this.mCurrentWindow != null)
         {
            this.mCurrentWindow.Link(this,0);
         }
         if(this.mCurrentWindow is UserEvent)
         {
            (this.mCurrentWindow as UserEvent).SetManager(mUsrEventMgr);
         }
      }
      
      override public function get name() : String
      {
         return "root3";
      }
      
      override public function get parent() : DisplayObjectContainer
      {
         return null;
      }
      
      override public function getChildAt(param1:int) : DisplayObject
      {
         return null;
      }
      
      override public function get numChildren() : int
      {
         return 0;
      }
      
      override public function getObjectsUnderPoint(param1:Point) : Array
      {
         return null;
      }
   }
}

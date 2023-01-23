package engine.core.pref
{
   import engine.core.logging.ILogger;
   import engine.core.util.AppInfo;
   import engine.core.util.ArrayUtil;
   import engine.core.util.StableJson;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   
   public class PrefBag extends EventDispatcher implements IPrefBag
   {
      
      protected static const VERSION:String = "VERSION";
      
      public static var ALLOW_LOAD:Boolean = true;
      
      public static var SAVE_INTERVAL:int = 1000;
      
      public static const EVENT_LOADED:String = "SagaPrefBag.EVENT_LOADED";
       
      
      public var loaded:Boolean = false;
      
      protected var prefs:Object;
      
      protected var defaults:Dictionary;
      
      protected var latestVersion:int;
      
      protected var dirty:Boolean;
      
      protected var internallyValid:Boolean;
      
      protected var saveTimer:Timer;
      
      protected var logger:ILogger;
      
      protected var path:String;
      
      protected var appInfo:AppInfo;
      
      public function PrefBag(param1:String, param2:int, param3:AppInfo, param4:ILogger, param5:Array)
      {
         var _loc6_:Object = null;
         var _loc7_:String = null;
         var _loc8_:* = undefined;
         this.prefs = {};
         this.defaults = new Dictionary();
         super();
         if(!param4)
         {
            throw new ArgumentError("no logger? please!");
         }
         this.appInfo = param3;
         this.path = "settings_" + param1 + ".json";
         if(ALLOW_LOAD)
         {
         }
         this.logger = param4;
         this.latestVersion = param2;
         for each(_loc6_ in param5)
         {
            _loc7_ = _loc6_.key;
            _loc8_ = _loc6_.value;
            this.defaults[_loc7_] = _loc8_;
         }
         this.loadPrefs();
         this.loadDefaults();
         if(this.getPref(VERSION) != param2)
         {
            param4.info("Upgrading prefbag " + param1 + " from version " + this.getPref(VERSION) + " to " + param2);
            this.setPref(VERSION,param2);
         }
         this.saveTimer = new Timer(SAVE_INTERVAL,1);
         this.saveTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.timerCompleteHandler);
      }
      
      protected function timerCompleteHandler(param1:TimerEvent) : void
      {
         this.savePrefs();
      }
      
      public function assignDefault(param1:String, param2:*) : void
      {
         if(!this.defaults)
         {
            return;
         }
         if(param2 == undefined)
         {
            delete this.defaults[param1];
         }
         this.defaults[param1] = param2;
         if(!(param1 in this.prefs))
         {
            this.prefs[param1] = param2;
         }
      }
      
      protected function loadDefaults() : void
      {
         var _loc1_:* = null;
         var _loc2_:* = undefined;
         if(!this.defaults)
         {
            return;
         }
         for(_loc1_ in this.defaults)
         {
            if(!(_loc1_ in this.prefs))
            {
               _loc2_ = this.defaults[_loc1_];
               this.prefs[_loc1_] = _loc2_;
            }
         }
      }
      
      protected function loadPrefs() : void
      {
         var s:String = null;
         var json:Object = null;
         try
         {
            s = this.appInfo.loadFileString(null,this.path);
            if(s)
            {
               json = StableJson.parse(s);
               if(json)
               {
                  this.prefs = json;
               }
            }
            else
            {
               this.logger.info("No prefs found at [" + this.path + "]");
            }
            this.dirty = false;
            this.loaded = true;
            dispatchEvent(new Event(EVENT_LOADED));
            return;
         }
         catch(e:Error)
         {
            logger.error("Failed to load prefs at [" + path + "]: " + e);
            logger.info("Prefs String:\n" + s);
            return;
         }
      }
      
      public function makePrefsDirty() : void
      {
         if(this.saveTimer != null && !this.saveTimer.running)
         {
            this.saveTimer.reset();
            this.saveTimer.start();
         }
         this.dirty = true;
      }
      
      public function get valid() : Boolean
      {
         return this.internallyValid || this.getPref(VERSION) == this.latestVersion;
      }
      
      public function setPref(param1:String, param2:*) : *
      {
         var _loc3_:* = this.getPref(param1);
         if(_loc3_ != param2)
         {
            this.makePrefsDirty();
         }
         if(_loc3_ is Array || param1 is Array)
         {
            if(!ArrayUtil.isEqual(_loc3_ as Array,param1 as Array))
            {
               this.makePrefsDirty();
            }
         }
         if(param2 == null || param2 == undefined)
         {
            delete this.prefs[param1];
         }
         else
         {
            this.prefs[param1] = param2;
         }
         return _loc3_;
      }
      
      public function getPref(param1:String, param2:* = undefined) : *
      {
         if(param1 in this.prefs)
         {
            return this.prefs[param1];
         }
         return param2;
      }
      
      public function getDefault(param1:String) : *
      {
         if(param1 in this.defaults)
         {
            return this.defaults[param1];
         }
         return undefined;
      }
      
      public function reset() : void
      {
         this.prefs = {};
         this.setPref(VERSION,0);
         this.loadDefaults();
      }
      
      public function savePrefs() : void
      {
         var _loc1_:String = null;
         if(!ALLOW_LOAD)
         {
            return;
         }
         this.setPref(VERSION,this.latestVersion);
         if(this.dirty)
         {
            this.dirty = false;
            _loc1_ = StableJson.stringify(this.prefs,null," ");
            this.appInfo.saveFileString(null,this.path,_loc1_,false);
         }
      }
   }
}

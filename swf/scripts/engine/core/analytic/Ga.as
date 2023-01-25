package engine.core.analytic
{
   import engine.core.logging.ILogger;
   import engine.core.util.AppInfo;
   import engine.core.util.StringUtil;
   import engine.math.Hash;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.net.URLVariables;
   import flash.utils.Dictionary;
   
   public class Ga
   {
      
      public static var tid:String;
      
      public static var an:String;
      
      public static var av:String;
      
      public static var cid:String;
      
      public static var logger:ILogger;
      
      public static var customDimensions:Dictionary = new Dictionary();
      
      public static var customMetrics:Dictionary = new Dictionary();
      
      public static var USE_SSL:Boolean = true;
      
      public static var hasTrackedStart:Boolean = false;
      
      private static var _appInfo:AppInfo = null;
      
      private static var _deferSends:Boolean;
      
      private static var _sent:int;
      
      private static var _discards:int;
      
      private static var _deferredSends:Vector.<URLVariables> = new Vector.<URLVariables>();
      
      private static var _sessionStartUv:URLVariables;
      
      private static var _hasSentStart:Boolean;
      
      public static var DEBUG_SQUELCH:Boolean;
       
      
      public function Ga()
      {
         super();
      }
      
      public static function getDebugString(param1:String = "    ", param2:String = "\n") : String
      {
         param1 = !!param1 ? param1 : "    ";
         param2 = !!param2 ? param2 : "\n";
         return "" + param1 + "Ga.tid      = " + tid + param2 + param1 + "Ga.an       = " + an + param2 + param1 + "Ga.av       = " + av + param2 + param1 + "Ga.cid      = " + cid + param2 + param1 + "Ga.USE_SSL  = " + USE_SSL + param2 + param1 + "Ga.started  = " + hasTrackedStart + param2 + param1 + "Ga.sent     = " + _sent + param2 + param1 + "Ga.discards = " + _discards + param2 + param1 + "Ga.defer    = " + _deferSends + param2 + param1 + "Ga.defers   = " + _deferredSends.length + param2;
      }
      
      public static function set deferSends(param1:Boolean) : void
      {
         var _loc2_:int = 0;
         var _loc3_:URLVariables = null;
         if(_deferSends == param1)
         {
            return;
         }
         _deferSends = param1;
         if(!param1)
         {
            if(tid)
            {
               logger.i("GA","Ga.deferSends unspooling " + _deferredSends.length);
               _loc2_ = 0;
               while(_loc2_ < _deferredSends.length)
               {
                  _loc3_ = _deferredSends[_loc2_];
                  send(_loc3_);
                  if(_deferSends)
                  {
                     _deferredSends.splice(0,_loc2_ + 1);
                     break;
                  }
                  _loc2_++;
               }
            }
            if(_deferredSends.length)
            {
               _deferredSends = new Vector.<URLVariables>();
            }
         }
      }
      
      public static function init(param1:AppInfo, param2:ILogger, param3:String, param4:String, param5:String, param6:String) : void
      {
         Ga.logger = param2;
         param2.i("GA","Ga.init CONFIG=\n" + GaConfig.getDebugString("  ","\n"));
         if(!GaConfig.optState.isSendOk)
         {
            param2.i("GA","Ga.init soft-init for GaConfig.optState=" + GaConfig.optState);
         }
         if(GaConfig.optState.isDefer)
         {
            param2.i("GA","Ga.init deferring for GaConfig.optState=" + GaConfig.optState);
            deferSends = true;
         }
         Ga.tid = escape(param3);
         Ga.an = escape(param4);
         Ga.cid = escape(param6);
         Ga.av = escape(param5);
         _appInfo = param1;
         param2.i("GA","Ga.init: tid=" + param3 + " an=" + param4 + " av=" + param5 + " cid=" + param6);
      }
      
      public static function stop(param1:String) : void
      {
         if(Boolean(Ga.tid) && Boolean(logger))
         {
            logger.i("GA","Ga.stop: " + param1);
            Ga.minimal("sys","ga_stop",param1,1);
         }
         Ga.tid = null;
      }
      
      public static function setCustomDimension(param1:int, param2:String) : void
      {
         customDimensions["cd" + param1] = param2;
      }
      
      public static function setCustomMetric(param1:int, param2:int) : void
      {
         customMetrics["cm" + param1] = param2;
      }
      
      public static function assignUsername(param1:String) : void
      {
         Ga.cid = escape(Hash.DJBHash(param1).toString(16));
         logger.i("GA","Ga.assignUsername: cid=" + cid);
      }
      
      public static function trackSessionStart(param1:int, param2:int, param3:String) : void
      {
         if(!tid)
         {
            return;
         }
         var _loc4_:URLVariables = new URLVariables();
         _loc4_["t"] = "screenview";
         _loc4_["cd"] = "init";
         _loc4_["sc"] = "start";
         _loc4_["sr"] = param1.toString() + "x" + param2.toString();
         _loc4_["ul"] = param3;
         if(av)
         {
            _loc4_["av"] = av;
         }
         _sessionStartUv = _loc4_;
         send(_sessionStartUv);
         hasTrackedStart = true;
      }
      
      public static function checkStartSend() : void
      {
         if(Boolean(_sessionStartUv) && !_hasSentStart)
         {
            if(GaConfig.optState.isSendOk)
            {
               send(_sessionStartUv);
            }
         }
      }
      
      public static function trackSessionEnd() : void
      {
         if(!tid)
         {
            return;
         }
         var _loc1_:URLVariables = new URLVariables();
         _loc1_["t"] = "screenview";
         _loc1_["sc"] = "end";
         send(_loc1_);
      }
      
      public static function trackException(param1:String) : void
      {
         if(!tid)
         {
            return;
         }
         if(StringUtil.startsWith(param1,"Ga "))
         {
            return;
         }
         if(param1.length > 256)
         {
            param1 = param1.substr(0,256);
            param1 += "...";
         }
         var _loc2_:URLVariables = new URLVariables();
         _loc2_["t"] = "exception";
         _loc2_["exd"] = param1;
         _loc2_["exf"] = 0;
         send(_loc2_);
      }
      
      public static function verbose(param1:String, param2:String, param3:String, param4:int) : void
      {
         if(GaConfig.verbosity.level < GaVerbosity.VERBOSE.level)
         {
            if(DEBUG_SQUELCH && logger.isDebugEnabled)
            {
               logger.d("GA  ","Current verbosity level too low. Squelching event send: cat=\'" + param1 + "\' action=\'" + param2 + "\' label=\'" + param3 + "\' value=\'" + param4 + "\'");
            }
            return;
         }
         sendEvent(param1,param2,param3,param4);
      }
      
      public static function normal(param1:String, param2:String, param3:String, param4:int) : void
      {
         if(GaConfig.verbosity.level < GaVerbosity.NORMAL.level)
         {
            if(DEBUG_SQUELCH && logger.isDebugEnabled)
            {
               logger.d("GA  ","Current verbosity level too low. Squelching event send: cat=\'" + param1 + "\' action=\'" + param2 + "\' label=\'" + param3 + "\' value=\'" + param4 + "\'");
            }
            return;
         }
         sendEvent(param1,param2,param3,param4);
      }
      
      public static function minimal(param1:String, param2:String, param3:String, param4:int) : void
      {
         sendEvent(param1,param2,param3,param4);
      }
      
      private static function sendEvent(param1:String, param2:String, param3:String, param4:int) : void
      {
         if(!tid)
         {
            return;
         }
         var _loc5_:URLVariables = new URLVariables();
         _loc5_["t"] = "event";
         _loc5_["ec"] = param1;
         _loc5_["ea"] = param2;
         if(param3)
         {
            _loc5_["el"] = param3;
         }
         _loc5_["ev"] = param4;
         send(_loc5_);
      }
      
      public static function trackPageView(param1:String) : void
      {
         if(!tid)
         {
            return;
         }
         var _loc2_:URLVariables = new URLVariables();
         _loc2_["t"] = "pageview";
         _loc2_["dp"] = param1;
         send(_loc2_);
      }
      
      public static function trackScreen(param1:String) : void
      {
         if(!tid)
         {
            return;
         }
         var _loc2_:URLVariables = new URLVariables();
         _loc2_["t"] = "screenview";
         _loc2_["cd"] = param1;
         send(_loc2_);
      }
      
      public static function trackPageLoadTime(param1:int) : void
      {
         if(!tid)
         {
            return;
         }
         var _loc2_:URLVariables = new URLVariables();
         _loc2_["t"] = "timing";
         _loc2_["plt"] = param1;
         send(_loc2_);
      }
      
      public static function trackScreenLoadTime(param1:String, param2:int) : void
      {
         if(!tid)
         {
            return;
         }
         var _loc3_:URLVariables = new URLVariables();
         _loc3_["t"] = "timing";
         _loc3_["utc"] = "load";
         _loc3_["utv"] = "screen";
         _loc3_["utl"] = param1;
         _loc3_["utt"] = param2;
         send(_loc3_);
      }
      
      public static function trackSceneLoadTime(param1:String, param2:int) : void
      {
         if(!tid)
         {
            return;
         }
         var _loc3_:URLVariables = new URLVariables();
         _loc3_["t"] = "timing";
         _loc3_["utc"] = "load";
         _loc3_["utv"] = "scene";
         _loc3_["utl"] = param1;
         _loc3_["utt"] = param2;
         send(_loc3_);
      }
      
      public static function trackSceneFrameTime(param1:String, param2:int, param3:int) : void
      {
         if(!tid)
         {
            return;
         }
         var _loc4_:URLVariables = new URLVariables();
         _loc4_["t"] = "timing";
         _loc4_["utc"] = "frametime";
         _loc4_["utv"] = "avg";
         _loc4_["utl"] = param1;
         _loc4_["utt"] = param2;
         send(_loc4_);
         _loc4_ = new URLVariables();
         _loc4_["t"] = "timing";
         _loc4_["utc"] = "frametime";
         _loc4_["utv"] = "max";
         _loc4_["utl"] = param1;
         _loc4_["utt"] = param3;
         send(_loc4_);
      }
      
      public static function trackSceneMemory(param1:String, param2:int) : void
      {
         if(!tid)
         {
            return;
         }
         minimal("scene","memory",param1,param2);
      }
      
      public static function trackUserTiming(param1:String, param2:String, param3:String, param4:int) : void
      {
         if(!tid)
         {
            return;
         }
         var _loc5_:URLVariables = new URLVariables();
         _loc5_["t"] = "timing";
         _loc5_["utc"] = param1;
         _loc5_["utv"] = param2;
         _loc5_["utl"] = param3;
         _loc5_["utt"] = param4;
         send(_loc5_);
      }
      
      private static function send(param1:URLVariables) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:URLRequest = null;
         var _loc8_:SmartUrlLoader_Ga = null;
         if(!tid)
         {
            return;
         }
         if(GaConfig.optState == GaOptState.OUT)
         {
            ++_discards;
            return;
         }
         if(_deferSends)
         {
            logger.i("GA","Ga.send deferring send of " + param1.toString());
            _deferredSends.push(param1);
            return;
         }
         if(param1 == _sessionStartUv)
         {
            if(_hasSentStart)
            {
               logger.i("GA","Ga.send already sent start of " + _sessionStartUv.toString());
               return;
            }
            _hasSentStart = true;
         }
         if(USE_SSL)
         {
            _loc2_ = "https://ssl.google-analytics.com/collect";
         }
         else
         {
            _loc2_ = "http://www.google-analytics.com/collect";
         }
         param1["v"] = 1;
         param1["tid"] = tid;
         param1["cid"] = cid;
         if(an)
         {
            param1["an"] = an;
            param1["av"] = av;
         }
         for(_loc3_ in customDimensions)
         {
            _loc5_ = String(customDimensions[_loc3_]);
            param1[_loc3_] = _loc5_;
         }
         for(_loc4_ in customMetrics)
         {
            _loc6_ = String(customMetrics[_loc4_]);
            param1[_loc4_] = _loc6_;
         }
         ++_sent;
         if(HttpConfig.USE_APPINFO_FOR_HTTP)
         {
            _appInfo.httpRequestAsync("POST",_loc2_,param1.toString());
         }
         else
         {
            _loc7_ = new URLRequest(_loc2_);
            _loc7_.method = URLRequestMethod.POST;
            _loc7_.data = param1;
            _loc7_.contentType = "application/x-www-form-urlencoded";
            _loc8_ = new SmartUrlLoader_Ga();
            _loc8_.addEventListener(Event.COMPLETE,onUrlLoadComplete);
            _loc8_.addEventListener(IOErrorEvent.IO_ERROR,onUrlIoError);
            try
            {
               _loc8_.load(_loc7_);
            }
            catch(error:Error)
            {
            }
         }
      }
      
      protected static function onUrlIoError(param1:IOErrorEvent) : void
      {
         var _loc2_:SmartUrlLoader_Ga = param1.target as SmartUrlLoader_Ga;
         if(logger.isDebugEnabled)
         {
            logger.debug("GA","Ga onUrlIoError " + _loc2_.debugString);
         }
      }
      
      protected static function onUrlLoadComplete(param1:Event) : void
      {
         var _loc2_:SmartUrlLoader_Ga = param1.target as SmartUrlLoader_Ga;
      }
   }
}

import flash.net.URLLoader;
import flash.net.URLRequest;

class SmartUrlLoader_Ga extends URLLoader
{
    
   
   public var req:URLRequest;
   
   public function SmartUrlLoader_Ga(param1:URLRequest = null)
   {
      super(param1);
      this.req = param1;
   }
   
   override public function load(param1:URLRequest) : void
   {
      this.req = param1;
      super.load(param1);
   }
   
   public function get debugString() : String
   {
      return this.req.url + " var=" + this.debugStringVars;
   }
   
   public function get debugStringVars() : String
   {
      var _loc2_:String = null;
      var _loc3_:String = null;
      var _loc1_:* = "";
      if(this.req.data)
      {
         for(_loc2_ in this.req.data)
         {
            _loc3_ = String(this.req.data[_loc2_]);
            if(_loc1_)
            {
               _loc1_ += ", ";
            }
            _loc1_ += _loc2_ + "=" + _loc3_;
         }
      }
      return _loc1_;
   }
}

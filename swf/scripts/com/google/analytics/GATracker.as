package com.google.analytics
{
   import com.google.analytics.core.Buffer;
   import com.google.analytics.core.Ecommerce;
   import com.google.analytics.core.EventTracker;
   import com.google.analytics.core.GIFRequest;
   import com.google.analytics.core.IdleTimer;
   import com.google.analytics.core.ServerOperationMode;
   import com.google.analytics.core.TrackerCache;
   import com.google.analytics.core.TrackerMode;
   import com.google.analytics.core.ga_internal;
   import com.google.analytics.debug.DebugConfiguration;
   import com.google.analytics.debug.Layout;
   import com.google.analytics.events.AnalyticsEvent;
   import com.google.analytics.external.AdSenseGlobals;
   import com.google.analytics.external.HTMLDOM;
   import com.google.analytics.external.JavascriptProxy;
   import com.google.analytics.utils.Environment;
   import com.google.analytics.utils.Version;
   import com.google.analytics.v4.Bridge;
   import com.google.analytics.v4.Configuration;
   import com.google.analytics.v4.GoogleAnalyticsAPI;
   import com.google.analytics.v4.Tracker;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   [Event(name="ready",type="com.google.analytics.events.AnalyticsEvent")]
   public class GATracker implements AnalyticsTracker
   {
      
      public static var autobuild:Boolean = true;
      
      public static var version:Version = API.version;
       
      
      private var _ready:Boolean = false;
      
      private var _display:DisplayObject;
      
      private var _eventDispatcher:EventDispatcher;
      
      private var _tracker:GoogleAnalyticsAPI;
      
      private var _config:Configuration;
      
      private var _debug:DebugConfiguration;
      
      private var _env:Environment;
      
      private var _buffer:Buffer;
      
      private var _gifRequest:GIFRequest;
      
      private var _jsproxy:JavascriptProxy;
      
      private var _dom:HTMLDOM;
      
      private var _adSense:AdSenseGlobals;
      
      private var _idleTimer:IdleTimer;
      
      private var _ecom:Ecommerce;
      
      private var _account:String;
      
      private var _mode:String;
      
      private var _visualDebug:Boolean;
      
      public function GATracker(param1:DisplayObject, param2:String, param3:String = "AS3", param4:Boolean = false, param5:Configuration = null, param6:DebugConfiguration = null)
      {
         super();
         this._display = param1;
         this._eventDispatcher = new EventDispatcher(this);
         this._tracker = new TrackerCache();
         this.account = param2;
         this.mode = param3;
         this.visualDebug = param4;
         if(!param6)
         {
            this.debug = new DebugConfiguration();
         }
         if(!param5)
         {
            this.config = new Configuration(param6);
         }
         else
         {
            this.config = param5;
         }
         if(autobuild)
         {
            this._factory();
         }
      }
      
      private function _factory() : void
      {
         var _loc1_:GoogleAnalyticsAPI = null;
         this._jsproxy = new JavascriptProxy(this.debug);
         if(this.visualDebug)
         {
            this.debug.layout = new Layout(this.debug,this._display);
            this.debug.active = this.visualDebug;
         }
         var _loc2_:TrackerCache = this._tracker as TrackerCache;
         switch(this.mode)
         {
            case TrackerMode.BRIDGE:
               _loc1_ = this._bridgeFactory();
               break;
            case TrackerMode.AS3:
            default:
               _loc1_ = this._trackerFactory();
         }
         if(!_loc2_.isEmpty())
         {
            _loc2_.tracker = _loc1_;
            _loc2_.flush();
         }
         this._tracker = _loc1_;
         this._ready = true;
         this.dispatchEvent(new AnalyticsEvent(AnalyticsEvent.READY,this));
      }
      
      private function _trackerFactory() : GoogleAnalyticsAPI
      {
         this.debug.info("GATracker (AS3) v" + version + "\naccount: " + this.account);
         this._adSense = new AdSenseGlobals(this.debug);
         this._dom = new HTMLDOM(this.debug);
         this._dom.cacheProperties();
         this._env = new Environment("","","",this.debug,this._dom);
         this._buffer = new Buffer(this.config,this.debug,false);
         this._gifRequest = new GIFRequest(this.config,this.debug,this._buffer,this._env);
         this._ecom = new Ecommerce(this._debug);
         this._env.ga_internal::url = this._display.stage.loaderInfo.url;
         return new Tracker(this.account,this.config,this.debug,this._env,this._buffer,this._gifRequest,this._adSense,this._ecom);
      }
      
      private function _bridgeFactory() : GoogleAnalyticsAPI
      {
         this.debug.info("GATracker (Bridge) v" + version + "\naccount: " + this.account);
         return new Bridge(this.account,this._debug,this._jsproxy);
      }
      
      public function get account() : String
      {
         return this._account;
      }
      
      public function set account(param1:String) : void
      {
         this._account = param1;
      }
      
      public function get config() : Configuration
      {
         return this._config;
      }
      
      public function set config(param1:Configuration) : void
      {
         this._config = param1;
      }
      
      public function get debug() : DebugConfiguration
      {
         return this._debug;
      }
      
      public function set debug(param1:DebugConfiguration) : void
      {
         this._debug = param1;
      }
      
      public function isReady() : Boolean
      {
         return this._ready;
      }
      
      public function get mode() : String
      {
         return this._mode;
      }
      
      public function set mode(param1:String) : void
      {
         this._mode = param1;
      }
      
      public function get visualDebug() : Boolean
      {
         return this._visualDebug;
      }
      
      public function set visualDebug(param1:Boolean) : void
      {
         this._visualDebug = param1;
      }
      
      public function build() : void
      {
         if(!this.isReady())
         {
            this._factory();
         }
      }
      
      public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         this._eventDispatcher.addEventListener(param1,param2,param3,param4,param5);
      }
      
      public function dispatchEvent(param1:Event) : Boolean
      {
         return this._eventDispatcher.dispatchEvent(param1);
      }
      
      public function hasEventListener(param1:String) : Boolean
      {
         return this._eventDispatcher.hasEventListener(param1);
      }
      
      public function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
      {
         this._eventDispatcher.removeEventListener(param1,param2,param3);
      }
      
      public function willTrigger(param1:String) : Boolean
      {
         return this._eventDispatcher.willTrigger(param1);
      }
      
      public function getAccount() : String
      {
         return this._tracker.getAccount();
      }
      
      public function getVersion() : String
      {
         return this._tracker.getVersion();
      }
      
      public function resetSession() : void
      {
         this._tracker.resetSession();
      }
      
      public function setSampleRate(param1:Number) : void
      {
         this._tracker.setSampleRate(param1);
      }
      
      public function setSessionTimeout(param1:int) : void
      {
         this._tracker.setSessionTimeout(param1);
      }
      
      public function setVar(param1:String) : void
      {
         this._tracker.setVar(param1);
      }
      
      public function trackPageview(param1:String = "") : void
      {
         this._tracker.trackPageview(param1);
      }
      
      public function setAllowAnchor(param1:Boolean) : void
      {
         this._tracker.setAllowAnchor(param1);
      }
      
      public function setCampContentKey(param1:String) : void
      {
         this._tracker.setCampContentKey(param1);
      }
      
      public function setCampMediumKey(param1:String) : void
      {
         this._tracker.setCampMediumKey(param1);
      }
      
      public function setCampNameKey(param1:String) : void
      {
         this._tracker.setCampNameKey(param1);
      }
      
      public function setCampNOKey(param1:String) : void
      {
         this._tracker.setCampNOKey(param1);
      }
      
      public function setCampSourceKey(param1:String) : void
      {
         this._tracker.setCampSourceKey(param1);
      }
      
      public function setCampTermKey(param1:String) : void
      {
         this._tracker.setCampTermKey(param1);
      }
      
      public function setCampaignTrack(param1:Boolean) : void
      {
         this._tracker.setCampaignTrack(param1);
      }
      
      public function setCookieTimeout(param1:int) : void
      {
         this._tracker.setCookieTimeout(param1);
      }
      
      public function cookiePathCopy(param1:String) : void
      {
         this._tracker.cookiePathCopy(param1);
      }
      
      public function getLinkerUrl(param1:String = "", param2:Boolean = false) : String
      {
         return this._tracker.getLinkerUrl(param1,param2);
      }
      
      public function link(param1:String, param2:Boolean = false) : void
      {
         this._tracker.link(param1,param2);
      }
      
      public function linkByPost(param1:Object, param2:Boolean = false) : void
      {
         this._tracker.linkByPost(param1,param2);
      }
      
      public function setAllowHash(param1:Boolean) : void
      {
         this._tracker.setAllowHash(param1);
      }
      
      public function setAllowLinker(param1:Boolean) : void
      {
         this._tracker.setAllowLinker(param1);
      }
      
      public function setCookiePath(param1:String) : void
      {
         this._tracker.setCookiePath(param1);
      }
      
      public function setDomainName(param1:String) : void
      {
         this._tracker.setDomainName(param1);
      }
      
      public function addItem(param1:String, param2:String, param3:String, param4:String, param5:Number, param6:int) : void
      {
         this._tracker.addItem(param1,param2,param3,param4,param5,param6);
      }
      
      public function addTrans(param1:String, param2:String, param3:Number, param4:Number, param5:Number, param6:String, param7:String, param8:String) : void
      {
         this._tracker.addTrans(param1,param2,param3,param4,param5,param6,param7,param8);
      }
      
      public function trackTrans() : void
      {
         this._tracker.trackTrans();
      }
      
      public function createEventTracker(param1:String) : EventTracker
      {
         return this._tracker.createEventTracker(param1);
      }
      
      public function trackEvent(param1:String, param2:String, param3:String = null, param4:Number = NaN) : Boolean
      {
         return this._tracker.trackEvent(param1,param2,param3,param4);
      }
      
      public function addIgnoredOrganic(param1:String) : void
      {
         this._tracker.addIgnoredOrganic(param1);
      }
      
      public function addIgnoredRef(param1:String) : void
      {
         this._tracker.addIgnoredRef(param1);
      }
      
      public function addOrganic(param1:String, param2:String) : void
      {
         this._tracker.addOrganic(param1,param2);
      }
      
      public function clearIgnoredOrganic() : void
      {
         this._tracker.clearIgnoredOrganic();
      }
      
      public function clearIgnoredRef() : void
      {
         this._tracker.clearIgnoredRef();
      }
      
      public function clearOrganic() : void
      {
         this._tracker.clearOrganic();
      }
      
      public function getClientInfo() : Boolean
      {
         return this._tracker.getClientInfo();
      }
      
      public function getDetectFlash() : Boolean
      {
         return this._tracker.getDetectFlash();
      }
      
      public function getDetectTitle() : Boolean
      {
         return this._tracker.getDetectTitle();
      }
      
      public function setClientInfo(param1:Boolean) : void
      {
         this._tracker.setClientInfo(param1);
      }
      
      public function setDetectFlash(param1:Boolean) : void
      {
         this._tracker.setDetectFlash(param1);
      }
      
      public function setDetectTitle(param1:Boolean) : void
      {
         this._tracker.setDetectTitle(param1);
      }
      
      public function getLocalGifPath() : String
      {
         return this._tracker.getLocalGifPath();
      }
      
      public function getServiceMode() : ServerOperationMode
      {
         return this._tracker.getServiceMode();
      }
      
      public function setLocalGifPath(param1:String) : void
      {
         this._tracker.setLocalGifPath(param1);
      }
      
      public function setLocalRemoteServerMode() : void
      {
         this._tracker.setLocalRemoteServerMode();
      }
      
      public function setLocalServerMode() : void
      {
         this._tracker.setLocalServerMode();
      }
      
      public function setRemoteServerMode() : void
      {
         this._tracker.setRemoteServerMode();
      }
   }
}

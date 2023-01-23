package com.google.analytics.v4
{
   import com.google.analytics.campaign.CampaignInfo;
   import com.google.analytics.campaign.CampaignManager;
   import com.google.analytics.core.BrowserInfo;
   import com.google.analytics.core.Buffer;
   import com.google.analytics.core.DocumentInfo;
   import com.google.analytics.core.DomainNameMode;
   import com.google.analytics.core.Ecommerce;
   import com.google.analytics.core.EventInfo;
   import com.google.analytics.core.EventTracker;
   import com.google.analytics.core.GIFRequest;
   import com.google.analytics.core.ServerOperationMode;
   import com.google.analytics.core.Utils;
   import com.google.analytics.data.X10;
   import com.google.analytics.debug.DebugConfiguration;
   import com.google.analytics.debug.VisualDebugMode;
   import com.google.analytics.ecommerce.Transaction;
   import com.google.analytics.external.AdSenseGlobals;
   import com.google.analytics.utils.Environment;
   import com.google.analytics.utils.Protocols;
   import com.google.analytics.utils.URL;
   import com.google.analytics.utils.Variables;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class Tracker implements GoogleAnalyticsAPI
   {
       
      
      private var _account:String;
      
      private var _domainHash:Number;
      
      private var _formatedReferrer:String;
      
      private var _timeStamp:Number;
      
      private var _hasInitData:Boolean = false;
      
      private var _isNewVisitor:Boolean = false;
      
      private var _noSessionInformation:Boolean = false;
      
      private var _config:Configuration;
      
      private var _debug:DebugConfiguration;
      
      private var _info:Environment;
      
      private var _buffer:Buffer;
      
      private var _gifRequest:GIFRequest;
      
      private var _adSense:AdSenseGlobals;
      
      private var _browserInfo:BrowserInfo;
      
      private var _campaignInfo:CampaignInfo;
      
      private const EVENT_TRACKER_PROJECT_ID:int = 5;
      
      private const EVENT_TRACKER_OBJECT_NAME_KEY_NUM:int = 1;
      
      private const EVENT_TRACKER_TYPE_KEY_NUM:int = 2;
      
      private const EVENT_TRACKER_LABEL_KEY_NUM:int = 3;
      
      private const EVENT_TRACKER_VALUE_VALUE_NUM:int = 1;
      
      private var _campaign:CampaignManager;
      
      private var _eventTracker:X10;
      
      private var _x10Module:X10;
      
      private var _ecom:Ecommerce;
      
      public function Tracker(param1:String, param2:Configuration, param3:DebugConfiguration, param4:Environment, param5:Buffer, param6:GIFRequest, param7:AdSenseGlobals, param8:Ecommerce)
      {
         var _loc9_:* = null;
         super();
         this._account = param1;
         this._config = param2;
         this._debug = param3;
         this._info = param4;
         this._buffer = param5;
         this._gifRequest = param6;
         this._adSense = param7;
         this._ecom = param8;
         if(!Utils.validateAccount(param1))
         {
            _loc9_ = "Account \"" + param1 + "\" is not valid.";
            this._debug.warning(_loc9_);
            throw new Error(_loc9_);
         }
      }
      
      private function _initData() : void
      {
         var _loc1_:* = null;
         var _loc2_:* = null;
         if(!this._hasInitData)
         {
            this._updateDomainName();
            this._domainHash = this._getDomainHash();
            this._timeStamp = Math.round(new Date().getTime() / 1000);
            if(this._debug.verbose)
            {
               _loc1_ = "";
               _loc1_ += "_initData 0";
               _loc1_ += "\ndomain name: " + this._config.domainName;
               _loc1_ += "\ndomain hash: " + this._domainHash;
               _loc1_ += "\ntimestamp:   " + this._timeStamp + " (" + new Date(this._timeStamp * 1000) + ")";
               this._debug.info(_loc1_,VisualDebugMode.geek);
            }
         }
         if(this._doTracking())
         {
            this._handleCookie();
         }
         if(!this._hasInitData)
         {
            if(this._doTracking())
            {
               this._formatedReferrer = this._formatReferrer();
               this._browserInfo = new BrowserInfo(this._config,this._info);
               this._debug.info("browserInfo: " + this._browserInfo.toURLString(),VisualDebugMode.advanced);
               if(this._config.campaignTracking)
               {
                  this._campaign = new CampaignManager(this._config,this._debug,this._buffer,this._domainHash,this._formatedReferrer,this._timeStamp);
                  this._campaignInfo = this._campaign.getCampaignInformation(this._info.locationSearch,this._noSessionInformation);
                  this._debug.info("campaignInfo: " + this._campaignInfo.toURLString(),VisualDebugMode.advanced);
                  this._debug.info("Search: " + this._info.locationSearch);
                  this._debug.info("CampaignTrackig: " + this._buffer.utmz.campaignTracking);
               }
            }
            this._x10Module = new X10();
            this._eventTracker = new X10();
            this._hasInitData = true;
         }
         if(this._config.hasSiteOverlay)
         {
            this._debug.warning("Site Overlay is not supported");
         }
         if(this._debug.verbose)
         {
            _loc2_ = "";
            _loc2_ += "_initData (misc)";
            _loc2_ += "\nflash version: " + this._info.flashVersion.toString(4);
            _loc2_ += "\nprotocol: " + this._info.protocol;
            _loc2_ += "\ndefault domain name (auto): \"" + this._info.domainName + "\"";
            _loc2_ += "\nlanguage: " + this._info.language;
            _loc2_ += "\ndomain hash: " + this._getDomainHash();
            _loc2_ += "\nuser-agent: " + this._info.userAgent;
            this._debug.info(_loc2_,VisualDebugMode.geek);
         }
      }
      
      private function _handleCookie() : void
      {
         var _loc1_:* = null;
         var _loc2_:* = null;
         var _loc3_:Array = null;
         var _loc4_:* = null;
         if(this._config.allowLinker)
         {
         }
         this._buffer.createSO();
         if(this._buffer.hasUTMA() && !this._buffer.utma.isEmpty())
         {
            if(!this._buffer.hasUTMB() || !this._buffer.hasUTMC())
            {
               this._buffer.updateUTMA(this._timeStamp);
               this._noSessionInformation = true;
            }
            if(this._debug.verbose)
            {
               this._debug.info("from cookie " + this._buffer.utma.toString(),VisualDebugMode.geek);
            }
         }
         else
         {
            this._debug.info("create a new utma",VisualDebugMode.advanced);
            this._buffer.utma.domainHash = this._domainHash;
            this._buffer.utma.sessionId = this._getUniqueSessionId();
            this._buffer.utma.firstTime = this._timeStamp;
            this._buffer.utma.lastTime = this._timeStamp;
            this._buffer.utma.currentTime = this._timeStamp;
            this._buffer.utma.sessionCount = 1;
            if(this._debug.verbose)
            {
               this._debug.info(this._buffer.utma.toString(),VisualDebugMode.geek);
            }
            this._noSessionInformation = true;
            this._isNewVisitor = true;
         }
         if(Boolean(this._adSense.gaGlobal) && this._adSense.dh == String(this._domainHash))
         {
            if(this._adSense.sid)
            {
               this._buffer.utma.currentTime = Number(this._adSense.sid);
               if(this._debug.verbose)
               {
                  _loc1_ = "";
                  _loc1_ += "AdSense sid found\n";
                  _loc1_ += "Override currentTime(" + this._buffer.utma.currentTime + ") from AdSense sid(" + Number(this._adSense.sid) + ")";
                  this._debug.info(_loc1_,VisualDebugMode.geek);
               }
            }
            if(this._isNewVisitor)
            {
               if(this._adSense.sid)
               {
                  this._buffer.utma.lastTime = Number(this._adSense.sid);
                  if(this._debug.verbose)
                  {
                     _loc2_ = "";
                     _loc2_ += "AdSense sid found (new visitor)\n";
                     _loc2_ += "Override lastTime(" + this._buffer.utma.lastTime + ") from AdSense sid(" + Number(this._adSense.sid) + ")";
                     this._debug.info(_loc2_,VisualDebugMode.geek);
                  }
               }
               if(this._adSense.vid)
               {
                  _loc3_ = this._adSense.vid.split(".");
                  this._buffer.utma.sessionId = Number(_loc3_[0]);
                  this._buffer.utma.firstTime = Number(_loc3_[1]);
                  if(this._debug.verbose)
                  {
                     _loc4_ = "";
                     _loc4_ += "AdSense vid found (new visitor)\n";
                     _loc4_ += "Override sessionId(" + this._buffer.utma.sessionId + ") from AdSense vid(" + Number(_loc3_[0]) + ")\n";
                     _loc4_ += "Override firstTime(" + this._buffer.utma.firstTime + ") from AdSense vid(" + Number(_loc3_[1]) + ")";
                     this._debug.info(_loc4_,VisualDebugMode.geek);
                  }
               }
               if(this._debug.verbose)
               {
                  this._debug.info("AdSense modified : " + this._buffer.utma.toString(),VisualDebugMode.geek);
               }
            }
         }
         this._buffer.utmb.domainHash = this._domainHash;
         if(isNaN(this._buffer.utmb.trackCount))
         {
            this._buffer.utmb.trackCount = 0;
         }
         if(isNaN(this._buffer.utmb.token))
         {
            this._buffer.utmb.token = this._config.tokenCliff;
         }
         if(isNaN(this._buffer.utmb.lastTime))
         {
            this._buffer.utmb.lastTime = this._buffer.utma.currentTime;
         }
         this._buffer.utmc.domainHash = this._domainHash;
         if(this._debug.verbose)
         {
            this._debug.info(this._buffer.utmb.toString(),VisualDebugMode.advanced);
            this._debug.info(this._buffer.utmc.toString(),VisualDebugMode.advanced);
         }
      }
      
      private function _isNotGoogleSearch() : Boolean
      {
         var _loc1_:String = this._config.domainName;
         var _loc2_:* = _loc1_.indexOf("www.google.") < 0;
         var _loc3_:* = _loc1_.indexOf(".google.") < 0;
         var _loc4_:* = _loc1_.indexOf("google.") < 0;
         var _loc5_:* = _loc1_.indexOf("google.org") > -1;
         return _loc2_ || _loc3_ || _loc4_ || this._config.cookiePath != "/" || _loc5_;
      }
      
      private function _doTracking() : Boolean
      {
         if(this._info.protocol != Protocols.file && this._info.protocol != Protocols.none && this._isNotGoogleSearch())
         {
            return true;
         }
         if(this._config.allowLocalTracking)
         {
            return true;
         }
         return false;
      }
      
      private function _updateDomainName() : void
      {
         var _loc1_:String = null;
         if(this._config.domain.mode == DomainNameMode.auto)
         {
            _loc1_ = this._info.domainName;
            if(_loc1_.substring(0,4) == "www.")
            {
               _loc1_ = _loc1_.substring(4);
            }
            this._config.domain.name = _loc1_;
         }
         this._config.domainName = this._config.domain.name.toLowerCase();
         this._debug.info("domain name: " + this._config.domainName,VisualDebugMode.advanced);
      }
      
      private function _formatReferrer() : String
      {
         var _loc2_:String = null;
         var _loc3_:URL = null;
         var _loc4_:URL = null;
         var _loc1_:String = this._info.referrer;
         if(_loc1_ == "" || _loc1_ == "localhost")
         {
            _loc1_ = "-";
         }
         else
         {
            _loc2_ = this._info.domainName;
            _loc3_ = new URL(_loc1_);
            _loc4_ = new URL("http://" + _loc2_);
            if(_loc3_.hostName == _loc2_)
            {
               return "-";
            }
            if(_loc4_.domain == _loc3_.domain)
            {
               if(_loc4_.subDomain != _loc3_.subDomain)
               {
                  _loc1_ = "0";
               }
            }
            if(_loc1_.charAt(0) == "[" && Boolean(_loc1_.charAt(_loc1_.length - 1)))
            {
               _loc1_ = "-";
            }
         }
         this._debug.info("formated referrer: " + _loc1_,VisualDebugMode.advanced);
         return _loc1_;
      }
      
      private function _generateUserDataHash() : Number
      {
         var _loc1_:String = "";
         _loc1_ += this._info.appName;
         _loc1_ += this._info.appVersion;
         _loc1_ += this._info.language;
         _loc1_ += this._info.platform;
         _loc1_ += this._info.userAgent.toString();
         _loc1_ += this._info.screenWidth + "x" + this._info.screenHeight + this._info.screenColorDepth;
         _loc1_ += this._info.referrer;
         return Utils.generateHash(_loc1_);
      }
      
      private function _getUniqueSessionId() : Number
      {
         var _loc1_:Number = (Utils.generate32bitRandom() ^ this._generateUserDataHash()) * 2147483647;
         this._debug.info("Session ID: " + _loc1_,VisualDebugMode.geek);
         return _loc1_;
      }
      
      private function _getDomainHash() : Number
      {
         if(!this._config.domainName || this._config.domainName == "" || this._config.domain.mode == DomainNameMode.none)
         {
            this._config.domainName = "";
            return 1;
         }
         this._updateDomainName();
         if(this._config.allowDomainHash)
         {
            return Utils.generateHash(this._config.domainName);
         }
         return 1;
      }
      
      private function _visitCode() : Number
      {
         if(this._debug.verbose)
         {
            this._debug.info("visitCode: " + this._buffer.utma.sessionId,VisualDebugMode.geek);
         }
         return this._buffer.utma.sessionId;
      }
      
      private function _takeSample() : Boolean
      {
         if(this._debug.verbose)
         {
            this._debug.info("takeSample: (" + this._visitCode() % 10000 + ") < (" + this._config.sampleRate * 10000 + ")",VisualDebugMode.geek);
         }
         return this._visitCode() % 10000 < this._config.sampleRate * 10000;
      }
      
      public function getAccount() : String
      {
         this._debug.info("getAccount()");
         return this._account;
      }
      
      public function getVersion() : String
      {
         this._debug.info("getVersion()");
         return this._config.version;
      }
      
      public function resetSession() : void
      {
         this._debug.info("resetSession()");
         this._buffer.resetCurrentSession();
      }
      
      public function setSampleRate(param1:Number) : void
      {
         if(param1 < 0)
         {
            this._debug.warning("sample rate can not be negative, ignoring value.");
         }
         else
         {
            this._config.sampleRate = param1;
         }
         this._debug.info("setSampleRate( " + this._config.sampleRate + " )");
      }
      
      public function setSessionTimeout(param1:int) : void
      {
         this._config.sessionTimeout = param1;
         this._debug.info("setSessionTimeout( " + this._config.sessionTimeout + " )");
      }
      
      public function setVar(param1:String) : void
      {
         var _loc2_:Variables = null;
         if(param1 != "" && this._isNotGoogleSearch())
         {
            this._initData();
            this._buffer.utmv.domainHash = this._domainHash;
            this._buffer.utmv.value = encodeURI(param1);
            if(this._debug.verbose)
            {
               this._debug.info(this._buffer.utmv.toString(),VisualDebugMode.geek);
            }
            this._debug.info("setVar( " + param1 + " )");
            if(this._takeSample())
            {
               _loc2_ = new Variables();
               _loc2_.utmt = "var";
               this._gifRequest.send(this._account,_loc2_);
            }
         }
         else
         {
            this._debug.warning("setVar \"" + param1 + "\" is ignored");
         }
      }
      
      public function trackPageview(param1:String = "") : void
      {
         this._debug.info("trackPageview( " + param1 + " )");
         if(this._doTracking())
         {
            this._initData();
            this._trackMetrics(param1);
            this._noSessionInformation = false;
         }
         else
         {
            this._debug.warning("trackPageview( " + param1 + " ) failed");
         }
      }
      
      private function _renderMetricsSearchVariables(param1:String = "") : Variables
      {
         var _loc4_:Variables = null;
         var _loc2_:Variables = new Variables();
         _loc2_.URIencode = true;
         var _loc3_:DocumentInfo = new DocumentInfo(this._config,this._info,this._formatedReferrer,param1,this._adSense);
         this._debug.info("docInfo: " + _loc3_.toURLString(),VisualDebugMode.geek);
         if(this._config.campaignTracking)
         {
            _loc4_ = this._campaignInfo.toVariables();
         }
         var _loc5_:Variables = this._browserInfo.toVariables();
         _loc2_.join(_loc3_.toVariables(),_loc5_,_loc4_);
         return _loc2_;
      }
      
      private function _trackMetrics(param1:String = "") : void
      {
         var _loc2_:Variables = null;
         var _loc3_:Variables = null;
         var _loc4_:Variables = null;
         var _loc5_:EventInfo = null;
         if(this._takeSample())
         {
            _loc2_ = new Variables();
            _loc2_.URIencode = true;
            if(Boolean(this._x10Module) && this._x10Module.hasData())
            {
               _loc5_ = new EventInfo(false,this._x10Module);
               _loc3_ = _loc5_.toVariables();
            }
            _loc4_ = this._renderMetricsSearchVariables(param1);
            _loc2_.join(_loc3_,_loc4_);
            this._gifRequest.send(this._account,_loc2_);
         }
      }
      
      public function setAllowAnchor(param1:Boolean) : void
      {
         this._config.allowAnchor = param1;
         this._debug.info("setAllowAnchor( " + this._config.allowAnchor + " )");
      }
      
      public function setCampContentKey(param1:String) : void
      {
         this._config.campaignKey.UCCT = param1;
         var _loc2_:* = "setCampContentKey( " + this._config.campaignKey.UCCT + " )";
         if(this._debug.mode == VisualDebugMode.geek)
         {
            this._debug.info(_loc2_ + " [UCCT]");
         }
         else
         {
            this._debug.info(_loc2_);
         }
      }
      
      public function setCampMediumKey(param1:String) : void
      {
         this._config.campaignKey.UCMD = param1;
         var _loc2_:* = "setCampMediumKey( " + this._config.campaignKey.UCMD + " )";
         if(this._debug.mode == VisualDebugMode.geek)
         {
            this._debug.info(_loc2_ + " [UCMD]");
         }
         else
         {
            this._debug.info(_loc2_);
         }
      }
      
      public function setCampNameKey(param1:String) : void
      {
         this._config.campaignKey.UCCN = param1;
         var _loc2_:* = "setCampNameKey( " + this._config.campaignKey.UCCN + " )";
         if(this._debug.mode == VisualDebugMode.geek)
         {
            this._debug.info(_loc2_ + " [UCCN]");
         }
         else
         {
            this._debug.info(_loc2_);
         }
      }
      
      public function setCampNOKey(param1:String) : void
      {
         this._config.campaignKey.UCNO = param1;
         var _loc2_:* = "setCampNOKey( " + this._config.campaignKey.UCNO + " )";
         if(this._debug.mode == VisualDebugMode.geek)
         {
            this._debug.info(_loc2_ + " [UCNO]");
         }
         else
         {
            this._debug.info(_loc2_);
         }
      }
      
      public function setCampSourceKey(param1:String) : void
      {
         this._config.campaignKey.UCSR = param1;
         var _loc2_:* = "setCampSourceKey( " + this._config.campaignKey.UCSR + " )";
         if(this._debug.mode == VisualDebugMode.geek)
         {
            this._debug.info(_loc2_ + " [UCSR]");
         }
         else
         {
            this._debug.info(_loc2_);
         }
      }
      
      public function setCampTermKey(param1:String) : void
      {
         this._config.campaignKey.UCTR = param1;
         var _loc2_:* = "setCampTermKey( " + this._config.campaignKey.UCTR + " )";
         if(this._debug.mode == VisualDebugMode.geek)
         {
            this._debug.info(_loc2_ + " [UCTR]");
         }
         else
         {
            this._debug.info(_loc2_);
         }
      }
      
      public function setCampaignTrack(param1:Boolean) : void
      {
         this._config.campaignTracking = param1;
         this._debug.info("setCampaignTrack( " + this._config.campaignTracking + " )");
      }
      
      public function setCookieTimeout(param1:int) : void
      {
         this._config.conversionTimeout = param1;
         this._debug.info("setCookieTimeout( " + this._config.conversionTimeout + " )");
      }
      
      public function cookiePathCopy(param1:String) : void
      {
         this._debug.warning("cookiePathCopy( " + param1 + " ) not implemented");
      }
      
      public function getLinkerUrl(param1:String = "", param2:Boolean = false) : String
      {
         this._initData();
         this._debug.info("getLinkerUrl( " + param1 + ", " + param2.toString() + " )");
         return this._buffer.getLinkerUrl(param1,param2);
      }
      
      public function link(param1:String, param2:Boolean = false) : void
      {
         var out:String;
         var request:URLRequest;
         var targetUrl:String = param1;
         var useHash:Boolean = param2;
         this._initData();
         out = this._buffer.getLinkerUrl(targetUrl,useHash);
         request = new URLRequest(out);
         this._debug.info("link( " + [targetUrl,useHash].join(",") + " )");
         try
         {
            navigateToURL(request,"_top");
         }
         catch(e:Error)
         {
            _debug.warning("An error occured in link() msg: " + e.message);
         }
      }
      
      public function linkByPost(param1:Object, param2:Boolean = false) : void
      {
         this._debug.warning("linkByPost not implemented in AS3 mode");
      }
      
      public function setAllowHash(param1:Boolean) : void
      {
         this._config.allowDomainHash = param1;
         this._debug.info("setAllowHash( " + this._config.allowDomainHash + " )");
      }
      
      public function setAllowLinker(param1:Boolean) : void
      {
         this._config.allowLinker = param1;
         this._debug.info("setAllowLinker( " + this._config.allowLinker + " )");
      }
      
      public function setCookiePath(param1:String) : void
      {
         this._config.cookiePath = param1;
         this._debug.info("setCookiePath( " + this._config.cookiePath + " )");
      }
      
      public function setDomainName(param1:String) : void
      {
         if(param1 == "auto")
         {
            this._config.domain.mode = DomainNameMode.auto;
         }
         else if(param1 == "none")
         {
            this._config.domain.mode = DomainNameMode.none;
         }
         else
         {
            this._config.domain.mode = DomainNameMode.custom;
            this._config.domain.name = param1;
         }
         this._updateDomainName();
         this._debug.info("setDomainName( " + this._config.domainName + " )");
      }
      
      public function addItem(param1:String, param2:String, param3:String, param4:String, param5:Number, param6:int) : void
      {
         var _loc7_:Transaction = null;
         _loc7_ = this._ecom.getTransaction(param1);
         if(_loc7_ == null)
         {
            _loc7_ = this._ecom.addTransaction(param1,"","","","","","","");
         }
         _loc7_.addItem(param2,param3,param4,param5.toString(),param6.toString());
         if(this._debug.active)
         {
            this._debug.info("addItem( " + [param1,param2,param3,param4,param5,param6].join(", ") + " )");
         }
      }
      
      public function addTrans(param1:String, param2:String, param3:Number, param4:Number, param5:Number, param6:String, param7:String, param8:String) : void
      {
         this._ecom.addTransaction(param1,param2,param3.toString(),param4.toString(),param5.toString(),param6,param7,param8);
         if(this._debug.active)
         {
            this._debug.info("addTrans( " + [param1,param2,param3,param4,param5,param6,param7,param8].join(", ") + " );");
         }
      }
      
      public function trackTrans() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc4_:Transaction = null;
         this._initData();
         var _loc3_:Array = new Array();
         if(this._takeSample())
         {
            _loc1_ = 0;
            while(_loc1_ < this._ecom.getTransLength())
            {
               _loc4_ = this._ecom.getTransFromArray(_loc1_);
               _loc3_.push(_loc4_.toGifParams());
               _loc2_ = 0;
               while(_loc2_ < _loc4_.getItemsLength())
               {
                  _loc3_.push(_loc4_.getItemFromArray(_loc2_).toGifParams());
                  _loc2_++;
               }
               _loc1_++;
            }
            _loc1_ = 0;
            while(_loc1_ < _loc3_.length)
            {
               this._gifRequest.send(this._account,_loc3_[_loc1_]);
               _loc1_++;
            }
         }
      }
      
      private function _sendXEvent(param1:X10 = null) : void
      {
         var _loc2_:Variables = null;
         var _loc3_:EventInfo = null;
         var _loc4_:Variables = null;
         var _loc5_:Variables = null;
         if(this._takeSample())
         {
            _loc2_ = new Variables();
            _loc2_.URIencode = true;
            _loc3_ = new EventInfo(true,this._x10Module,param1);
            _loc4_ = _loc3_.toVariables();
            _loc5_ = this._renderMetricsSearchVariables();
            _loc2_.join(_loc4_,_loc5_);
            this._gifRequest.send(this._account,_loc2_,false,true);
         }
      }
      
      public function createEventTracker(param1:String) : EventTracker
      {
         this._debug.info("createEventTracker( " + param1 + " )");
         return new EventTracker(param1,this);
      }
      
      public function trackEvent(param1:String, param2:String, param3:String = null, param4:Number = NaN) : Boolean
      {
         this._initData();
         var _loc5_:Boolean = true;
         var _loc6_:int = 2;
         if(param1 != "" && param2 != "")
         {
            this._eventTracker.clearKey(this.EVENT_TRACKER_PROJECT_ID);
            this._eventTracker.clearValue(this.EVENT_TRACKER_PROJECT_ID);
            _loc5_ = this._eventTracker.setKey(this.EVENT_TRACKER_PROJECT_ID,this.EVENT_TRACKER_OBJECT_NAME_KEY_NUM,param1);
            _loc5_ = this._eventTracker.setKey(this.EVENT_TRACKER_PROJECT_ID,this.EVENT_TRACKER_TYPE_KEY_NUM,param2);
            if(param3)
            {
               _loc5_ = this._eventTracker.setKey(this.EVENT_TRACKER_PROJECT_ID,this.EVENT_TRACKER_LABEL_KEY_NUM,param3);
               _loc6_ = 3;
            }
            if(!isNaN(param4))
            {
               _loc5_ = this._eventTracker.setValue(this.EVENT_TRACKER_PROJECT_ID,this.EVENT_TRACKER_VALUE_VALUE_NUM,param4);
               _loc6_ = 4;
            }
            if(_loc5_)
            {
               this._debug.info("valid event tracking call\ncategory: " + param1 + "\naction: " + param2,VisualDebugMode.geek);
               this._sendXEvent(this._eventTracker);
            }
         }
         else
         {
            this._debug.warning("event tracking call is not valid, failed!\ncategory: " + param1 + "\naction: " + param2,VisualDebugMode.geek);
            _loc5_ = false;
         }
         switch(_loc6_)
         {
            case 4:
               this._debug.info("trackEvent( " + [param1,param2,param3,param4].join(", ") + " )");
               break;
            case 3:
               this._debug.info("trackEvent( " + [param1,param2,param3].join(", ") + " )");
               break;
            case 2:
            default:
               this._debug.info("trackEvent( " + [param1,param2].join(", ") + " )");
         }
         return _loc5_;
      }
      
      public function addIgnoredOrganic(param1:String) : void
      {
         this._debug.info("addIgnoredOrganic( " + param1 + " )");
         this._config.organic.addIgnoredKeyword(param1);
      }
      
      public function addIgnoredRef(param1:String) : void
      {
         this._debug.info("addIgnoredRef( " + param1 + " )");
         this._config.organic.addIgnoredReferral(param1);
      }
      
      public function addOrganic(param1:String, param2:String) : void
      {
         this._debug.info("addOrganic( " + [param1,param2].join(", ") + " )");
         this._config.organic.addSource(param1,param2);
      }
      
      public function clearIgnoredOrganic() : void
      {
         this._debug.info("clearIgnoredOrganic()");
         this._config.organic.clearIgnoredKeywords();
      }
      
      public function clearIgnoredRef() : void
      {
         this._debug.info("clearIgnoredRef()");
         this._config.organic.clearIgnoredReferrals();
      }
      
      public function clearOrganic() : void
      {
         this._debug.info("clearOrganic()");
         this._config.organic.clearEngines();
      }
      
      public function getClientInfo() : Boolean
      {
         this._debug.info("getClientInfo()");
         return this._config.detectClientInfo;
      }
      
      public function getDetectFlash() : Boolean
      {
         this._debug.info("getDetectFlash()");
         return this._config.detectFlash;
      }
      
      public function getDetectTitle() : Boolean
      {
         this._debug.info("getDetectTitle()");
         return this._config.detectTitle;
      }
      
      public function setClientInfo(param1:Boolean) : void
      {
         this._config.detectClientInfo = param1;
         this._debug.info("setClientInfo( " + this._config.detectClientInfo + " )");
      }
      
      public function setDetectFlash(param1:Boolean) : void
      {
         this._config.detectFlash = param1;
         this._debug.info("setDetectFlash( " + this._config.detectFlash + " )");
      }
      
      public function setDetectTitle(param1:Boolean) : void
      {
         this._config.detectTitle = param1;
         this._debug.info("setDetectTitle( " + this._config.detectTitle + " )");
      }
      
      public function getLocalGifPath() : String
      {
         this._debug.info("getLocalGifPath()");
         return this._config.localGIFpath;
      }
      
      public function getServiceMode() : ServerOperationMode
      {
         this._debug.info("getServiceMode()");
         return this._config.serverMode;
      }
      
      public function setLocalGifPath(param1:String) : void
      {
         this._config.localGIFpath = param1;
         this._debug.info("setLocalGifPath( " + this._config.localGIFpath + " )");
      }
      
      public function setLocalRemoteServerMode() : void
      {
         this._config.serverMode = ServerOperationMode.both;
         this._debug.info("setLocalRemoteServerMode()");
      }
      
      public function setLocalServerMode() : void
      {
         this._config.serverMode = ServerOperationMode.local;
         this._debug.info("setLocalServerMode()");
      }
      
      public function setRemoteServerMode() : void
      {
         this._config.serverMode = ServerOperationMode.remote;
         this._debug.info("setRemoteServerMode()");
      }
   }
}

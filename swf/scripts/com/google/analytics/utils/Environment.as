package com.google.analytics.utils
{
   import com.google.analytics.core.ga_internal;
   import com.google.analytics.debug.DebugConfiguration;
   import com.google.analytics.external.HTMLDOM;
   import flash.system.Capabilities;
   import flash.system.Security;
   import flash.system.System;
   
   public class Environment
   {
       
      
      private var _debug:DebugConfiguration;
      
      private var _dom:HTMLDOM;
      
      private var _protocol:Protocols;
      
      private var _appName:String;
      
      private var _appVersion:Version;
      
      private var _userAgent:UserAgent;
      
      private var _url:String;
      
      public function Environment(param1:String = "", param2:String = "", param3:String = "", param4:DebugConfiguration = null, param5:HTMLDOM = null)
      {
         var _loc6_:Version = null;
         super();
         if(param2 == "")
         {
            if(this.isAIR())
            {
               param2 = "AIR";
            }
            else
            {
               param2 = "Flash";
            }
         }
         if(param3 == "")
         {
            _loc6_ = this.flashVersion;
         }
         else
         {
            _loc6_ = Version.fromString(param3);
         }
         this._url = param1;
         this._appName = param2;
         this._appVersion = _loc6_;
         this._debug = param4;
         this._dom = param5;
      }
      
      private function _findProtocol() : void
      {
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc1_:Protocols = Protocols.none;
         if(this._url != "")
         {
            _loc4_ = this._url.toLowerCase();
            _loc5_ = _loc4_.substr(0,5);
            switch(_loc5_)
            {
               case "file:":
                  _loc1_ = Protocols.file;
                  break;
               case "http:":
                  _loc1_ = Protocols.HTTP;
                  break;
               case "https":
                  if(_loc4_.charAt(5) == ":")
                  {
                     _loc1_ = Protocols.HTTPS;
                  }
                  break;
               default:
                  this._protocol = Protocols.none;
            }
         }
         var _loc2_:String = this._dom.protocol;
         var _loc3_:String = (_loc1_.toString() + ":").toLowerCase();
         if(_loc2_ && _loc2_ != _loc3_ && Boolean(this._debug))
         {
            this._debug.warning("Protocol mismatch: SWF=" + _loc3_ + ", DOM=" + _loc2_);
         }
         this._protocol = _loc1_;
      }
      
      public function get appName() : String
      {
         return this._appName;
      }
      
      public function set appName(param1:String) : void
      {
         this._appName = param1;
         this.userAgent.applicationProduct = param1;
      }
      
      public function get appVersion() : Version
      {
         return this._appVersion;
      }
      
      public function set appVersion(param1:Version) : void
      {
         this._appVersion = param1;
         this.userAgent.applicationVersion = param1.toString(4);
      }
      
      ga_internal function set url(param1:String) : void
      {
         this._url = param1;
      }
      
      public function get locationSWFPath() : String
      {
         return this._url;
      }
      
      public function get referrer() : String
      {
         var _loc1_:String = this._dom.referrer;
         if(_loc1_)
         {
            return _loc1_;
         }
         if(this.protocol == Protocols.file)
         {
            return "localhost";
         }
         return "";
      }
      
      public function get documentTitle() : String
      {
         var _loc1_:String = this._dom.title;
         if(_loc1_)
         {
            return _loc1_;
         }
         return "";
      }
      
      public function get domainName() : String
      {
         var _loc1_:String = null;
         var _loc2_:String = null;
         var _loc3_:int = 0;
         if(this.protocol == Protocols.HTTP || this.protocol == Protocols.HTTPS)
         {
            _loc1_ = this._url.toLowerCase();
            if(this.protocol == Protocols.HTTP)
            {
               _loc2_ = _loc1_.split("http://").join("");
            }
            else if(this.protocol == Protocols.HTTPS)
            {
               _loc2_ = _loc1_.split("https://").join("");
            }
            _loc3_ = _loc2_.indexOf("/");
            if(_loc3_ > -1)
            {
               _loc2_ = _loc2_.substring(0,_loc3_);
            }
            return _loc2_;
         }
         if(this.protocol == Protocols.file)
         {
            return "localhost";
         }
         return "";
      }
      
      public function isAIR() : Boolean
      {
         return this.playerType == "Desktop" && Security.sandboxType.toString() == "application";
      }
      
      public function isInHTML() : Boolean
      {
         return Capabilities.playerType == "PlugIn";
      }
      
      public function get locationPath() : String
      {
         var _loc1_:String = this._dom.pathname;
         if(_loc1_)
         {
            return _loc1_;
         }
         return "";
      }
      
      public function get locationSearch() : String
      {
         var _loc1_:String = this._dom.search;
         if(_loc1_)
         {
            return _loc1_;
         }
         return "";
      }
      
      public function get flashVersion() : Version
      {
         return Version.fromString(Capabilities.version.split(" ")[1],",");
      }
      
      public function get language() : String
      {
         var _loc1_:String = this._dom.language;
         var _loc2_:String = Capabilities.language;
         if(_loc1_)
         {
            if(_loc1_.length > _loc2_.length && _loc1_.substr(0,_loc2_.length) == _loc2_)
            {
               _loc2_ = _loc1_;
            }
         }
         return _loc2_;
      }
      
      public function get languageEncoding() : String
      {
         var _loc1_:String = null;
         if(System.useCodePage)
         {
            _loc1_ = this._dom.characterSet;
            if(_loc1_)
            {
               return _loc1_;
            }
            return "-";
         }
         return "UTF-8";
      }
      
      public function get operatingSystem() : String
      {
         return Capabilities.os;
      }
      
      public function get playerType() : String
      {
         return Capabilities.playerType;
      }
      
      public function get platform() : String
      {
         var _loc1_:String = Capabilities.manufacturer;
         return _loc1_.split("Adobe ")[1];
      }
      
      public function get protocol() : Protocols
      {
         if(!this._protocol)
         {
            this._findProtocol();
         }
         return this._protocol;
      }
      
      public function get screenHeight() : Number
      {
         return Capabilities.screenResolutionY;
      }
      
      public function get screenWidth() : Number
      {
         return Capabilities.screenResolutionX;
      }
      
      public function get screenColorDepth() : String
      {
         var _loc1_:String = null;
         switch(Capabilities.screenColor)
         {
            case "bw":
               _loc1_ = "1";
               break;
            case "gray":
               _loc1_ = "2";
               break;
            case "color":
            default:
               _loc1_ = "24";
         }
         var _loc2_:String = this._dom.colorDepth;
         if(_loc2_)
         {
            _loc1_ = _loc2_;
         }
         return _loc1_;
      }
      
      public function get userAgent() : UserAgent
      {
         if(!this._userAgent)
         {
            this._userAgent = new UserAgent(this,this.appName,this.appVersion.toString(4));
         }
         return this._userAgent;
      }
      
      public function set userAgent(param1:UserAgent) : void
      {
         this._userAgent = param1;
      }
   }
}

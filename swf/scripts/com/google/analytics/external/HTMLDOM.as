package com.google.analytics.external
{
   import com.google.analytics.debug.DebugConfiguration;
   
   public class HTMLDOM extends JavascriptProxy
   {
      
      public static var cache_properties_js:XML = <script>
            <![CDATA[
                    function()
                    {
                        var obj = {};
                            obj.host         = document.location.host;
                            obj.language     = navigator.language ? navigator.language : navigator.browserLanguage;
                            obj.characterSet = document.characterSet ? document.characterSet : document.charset;
                            obj.colorDepth   = window.screen.colorDepth;
                            obj.location     = document.location.toString();
                            obj.pathname     = document.location.pathname;
                            obj.protocol     = document.location.protocol;
                            obj.search       = document.location.search;
                            obj.referrer     = document.referrer;
                            obj.title        = document.title;
                        
                        return obj;
                    }
                ]]>
         </script>;
       
      
      private var _host:String;
      
      private var _language:String;
      
      private var _characterSet:String;
      
      private var _colorDepth:String;
      
      private var _location:String;
      
      private var _pathname:String;
      
      private var _protocol:String;
      
      private var _search:String;
      
      private var _referrer:String;
      
      private var _title:String;
      
      public function HTMLDOM(param1:DebugConfiguration)
      {
         super(param1);
      }
      
      public function cacheProperties() : void
      {
         if(!isAvailable())
         {
            return;
         }
         var _loc1_:Object = call(cache_properties_js);
         if(_loc1_)
         {
            this._host = _loc1_.host;
            this._language = _loc1_.language;
            this._characterSet = _loc1_.characterSet;
            this._colorDepth = _loc1_.colorDepth;
            this._location = _loc1_.location;
            this._pathname = _loc1_.pathname;
            this._protocol = _loc1_.protocol;
            this._search = _loc1_.search;
            this._referrer = _loc1_.referrer;
            this._title = _loc1_.title;
         }
      }
      
      public function get host() : String
      {
         if(this._host)
         {
            return this._host;
         }
         if(!isAvailable())
         {
            return null;
         }
         this._host = getProperty("document.location.host");
         return this._host;
      }
      
      public function get language() : String
      {
         if(this._language)
         {
            return this._language;
         }
         if(!isAvailable())
         {
            return null;
         }
         var _loc1_:String = getProperty("navigator.language");
         if(_loc1_ == null)
         {
            _loc1_ = getProperty("navigator.browserLanguage");
         }
         this._language = _loc1_;
         return this._language;
      }
      
      public function get characterSet() : String
      {
         if(this._characterSet)
         {
            return this._characterSet;
         }
         if(!isAvailable())
         {
            return null;
         }
         var _loc1_:String = getProperty("document.characterSet");
         if(_loc1_ == null)
         {
            _loc1_ = getProperty("document.charset");
         }
         this._characterSet = _loc1_;
         return this._characterSet;
      }
      
      public function get colorDepth() : String
      {
         if(this._colorDepth)
         {
            return this._colorDepth;
         }
         if(!isAvailable())
         {
            return null;
         }
         this._colorDepth = getProperty("window.screen.colorDepth");
         return this._colorDepth;
      }
      
      public function get location() : String
      {
         if(this._location)
         {
            return this._location;
         }
         if(!isAvailable())
         {
            return null;
         }
         this._location = getPropertyString("document.location");
         return this._location;
      }
      
      public function get pathname() : String
      {
         if(this._pathname)
         {
            return this._pathname;
         }
         if(!isAvailable())
         {
            return null;
         }
         this._pathname = getProperty("document.location.pathname");
         return this._pathname;
      }
      
      public function get protocol() : String
      {
         if(this._protocol)
         {
            return this._protocol;
         }
         if(!isAvailable())
         {
            return null;
         }
         this._protocol = getProperty("document.location.protocol");
         return this._protocol;
      }
      
      public function get search() : String
      {
         if(this._search)
         {
            return this._search;
         }
         if(!isAvailable())
         {
            return null;
         }
         this._search = getProperty("document.location.search");
         return this._search;
      }
      
      public function get referrer() : String
      {
         if(this._referrer)
         {
            return this._referrer;
         }
         if(!isAvailable())
         {
            return null;
         }
         this._referrer = getProperty("document.referrer");
         return this._referrer;
      }
      
      public function get title() : String
      {
         if(this._title)
         {
            return this._title;
         }
         if(!isAvailable())
         {
            return null;
         }
         this._title = getProperty("document.title");
         return this._title;
      }
   }
}

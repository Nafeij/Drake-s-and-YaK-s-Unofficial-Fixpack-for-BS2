package com.google.analytics.core
{
   import com.google.analytics.external.AdSenseGlobals;
   import com.google.analytics.utils.Environment;
   import com.google.analytics.utils.Variables;
   import com.google.analytics.v4.Configuration;
   
   public class DocumentInfo
   {
       
      
      private var _config:Configuration;
      
      private var _info:Environment;
      
      private var _adSense:AdSenseGlobals;
      
      private var _pageURL:String;
      
      private var _utmr:String;
      
      public function DocumentInfo(param1:Configuration, param2:Environment, param3:String, param4:String = null, param5:AdSenseGlobals = null)
      {
         super();
         this._config = param1;
         this._info = param2;
         this._adSense = param5;
      }
      
      private function _generateHitId() : Number
      {
         var _loc1_:Number = NaN;
         if(Boolean(this._adSense.hid) && this._adSense.hid != "")
         {
            _loc1_ = Number(this._adSense.hid);
         }
         else
         {
            _loc1_ = Math.round(Math.random() * 2147483647);
            this._adSense.hid = String(_loc1_);
         }
         return _loc1_;
      }
      
      private function _renderPageURL(param1:String = "") : String
      {
         var _loc2_:String = this._info.locationPath;
         var _loc3_:String = this._info.locationSearch;
         if(!param1 || param1 == "")
         {
            param1 = _loc2_ + unescape(_loc3_);
            if(param1 == "")
            {
               param1 = "/";
            }
         }
         return param1;
      }
      
      public function get utmdt() : String
      {
         return this._info.documentTitle;
      }
      
      public function get utmhid() : String
      {
         return String(this._generateHitId());
      }
      
      public function get utmr() : String
      {
         if(!this._utmr)
         {
            return "-";
         }
         return "";
      }
      
      public function get utmp() : String
      {
         return this._renderPageURL(this._pageURL);
      }
      
      public function toVariables() : Variables
      {
         var _loc1_:Variables = new Variables();
         _loc1_.URIencode = true;
         if(this._config.detectTitle && this.utmdt != "")
         {
            _loc1_.utmdt = this.utmdt;
         }
         _loc1_.utmhid = this.utmhid;
         _loc1_.utmr = "";
         _loc1_.utmp = this.utmp;
         return _loc1_;
      }
      
      public function toURLString() : String
      {
         var _loc1_:Variables = this.toVariables();
         return _loc1_.toString();
      }
   }
}

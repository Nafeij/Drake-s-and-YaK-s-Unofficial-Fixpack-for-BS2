package com.google.analytics.core
{
   import com.google.analytics.utils.Environment;
   import com.google.analytics.utils.Variables;
   import com.google.analytics.utils.Version;
   import com.google.analytics.v4.Configuration;
   
   public class BrowserInfo
   {
       
      
      private var _config:Configuration;
      
      private var _info:Environment;
      
      public function BrowserInfo(param1:Configuration, param2:Environment)
      {
         super();
         this._config = param1;
         this._info = param2;
      }
      
      public function get utmcs() : String
      {
         return this._info.languageEncoding;
      }
      
      public function get utmsr() : String
      {
         return this._info.screenWidth + "x" + this._info.screenHeight;
      }
      
      public function get utmsc() : String
      {
         return this._info.screenColorDepth + "-bit";
      }
      
      public function get utmul() : String
      {
         return this._info.language.toLowerCase();
      }
      
      public function get utmje() : String
      {
         return "0";
      }
      
      public function get utmfl() : String
      {
         var _loc1_:Version = null;
         if(this._config.detectFlash)
         {
            _loc1_ = this._info.flashVersion;
            return _loc1_.major + "." + _loc1_.minor + " r" + _loc1_.build;
         }
         return "-";
      }
      
      public function toVariables() : Variables
      {
         var _loc1_:Variables = new Variables();
         _loc1_.URIencode = true;
         _loc1_.utmcs = this.utmcs;
         _loc1_.utmsr = this.utmsr;
         _loc1_.utmsc = this.utmsc;
         _loc1_.utmul = this.utmul;
         _loc1_.utmje = this.utmje;
         _loc1_.utmfl = this.utmfl;
         return _loc1_;
      }
      
      public function toURLString() : String
      {
         var _loc1_:Variables = this.toVariables();
         return _loc1_.toString();
      }
   }
}

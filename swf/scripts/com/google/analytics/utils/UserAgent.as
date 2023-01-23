package com.google.analytics.utils
{
   import com.google.analytics.core.Utils;
   import flash.system.Capabilities;
   import flash.system.System;
   
   public class UserAgent
   {
      
      public static var minimal:Boolean = false;
       
      
      private var _applicationProduct:String;
      
      private var _localInfo:Environment;
      
      private var _version:Version;
      
      public function UserAgent(param1:Environment, param2:String = "", param3:String = "")
      {
         super();
         this._localInfo = param1;
         this.applicationProduct = param2;
         this._version = Version.fromString(param3);
      }
      
      public function get applicationComment() : String
      {
         var _loc1_:Array = [];
         _loc1_.push(this._localInfo.platform);
         _loc1_.push(this._localInfo.playerType);
         if(!UserAgent.minimal)
         {
            _loc1_.push(this._localInfo.operatingSystem);
            _loc1_.push(this._localInfo.language);
         }
         if(Capabilities.isDebugger)
         {
            _loc1_.push("DEBUG");
         }
         if(_loc1_.length > 0)
         {
            return "(" + _loc1_.join("; ") + ")";
         }
         return "";
      }
      
      public function get applicationProduct() : String
      {
         return this._applicationProduct;
      }
      
      public function set applicationProduct(param1:String) : void
      {
         this._applicationProduct = param1;
      }
      
      public function get applicationProductToken() : String
      {
         var _loc1_:String = this.applicationProduct;
         if(this.applicationVersion != "")
         {
            _loc1_ += "/" + this.applicationVersion;
         }
         return _loc1_;
      }
      
      public function get applicationVersion() : String
      {
         return this._version.toString(2);
      }
      
      public function set applicationVersion(param1:String) : void
      {
         this._version = Version.fromString(param1);
      }
      
      public function get tamarinProductToken() : String
      {
         if(UserAgent.minimal)
         {
            return "";
         }
         if(System.vmVersion)
         {
            return "Tamarin/" + Utils.trim(System.vmVersion,true);
         }
         return "";
      }
      
      public function get vendorProductToken() : String
      {
         var _loc1_:* = "";
         if(this._localInfo.isAIR())
         {
            _loc1_ += "AIR";
         }
         else
         {
            _loc1_ += "FlashPlayer";
         }
         _loc1_ += "/";
         return _loc1_ + this._version.toString(3);
      }
      
      public function toString() : String
      {
         var _loc1_:String = "";
         _loc1_ += this.applicationProductToken;
         if(this.applicationComment != "")
         {
            _loc1_ += " " + this.applicationComment;
         }
         if(this.tamarinProductToken != "")
         {
            _loc1_ += " " + this.tamarinProductToken;
         }
         if(this.vendorProductToken != "")
         {
            _loc1_ += " " + this.vendorProductToken;
         }
         return _loc1_;
      }
   }
}

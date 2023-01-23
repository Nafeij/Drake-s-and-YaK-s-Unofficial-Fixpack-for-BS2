package com.google.analytics.data
{
   import com.google.analytics.utils.Timespan;
   
   public class UTMV extends UTMCookie
   {
       
      
      private var _domainHash:Number;
      
      private var _value:String;
      
      public function UTMV(param1:Number = NaN, param2:String = "")
      {
         super("utmv","__utmv",["domainHash","value"],Timespan.twoyears * 1000);
         this.domainHash = param1;
         this.value = param2;
      }
      
      public function get domainHash() : Number
      {
         return this._domainHash;
      }
      
      public function set domainHash(param1:Number) : void
      {
         this._domainHash = param1;
         update();
      }
      
      public function get value() : String
      {
         return this._value;
      }
      
      public function set value(param1:String) : void
      {
         this._value = param1;
         update();
      }
   }
}

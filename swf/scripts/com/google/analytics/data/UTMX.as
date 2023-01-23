package com.google.analytics.data
{
   public class UTMX extends UTMCookie
   {
       
      
      private var _value:String;
      
      public function UTMX()
      {
         super("utmx","__utmx",["value"],0);
         this._value = "-";
      }
      
      public function get value() : String
      {
         return this._value;
      }
      
      public function set value(param1:String) : void
      {
         this._value = param1;
      }
   }
}

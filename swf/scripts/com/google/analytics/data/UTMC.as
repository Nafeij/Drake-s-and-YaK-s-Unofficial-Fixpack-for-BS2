package com.google.analytics.data
{
   public class UTMC extends UTMCookie
   {
       
      
      private var _domainHash:Number;
      
      public function UTMC(param1:Number = NaN)
      {
         super("utmc","__utmc",["domainHash"]);
         this.domainHash = param1;
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
   }
}

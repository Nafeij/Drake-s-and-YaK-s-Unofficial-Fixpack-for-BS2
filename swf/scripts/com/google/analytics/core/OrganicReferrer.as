package com.google.analytics.core
{
   public class OrganicReferrer
   {
       
      
      private var _engine:String;
      
      private var _keyword:String;
      
      public function OrganicReferrer(param1:String, param2:String)
      {
         super();
         this.engine = param1;
         this.keyword = param2;
      }
      
      public function get engine() : String
      {
         return this._engine;
      }
      
      public function set engine(param1:String) : void
      {
         this._engine = param1.toLowerCase();
      }
      
      public function get keyword() : String
      {
         return this._keyword;
      }
      
      public function set keyword(param1:String) : void
      {
         this._keyword = param1.toLowerCase();
      }
      
      public function toString() : String
      {
         return this.engine + "?" + this.keyword;
      }
   }
}

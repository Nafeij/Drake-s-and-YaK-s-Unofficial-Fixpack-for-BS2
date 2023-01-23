package com.google.analytics.core
{
   public class DomainNameMode
   {
      
      public static const none:DomainNameMode = new DomainNameMode(0,"none");
      
      public static const auto:DomainNameMode = new DomainNameMode(1,"auto");
      
      public static const custom:DomainNameMode = new DomainNameMode(2,"custom");
       
      
      private var _value:int;
      
      private var _name:String;
      
      public function DomainNameMode(param1:int = 0, param2:String = "")
      {
         super();
         this._value = param1;
         this._name = param2;
      }
      
      public function valueOf() : int
      {
         return this._value;
      }
      
      public function toString() : String
      {
         return this._name;
      }
   }
}

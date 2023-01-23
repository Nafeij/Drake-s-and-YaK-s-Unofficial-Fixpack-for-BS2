package com.google.analytics.debug
{
   public class VisualDebugMode
   {
      
      public static const basic:VisualDebugMode = new VisualDebugMode(0,"basic");
      
      public static const advanced:VisualDebugMode = new VisualDebugMode(1,"advanced");
      
      public static const geek:VisualDebugMode = new VisualDebugMode(2,"geek");
       
      
      private var _name:String;
      
      private var _value:int;
      
      public function VisualDebugMode(param1:int = 0, param2:String = "")
      {
         super();
         this._value = param1;
         this._name = param2;
      }
      
      public function toString() : String
      {
         return this._name;
      }
      
      public function valueOf() : int
      {
         return this._value;
      }
   }
}

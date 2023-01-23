package com.sociodox.theminer.data
{
   public class FunctionCall
   {
      
      private static var mNext:int = 0;
       
      
      public var _fqcn:String;
      
      public var _lineNumber:uint;
      
      public var _methodName:String;
      
      public var _methodArguments:String;
      
      public function FunctionCall(param1:String, param2:uint, param3:String, param4:String)
      {
         super();
         this._fqcn = param1;
         this._lineNumber = param2;
         this._methodName = param3;
         this._methodArguments = param4;
      }
   }
}

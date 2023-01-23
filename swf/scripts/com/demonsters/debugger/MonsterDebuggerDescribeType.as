package com.demonsters.debugger
{
   import flash.utils.describeType;
   import flash.utils.getQualifiedClassName;
   
   internal class MonsterDebuggerDescribeType
   {
      
      private static var cache:Object = {};
       
      
      public function MonsterDebuggerDescribeType()
      {
         super();
      }
      
      internal static function get(param1:*) : XML
      {
         var _loc2_:String = getQualifiedClassName(param1);
         if(_loc2_ in cache)
         {
            return cache[_loc2_];
         }
         var _loc3_:XML = describeType(param1);
         cache[_loc2_] = _loc3_;
         return _loc3_;
      }
   }
}

package engine.core.util
{
   import flash.utils.describeType;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   public class UtilFunctions
   {
       
      
      public function UtilFunctions()
      {
         super();
      }
      
      private static function newSibling(param1:Object) : *
      {
         var _loc2_:* = undefined;
         var _loc3_:Class = null;
         if(param1)
         {
            _loc3_ = getDefinitionByName(getQualifiedClassName(param1)) as Class;
            return new _loc3_();
         }
         return null;
      }
      
      public static function clone(param1:Object) : Object
      {
         var _loc2_:Object = null;
         if(param1)
         {
            _loc2_ = newSibling(param1);
            if(_loc2_)
            {
               copyData(param1,_loc2_);
            }
         }
         return _loc2_;
      }
      
      private static function copyData(param1:Object, param2:Object) : void
      {
         var _loc3_:XML = null;
         var _loc4_:XML = null;
         var _loc5_:* = null;
         if(Boolean(param1) && Boolean(param2))
         {
            _loc3_ = describeType(param1);
            for each(_loc4_ in _loc3_.variable)
            {
               if(param2.hasOwnProperty(_loc4_.@name))
               {
                  param2[_loc4_.@name] = param1[_loc4_.@name];
               }
            }
            for each(_loc4_ in _loc3_.accessor)
            {
               if(_loc4_.@access == "readwrite")
               {
                  if(param2.hasOwnProperty(_loc4_.@name))
                  {
                     param2[_loc4_.@name] = param1[_loc4_.@name];
                  }
               }
            }
            for(_loc5_ in param1)
            {
               param2[_loc5_] = param1[_loc5_];
            }
         }
      }
      
      public static function safety(param1:Number) : Number
      {
         return isNaN(param1) ? 0 : param1;
      }
      
      public static function GetProperty(param1:String, param2:Object) : *
      {
         if(param2 != null && param2.hasOwnProperty(param1) && param2[param1] != "")
         {
            return param2[param1];
         }
         return null;
      }
   }
}

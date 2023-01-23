package engine.core.util
{
   public class StableJson
   {
      
      public static var customParseFunc:Function;
       
      
      public function StableJson()
      {
         super();
      }
      
      public static function parse(param1:String) : *
      {
         if(customParseFunc != null)
         {
            return customParseFunc(param1);
         }
         return JSON.parse(param1);
      }
      
      public static function stringify(param1:*, param2:Function = null, param3:String = "", param4:String = "") : String
      {
         var _loc5_:String = null;
         if(param1 == null || param1 == undefined)
         {
            return "null";
         }
         if(param1 is String)
         {
            _loc5_ = param1 as String;
            _loc5_ = _loc5_.replace(/\\\"/g,"\"");
            _loc5_ = _loc5_.replace(/\"/g,"\\\"");
            _loc5_ = _loc5_.replace(/\n/g,"\\n");
            return "\"" + _loc5_ + "\"";
         }
         if(param1 is Number)
         {
            if(isNaN(param1))
            {
               return "0";
            }
            return param1;
         }
         if(param1 is uint || param1 is int || param1 is Boolean)
         {
            return param1;
         }
         if(param1 is Array)
         {
            return stringifyArray(param1,param3,param4);
         }
         if(param1 is Object)
         {
            return stringifyObject(param1,param3,param4);
         }
         return "null";
      }
      
      public static function stringifyArray(param1:Array, param2:String = "", param3:String = "") : String
      {
         var _loc6_:Boolean = false;
         var _loc7_:* = undefined;
         var _loc4_:* = "[";
         var _loc5_:String = param3 + param2;
         for each(_loc7_ in param1)
         {
            if(_loc6_)
            {
               _loc4_ += ",\n";
            }
            else
            {
               _loc4_ += "\n";
            }
            _loc4_ += _loc5_ + stringify(_loc7_,null,param2,_loc5_);
            _loc6_ = true;
         }
         if(_loc6_)
         {
            _loc4_ += "\n" + param3 + "]";
         }
         else
         {
            _loc4_ += "]";
         }
         return _loc4_;
      }
      
      public static function stringifyObject(param1:Object, param2:String = "", param3:String = "") : String
      {
         var _loc7_:Boolean = false;
         var _loc9_:* = undefined;
         var _loc10_:* = undefined;
         var _loc4_:* = "{\n";
         var _loc5_:String = param3 + param2;
         var _loc6_:String = _loc5_ + param2;
         var _loc8_:Array = [];
         for(_loc9_ in param1)
         {
            _loc8_.push(_loc9_);
         }
         _loc8_.sort();
         for each(_loc9_ in _loc8_)
         {
            _loc10_ = param1[_loc9_];
            if(_loc7_)
            {
               _loc4_ += ",\n";
            }
            _loc4_ += _loc5_ + "\"" + _loc9_ + "\": ";
            _loc4_ += stringify(_loc10_,null,param2,_loc5_);
            _loc7_ = true;
         }
         if(_loc7_)
         {
            _loc4_ += "\n";
         }
         return _loc4_ + (param3 + "}");
      }
   }
}

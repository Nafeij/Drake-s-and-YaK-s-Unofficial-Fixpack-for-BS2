package engine.core.util
{
   import engine.core.logging.ILogger;
   import engine.math.Rng;
   import flash.errors.IllegalOperationError;
   import flash.utils.Dictionary;
   
   public class ArrayUtil
   {
       
      
      public function ArrayUtil()
      {
         super();
      }
      
      public static function cloneDictionary(param1:Dictionary) : Dictionary
      {
         return combineDictionaries(param1,null);
      }
      
      public static function combineDictionaries(param1:Dictionary, param2:Dictionary) : Dictionary
      {
         var _loc3_:Object = null;
         if(!param2)
         {
            param2 = new Dictionary();
         }
         for(_loc3_ in param1)
         {
            param2[_loc3_] = param1[_loc3_];
         }
         return param2;
      }
      
      public static function subtractDictionaries(param1:Dictionary, param2:Dictionary) : void
      {
         var _loc3_:Object = null;
         for(_loc3_ in param1)
         {
            delete param2[_loc3_];
         }
      }
      
      public static function appendStringVector(param1:Vector.<String>, param2:Vector.<String>) : void
      {
         var _loc3_:String = null;
         for each(_loc3_ in param1)
         {
            param2.push(_loc3_);
         }
      }
      
      public static function subtractStringVector(param1:Vector.<String>, param2:Vector.<String>) : void
      {
         var _loc3_:String = null;
         var _loc4_:int = 0;
         for each(_loc3_ in param1)
         {
            _loc4_ = param2.indexOf(_loc3_);
            if(_loc4_ >= 0)
            {
               param2.splice(_loc4_,1);
            }
         }
      }
      
      public static function arrayProcessDefs(param1:Array, param2:Class, param3:ILogger, param4:Function) : void
      {
         var msg:String = null;
         var o:Object = null;
         var s:* = undefined;
         var arr:Array = param1;
         var clazz:Class = param2;
         var logger:ILogger = param3;
         var f:Function = param4;
         if(!arr)
         {
            return;
         }
         for each(o in arr)
         {
            s = new clazz();
            try
            {
               s.fromJson(o,logger);
            }
            catch(e:Error)
            {
               msg = "Failed to call fromJson() on " + s + ":\n" + e.getStackTrace();
               if(logger)
               {
                  logger.error(msg);
                  break;
               }
               throw new IllegalOperationError(msg);
            }
            try
            {
               f(s);
            }
            catch(e:Error)
            {
               msg = "Failed to process " + s + " to " + f + ":\n" + e.getStackTrace();
               if(logger)
               {
                  logger.error(msg);
                  break;
               }
               throw new IllegalOperationError(msg);
            }
         }
      }
      
      public static function arrayToDefVector(param1:Array, param2:Class, param3:ILogger, param4:Object, param5:Function = null) : Object
      {
         var msg:String = null;
         var r:Object = null;
         var o:Object = null;
         var s:* = undefined;
         var arr:Array = param1;
         var clazz:Class = param2;
         var logger:ILogger = param3;
         var vector:Object = param4;
         var itemCallback:Function = param5;
         if(!arr)
         {
            return null;
         }
         r = vector;
         try
         {
            if(!r)
            {
               r = clazz["vctor"]();
            }
         }
         catch(e:Error)
         {
            msg = "Failed to call the vctor() static method on " + clazz + ":\n" + e.getStackTrace();
            if(logger)
            {
               logger.error(msg);
               return null;
            }
            throw new IllegalOperationError(msg);
         }
         for each(o in arr)
         {
            s = new clazz();
            try
            {
               s.fromJson(o,logger);
            }
            catch(e:Error)
            {
               msg = "Failed to call fromJson() on " + s + ":\n" + e.getStackTrace();
               if(logger)
               {
                  logger.error(msg);
                  break;
               }
               throw new IllegalOperationError(msg);
            }
            try
            {
               r.push(s);
               if(itemCallback != null)
               {
                  itemCallback(s,r.length - 1);
               }
            }
            catch(e:Error)
            {
               msg = "Failed to add " + s + " to " + r + ":\n" + e.getStackTrace();
               if(logger)
               {
                  logger.error(msg);
                  break;
               }
               throw new IllegalOperationError(msg);
            }
         }
         return r;
      }
      
      public static function defVectorToArray(param1:*, param2:Boolean, param3:Boolean = false) : Array
      {
         var _loc5_:Object = null;
         var _loc6_:Object = null;
         if(!param1)
         {
            return param2 ? [] : null;
         }
         var _loc4_:Array = [];
         for each(_loc5_ in param1)
         {
            if(param3 && Boolean(_loc5_.toJson.length))
            {
               _loc6_ = _loc5_.toJson(param3);
            }
            else
            {
               _loc6_ = _loc5_.toJson();
            }
            _loc4_.push(_loc6_);
         }
         return _loc4_;
      }
      
      public static function stringArrayToStringVector(param1:Array) : Vector.<String>
      {
         var _loc3_:String = null;
         if(!param1)
         {
            return null;
         }
         var _loc2_:Vector.<String> = new Vector.<String>();
         for each(_loc3_ in param1)
         {
            _loc2_.push(_loc3_);
         }
         return _loc2_;
      }
      
      public static function stringVectorToStringArray(param1:Vector.<String>) : Array
      {
         var _loc3_:String = null;
         if(!param1)
         {
            return null;
         }
         var _loc2_:Array = [];
         for each(_loc3_ in param1)
         {
            _loc2_.push(_loc3_);
         }
         return _loc2_;
      }
      
      public static function stringToArray(param1:String, param2:String = ",") : Array
      {
         var _loc3_:Array = null;
         if(param1)
         {
            _loc3_ = param1.split(param2);
         }
         return _loc3_;
      }
      
      public static function makeArrayDict(param1:Array) : Dictionary
      {
         var _loc2_:Dictionary = null;
         var _loc3_:String = null;
         if(Boolean(param1) && Boolean(param1.length))
         {
            _loc2_ = new Dictionary();
            for each(_loc3_ in param1)
            {
               _loc2_[_loc3_] = true;
            }
         }
         return _loc2_;
      }
      
      public static function shuffle(param1:Array, param2:Rng) : Array
      {
         var _loc4_:int = 0;
         var _loc5_:* = undefined;
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            _loc4_ = param2.nextMax(param1.length - 1);
            if(_loc3_ != _loc4_)
            {
               _loc5_ = param1[_loc3_];
               param1[_loc3_] = param1[_loc4_];
               param1[_loc4_] = _loc5_;
            }
            _loc3_++;
         }
         return param1;
      }
      
      public static function shuffleTight(param1:Array, param2:int, param3:Rng) : Array
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:* = undefined;
         var _loc4_:int = 0;
         while(_loc4_ < param1.length)
         {
            _loc5_ = Math.max(0,_loc4_ - param2);
            _loc6_ = Math.min(param1.length - 1,_loc4_ + param2);
            _loc7_ = param3.nextMinMax(_loc5_,_loc6_);
            if(_loc4_ != _loc7_)
            {
               _loc8_ = param1[_loc4_];
               param1[_loc4_] = param1[_loc7_];
               param1[_loc7_] = _loc8_;
            }
            _loc4_++;
         }
         return param1;
      }
      
      public static function makeReason(param1:Array, param2:String) : void
      {
         if(param1)
         {
            param1.push(param2);
         }
      }
      
      public static function isEqual(param1:Array, param2:Array, param3:Array = null, param4:Function = null, param5:* = undefined) : Boolean
      {
         var _loc7_:Object = null;
         var _loc8_:Object = null;
         if(param1 == param2)
         {
            return true;
         }
         if(!param1 || !param2)
         {
            makeReason(param3,"ArrayUtil.isEqual(null lhs=" + param1 + " rhs=" + param2 + ")");
            return false;
         }
         if(param1.length != param2.length)
         {
            makeReason(param3,"ArrayUtil.isEqual(length mismatch lhs=" + param1.length + " rhs=" + param2.length + ")");
            return false;
         }
         var _loc6_:int = 0;
         while(true)
         {
            if(_loc6_ >= param1.length)
            {
               return true;
            }
            _loc7_ = param1[_loc6_];
            _loc8_ = param2[_loc6_];
            if(param4 != null)
            {
               if(!param4(_loc7_,_loc8_,param3,param5))
               {
                  makeReason(param3,"ArrayUtil.isEqual(comp)");
                  return false;
               }
            }
            else if(_loc7_ != _loc8_)
            {
               if(_loc7_ is Vector.<String> && _loc8_ is Array)
               {
                  if(!ArrayUtil.isEqualStringVectorArray(_loc7_ as Vector.<String>,_loc8_ as Array))
                  {
                     break;
                  }
               }
               else
               {
                  if(!(_loc8_ is Vector.<String> && _loc7_ is Array))
                  {
                     break;
                  }
                  if(!ArrayUtil.isEqualStringVectorArray(_loc8_ as Vector.<String>,_loc7_ as Array))
                  {
                     break;
                  }
               }
            }
            _loc6_++;
         }
         makeReason(param3,"ArrayUtil.isEqual(ref " + _loc6_ + " lo=" + _loc7_ + " ro=" + _loc8_ + ")");
         return false;
      }
      
      public static function getDictionaryKeys(param1:Dictionary) : Array
      {
         var _loc2_:Array = null;
         var _loc3_:Object = null;
         if(param1)
         {
            _loc2_ = [];
            for(_loc3_ in param1)
            {
               _loc2_.push(_loc3_);
            }
         }
         return _loc2_;
      }
      
      public static function getDictionaryValues(param1:Dictionary) : Array
      {
         var _loc2_:Array = null;
         var _loc3_:Object = null;
         if(param1)
         {
            _loc2_ = [];
            for each(_loc3_ in param1)
            {
               _loc2_.push(_loc3_);
            }
         }
         return _loc2_;
      }
      
      public static function toString(param1:Array, param2:String) : String
      {
         if(!param1 || param1.length == 0)
         {
            return null;
         }
         var _loc3_:String = String(param1[0]);
         var _loc4_:int = 1;
         while(_loc4_ < param1.length)
         {
            _loc3_ += param2 + param1[_loc4_];
            _loc4_++;
         }
         return _loc3_;
      }
      
      public static function isEqualStringVectors(param1:Vector.<String>, param2:Vector.<String>) : Boolean
      {
         var _loc5_:String = null;
         var _loc6_:String = null;
         if(param1 == param2)
         {
            return true;
         }
         if(!param1 || !param2)
         {
            return false;
         }
         if(param1.length != param2.length)
         {
            return false;
         }
         var _loc3_:int = int(param1.length);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc5_ = param1[_loc4_];
            _loc6_ = param2[_loc4_];
            if(_loc5_ != _loc6_)
            {
               return false;
            }
            _loc4_++;
         }
         return true;
      }
      
      public static function isEqualStringVectorArray(param1:Vector.<String>, param2:Array) : Boolean
      {
         var _loc5_:String = null;
         var _loc6_:String = null;
         if(!param1 || !param2)
         {
            return false;
         }
         if(param1.length != param2.length)
         {
            return false;
         }
         var _loc3_:int = int(param1.length);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc5_ = param1[_loc4_];
            _loc6_ = String(param2[_loc4_]);
            if(_loc5_ != _loc6_)
            {
               return false;
            }
            _loc4_++;
         }
         return true;
      }
      
      public static function isDictEqualKeys(param1:Dictionary, param2:Dictionary) : Boolean
      {
         var _loc3_:Object = null;
         if(param1 == param2)
         {
            return true;
         }
         if(!param1 || !param2)
         {
            return false;
         }
         for(_loc3_ in param1)
         {
            if(param2[_loc3_] == undefined)
            {
               return false;
            }
         }
         for(_loc3_ in param2)
         {
            if(param1[_loc3_] == undefined)
            {
               return false;
            }
         }
         return true;
      }
      
      public static function getDictionaryLength(param1:Dictionary) : int
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         for(_loc3_ in param1)
         {
            _loc2_++;
         }
         return _loc2_;
      }
      
      public static function isDictEqualLength(param1:Dictionary, param2:Dictionary) : Boolean
      {
         var _loc3_:int = getDictionaryLength(param1);
         var _loc4_:int = getDictionaryLength(param2);
         return _loc3_ == _loc4_;
      }
      
      public static function visit(param1:*, param2:Function) : Boolean
      {
         var _loc3_:* = undefined;
         for each(_loc3_ in param1)
         {
            if(param2(_loc3_))
            {
               return true;
            }
         }
         return false;
      }
      
      public static function compare(param1:*, param2:Array) : Boolean
      {
         var _loc4_:* = undefined;
         var _loc5_:* = undefined;
         if(!param1 && !param2)
         {
            return true;
         }
         if(param1 && !param2 || param2 && !param1)
         {
            return false;
         }
         if(param1.length != param2.length)
         {
            return false;
         }
         var _loc3_:int = 0;
         while(_loc3_ < param2.length)
         {
            _loc4_ = param1[_loc3_];
            _loc5_ = param2[_loc3_];
            if(_loc4_ != _loc5_)
            {
               if(_loc4_["equals"] != undefined)
               {
                  if(!_loc4_.equals(_loc5_))
                  {
                     return false;
                  }
               }
            }
            _loc3_++;
         }
         return true;
      }
      
      public static function removeAt(param1:*, param2:int) : Object
      {
         var _loc4_:Object = null;
         var _loc5_:int = 0;
         var _loc3_:uint = uint(param1.length);
         if(param2 < 0)
         {
            param2 += _loc3_;
         }
         if(param2 < 0)
         {
            param2 = 0;
         }
         else if(param2 >= _loc3_)
         {
            param2 = int(_loc3_ - 1);
         }
         _loc4_ = param1[param2];
         _loc5_ = param2 + 1;
         while(_loc5_ < _loc3_)
         {
            param1[int(_loc5_ - 1)] = param1[_loc5_];
            _loc5_++;
         }
         param1.length = _loc3_ - 1;
         return _loc4_;
      }
      
      public static function insertAt(param1:*, param2:int, param3:Object) : void
      {
         var _loc4_:int = 0;
         var _loc5_:uint = uint(param1.length);
         if(param2 < 0)
         {
            param2 += _loc5_ + 1;
         }
         if(param2 < 0)
         {
            param2 = 0;
         }
         _loc4_ = param2 - 1;
         while(_loc4_ >= _loc5_)
         {
            param1[_loc4_] = null;
            _loc4_--;
         }
         _loc4_ = int(_loc5_);
         while(_loc4_ > param2)
         {
            param1[_loc4_] = param1[int(_loc4_ - 1)];
            _loc4_--;
         }
         param1[param2] = param3;
      }
   }
}

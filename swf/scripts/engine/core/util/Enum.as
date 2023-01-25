package engine.core.util
{
   import engine.core.logging.ILogger;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   public class Enum
   {
      
      private static const byClassByName:Dictionary = new Dictionary();
      
      private static const byClassVector:Dictionary = new Dictionary();
      
      private static var pending:Vector.<Enum> = new Vector.<Enum>();
      
      protected static const enumCtorKey:Object = {};
       
      
      private var _value:int;
      
      private var _name:String;
      
      public function Enum(param1:String, param2:Object)
      {
         super();
         if(enumCtorKey != param2)
         {
            throw new ArgumentError("secret!");
         }
         pending.push(this);
         this._name = param1;
      }
      
      private static function initializeClass(param1:Object, param2:ILogger = null) : void
      {
         var v:Vector.<Enum>;
         var n:int;
         var i:int;
         var e:Enum = null;
         var qn:String = null;
         var cz:Class = null;
         var clazz:Object = param1;
         var logger:ILogger = param2;
         var b:Dictionary = byClassByName[clazz];
         if(b)
         {
            return;
         }
         if(Boolean(logger) && logger.isDebugEnabled)
         {
            logger.debug("Enum.initializeClass " + clazz + " new dict");
         }
         b = new Dictionary();
         v = new Vector.<Enum>();
         n = int(pending.length);
         i = 0;
         while(i < n)
         {
            e = pending[i];
            qn = getQualifiedClassName(e);
            cz = null;
            try
            {
               cz = getDefinitionByName(qn) as Class;
            }
            catch(e:Error)
            {
               if(logger)
               {
                  logger.error("No such class " + qn + ": " + e);
               }
               i++;
               continue;
            }
            if(cz == clazz)
            {
               e._value = v.length;
               v.push(e);
               b[e.name] = e;
               n--;
               pending[i] = pending[n];
            }
            else
            {
               i++;
            }
         }
         byClassByName[clazz] = b;
         byClassVector[clazz] = v;
         pending.splice(n,pending.length - n);
         if(Boolean(logger) && logger.isDebugEnabled)
         {
            logger.debug("Enum.initializeClass " + clazz + " found " + v.length);
         }
      }
      
      private static function getByName(param1:Class, param2:ILogger) : Dictionary
      {
         initializeClass(param1,param2);
         return byClassByName[param1];
      }
      
      public static function getVector(param1:Class) : Vector.<Enum>
      {
         initializeClass(param1);
         return byClassVector[param1];
      }
      
      public static function getByOrdinal(param1:Class, param2:int) : Enum
      {
         initializeClass(param1);
         var _loc3_:Vector.<Enum> = byClassVector[param1];
         if(param2 >= 0 && param2 < _loc3_.length)
         {
            return _loc3_[param2];
         }
         return null;
      }
      
      public static function getCount(param1:Class) : int
      {
         initializeClass(param1);
         return byClassVector[param1].length;
      }
      
      public static function fuzzyParse(param1:Class, param2:String, param3:ILogger) : Enum
      {
         var _loc5_:String = null;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc4_:Dictionary = getByName(param1,param3);
         if(!_loc4_)
         {
            throw new ArgumentError("Enum.fuzzyParse invalid class=" + param1);
         }
         var _loc6_:int = 100000;
         for(_loc7_ in _loc4_)
         {
            _loc8_ = StringUtil.fuzzyComparison(param2,_loc7_);
            if(_loc8_ < _loc6_)
            {
               _loc6_ = _loc8_;
               _loc5_ = _loc7_;
            }
         }
         if(_loc5_)
         {
            return _loc4_[_loc5_];
         }
         return null;
      }
      
      public static function parse(param1:Class, param2:String, param3:Boolean = true, param4:ILogger = null) : Enum
      {
         var _loc7_:Enum = null;
         var _loc5_:Dictionary = getByName(param1,param4);
         if(!_loc5_)
         {
            throw new ArgumentError("Enum.parse invalid class=" + param1);
         }
         var _loc6_:Enum = _loc5_[param2];
         if(!_loc6_ && param3)
         {
            _loc7_ = fuzzyParse(param1,param2,param4);
            if(_loc7_)
            {
               throw new ArgumentError("Enum.parse invalid enum [" + param2 + "] for type [" + param1 + "]. Did you mean [" + _loc7_ + "]?");
            }
            throw new ArgumentError("Enum.parse invalid enum [" + param2 + "] for type [" + param1 + "]");
         }
         return _loc6_;
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function toString() : String
      {
         return this.name;
      }
      
      public function get value() : int
      {
         return this._value;
      }
   }
}

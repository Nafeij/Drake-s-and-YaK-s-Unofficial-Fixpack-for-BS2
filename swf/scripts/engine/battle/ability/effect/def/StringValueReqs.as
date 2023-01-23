package engine.battle.ability.effect.def
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   
   public class StringValueReqs
   {
      
      public static const schema:Object = {
         "name":"StringValueReqs",
         "properties":{
            "all":{
               "type":"array",
               "items":"string",
               "optional":true
            },
            "any":{
               "type":"array",
               "items":"string",
               "optional":true
            },
            "none":{
               "type":"array",
               "items":"string",
               "optional":true
            }
         }
      };
      
      public static const empty:StringValueReqs = new StringValueReqs();
      
      public static const emptyJsonEverything:Object = empty.save(true);
      
      private static const ev:Vector.<String> = new Vector.<String>();
       
      
      public var all:Vector.<String>;
      
      public var any:Vector.<String>;
      
      public var none:Vector.<String>;
      
      public function StringValueReqs()
      {
         super();
      }
      
      protected static function captureValueArray(param1:Array) : Vector.<String>
      {
         var _loc2_:Vector.<String> = null;
         var _loc3_:String = null;
         if(Boolean(param1) && Boolean(param1.length))
         {
            _loc2_ = new Vector.<String>();
            for each(_loc3_ in param1)
            {
               _loc2_.push(_loc3_);
            }
         }
         return _loc2_;
      }
      
      private static function saveValues(param1:Vector.<String>) : Array
      {
         var _loc3_:String = null;
         param1 = !!param1 ? param1 : ev;
         var _loc2_:Array = [];
         for each(_loc3_ in param1)
         {
            _loc2_.push(_loc3_);
         }
         return _loc2_;
      }
      
      public function get isEmpty() : Boolean
      {
         return (!this.all || !this.all.length) && (!this.any || !this.any.length) && (!this.none || !this.none.length);
      }
      
      public function toString() : String
      {
         var _loc2_:String = null;
         var _loc1_:* = "";
         _loc1_ += "all=[";
         if(this.all)
         {
            for each(_loc2_ in this.all)
            {
               _loc1_ += _loc2_ + ",";
            }
         }
         _loc1_ += "], any=[";
         if(this.any)
         {
            for each(_loc2_ in this.any)
            {
               _loc1_ += _loc2_ + ",";
            }
         }
         _loc1_ += "], none=[";
         if(this.none)
         {
            for each(_loc2_ in this.none)
            {
               _loc1_ += _loc2_ + ",";
            }
         }
         return _loc1_ + "]";
      }
      
      public function checkValue(param1:String, param2:ILogger, param3:Array = null) : Boolean
      {
         var _loc6_:String = null;
         var _loc4_:int = 0;
         var _loc5_:String = null;
         if(this.all)
         {
            for each(_loc6_ in this.all)
            {
               if(_loc6_ != param1)
               {
                  if(Boolean(param3) && param3.length > 0)
                  {
                     param3[0] = "no_" + _loc6_;
                  }
                  return false;
               }
            }
         }
         if(this.any)
         {
            for each(_loc6_ in this.any)
            {
               _loc5_ = _loc6_;
               if(param1 == _loc6_)
               {
                  _loc4_++;
                  break;
               }
            }
         }
         if(Boolean(_loc5_) && _loc4_ <= 0)
         {
            if(Boolean(param3) && param3.length > 0)
            {
               param3[0] = "no_" + _loc5_;
            }
            return false;
         }
         if(this.none)
         {
            for each(_loc6_ in this.none)
            {
               if(param1 == _loc6_)
               {
                  if(Boolean(param3) && param3.length > 0)
                  {
                     param3[0] = "has_" + _loc6_;
                  }
                  return false;
               }
            }
         }
         return true;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : StringValueReqs
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.all = captureValueArray(param1.all);
         this.any = captureValueArray(param1.any);
         this.none = captureValueArray(param1.none);
         return this;
      }
      
      public function save(param1:Boolean) : Object
      {
         var _loc2_:Object = {};
         if(Boolean(this.all) || param1)
         {
            _loc2_.all = saveValues(this.all);
         }
         if(Boolean(this.any) || param1)
         {
            _loc2_.any = saveValues(this.any);
         }
         if(Boolean(this.none) || param1)
         {
            _loc2_.none = saveValues(this.none);
         }
         return _loc2_;
      }
   }
}

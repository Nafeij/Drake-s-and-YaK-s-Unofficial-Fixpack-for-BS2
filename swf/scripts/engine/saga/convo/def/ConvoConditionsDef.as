package engine.saga.convo.def
{
   import engine.core.logging.ILogger;
   import engine.core.util.ArrayUtil;
   import engine.core.util.StringUtil;
   import engine.expression.exp.operator.OperatorBinary;
   import engine.expression.exp.operator.OperatorUnary;
   import engine.saga.ISagaExpression;
   import engine.saga.vars.IVariable;
   import flash.utils.ByteArray;
   
   public class ConvoConditionsDef
   {
      
      public static var FATAL_OPERATOR_CHECK:Boolean = true;
       
      
      public var notIfConditions:Vector.<String>;
      
      public var ifConditions:Vector.<String>;
      
      public function ConvoConditionsDef()
      {
         super();
      }
      
      public static function comparator(param1:ConvoConditionsDef, param2:ConvoConditionsDef) : Boolean
      {
         if(param1 == param2)
         {
            return true;
         }
         if(!param1 || !param2)
         {
            return false;
         }
         return param1.equals(param2);
      }
      
      public static function cleanupCondition(param1:String) : String
      {
         var _loc2_:RegExp = null;
         var _loc3_:OperatorBinary = null;
         var _loc4_:Array = null;
         var _loc5_:OperatorUnary = null;
         if(!param1)
         {
            return param1;
         }
         param1 = StringUtil.stripSurroundingSpace(param1);
         for each(_loc3_ in OperatorBinary.order)
         {
            _loc2_ = new RegExp("\\s*" + _loc3_.escapedStr + "\\s*","g");
            param1 = param1.replace(_loc2_,_loc3_.str);
         }
         for each(_loc4_ in OperatorUnary.order)
         {
            for each(_loc5_ in _loc4_)
            {
               _loc2_ = new RegExp("\\s*" + _loc5_.escapedStr + "\\s*","g");
               param1 = param1.replace(_loc2_,_loc5_.str);
            }
         }
         return param1.replace(/ /g,"_");
      }
      
      public function get hasConditions() : Boolean
      {
         return Boolean(this.notIfConditions) && Boolean(this.notIfConditions.length) || Boolean(this.ifConditions) && Boolean(this.ifConditions.length);
      }
      
      public function getComparisonString() : String
      {
         var _loc1_:String = "";
         if(this.notIfConditions)
         {
            _loc1_ += this.notIfConditions.join("");
         }
         if(this.ifConditions)
         {
            _loc1_ += this.ifConditions.join("");
         }
         return _loc1_;
      }
      
      public function getDebugString() : String
      {
         var _loc2_:String = null;
         var _loc1_:* = "";
         if(this.ifConditions)
         {
            for each(_loc2_ in this.ifConditions)
            {
               if(_loc1_)
               {
                  _loc1_ += " ";
               }
               _loc1_ += "{" + _loc2_ + "}";
            }
         }
         return _loc1_;
      }
      
      public function equals(param1:ConvoConditionsDef) : Boolean
      {
         if(!ArrayUtil.isEqualStringVectors(this.notIfConditions,param1.notIfConditions))
         {
            return false;
         }
         if(!ArrayUtil.isEqualStringVectors(this.ifConditions,param1.ifConditions))
         {
            return false;
         }
         return true;
      }
      
      public function checkConditions(param1:String, param2:ISagaExpression, param3:ILogger) : Boolean
      {
         var _loc4_:IVariable = null;
         var _loc5_:String = null;
         var _loc6_:Number = NaN;
         if(this.notIfConditions)
         {
            for each(_loc5_ in this.notIfConditions)
            {
               if(param2.evaluate(_loc5_,false))
               {
                  param3.d("CONV","NOT-IF CONDITION FAIL [" + _loc5_ + "] for [" + param1 + "]");
                  return false;
               }
            }
         }
         if(this.ifConditions)
         {
            for each(_loc5_ in this.ifConditions)
            {
               if(_loc5_ == "ONCE")
               {
                  _loc5_ = "!cnvn." + param1;
               }
               _loc6_ = param2.evaluate(_loc5_,false);
               if(!_loc6_)
               {
                  param3.d("CONV","    IF CONDITION FAIL [" + _loc5_ + "] for [" + param1 + "]");
                  return false;
               }
            }
         }
         return true;
      }
      
      public function addIfCondition(param1:String) : void
      {
         param1 = cleanupCondition(param1);
         if(param1.indexOf("$") >= 0)
         {
            if(FATAL_OPERATOR_CHECK)
            {
               throw new Error("Condition IF [" + param1 + "] contains a invalid character");
            }
            return;
         }
         if(!this.ifConditions)
         {
            this.ifConditions = new Vector.<String>();
         }
         this.ifConditions.push(param1);
      }
      
      public function addNotIfCondition(param1:String) : void
      {
         param1 = cleanupCondition(param1);
         if(param1.indexOf("$") >= 0)
         {
            if(FATAL_OPERATOR_CHECK)
            {
               throw new Error("Condition NOT IF [" + param1 + "] contains a invalid character");
            }
            return;
         }
         if(!this.notIfConditions)
         {
            this.notIfConditions = new Vector.<String>();
         }
         this.notIfConditions.push(param1);
      }
      
      public function readBytes(param1:ByteArray) : ConvoConditionsDef
      {
         var _loc2_:int = param1.readInt();
         this.notIfConditions = this.readConditionsVector(param1);
         this.ifConditions = this.readConditionsVector(param1);
         return this;
      }
      
      private function readConditionsVector(param1:ByteArray) : Vector.<String>
      {
         var _loc5_:String = null;
         var _loc2_:int = param1.readInt();
         if(!_loc2_)
         {
            return null;
         }
         var _loc3_:Vector.<String> = new Vector.<String>();
         var _loc4_:int = 0;
         while(_loc4_ < _loc2_)
         {
            _loc5_ = param1.readUTF();
            _loc5_ = cleanupCondition(_loc5_);
            _loc3_.push(_loc5_);
            _loc4_++;
         }
         return _loc3_;
      }
      
      public function writeBytes(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         param1.writeInt(_loc2_);
         this.writeConditionsVector(param1,this.notIfConditions);
         this.writeConditionsVector(param1,this.ifConditions);
      }
      
      private function writeConditionsVector(param1:ByteArray, param2:Vector.<String>) : void
      {
         var _loc5_:String = null;
         var _loc3_:int = !!param2 ? int(param2.length) : 0;
         param1.writeInt(_loc3_);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc5_ = param2[_loc4_];
            param1.writeUTF(_loc5_);
            _loc4_++;
         }
      }
   }
}

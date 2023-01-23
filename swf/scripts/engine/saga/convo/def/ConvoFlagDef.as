package engine.saga.convo.def
{
   import engine.core.analytic.Ga;
   import engine.core.logging.ILogger;
   import engine.core.util.StringUtil;
   import engine.expression.ISymbols;
   import engine.expression.Parser;
   import engine.math.Rng;
   import engine.saga.convo.Convo;
   import engine.saga.happening.IHappeningProvider;
   import engine.saga.vars.IVariable;
   import engine.saga.vars.IVariableProvider;
   import engine.saga.vars.VariableType;
   import flash.utils.ByteArray;
   
   public class ConvoFlagDef
   {
      
      private static const operators:Array = ["-=","+=","*=","/=","=","-","+","*","/"];
      
      private static const MINUS_EQUAL:int = 0;
      
      private static const PLUS_EQUAL:int = 1;
      
      private static const MULT_EQUAL:int = 2;
      
      private static const DIVIDE_EQUAL:int = 3;
      
      private static const EQUAL:int = 4;
      
      private static const MINUS:int = 5;
      
      private static const PLUS:int = 6;
      
      private static const MULT:int = 7;
      
      private static const DIVIDE:int = 8;
      
      public static var metaKeys:Array = ["happening","hide","show","ga","bookmark"];
       
      
      public var raw:String;
      
      public var meta:Boolean;
      
      public var name:String;
      
      public var flagIncrement:Boolean;
      
      public var flagDecrement:Boolean;
      
      public var flagMultiply:Boolean;
      
      public var flagDivide:Boolean;
      
      public var flagRand:Boolean;
      
      public var flagValue;
      
      public var flagRandMax:Number = 0;
      
      public var flagRandMin:Number = 0;
      
      public function ConvoFlagDef()
      {
         super();
      }
      
      public static function comparator(param1:ConvoFlagDef, param2:ConvoFlagDef) : Boolean
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
      
      public static function comparatorVectors(param1:Vector.<ConvoFlagDef>, param2:Vector.<ConvoFlagDef>) : Boolean
      {
         var _loc5_:ConvoFlagDef = null;
         var _loc6_:ConvoFlagDef = null;
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
         var _loc3_:int = param1.length;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc5_ = param1[_loc4_];
            _loc6_ = param2[_loc4_];
            if(!comparator(_loc5_,_loc6_))
            {
               return false;
            }
            _loc4_++;
         }
         return true;
      }
      
      public static function startsWithMetaFlag(param1:String) : Boolean
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         for each(_loc2_ in metaKeys)
         {
            _loc3_ = "@" + _loc2_;
            if(StringUtil.startsWith(param1,_loc3_))
            {
               return true;
            }
         }
         return false;
      }
      
      public function equals(param1:ConvoFlagDef) : Boolean
      {
         if(this.raw != param1.raw)
         {
            return false;
         }
         if(this.meta != param1.meta)
         {
            return false;
         }
         if(this.name != param1.name)
         {
            return false;
         }
         if(this.flagIncrement != param1.flagIncrement)
         {
            return false;
         }
         if(this.flagDecrement != param1.flagDecrement)
         {
            return false;
         }
         if(this.flagMultiply != param1.flagMultiply)
         {
            return false;
         }
         if(this.flagDivide != param1.flagDivide)
         {
            return false;
         }
         if(this.flagRand != param1.flagRand)
         {
            return false;
         }
         if(this.flagValue != param1.flagValue)
         {
            return false;
         }
         if(this.flagRandMax != param1.flagRandMax)
         {
            return false;
         }
         if(this.flagRandMin != param1.flagRandMin)
         {
            return false;
         }
         return true;
      }
      
      public function doComputeFlagValue(param1:Rng, param2:ISymbols) : *
      {
         if(this.flagValue is Parser)
         {
            return (this.flagValue as Parser).exp.evaluate(param2,true);
         }
         if(this.flagValue is Boolean || this.flagValue is String)
         {
            return this.flagValue;
         }
         var _loc3_:Number = this.flagValue;
         if(this.flagRand)
         {
            _loc3_ = this.flagRandMin + param1.nextNumber() * (this.flagRandMax - this.flagRandMin);
         }
         if(this.flagDecrement)
         {
            return -_loc3_;
         }
         return _loc3_;
      }
      
      private function getOpString() : String
      {
         if(this.flagIncrement)
         {
            return "+";
         }
         if(this.flagDecrement)
         {
            return "-";
         }
         if(this.flagMultiply)
         {
            return "*";
         }
         if(this.flagDivide)
         {
            return "/";
         }
         return "=";
      }
      
      public function get labelString() : String
      {
         var _loc1_:String = "";
         if(this.meta)
         {
            _loc1_ = "@";
         }
         _loc1_ += this.name;
         var _loc2_:String = this.getOpString();
         if(this.flagRand)
         {
            return _loc1_ + _loc2_ + " R(" + this.flagRandMin + ", " + this.flagRandMax + ")";
         }
         return _loc1_ + _loc2_ + this.flagValue;
      }
      
      private function applyGa() : void
      {
         var _loc1_:String = this.flagValue;
         var _loc2_:Array = _loc1_.split("/");
         if(_loc2_.length != 4)
         {
            throw new ArgumentError("Malformed Ga [" + _loc1_ + "] expected 4 segments: [category/action/label/value]");
         }
         var _loc3_:String = _loc2_[0];
         var _loc4_:String = _loc2_[1];
         var _loc5_:String = _loc2_[2];
         var _loc6_:int = int(_loc2_[3]);
         Ga.normal(_loc3_,_loc4_,_loc5_,_loc6_);
      }
      
      public function apply(param1:IHappeningProvider, param2:IVariableProvider, param3:Convo, param4:Rng) : void
      {
         if(this.meta)
         {
            if(this.name == "@happening")
            {
               if(!param1)
               {
                  throw new ArgumentError("ConvoFlagDef.apply cannot call happening [" + this.flagValue + "]");
               }
               param1.executeHappeningById(this.flagValue,null,param3);
            }
            else if(this.name == "@bookmark")
            {
               if(!param1)
               {
                  throw new ArgumentError("ConvoFlagDef.apply cannot call happening [" + this.flagValue + "]");
               }
               param1.gotoBookmark(this.flagValue,false);
            }
            else if(this.name == "@hide")
            {
               param3.setActorVisible(this.flagValue,false,true);
            }
            else if(this.name == "@show")
            {
               param3.setActorVisible(this.flagValue,true,true);
            }
            else if(this.name == "@ga")
            {
               this.applyGa();
            }
            return;
         }
         var _loc5_:IVariable = param2.getVar(this.name,VariableType.DECIMAL);
         var _loc6_:Number = _loc5_.asNumber;
         var _loc7_:Number = this.doComputeFlagValue(param4,param2);
         var _loc8_:Number = _loc7_;
         if(this.flagIncrement || this.flagDecrement)
         {
            _loc8_ = _loc6_ + _loc7_;
         }
         else if(this.flagMultiply)
         {
            _loc8_ = _loc6_ * _loc7_;
         }
         else if(this.flagDivide)
         {
            _loc8_ = _loc6_ / _loc7_;
         }
         param3.logger.i("CONV","SETVAR " + this.labelString + " (" + _loc8_ + "=" + _loc6_ + this.getOpString() + _loc7_ + ")");
         param2.setVar(this.name,_loc8_);
      }
      
      public function parse(param1:String, param2:ILogger, param3:String = null) : ConvoFlagDef
      {
         var _loc6_:int = 0;
         if(!param1)
         {
            return this;
         }
         this.raw = param1;
         if(param1.charAt(0) == "@")
         {
            this.meta = true;
         }
         var _loc4_:int = this.getOperator(param1);
         var _loc5_:int = param1.indexOf(operators[_loc4_]);
         switch(_loc4_)
         {
            case EQUAL:
               this.name = param1.substring(0,_loc5_);
               this.flagValue = param1.substring(_loc5_ + 1);
               if(this.flagValue == "true")
               {
                  this.flagValue = true;
               }
               else if(this.flagValue == "false")
               {
                  this.flagValue = false;
               }
               else if(!this.meta)
               {
                  this.processFlagValue(param2);
               }
               break;
            case MINUS_EQUAL:
               this.name = param1.substring(0,_loc5_);
               this.flagValue = param1.substring(_loc5_ + 2);
               this.flagDecrement = true;
               this.processFlagValue(param2);
               break;
            case MINUS:
               this.name = param1.substring(0,_loc5_);
               this.flagValue = param1.substring(_loc5_ + 1);
               this.flagDecrement = true;
               this.processFlagValue(param2);
               break;
            case PLUS_EQUAL:
               this.name = param1.substring(0,_loc5_);
               this.flagValue = param1.substring(_loc5_ + 2);
               this.flagIncrement = true;
               this.processFlagValue(param2);
               break;
            case PLUS:
               this.name = param1.substring(0,_loc5_);
               this.flagValue = param1.substring(_loc5_ + 1);
               this.flagIncrement = true;
               this.processFlagValue(param2);
               break;
            case MULT_EQUAL:
               this.name = param1.substring(0,_loc5_);
               this.flagValue = param1.substring(_loc5_ + 2);
               this.flagMultiply = true;
               this.processFlagValue(param2);
               break;
            case MULT:
               this.name = param1.substring(0,_loc5_);
               this.flagValue = param1.substring(_loc5_ + 1);
               this.flagMultiply = true;
               this.processFlagValue(param2);
               break;
            case DIVIDE_EQUAL:
               this.name = param1.substring(0,_loc5_);
               this.flagValue = param1.substring(_loc5_ + 1);
               this.flagDivide = true;
               this.processFlagValue(param2);
               break;
            case DIVIDE:
               this.name = param1.substring(0,_loc5_);
               this.flagValue = param1.substring(_loc5_ + 1);
               this.flagDivide = true;
               this.processFlagValue(param2);
               break;
            default:
               this.name = param1;
               this.flagValue = true;
         }
         this.name = StringUtil.stripSurroundingSpace(this.name);
         this.name = this.name.replace(/ /g,"_");
         if(!this.meta)
         {
            if(param3)
            {
               _loc6_ = this.name.indexOf(".");
               if(_loc6_ < 0)
               {
                  this.name = param3 + "." + this.name;
               }
            }
         }
         return this;
      }
      
      private function getOperator(param1:String) : int
      {
         var _loc2_:int = 0;
         while(_loc2_ < operators.length)
         {
            if(param1.indexOf(operators[_loc2_]) >= 0)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return -1;
      }
      
      private function processFlagValue(param1:ILogger) : void
      {
         var _loc4_:Boolean = false;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Parser = null;
         var _loc2_:String = this.flagValue;
         if(!_loc2_)
         {
            return;
         }
         _loc2_ = StringUtil.stripWhitespace(_loc2_);
         var _loc3_:int = 0;
         if(_loc2_.charAt(0) == "-")
         {
            _loc4_ = true;
            _loc3_ = 1;
         }
         if(_loc2_.charAt(_loc3_) == "(")
         {
            _loc5_ = _loc2_.indexOf(",",_loc3_);
            if(_loc5_ < 0)
            {
               param1.error("Bad rand range no \',\' : " + _loc2_);
               return;
            }
            _loc6_ = _loc2_.indexOf(")",_loc5_);
            if(_loc6_ < 0)
            {
               param1.error("Bad rand range no terminating \')\' : " + _loc2_);
               return;
            }
            this.flagRandMin = Number(_loc2_.substring(_loc3_ + 1,_loc5_));
            this.flagRandMax = Number(_loc2_.substring(_loc5_ + 1,_loc6_));
            if(this.flagRandMax <= this.flagRandMin)
            {
               param1.error("Bad rand range mixup " + this.flagRandMin + " >= " + this.flagRandMax);
               return;
            }
            if(_loc4_)
            {
               this.flagRandMin = -this.flagRandMin;
               this.flagRandMax = -this.flagRandMax;
            }
            this.flagValue = null;
            this.flagRand = true;
         }
         else
         {
            this.flagValue = Number(this.flagValue);
            if(isNaN(this.flagValue) || this.flagValue.toString() != _loc2_)
            {
               _loc7_ = new Parser(_loc2_,param1);
               this.flagValue = _loc7_;
            }
         }
      }
      
      public function readBytes(param1:ByteArray, param2:ILogger) : ConvoFlagDef
      {
         var _loc3_:int = param1.readInt();
         this.raw = param1.readUTF();
         this.parse(this.raw,param2);
         return this;
      }
      
      public function writeBytes(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         param1.writeInt(_loc2_);
         param1.writeUTF(this.raw);
      }
   }
}

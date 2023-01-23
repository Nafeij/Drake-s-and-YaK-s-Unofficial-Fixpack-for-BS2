package engine.expression.exp
{
   import engine.expression.ErrorExp;
   import engine.expression.ISymbols;
   import engine.expression.Symbols;
   import engine.expression.exp.operator.OperatorBinary;
   import engine.expression.exp.operator.OperatorUnary;
   import flash.errors.IllegalOperationError;
   import flash.utils.getQualifiedClassName;
   
   public class Exp
   {
       
      
      public function Exp()
      {
         super();
      }
      
      public static function factory(param1:*) : Exp
      {
         if(param1 is Array)
         {
            return factoryTokens(param1 as Array);
         }
         return factoryToken(param1);
      }
      
      public static function factoryToken(param1:String) : Exp
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         if(param1 == "false")
         {
            return new ExpLiteral(param1,0);
         }
         if(param1 == "true")
         {
            return new ExpLiteral(param1,1);
         }
         if(param1.charAt(0) == "\'" && param1.charAt(param1.length - 1) == "\'")
         {
            _loc3_ = param1.substring(1,param1.length - 1);
            return new ExpLiteral(param1,Symbols.hash(_loc3_));
         }
         var _loc2_:Number = Number(param1);
         if(!isNaN(_loc2_))
         {
            _loc4_ = _loc2_.toString();
            if(_loc4_ == param1 || "0" + param1 == _loc4_)
            {
               return new ExpLiteral(param1,_loc2_);
            }
         }
         return new ExpSymbol(param1);
      }
      
      public static function collectScopes(param1:Array) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         while(true)
         {
            _loc2_ = _findLastTokenIndex("(",param1,param1.length - 1);
            if(_loc2_ < 0)
            {
               break;
            }
            _loc3_ = _findFirstTokenIndex(")",param1,_loc2_);
            if(_loc3_ < 0)
            {
               throw new ErrorExp("Mismached paren",param1[_loc2_].index);
            }
            _loc4_ = [];
            _loc4_.scoped = true;
            _loc5_ = _loc2_ + 1;
            while(_loc5_ < _loc3_)
            {
               _loc4_.push(param1[_loc5_]);
               _loc5_++;
            }
            _loc6_ = 1 + _loc3_ - _loc2_;
            param1.splice(_loc2_,_loc6_,_loc4_);
            Exp.collectScopes(_loc4_);
         }
         collectUnaries(param1);
         collectBinaries(param1);
      }
      
      public static function collectUnaries(param1:Array) : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:Array = null;
         if(param1.length <= 2)
         {
            return;
         }
         for each(_loc2_ in OperatorUnary.order)
         {
            while(true)
            {
               _loc3_ = _findLastOperator(_loc2_,param1);
               if(_loc3_ < 0)
               {
                  break;
               }
               _loc4_ = [];
               _loc4_.scoped = true;
               _loc4_.push(param1[_loc3_]);
               _loc4_.push(param1[_loc3_ + 1]);
               param1.splice(_loc3_,2,_loc4_);
               collectUnaries(_loc4_[1]);
            }
         }
      }
      
      private static function _findLastOperator(param1:Array, param2:Array) : int
      {
         var _loc4_:OperatorUnary = null;
         var _loc5_:int = 0;
         var _loc6_:Array = null;
         var _loc7_:Array = null;
         var _loc8_:String = null;
         var _loc3_:int = -1;
         for each(_loc4_ in param1)
         {
            _loc5_ = param2.length - 1;
            while(_loc5_ >= _loc3_)
            {
               _loc5_ = _findLastTokenIndex(_loc4_.str,param2,_loc5_);
               if(_loc5_ < 0)
               {
                  break;
               }
               _loc6_ = _loc5_ > 0 ? param2[_loc5_ - 1] : null;
               _loc7_ = !!_loc6_ ? _loc6_[0] as Array : null;
               _loc8_ = !!_loc6_ ? _loc6_[0] as String : null;
               if(!_loc7_)
               {
                  if(!(_loc8_ && !OperatorUnary.fetch(_loc8_) && !OperatorBinary.fetch(_loc8_)))
                  {
                     if(_loc3_ < _loc5_)
                     {
                        _loc3_ = _loc5_;
                     }
                     break;
                  }
               }
               _loc5_--;
            }
         }
         return _loc3_;
      }
      
      public static function collectBinaries(param1:Array) : void
      {
         var _loc3_:OperatorBinary = null;
         var _loc4_:int = 0;
         var _loc5_:Array = null;
         var _loc6_:int = 0;
         var _loc7_:Array = null;
         var _loc8_:Array = null;
         if(param1.length <= 3)
         {
            return;
         }
         var _loc2_:int = 0;
         while(_loc2_ < OperatorBinary.order.length)
         {
            _loc3_ = OperatorBinary.order[_loc2_];
            _loc4_ = _findFirstTokenIndex(_loc3_.str,param1,1);
            if(_loc4_ >= 0)
            {
               _loc5_ = [];
               _loc6_ = 0;
               while(_loc6_ < _loc4_)
               {
                  _loc5_.push(param1[_loc6_]);
                  _loc6_++;
               }
               _loc7_ = [];
               _loc6_ = _loc4_ + 1;
               while(_loc6_ < param1.length)
               {
                  _loc7_.push(param1[_loc6_]);
                  _loc6_++;
               }
               _loc8_ = param1[_loc4_];
               param1.splice(0,param1.length);
               param1.push(_loc5_);
               param1.push(_loc8_);
               param1.push(_loc7_);
               collectBinaries(_loc5_);
               collectBinaries(_loc7_);
            }
            _loc2_++;
         }
      }
      
      public static function factoryTokens(param1:Array) : Exp
      {
         if(param1.length == 1)
         {
            return factory(param1[0]);
         }
         if(param1.length == 2)
         {
            return new ExpUnary().fromTokens(param1[0],param1[1]);
         }
         if(param1.length == 3)
         {
            return new ExpBinary().fromTokens(param1);
         }
         throw new ErrorExp("Got to factory with " + param1.length + " tokens: " + param1.join(" "),param1[0].index);
      }
      
      private static function _findFirstTokenIndex(param1:String, param2:Array, param3:int = 0) : int
      {
         var _loc5_:Object = null;
         var _loc4_:int = param3;
         while(_loc4_ < param2.length)
         {
            _loc5_ = param2[_loc4_];
            if(!_loc5_.scoped)
            {
               if(_loc5_[0] == param1)
               {
                  return _loc4_;
               }
            }
            _loc4_++;
         }
         return -1;
      }
      
      private static function _findLastTokenIndex(param1:String, param2:Array, param3:int = 2147483647) : int
      {
         var _loc5_:Object = null;
         param3 = Math.min(param3,param2.length - 1);
         var _loc4_:int = param3;
         while(_loc4_ >= 0)
         {
            _loc5_ = param2[_loc4_];
            if(!_loc5_.scoped)
            {
               if(_loc5_[0] == param1)
               {
                  return _loc4_;
               }
            }
            _loc4_--;
         }
         return -1;
      }
      
      public function toStringRecursive() : String
      {
         return getQualifiedClassName(this);
      }
      
      public function evaluate(param1:ISymbols, param2:Boolean) : Number
      {
         throw new IllegalOperationError("pure virtual expression evaluate " + getQualifiedClassName(this));
      }
   }
}

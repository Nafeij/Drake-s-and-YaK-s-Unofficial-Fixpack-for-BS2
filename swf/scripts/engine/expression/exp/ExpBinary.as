package engine.expression.exp
{
   import engine.expression.ErrorExp;
   import engine.expression.ISymbols;
   import engine.expression.exp.operator.OperatorBinary;
   
   public class ExpBinary extends Exp
   {
       
      
      public var lhs:Exp;
      
      public var rhs:Exp;
      
      public var operator:OperatorBinary;
      
      public function ExpBinary()
      {
         super();
      }
      
      public function fromTokens(param1:Array) : ExpBinary
      {
         if(param1.length != 3)
         {
            throw new ArgumentError("Not enough tokens for ExpBinary: [" + param1.join(";") + "]");
         }
         var _loc2_:Object = param1[0];
         var _loc3_:Object = param1[1];
         var _loc4_:Object = param1[2];
         var _loc5_:String = String(_loc3_[0]);
         this.operator = OperatorBinary.fetch(_loc5_);
         if(!this.operator)
         {
            throw new ErrorExp("Invalid operator [" + _loc5_ + "]",_loc3_.index);
         }
         this.lhs = Exp.factory(_loc2_);
         this.rhs = Exp.factory(_loc4_);
         return this;
      }
      
      override public function evaluate(param1:ISymbols, param2:Boolean) : Number
      {
         var _loc3_:Number = this.lhs.evaluate(param1,param2);
         var _loc4_:Number = this.rhs.evaluate(param1,param2);
         return this.operator.evaluate(_loc3_,_loc4_);
      }
      
      override public function toStringRecursive() : String
      {
         return "(" + this.lhs.toStringRecursive() + " " + this.operator + " " + this.rhs.toStringRecursive() + ")";
      }
   }
}

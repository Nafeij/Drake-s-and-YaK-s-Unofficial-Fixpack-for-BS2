package engine.expression.exp
{
   import engine.expression.ISymbols;
   import engine.expression.exp.operator.OperatorUnary;
   
   public class ExpUnary extends Exp
   {
       
      
      public var rhs:Exp;
      
      public var operator:OperatorUnary;
      
      public function ExpUnary()
      {
         super();
      }
      
      public function fromTokens(param1:Array, param2:Array) : ExpUnary
      {
         var _loc3_:String = String(param1[0]);
         this.operator = OperatorUnary.fetch(_loc3_);
         if(!this.operator)
         {
            throw new ArgumentError("ExpUnary Invalid operator for [" + _loc3_ + "] in array [" + param1.join(",") + "]");
         }
         this.rhs = Exp.factory(param2);
         return this;
      }
      
      override public function toStringRecursive() : String
      {
         return "(" + this.operator + " " + this.rhs.toStringRecursive() + ")";
      }
      
      override public function evaluate(param1:ISymbols, param2:Boolean) : Number
      {
         var _loc3_:Number = this.rhs.evaluate(param1,param2);
         return this.operator.evaluate(_loc3_);
      }
   }
}

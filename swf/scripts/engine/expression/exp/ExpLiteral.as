package engine.expression.exp
{
   import engine.expression.ISymbols;
   
   public class ExpLiteral extends Exp
   {
       
      
      public var value:Number;
      
      public var raw:String;
      
      public function ExpLiteral(param1:String, param2:Number)
      {
         super();
         this.raw = param1;
         this.value = param2;
      }
      
      override public function toStringRecursive() : String
      {
         return this.value.toString();
      }
      
      override public function evaluate(param1:ISymbols, param2:Boolean) : Number
      {
         return this.value;
      }
   }
}

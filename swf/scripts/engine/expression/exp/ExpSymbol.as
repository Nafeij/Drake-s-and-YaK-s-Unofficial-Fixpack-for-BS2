package engine.expression.exp
{
   import engine.expression.ISymbols;
   
   public class ExpSymbol extends Exp
   {
       
      
      public var value:String;
      
      public function ExpSymbol(param1:String)
      {
         super();
         this.value = param1;
      }
      
      override public function toStringRecursive() : String
      {
         return this.value;
      }
      
      override public function evaluate(param1:ISymbols, param2:Boolean) : Number
      {
         return param1.getSymbolValue(this.value,param2);
      }
   }
}

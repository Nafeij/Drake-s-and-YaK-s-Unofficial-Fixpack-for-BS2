package engine.saga
{
   public interface ISagaExpression
   {
       
      
      function getSymbolValue(param1:String) : Number;
      
      function evaluate(param1:String, param2:Boolean) : Number;
   }
}

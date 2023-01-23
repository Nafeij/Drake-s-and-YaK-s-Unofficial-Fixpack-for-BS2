package engine.saga
{
   import engine.core.logging.ILogger;
   import engine.expression.Parser;
   import engine.saga.vars.IVariable;
   import engine.saga.vars.IVariableProvider;
   
   public class SagaExpression implements ISagaExpression
   {
       
      
      public var vars:IVariableProvider;
      
      public var logger:ILogger;
      
      public function SagaExpression(param1:IVariableProvider, param2:ILogger)
      {
         super();
         this.vars = param1;
         this.logger = param2;
      }
      
      public function getSymbolValue(param1:String) : Number
      {
         var _loc2_:IVariable = this.vars.getVar(param1,null);
         return !!_loc2_ ? _loc2_.asNumber : 0;
      }
      
      public function evaluate(param1:String, param2:Boolean) : Number
      {
         if(!param1)
         {
            return 0;
         }
         var _loc3_:Parser = new Parser(param1,null);
         if(!_loc3_.exp)
         {
            this.logger.error("SagaExpression failed to parse expression [" + param1 + "]:\n" + _loc3_.printParseErrors());
            new Parser(param1,null);
            return 0;
         }
         return _loc3_.evaluate(this.vars,param2,this.logger);
      }
   }
}

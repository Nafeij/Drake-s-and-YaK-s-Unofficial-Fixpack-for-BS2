package engine.saga
{
   import engine.saga.vars.VariableDef;
   
   public interface IVariableDefProvider
   {
       
      
      function getVariableDefByName(param1:String) : VariableDef;
      
      function getVariables() : Vector.<VariableDef>;
   }
}

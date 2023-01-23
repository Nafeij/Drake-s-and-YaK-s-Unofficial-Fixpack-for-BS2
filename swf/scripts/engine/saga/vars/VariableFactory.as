package engine.saga.vars
{
   import engine.core.logging.ILogger;
   
   public class VariableFactory
   {
       
      
      public function VariableFactory()
      {
         super();
      }
      
      public static function factory(param1:IBattleEntityProvider, param2:VariableDef, param3:ILogger) : Variable
      {
         if(param2.scripted)
         {
            return new ScriptedVariable(param1,param2,param3);
         }
         return new Variable(param2,param3);
      }
   }
}

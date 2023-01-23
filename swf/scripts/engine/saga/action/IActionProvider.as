package engine.saga.action
{
   import engine.saga.happening.Happening;
   
   public interface IActionProvider
   {
       
      
      function executeActionDef(param1:ActionDef, param2:Happening, param3:IActionListener) : Action;
   }
}

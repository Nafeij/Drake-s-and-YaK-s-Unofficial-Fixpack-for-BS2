package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_SaveLoadShowGui extends Action
   {
       
      
      public function Action_SaveLoadShowGui(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:* = def.varvalue != 0;
         saga.showSaveLoad(_loc1_,saga.profile_index,false);
         end();
      }
   }
}

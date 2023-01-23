package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_GuiSurvivalBattlePopup extends Action
   {
       
      
      public function Action_GuiSurvivalBattlePopup(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         paused = true;
         var _loc1_:String = "Survival!";
         var _loc2_:String = def.msg;
         _loc2_ = translateMsg(_loc2_);
         saga.performSagaSurvivalBattlePopup(_loc2_,this.closedHandler);
      }
      
      private function closedHandler() : void
      {
         end();
      }
   }
}

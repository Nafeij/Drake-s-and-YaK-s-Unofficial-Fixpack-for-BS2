package engine.saga.action
{
   import engine.saga.Saga;
   import engine.saga.SagaVar;
   
   public class Action_DisplayShatterGui extends Action
   {
       
      
      public function Action_DisplayShatterGui(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         saga.performTally(def.param,this.onTallyComplete,false);
      }
      
      public function onTallyComplete() : void
      {
         var _loc1_:int = saga.caravanVars.getVarInt(SagaVar.VAR_TRAVEL_HUD_APPEARANCE);
         if(_loc1_ == SagaVar.TRAVEL_HUD_APPEARANCE_LIGHT)
         {
            saga.setVar(SagaVar.VAR_TRAVEL_HUD_APPEARANCE,SagaVar.TRAVEL_HUD_APPEARANCE_LIGHT_SHATTERED);
         }
         else if(_loc1_ == SagaVar.TRAVEL_HUD_APPEARANCE_DARKNESS)
         {
            saga.setVar(SagaVar.VAR_TRAVEL_HUD_APPEARANCE,SagaVar.TRAVEL_HUD_APPEARANCE_DARK_SHATTERED);
         }
         end();
      }
   }
}

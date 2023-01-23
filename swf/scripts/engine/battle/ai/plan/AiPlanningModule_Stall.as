package engine.battle.ai.plan
{
   import engine.battle.ai.def.AiPlanningModuleDef;
   import engine.battle.ai.def.AiPlanningModuleDef_Stall;
   import engine.battle.ai.phase.AiPhase_Plan;
   
   public class AiPlanningModule_Stall extends AiPlanningModule
   {
       
      
      public var defStall:AiPlanningModuleDef_Stall;
      
      public function AiPlanningModule_Stall(param1:AiPhase_Plan, param2:AiPlanningModuleDef)
      {
         super(param1,param2);
         this.defStall = param2 as AiPlanningModuleDef_Stall;
      }
      
      override public function update(param1:int) : void
      {
         super.update(param1);
         if(phase.elapsedWallMs >= this.defStall.stallMs)
         {
            complete = true;
         }
         var _loc2_:int = 0;
         while(_loc2_ < this.defStall.timeoutChecks)
         {
            if(ai.checkStopTick())
            {
               return;
            }
            _loc2_++;
         }
      }
   }
}

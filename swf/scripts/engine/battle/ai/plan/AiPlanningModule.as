package engine.battle.ai.plan
{
   import engine.battle.ai.Ai;
   import engine.battle.ai.def.AiPlanningModuleDef;
   import engine.battle.ai.phase.AiPhase_Plan;
   import engine.battle.fsm.aimodule.AiConfig;
   
   public class AiPlanningModule
   {
       
      
      public var def:AiPlanningModuleDef;
      
      public var phase:AiPhase_Plan;
      
      public var ai:Ai;
      
      public var config:AiConfig;
      
      public var complete:Boolean;
      
      public function AiPlanningModule(param1:AiPhase_Plan, param2:AiPlanningModuleDef)
      {
         super();
         this.phase = param1;
         this.def = param2;
         this.ai = param1.ai;
         this.config = this.ai.config;
      }
      
      public function update(param1:int) : void
      {
      }
   }
}

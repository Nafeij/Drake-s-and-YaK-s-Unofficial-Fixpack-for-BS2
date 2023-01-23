package engine.battle.ai.def
{
   public class AiPlanningModuleDef_Stall extends AiPlanningModuleDef
   {
       
      
      public var stallMs:int;
      
      public var timeoutChecks:int;
      
      public function AiPlanningModuleDef_Stall()
      {
         super();
      }
      
      public function init(param1:int, param2:int) : AiPlanningModuleDef_Stall
      {
         this.stallMs = param1;
         this.timeoutChecks = param2;
         return this;
      }
   }
}

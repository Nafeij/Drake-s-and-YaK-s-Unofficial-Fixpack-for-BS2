package engine.battle.ai.def
{
   public class AiDef
   {
       
      
      public var planningModuleDefs:Vector.<AiPlanningModuleDef>;
      
      public function AiDef()
      {
         this.planningModuleDefs = new Vector.<AiPlanningModuleDef>();
         super();
      }
   }
}

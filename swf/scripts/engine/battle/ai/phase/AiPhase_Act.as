package engine.battle.ai.phase
{
   import engine.battle.ai.Ai;
   
   public class AiPhase_Act extends AiPhase
   {
       
      
      public function AiPhase_Act(param1:Ai)
      {
         super(param1);
      }
      
      override public function update(param1:int) : void
      {
         super.update(param1);
         complete = true;
      }
   }
}

package engine.battle.ai.phase
{
   public class AiPhaseOrder
   {
       
      
      public function AiPhaseOrder()
      {
         super();
      }
      
      public static function getNextClazz(param1:AiPhase, param2:Boolean) : Class
      {
         if(!param1)
         {
            return AiPhase_Prepare;
         }
         if(param1 is AiPhase_Prepare)
         {
            return AiPhase_Plan;
         }
         if(param1 is AiPhase_Plan)
         {
            return AiPhase_Move;
         }
         if(param1 is AiPhase_Move)
         {
            return AiPhase_Act;
         }
         if(param1 is AiPhase_Act)
         {
            if(param2)
            {
               return AiPhase_Runaway;
            }
         }
         return null;
      }
   }
}

package engine.saga.action
{
   import com.greensock.TweenMax;
   import engine.saga.Saga;
   
   public class Action_SurvivalComputeScore extends Action
   {
       
      
      public function Action_SurvivalComputeScore(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleEnded() : void
      {
         TweenMax.killDelayedCallsTo(this.delayHandler);
      }
      
      override protected function handleStarted() : void
      {
         saga.def.survival.computeScores(saga,this.scoreHandler);
         TweenMax.delayedCall(10,this.delayHandler);
      }
      
      private function delayHandler() : void
      {
         if(!saga || !saga.locale)
         {
            end();
            return;
         }
         var _loc1_:String = saga.locale.translateGui("survival_score_upload");
         saga.showFlyText(_loc1_,16711680,null,5);
         TweenMax.delayedCall(10,this.delayHandler);
      }
      
      private function scoreHandler() : void
      {
         end();
      }
   }
}

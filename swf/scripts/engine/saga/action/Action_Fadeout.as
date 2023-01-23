package engine.saga.action
{
   import com.greensock.TweenMax;
   import engine.saga.Saga;
   
   public class Action_Fadeout extends Action
   {
       
      
      public function Action_Fadeout(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         saga.sceneFadeOut(def.time);
         if(def.time > 0)
         {
            TweenMax.delayedCall(def.time,end);
         }
         else
         {
            end();
         }
      }
      
      override public function fastForward() : Boolean
      {
         if(!ended && !def.instant)
         {
            end(true);
            return true;
         }
         return false;
      }
   }
}

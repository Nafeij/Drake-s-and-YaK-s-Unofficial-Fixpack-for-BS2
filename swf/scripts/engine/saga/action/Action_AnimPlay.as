package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_AnimPlay extends Action
   {
       
      
      public function Action_AnimPlay(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         saga.performSceneAnimPlay(def.id,def.frame,def.loops);
         end();
      }
   }
}

package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_MusicStop extends Action
   {
       
      
      public function Action_MusicStop(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         saga.sound.stopMusic(def.location,def.id);
         end();
      }
   }
}

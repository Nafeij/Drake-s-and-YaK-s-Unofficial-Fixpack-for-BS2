package engine.saga.action
{
   import engine.saga.Saga;
   import engine.sound.view.ISound;
   
   public class Action_MusicStart extends BaseAction_Sound
   {
       
      
      public function Action_MusicStart(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         startLoadingSound(def.location,def.id,def.param,def.varvalue);
      }
      
      override protected function handlePlaySound() : Boolean
      {
         var _loc1_:ISound = saga.sound.playMusicStart(sku,event,param,value);
         if(!_loc1_ || !_loc1_.playing)
         {
            logger.error("Failed to play music [" + event + "] for " + this);
         }
         end();
         return false;
      }
   }
}

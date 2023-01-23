package engine.saga.action
{
   import engine.saga.Saga;
   import engine.sound.ISoundEventId;
   
   public class Action_SoundPlayEvent extends BaseAction_Sound
   {
       
      
      public var isScene:Boolean;
      
      public function Action_SoundPlayEvent(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         this.isScene = def.scene == "scene";
         startLoadingSound(def.location,def.id,def.param,def.varvalue);
      }
      
      override protected function handlePlaySound() : Boolean
      {
         var _loc1_:ISoundEventId = null;
         if(this.isScene)
         {
            saga.performSoundPlayEventScene(event,sku,param,value,bundle);
         }
         else
         {
            if(!saga.sound.system.enabled)
            {
               end();
               return false;
            }
            _loc1_ = saga.sound.system.driver.playEvent(event);
            if(!_loc1_)
            {
               saga.logger.error("Action_SoundPlayEvent Failed to play sound: " + event);
            }
            else if(param)
            {
               saga.sound.system.driver.setEventParameterValueByName(_loc1_,param,value);
            }
            if(def.sound_volume != 1)
            {
               saga.sound.system.driver.setEventVolume(_loc1_,def.sound_volume);
            }
         }
         end();
         return false;
      }
   }
}

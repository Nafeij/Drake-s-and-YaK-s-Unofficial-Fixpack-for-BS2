package engine.saga.action
{
   import engine.saga.Saga;
   import engine.sound.view.ISound;
   
   public class Action_MusicIncidental extends BaseAction_Sound
   {
       
      
      public var sound:ISound;
      
      public function Action_MusicIncidental(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         startLoadingSound(def.location,def.id,def.param,def.varvalue);
      }
      
      override protected function handlePlaySound() : Boolean
      {
         this.sound = saga.sound.playMusicIncidental(sku,event,param,value);
         end();
         return false;
      }
   }
}

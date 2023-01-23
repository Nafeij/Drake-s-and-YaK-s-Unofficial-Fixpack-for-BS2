package engine.saga.action
{
   import engine.saga.Saga;
   import engine.sound.view.ISound;
   
   public class Action_SoundPlay extends Action
   {
       
      
      public var sound:ISound;
      
      public function Action_SoundPlay(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         this.sound = saga.sound.system.controller.getSound(def.id,null);
         if(!this.sound)
         {
            saga.logger.error("No such sound: " + def.id + " for: " + this);
         }
         else
         {
            this.sound.start();
            if(def.param)
            {
               this.sound.setParameter(def.param,def.varvalue);
            }
         }
         end();
      }
   }
}

package engine.saga.action
{
   import engine.saga.Saga;
   import engine.sound.def.ISoundDef;
   
   public class Action_SoundParam extends Action
   {
       
      
      public function Action_SoundParam(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:ISoundDef = saga.sound.system.controller.library.getSoundDef(def.id);
         if(!_loc1_)
         {
            saga.logger.error("No such sound: " + def.id + " for: " + this);
         }
         else if(!def.param)
         {
            saga.logger.error("No param set for Action_SoundParam: " + this);
         }
         else
         {
            saga.sound.system.controller.soundDriver.setEventParameter(_loc1_.eventName,def.param,def.varvalue);
         }
         end();
      }
   }
}

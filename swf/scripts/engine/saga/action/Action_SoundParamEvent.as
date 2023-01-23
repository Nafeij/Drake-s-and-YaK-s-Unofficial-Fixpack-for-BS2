package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_SoundParamEvent extends Action
   {
       
      
      public function Action_SoundParamEvent(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:String = def.id;
         var _loc2_:String = def.param;
         var _loc3_:Number = def.varvalue;
         if(!_loc1_)
         {
            throw new ArgumentError("Bad event");
         }
         if(!_loc2_)
         {
            throw new ArgumentError("Bad param");
         }
         if(saga.sound.system.enabled)
         {
            saga.sound.system.controller.soundDriver.setEventParameter(_loc1_,_loc2_,_loc3_);
         }
         end();
      }
   }
}

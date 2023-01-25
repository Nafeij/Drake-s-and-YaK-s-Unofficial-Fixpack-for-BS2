package engine.saga.action
{
   import engine.saga.Saga;
   import engine.sound.ISoundDriver;
   import engine.sound.ISoundEventId;
   
   public class Action_SoundStop extends Action
   {
       
      
      public function Action_SoundStop(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:Boolean = Boolean(def.param) && def.param.indexOf("immediate") >= 0;
         var _loc2_:ISoundEventId = this.findPlayingSoundByName(def.id);
         if(!_loc2_)
         {
            saga.logger.info("No such sound playing: [" + def.id + "]");
            return;
         }
         var _loc3_:ISoundDriver = saga.sound.system.driver;
         _loc3_.stopEvent(_loc2_,_loc1_);
         end();
      }
      
      private function findPlayingSoundByName(param1:String) : ISoundEventId
      {
         var _loc3_:Object = null;
         var _loc4_:ISoundEventId = null;
         var _loc5_:String = null;
         var _loc2_:ISoundDriver = saga.sound.system.driver;
         for(_loc3_ in _loc2_.playing)
         {
            _loc4_ = _loc3_ as ISoundEventId;
            _loc5_ = String(_loc2_.playing[_loc3_]);
            if(_loc5_ == param1)
            {
               return _loc4_;
            }
         }
         return null;
      }
   }
}

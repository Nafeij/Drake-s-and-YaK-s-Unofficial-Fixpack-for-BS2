package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_MusicParam extends Action
   {
       
      
      private var eventName:String;
      
      public function Action_MusicParam(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:String = def.id;
         var _loc2_:String = def.location;
         var _loc3_:String = def.param;
         var _loc4_:Number = def.varvalue;
         if(saga.sound.system.enabled)
         {
            saga.sound.setMusicParam(_loc2_,_loc1_,_loc3_,_loc4_);
         }
         end();
      }
   }
}

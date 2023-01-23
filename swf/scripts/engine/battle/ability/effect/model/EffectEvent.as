package engine.battle.ability.effect.model
{
   import flash.events.Event;
   
   public class EffectEvent extends Event
   {
      
      public static const REMOVED:String = "EffectEvent.REMOVED";
       
      
      public function EffectEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
   }
}

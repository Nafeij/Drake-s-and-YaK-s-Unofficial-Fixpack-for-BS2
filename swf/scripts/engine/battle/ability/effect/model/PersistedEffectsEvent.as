package engine.battle.ability.effect.model
{
   import flash.events.Event;
   
   public class PersistedEffectsEvent extends Event
   {
      
      public static const CHANGED:String = "PersistedEffectsEvent.CHANGED";
       
      
      public function PersistedEffectsEvent(param1:String)
      {
         super(param1);
      }
      
      public function get effects() : PersistedEffects
      {
         return target as PersistedEffects;
      }
   }
}

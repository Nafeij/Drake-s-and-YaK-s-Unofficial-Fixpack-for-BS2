package engine.stat.model
{
   import flash.events.Event;
   
   public class StatEvent extends Event
   {
      
      public static const CHANGE:String = "StatEvent.CHANGE";
      
      public static const BASE_CHANGE:String = "StatEvent.BASE_CHANGE";
       
      
      public var delta;
      
      public function StatEvent(param1:String, param2:*)
      {
         super(param1);
         this.delta = param2;
      }
      
      public function get stat() : Stat
      {
         return target as Stat;
      }
   }
}

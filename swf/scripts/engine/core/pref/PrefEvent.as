package engine.core.pref
{
   import flash.events.Event;
   
   public class PrefEvent extends Event
   {
      
      public static const PREF_BAG_CHANGED:String = "PREF_BAG_CHANGED";
      
      public static const PREF_CHANGED:String = "PREF_CHANGED";
       
      
      public var key:String;
      
      public var value;
      
      public function PrefEvent(param1:String, param2:String, param3:*, param4:Boolean = false, param5:Boolean = false)
      {
         super(param1,param4,param5);
         this.key = param2;
         this.value = param3;
      }
   }
}

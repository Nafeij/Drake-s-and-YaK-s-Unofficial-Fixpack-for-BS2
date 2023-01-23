package air.steamworks.ane
{
   import flash.events.Event;
   
   public class SteamworksCallbackEvent extends Event
   {
      
      public static const TYPE:String = "SteamworksCallbackEvent.TYPE";
       
      
      public var callback:Object;
      
      public function SteamworksCallbackEvent(param1:Object)
      {
         super(TYPE);
         this.callback = param1;
      }
   }
}

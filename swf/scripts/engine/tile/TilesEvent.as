package engine.tile
{
   import flash.events.Event;
   
   public class TilesEvent extends Event
   {
      
      public static const TILE_FLYTEXT:String = "TilesEvent.TILE_FLYTEXT";
       
      
      public function TilesEvent(param1:String)
      {
         super(param1,false,false);
      }
   }
}

package engine.landscape.def
{
   import flash.events.Event;
   
   public class LandscapeDefEvent extends Event
   {
      
      public static const SPRITE_TOOLTIP:String = "LandscapeDefEvent.SPRITE_TOOLTIP";
       
      
      public var sprite:LandscapeSpriteDef;
      
      public function LandscapeDefEvent(param1:String, param2:LandscapeSpriteDef)
      {
         super(param1);
         this.sprite = this.sprite;
      }
   }
}

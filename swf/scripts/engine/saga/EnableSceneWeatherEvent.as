package engine.saga
{
   import flash.events.Event;
   
   public class EnableSceneWeatherEvent extends Event
   {
      
      public static const TYPE:String = "EnableSceneWeatherEvent.TYPE";
       
      
      public var enabled:Boolean;
      
      public function EnableSceneWeatherEvent(param1:Boolean)
      {
         super(TYPE);
      }
   }
}

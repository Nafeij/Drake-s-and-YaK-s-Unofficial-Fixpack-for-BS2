package engine.saga
{
   import flash.events.Event;
   
   public class SceneCameraSplineEvent extends Event
   {
      
      public static const TYPE:String = "SceneCameraSplineEvent.TYPE";
       
      
      public var spline:String;
      
      public var speed:Number = 1000;
      
      public var time:Number = 0;
      
      public function SceneCameraSplineEvent(param1:String, param2:Number, param3:Number)
      {
         super(TYPE);
         this.spline = param1;
         this.speed = param2;
         this.time = param3;
      }
   }
}

package engine.saga
{
   import flash.events.Event;
   
   public class EnableSceneElementEvent extends Event
   {
      
      public static const TYPE:String = "EnableSceneElementEvent.TYPE";
       
      
      public var id:String;
      
      public var enabled:Boolean;
      
      public var layer:Boolean;
      
      public var clickable:Boolean;
      
      public var time:Number = 0;
      
      public var reason:String;
      
      public function EnableSceneElementEvent(param1:Boolean, param2:String, param3:Boolean, param4:Boolean, param5:Number, param6:String)
      {
         super(TYPE);
         this.id = param2;
         this.enabled = param1;
         this.layer = param3;
         this.clickable = param4;
         this.time = param5;
         this.reason = param6;
      }
   }
}

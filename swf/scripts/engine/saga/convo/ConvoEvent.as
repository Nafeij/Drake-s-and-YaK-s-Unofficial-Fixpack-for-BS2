package engine.saga.convo
{
   import flash.events.Event;
   
   public class ConvoEvent extends Event
   {
      
      public static const START:String = "ConvoEvent.START";
      
      public static const FINISHED:String = "ConvoEvent.EVENT_FINISHED";
      
      public static const OPTION:String = "ConvoEvent.EVENT_OPTION";
      
      public static const HIDE_ACTOR:String = "ConvoEvent.HIDE_ACTOR";
      
      public static const SHOW_ACTOR:String = "ConvoEvent.SHOW_ACTOR";
       
      
      public var convo:Convo;
      
      public var arg:Object;
      
      public function ConvoEvent(param1:String, param2:Convo, param3:Object = null)
      {
         super(param1);
         this.convo = param2;
         this.arg = param3;
      }
   }
}

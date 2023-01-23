package engine.saga.vars
{
   import flash.events.Event;
   
   public class VariableEvent extends Event
   {
      
      public static const TYPE:String = "VariableEvent.TYPE";
       
      
      public var value:Variable;
      
      public var oldValue:String;
      
      public function VariableEvent(param1:Variable, param2:String)
      {
         this.value = param1;
         this.oldValue = param2;
         super(TYPE);
      }
   }
}

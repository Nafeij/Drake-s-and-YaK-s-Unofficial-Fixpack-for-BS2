package engine.core.fsm
{
   public class StatePhase
   {
      
      public static const INIT:StatePhase = new StatePhase(0,"INIT");
      
      public static const ENTERING:StatePhase = new StatePhase(1,"ENTERING");
      
      public static const ENTERED:StatePhase = new StatePhase(2,"ENTERED");
      
      public static const COMPLETING:StatePhase = new StatePhase(3,"COMPLETING");
      
      public static const COMPLETED:StatePhase = new StatePhase(4,"COMPLETED");
      
      public static const FAILED:StatePhase = new StatePhase(5,"FAILED");
      
      public static const INTERRUPTED:StatePhase = new StatePhase(6,"INTERRUPTED");
       
      
      private var m_value:int;
      
      public var name:String;
      
      public function StatePhase(param1:int, param2:String)
      {
         super();
         this.m_value = param1;
         this.name = param2;
      }
      
      public function get value() : int
      {
         return this.m_value;
      }
      
      public function toString() : String
      {
         return this.name;
      }
   }
}

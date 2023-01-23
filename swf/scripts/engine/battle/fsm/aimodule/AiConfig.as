package engine.battle.fsm.aimodule
{
   import flash.utils.getTimer;
   
   public class AiConfig
   {
       
      
      public var fast:Boolean;
      
      public var max_think_ms:int;
      
      public function AiConfig(param1:Boolean, param2:int)
      {
         super();
         this.fast = param1;
         this.max_think_ms = param2;
      }
      
      public function getTimerMs() : int
      {
         return getTimer();
      }
   }
}

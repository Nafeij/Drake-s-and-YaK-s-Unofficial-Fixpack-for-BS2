package engine.automator
{
   import engine.core.cmd.IKeyBinder;
   import engine.core.logging.ILogger;
   
   public class AutomatedProgramContext
   {
       
      
      public var keybinder:IKeyBinder;
      
      public var logger:ILogger;
      
      public var clicker:IClicker;
      
      public var fastForward:IFastForward;
      
      public function AutomatedProgramContext()
      {
         super();
      }
      
      public function setFastForward(param1:IFastForward) : AutomatedProgramContext
      {
         this.fastForward = param1;
         return this;
      }
      
      public function setClicker(param1:IClicker) : AutomatedProgramContext
      {
         this.clicker = param1;
         return this;
      }
      
      public function setKeyBinder(param1:IKeyBinder) : AutomatedProgramContext
      {
         this.keybinder = param1;
         return this;
      }
      
      public function setLogger(param1:ILogger) : AutomatedProgramContext
      {
         this.logger = param1;
         return this;
      }
      
      public function exit(param1:Boolean) : void
      {
      }
   }
}

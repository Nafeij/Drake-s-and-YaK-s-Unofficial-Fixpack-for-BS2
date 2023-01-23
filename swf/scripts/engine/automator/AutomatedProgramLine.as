package engine.automator
{
   import engine.core.logging.ILogger;
   import engine.core.util.StringUtil;
   import flash.errors.IllegalOperationError;
   
   public class AutomatedProgramLine
   {
       
      
      public var line:String;
      
      public var argv:Array;
      
      public var finished:Boolean;
      
      public var executed:Boolean;
      
      public var reexecute:Boolean;
      
      public var program:AutomatedProgram;
      
      public var context:AutomatedProgramContext;
      
      public var num:int;
      
      public var logger:ILogger;
      
      public function AutomatedProgramLine(param1:AutomatedProgram, param2:int, param3:String, param4:Array)
      {
         super();
         this.program = param1;
         this.num = param2;
         this.context = param1.context;
         this.line = param3;
         this.argv = param4;
         this.logger = param1.logger;
      }
      
      public function toString() : String
      {
         return StringUtil.padLeft(this.num.toString()," ",3) + ":[" + this.line + "]";
      }
      
      final public function execute() : void
      {
         if(this.executed && !this.reexecute)
         {
            throw new IllegalOperationError("already executed " + this);
         }
         if(this.finished)
         {
            throw new IllegalOperationError("already finished " + this);
         }
         this.executed = true;
         this.handleExecuted();
      }
      
      public function consumeNotification(param1:String) : Boolean
      {
         return false;
      }
      
      final public function finish() : void
      {
         if(this.finished)
         {
            throw new Error("double finish!");
         }
         this.logger.i("AUTO","FINISH " + this);
         this.finished = true;
         this.handleFinished();
      }
      
      protected function handleExecuted() : void
      {
      }
      
      protected function handleFinished() : void
      {
      }
   }
}

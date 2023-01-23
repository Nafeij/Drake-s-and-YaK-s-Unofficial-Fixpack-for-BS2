package engine.automator
{
   import engine.core.logging.ILogger;
   import engine.core.util.StringUtil;
   import flash.errors.IllegalOperationError;
   
   public class AutomatedProgramExecutor
   {
       
      
      public var _program:AutomatedProgram;
      
      public var _cursor:int;
      
      public var _line:AutomatedProgramLine;
      
      public var logger:ILogger;
      
      public var failed:Boolean;
      
      public function AutomatedProgramExecutor(param1:AutomatedProgram)
      {
         super();
         this._program = param1;
         this.logger = param1.logger;
      }
      
      public function get canConsumeNotifications() : Boolean
      {
         return Boolean(this._line) && this._line.executed && !this._line.finished;
      }
      
      public function consumeNotification(param1:String) : Boolean
      {
         if(!this.canConsumeNotifications)
         {
            return false;
         }
         return this._line.consumeNotification(param1);
      }
      
      public function checkNext() : Boolean
      {
         if(!this._line || this._line.finished)
         {
            return this.next();
         }
         return false;
      }
      
      private function next() : Boolean
      {
         if(this._cursor >= this._program.programLines.length)
         {
            if(this._line)
            {
               this._line = null;
               this.logger.i("AUTO","reached end");
            }
            return false;
         }
         this._line = this._program.programLines[this._cursor];
         this.logger.i("AUTO","next line " + this._cursor + " " + this._line);
         ++this._cursor;
         return true;
      }
      
      public function execute(param1:Boolean = true) : void
      {
         var msg:String = null;
         var showError:Boolean = param1;
         if(!this._line)
         {
            throw new IllegalOperationError("Line null for execution " + this._line);
         }
         if(this._line.finished)
         {
            throw new IllegalOperationError("Line finished for execution " + this._line);
         }
         if(this._line.executed && !this._line.reexecute)
         {
            throw new IllegalOperationError("Line not reexecute " + this._line);
         }
         if(this.failed)
         {
            throw new IllegalOperationError("Unable to execute a failed program");
         }
         try
         {
            this._line.execute();
         }
         catch(e:Error)
         {
            if(showError)
            {
               msg = "AutomatedProgramExecutor failed on line " + _cursor + "\n" + _line;
               msg = msg + "\n" + e.getStackTrace();
               logger.e("AUTO",msg);
            }
            failed = true;
            if(EngineAutomator.TERMINATE_ON_FAILURE)
            {
               _program.context.exit(false);
            }
         }
      }
      
      public function unfail() : void
      {
         if(this.failed)
         {
            this.failed = false;
            if(this._line.executed)
            {
               this._line.finished = true;
            }
         }
      }
      
      public function list() : void
      {
         var _loc1_:AutomatedProgramLine = null;
         if(!this._program)
         {
            this.logger.i("AUTO","list no lines");
            return;
         }
         for each(_loc1_ in this._program.programLines)
         {
            if(_loc1_ == this._line)
            {
               this.logger.info(" *> " + _loc1_);
            }
            else
            {
               this.logger.info("    " + _loc1_);
            }
         }
         if(!this._line)
         {
            this.logger.info(" *> " + StringUtil.padLeft(this._cursor.toString()," ",3) + " ...");
         }
      }
      
      public function where() : void
      {
         if(!this._program || !this._line)
         {
            this.logger.info(" *> " + StringUtil.padLeft(this._cursor.toString()," ",3) + " ...");
            return;
         }
         this.logger.info(" *> " + this._line);
      }
   }
}

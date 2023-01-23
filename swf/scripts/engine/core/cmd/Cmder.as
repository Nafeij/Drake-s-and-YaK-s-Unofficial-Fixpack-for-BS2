package engine.core.cmd
{
   import engine.IInstrumentation;
   import engine.core.logging.ILogger;
   import engine.saga.SagaCheat;
   import flash.events.EventDispatcher;
   
   public class Cmder extends EventDispatcher
   {
       
      
      public var cmds:Vector.<Cmd>;
      
      public var history:Vector.<CmdExec>;
      
      public var logger:ILogger;
      
      public var cheat:Boolean;
      
      public var inst:IInstrumentation;
      
      public var cursor:uint;
      
      public function Cmder(param1:ILogger)
      {
         this.cmds = new Vector.<Cmd>();
         this.history = new Vector.<CmdExec>();
         super();
         this.logger = param1;
      }
      
      public function cleanupCmder() : void
      {
         this.cmds = null;
         this.history = null;
      }
      
      public function execute(param1:Cmd, param2:String, param3:*) : void
      {
         var cmde:CmdExec;
         var cmd:Cmd = param1;
         var cmdline:String = param2;
         var input:* = param3;
         if(this.cheat || cmd.cheat)
         {
            SagaCheat.devCheat("shell: " + cmdline);
         }
         this.inst && this.inst.instrument("Cmder.execute",cmd);
         cmde = new CmdExec(cmd,cmdline,input);
         if(cmd.undoable)
         {
            this.history.push(cmde);
            this.cursor = this.history.length;
         }
         try
         {
            cmde.execute();
         }
         catch(err:Error)
         {
            logger.error("Failed to execute [" + cmd + "]");
            logger.error(err.getStackTrace());
         }
      }
      
      public function undo() : CmdExec
      {
         var cmde:CmdExec = null;
         if(this.cursor > 0)
         {
            cmde = this.history[--this.cursor];
            this.inst && this.inst.instrument("Cmder.undo",cmde);
            try
            {
               cmde.executeUndo();
            }
            catch(err:Error)
            {
               logger.error("Failed to undo [" + cmde + "]");
               logger.error(err.getStackTrace());
            }
            return cmde;
         }
         return null;
      }
      
      public function redo() : CmdExec
      {
         var cmde:CmdExec = null;
         if(this.history.length != 0 && this.cursor < this.history.length)
         {
            cmde = this.history[this.cursor];
            this.inst && this.inst.instrument("Cmder.redo",cmde);
            ++this.cursor;
            try
            {
               cmde.execute();
            }
            catch(err:Error)
            {
               logger.error("Failed to redo [" + cmde + "]");
               logger.error(err.getStackTrace());
            }
            return cmde;
         }
         return null;
      }
      
      public function currentCmdExec() : CmdExec
      {
         if(this.cursor > 0)
         {
            return this.history[this.cursor - 1];
         }
         return null;
      }
      
      public function unregisterCmd(param1:Cmd) : void
      {
         var _loc2_:int = this.cmds.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this.cmds.splice(_loc2_,1);
         }
      }
      
      public function registerCmd(param1:Cmd) : void
      {
         this.cmds.push(param1);
      }
      
      public function registerCmds(param1:Array) : void
      {
         var _loc2_:* = undefined;
         for each(_loc2_ in param1)
         {
            this.registerCmd(_loc2_);
         }
      }
   }
}

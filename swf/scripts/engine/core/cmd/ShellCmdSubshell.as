package engine.core.cmd
{
   import flash.events.Event;
   
   public class ShellCmdSubshell
   {
       
      
      private var name:String;
      
      public var lowerName:String;
      
      private var shell:ShellCmdManager;
      
      private var parent:ShellCmdManager;
      
      public function ShellCmdSubshell(param1:String, param2:ShellCmdManager, param3:ShellCmdManager)
      {
         super();
         this.name = param1;
         this.lowerName = param1.toLowerCase();
         this.shell = param2;
         this.parent = param3;
         param2.addEventListener(Event.COMPLETE,this.shellCmdManagerCompleteHandler,false,0,true);
         var _loc4_:Cmd = param3.add(param1,this.func);
         _loc4_.isShell = true;
         _loc4_.cheat = param2.cheat || Boolean(param3) && param3.cheat;
      }
      
      public function cleanup() : void
      {
         this.shellCmdManagerCompleteHandler(null);
         this.shell = null;
         this.parent = null;
      }
      
      private function shellCmdManagerCompleteHandler(param1:Event) : void
      {
         this.shell.removeEventListener(Event.COMPLETE,this.shellCmdManagerCompleteHandler);
         this.parent.removeShell(this.name);
      }
      
      private function func(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         _loc2_ = _loc2_.slice(1);
         if(!this.shell.execArgv(param1.cmdline,_loc2_))
         {
            if(_loc2_.length > 0)
            {
               this.parent.logger.info("No such subcommand for " + param1.cmd.name + ": " + _loc2_[0]);
            }
            else
            {
               this.parent.logger.info("Empty subcommand not supported by " + param1.cmd.name);
            }
         }
      }
   }
}

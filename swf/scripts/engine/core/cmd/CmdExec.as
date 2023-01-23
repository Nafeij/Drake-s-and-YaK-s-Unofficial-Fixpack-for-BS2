package engine.core.cmd
{
   public class CmdExec
   {
       
      
      public var cmd:Cmd;
      
      private var input;
      
      public var cmdline:String;
      
      private var inputUndo;
      
      public var param;
      
      public function CmdExec(param1:Cmd, param2:String, param3:*)
      {
         super();
         this.cmd = param1;
         this.cmdline = param2;
         this.input = param3;
      }
      
      public function execute() : void
      {
         this.param = this.input;
         var _loc1_:* = this.cmd.func(this);
         if(!this.inputUndo)
         {
            this.inputUndo = _loc1_;
         }
      }
      
      public function executeUndo() : void
      {
         this.param = this.inputUndo;
         this.cmd.func(this);
      }
      
      public function toString() : String
      {
         return "[CmdExec cmd=" + this.cmd + " input=" + this.input + "]";
      }
   }
}

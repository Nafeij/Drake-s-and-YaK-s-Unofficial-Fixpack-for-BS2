package engine.battle.fsm.state.turn.cmd
{
   import flash.errors.IllegalOperationError;
   
   public class TurnCmd
   {
       
      
      public var seq:TurnSeqCmds;
      
      public var ordinal:int;
      
      public var executing:Boolean;
      
      public var executed:Boolean;
      
      public var requiresOrdering:Boolean;
      
      public function TurnCmd(param1:TurnSeqCmds, param2:int, param3:Boolean)
      {
         super();
         this.seq = param1;
         this.ordinal = param2;
         this.requiresOrdering = param3;
         if(param2 != 0 && param3)
         {
            throw new ArgumentError("Bad ordering");
         }
      }
      
      final public function cleanup() : void
      {
         this.handleCleanup();
      }
      
      protected function handleCleanup() : void
      {
      }
      
      protected function handleExecute() : void
      {
      }
      
      final public function execute() : void
      {
         if(this.executing || this.executed)
         {
            throw new IllegalOperationError("already executing/ed");
         }
         this.executing = true;
         this.handleExecute();
      }
      
      final protected function complete() : void
      {
         if(!this.executing || this.executed)
         {
            throw new IllegalOperationError("already execute/not executing");
         }
         this.executing = false;
         this.executed = true;
         this.cleanup();
         this.seq.onCmdComplete(this);
      }
   }
}

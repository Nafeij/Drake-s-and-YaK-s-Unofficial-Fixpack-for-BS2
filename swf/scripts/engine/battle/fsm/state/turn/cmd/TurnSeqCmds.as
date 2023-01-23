package engine.battle.fsm.state.turn.cmd
{
   import flash.errors.IllegalOperationError;
   
   public class TurnSeqCmds
   {
       
      
      protected var _cmds:Vector.<TurnCmd>;
      
      protected var _executingCmd:TurnCmd;
      
      protected var _lastCmdOrdinal:int;
      
      private var _autoSequence:Boolean;
      
      public var _completing:Boolean;
      
      public function TurnSeqCmds(param1:Boolean)
      {
         this._cmds = new Vector.<TurnCmd>();
         super();
         this._autoSequence = param1;
      }
      
      public function cleanup() : void
      {
         this.completing();
         if(this._executingCmd)
         {
            this._executingCmd.cleanup();
         }
      }
      
      public function get numCmds() : int
      {
         return this._cmds.length;
      }
      
      public function hasOrdinal(param1:int) : Boolean
      {
         var _loc2_:TurnCmd = null;
         for each(_loc2_ in this._cmds)
         {
            if(_loc2_.ordinal == param1)
            {
               return true;
            }
         }
         return false;
      }
      
      public function addCmd(param1:TurnCmd, param2:Boolean = true) : void
      {
         if(!this._autoSequence && param1.requiresOrdering)
         {
            throw new ArgumentError("cannot autosequence " + param1);
         }
         if(this._autoSequence && param1.ordinal != 0)
         {
            throw new ArgumentError("must autosequence " + param1);
         }
         if(!this._cmds || this._completing)
         {
            throw new IllegalOperationError("Already completing");
         }
         if(!this._autoSequence)
         {
            if(param1.ordinal <= this._lastCmdOrdinal)
            {
               return;
            }
         }
         this._cmds.push(param1);
         if(param2)
         {
            this.executeTurnSeqCmds();
         }
      }
      
      public function executeTurnSeqCmds() : void
      {
         var _loc1_:int = 0;
         var _loc2_:TurnCmd = null;
         if(this._completing || !this._cmds)
         {
            return;
         }
         if(!this._executingCmd)
         {
            _loc1_ = 0;
            while(_loc1_ < this._cmds.length)
            {
               _loc2_ = this._cmds[_loc1_];
               if(this._autoSequence || _loc2_.ordinal == this._lastCmdOrdinal + 1)
               {
                  this._cmds.splice(_loc1_,1);
                  this.executeCmd(_loc2_);
                  return;
               }
               _loc1_++;
            }
         }
      }
      
      private function executeCmd(param1:TurnCmd) : void
      {
         if(this._executingCmd)
         {
            throw new IllegalOperationError("already executing");
         }
         if(!this._autoSequence)
         {
            this._lastCmdOrdinal = param1.ordinal;
         }
         this._executingCmd = param1;
         if(this._autoSequence)
         {
            if(this._executingCmd.ordinal == 0 && this._executingCmd.requiresOrdering)
            {
               this._executingCmd.ordinal = ++this._lastCmdOrdinal;
            }
         }
         this._executingCmd.execute();
      }
      
      internal function onCmdComplete(param1:TurnCmd) : void
      {
         if(param1 != this._executingCmd)
         {
            throw new ArgumentError("invalid cmd complete");
         }
         this._executingCmd.cleanup();
         this._executingCmd = null;
      }
      
      public function updateTurnSeqCmds() : void
      {
         this.executeTurnSeqCmds();
      }
      
      public function completing() : void
      {
         var _loc1_:TurnCmd = null;
         if(!this._completing)
         {
            this._completing = true;
            for each(_loc1_ in this._cmds)
            {
               _loc1_.cleanup();
            }
            this._cmds = null;
         }
      }
   }
}

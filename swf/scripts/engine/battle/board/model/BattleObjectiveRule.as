package engine.battle.board.model
{
   import engine.battle.ability.model.BattleAbilityManager;
   import engine.core.logging.ILogger;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class BattleObjectiveRule extends EventDispatcher
   {
      
      protected static var _secret:Object = "the secret is out";
       
      
      public var count:int;
      
      public var _complete:Boolean;
      
      public var logger:ILogger;
      
      public var def:BattleObjectiveRuleDef;
      
      public var objective:BattleObjective;
      
      public var board:IBattleBoard;
      
      protected var manager:BattleAbilityManager;
      
      public function BattleObjectiveRule(param1:BattleObjective, param2:BattleObjectiveRuleDef, param3:*)
      {
         super();
         if(param3 != _secret)
         {
            throw new IllegalOperationError("This must not be created directly, use BattleObjectiveRuleDef.createObjectiveRule()");
         }
         this.def = param2;
         this.objective = param1;
         this.logger = param1.logger;
         this.board = param1.board;
         this.manager = param1.manager;
      }
      
      override public function toString() : String
      {
         return this.def.toString();
      }
      
      public function cleanup() : void
      {
         this.def = null;
         this.objective = null;
         this.logger = null;
         this.board = null;
         this.manager = null;
      }
      
      public function handleBattleWin() : void
      {
      }
      
      public function handleBattleStarted() : void
      {
      }
      
      public function handleFreeTurn(param1:IBattleEntity) : void
      {
      }
      
      public function handleTurnStart(param1:IBattleEntity) : void
      {
      }
      
      protected function handleComplete() : void
      {
      }
      
      public function set complete(param1:Boolean) : void
      {
         if(this._complete == param1)
         {
            return;
         }
         if(param1 && Boolean(this.def.count))
         {
            ++this.count;
            this.logger.info("  COUNT " + this.count + " / " + this.def.count);
            dispatchEvent(new Event(Event.CHANGE));
            if(this.count < this.def.count)
            {
               return;
            }
         }
         this._complete = param1;
         if(this._complete)
         {
            this.logger.info("BattleObjectiveRule.complete " + this);
            if(this.def.negate)
            {
               this.objective.handleRuleFailed(this);
               return;
            }
            if(this.def.count)
            {
               ++this.count;
               dispatchEvent(new Event(Event.CHANGE));
               if(this.count < this.def.count)
               {
                  return;
               }
            }
            this.handleComplete();
            dispatchEvent(new Event(Event.COMPLETE));
            this.objective.handleRuleComplete(this);
         }
      }
      
      public function get complete() : Boolean
      {
         return this._complete;
      }
   }
}

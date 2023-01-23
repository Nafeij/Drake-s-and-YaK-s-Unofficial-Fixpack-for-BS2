package engine.battle.board.model
{
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.phantasm.def.ChainPhantasmsDef;
   import engine.battle.ability.phantasm.model.ChainPhantasms;
   import engine.battle.ability.phantasm.model.ChainPhantasmsEvent;
   import engine.battle.ability.phantasm.model.PhantasmsEvent;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class BattleBoardPhantasms extends EventDispatcher
   {
       
      
      private var _board:BattleBoard;
      
      private var _chains:Dictionary;
      
      public function BattleBoardPhantasms(param1:BattleBoard)
      {
         this._chains = new Dictionary();
         super();
         this._board = param1;
      }
      
      public function cleanup() : void
      {
         var _loc1_:ChainPhantasms = null;
         for each(_loc1_ in this.chains)
         {
            _loc1_.removeEventListener(ChainPhantasmsEvent.STARTED,this.chainStartedHandler);
            _loc1_.removeEventListener(ChainPhantasmsEvent.ENDED,this.chainEndedHandler);
            _loc1_.cleanup();
         }
         this._chains = null;
         this._board = null;
      }
      
      public function createChainForEffect(param1:Effect) : ChainPhantasms
      {
         var _loc3_:ChainPhantasms = null;
         var _loc2_:ChainPhantasmsDef = param1.def.getChainPhantasmsForResult(param1.result);
         if(_loc2_)
         {
            _loc3_ = new ChainPhantasms(param1,_loc2_,this.board.logger);
            this.chains[_loc3_] = _loc3_;
            _loc3_.addEventListener(ChainPhantasmsEvent.STARTED,this.chainStartedHandler);
            return _loc3_;
         }
         return null;
      }
      
      protected function chainStartedHandler(param1:ChainPhantasmsEvent) : void
      {
         param1.chain.removeEventListener(ChainPhantasmsEvent.STARTED,this.chainStartedHandler);
         dispatchEvent(new PhantasmsEvent(PhantasmsEvent.CHAIN_STARTED,param1.chain,null));
      }
      
      protected function chainEndedHandler(param1:ChainPhantasmsEvent) : void
      {
         param1.chain.removeEventListener(ChainPhantasmsEvent.ENDED,this.chainStartedHandler);
         delete this.chains[param1.chain];
      }
      
      public function get board() : IBattleBoard
      {
         return this._board;
      }
      
      public function get chains() : Dictionary
      {
         return this._chains;
      }
   }
}

package engine.battle.ability.model
{
   import engine.battle.ability.def.BattleAbilityDefFactory;
   import engine.battle.ability.def.IBattleAbilityDefFactory;
   import engine.battle.ability.effect.model.IEffect;
   import engine.battle.ability.effect.op.model.Op;
   import engine.battle.ability.phantasm.model.ChainPhantasms;
   import engine.core.logging.ILogger;
   import engine.expression.ISymbols;
   import engine.math.Rng;
   import engine.math.RngSampler_SeedArray;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class BattleAbilityManager extends EventDispatcher implements IBattleAbilityManager
   {
      
      public static var DEBUG_INCOMPLETES:Boolean = false;
       
      
      public var logger:ILogger;
      
      public var factory:BattleAbilityDefFactory;
      
      private var _lastId:int = 0;
      
      private var _lastExecutedId:int = 0;
      
      private var _lastFakeExecutedId:int = 0;
      
      private var lastFakeId:int = 0;
      
      public var _faking:Boolean;
      
      private var _rng:Rng;
      
      private var _fakeRng:Rng;
      
      private var _numIncompleteAbilities:int;
      
      private var _incompleteAbilities:Dictionary;
      
      public var enabled:Boolean = true;
      
      public var persistedAbilityCounts:Dictionary;
      
      public var _symbols:ISymbols;
      
      private var _lastIncompleteTicker:int;
      
      public function BattleAbilityManager(param1:ILogger, param2:BattleAbilityDefFactory, param3:ISymbols)
      {
         this._incompleteAbilities = new Dictionary();
         this.persistedAbilityCounts = new Dictionary();
         super();
         this.logger = param1;
         this.factory = param2;
         this._symbols = param3;
      }
      
      public function get symbols() : ISymbols
      {
         return this._symbols;
      }
      
      public function notifyPersistedAbilityEffectAdded(param1:IBattleAbility, param2:IEffect) : void
      {
         var _loc3_:String = param1.def.id;
         var _loc4_:int = int(this.persistedAbilityCounts[_loc3_]);
         _loc4_++;
         this.persistedAbilityCounts[_loc3_] = _loc4_;
         if(!this._faking && !param1.fake)
         {
            dispatchEvent(new BattleAbilityEvent(BattleAbilityEvent.PERSISTED_ADDED,param1,param2));
         }
      }
      
      public function notifyPersistedAbilityEffectRemoved(param1:IBattleAbility, param2:IEffect) : void
      {
         var _loc3_:String = param1.def.id;
         var _loc4_:int = int(this.persistedAbilityCounts[_loc3_]);
         _loc4_--;
         this.persistedAbilityCounts[_loc3_] = Math.max(0,_loc4_);
         if(!this._faking && !param1.fake)
         {
            dispatchEvent(new BattleAbilityEvent(BattleAbilityEvent.PERSISTED_REMOVED,param1,param2));
         }
      }
      
      public function cleanup() : void
      {
         this.enabled = false;
      }
      
      public function get incompleteAbilities() : Dictionary
      {
         return this._incompleteAbilities;
      }
      
      public function isOpIncomplete(param1:Op) : Boolean
      {
         var _loc2_:BattleAbility = null;
         for each(_loc2_ in this._incompleteAbilities)
         {
            if(_loc2_.hasOp(param1))
            {
               return true;
            }
         }
         return false;
      }
      
      public function get numIncompleteAbilities() : int
      {
         return this._numIncompleteAbilities;
      }
      
      public function get lastExecutedId() : int
      {
         return this._lastExecutedId;
      }
      
      public function get lastId() : int
      {
         return this._lastId;
      }
      
      public function get nextId() : int
      {
         if(this._faking)
         {
            return --this.lastFakeId;
         }
         return ++this._lastId;
      }
      
      public function get nextExecutedId() : int
      {
         if(this._faking)
         {
            return --this._lastFakeExecutedId;
         }
         return ++this._lastExecutedId;
      }
      
      public function handleStartTurn() : void
      {
      }
      
      public function get debugIncompletes() : String
      {
         var _loc2_:BattleAbility = null;
         var _loc1_:String = "";
         for each(_loc2_ in this._incompleteAbilities)
         {
            _loc1_ += "\n            " + _loc2_;
         }
         return _loc1_;
      }
      
      public function onAbilityExecuting(param1:IBattleAbility) : void
      {
         if(!this._incompleteAbilities[param1])
         {
            ++this._numIncompleteAbilities;
            this._incompleteAbilities[param1] = param1;
         }
         if(!this._faking)
         {
            if(DEBUG_INCOMPLETES)
            {
               if(this.logger.isDebugEnabled)
               {
                  this.logger.debug("BattleAbilityManager.onAbilityExecuting " + param1 + ", incompletes=" + this._numIncompleteAbilities + " " + this.debugIncompletes);
               }
            }
         }
         dispatchEvent(new BattleAbilityEvent(BattleAbilityEvent.EXECUTING,param1,null));
      }
      
      public function onAbilityPreComplete(param1:IBattleAbility) : void
      {
         if(!this._faking)
         {
            if(DEBUG_INCOMPLETES)
            {
               if(this.logger.isDebugEnabled)
               {
                  this.logger.debug("BattleAbilityManager.onAbilityPreComplete " + param1);
               }
            }
         }
         dispatchEvent(new BattleAbilityEvent(BattleAbilityEvent.ABILITY_PRE_COMPLETE,param1,null));
      }
      
      public function onAbilityPostComplete(param1:IBattleAbility) : void
      {
         if(!this._faking)
         {
            if(DEBUG_INCOMPLETES)
            {
               if(this.logger.isDebugEnabled)
               {
                  this.logger.debug("BattleAbilityManager.onAbilityPostComplete " + param1);
               }
            }
         }
         dispatchEvent(new BattleAbilityEvent(BattleAbilityEvent.ABILITY_POST_COMPLETE,param1,null));
      }
      
      public function get lastIncompleteTicker() : int
      {
         return this._lastIncompleteTicker;
      }
      
      public function onAbilityFinalComplete(param1:IBattleAbility) : void
      {
         if(!this._faking)
         {
            if(DEBUG_INCOMPLETES)
            {
               if(this.logger.isDebugEnabled)
               {
                  this.logger.debug("BattleAbilityManager.onAbilityFinalComplete " + param1);
               }
            }
         }
         dispatchEvent(new BattleAbilityEvent(BattleAbilityEvent.FINAL_COMPLETE,param1,null));
         if(this._incompleteAbilities[param1])
         {
            ++this._lastIncompleteTicker;
            --this._numIncompleteAbilities;
            delete this._incompleteAbilities[param1];
            dispatchEvent(new BattleAbilityEvent(BattleAbilityEvent.FINAL_COMPLETE_MANAGED,param1,null));
            if(!this._faking)
            {
               if(DEBUG_INCOMPLETES)
               {
                  if(this.logger.isDebugEnabled)
                  {
                     this.logger.debug("BattleAbilityManager.onAbilityFinalComplete " + param1 + ", incompletes=" + this._numIncompleteAbilities + " " + this.debugIncompletes);
                  }
               }
            }
            if(!this._numIncompleteAbilities)
            {
               dispatchEvent(new BattleAbilityEvent(BattleAbilityEvent.INCOMPLETES_EMPTY,param1,null));
            }
         }
      }
      
      public function onAbilityAndChildrenComplete(param1:IBattleAbility) : void
      {
         if(!this._faking)
         {
            if(DEBUG_INCOMPLETES)
            {
               if(this.logger.isDebugEnabled)
               {
                  this.logger.debug("BattleAbilityManager.onAbilityAndChildrenComplete " + param1);
               }
            }
         }
         dispatchEvent(new BattleAbilityEvent(BattleAbilityEvent.ABILITY_AND_CHILDREN_COMPLETE,param1,null));
      }
      
      public function get rng() : Rng
      {
         if(this._faking)
         {
            return this._fakeRng;
         }
         return this._rng;
      }
      
      public function set seedRng(param1:int) : void
      {
         this._rng = RngSampler_SeedArray.ctor(param1,this.logger);
         this._fakeRng = RngSampler_SeedArray.ctor(param1,this.logger);
      }
      
      public function forceCompleteAbilities() : void
      {
         var _loc2_:BattleAbility = null;
         var _loc3_:ChainPhantasms = null;
         var _loc1_:Vector.<BattleAbility> = new Vector.<BattleAbility>();
         for each(_loc2_ in this._incompleteAbilities)
         {
            _loc1_.push(_loc2_);
         }
         for each(_loc2_ in _loc1_)
         {
            for each(_loc3_ in _loc2_.chains)
            {
               _loc3_.ended = true;
            }
            _loc2_.checkCompletion();
         }
      }
      
      public function get isFaking() : Boolean
      {
         return this._faking;
      }
      
      public function setFaking(param1:Boolean) : void
      {
         this._faking = param1;
      }
      
      public function get getLogger() : ILogger
      {
         return this.logger;
      }
      
      public function get getFactory() : IBattleAbilityDefFactory
      {
         return this.factory;
      }
      
      public function get faking() : Boolean
      {
         return this._faking;
      }
   }
}

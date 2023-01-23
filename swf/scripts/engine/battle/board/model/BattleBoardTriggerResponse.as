package engine.battle.board.model
{
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.ability.def.IBattleAbilityDefFactory;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.board.def.BattleBoardTriggerResponseDef;
   import engine.core.BoxString;
   import engine.core.logging.ILogger;
   import engine.saga.ISaga;
   import engine.saga.SagaInstance;
   import engine.saga.SagaVar;
   import engine.saga.happening.HappeningDef;
   import engine.saga.happening.IHappening;
   import engine.tile.Tile;
   
   public class BattleBoardTriggerResponse
   {
      
      private static var _prereqReasons:BoxString = new BoxString();
       
      
      public var _battleAbilityDef:IBattleAbilityDef;
      
      public var _displayAbilityDef:IBattleAbilityDef;
      
      protected var entitiesHitThisTurn:Array;
      
      public var _def:BattleBoardTriggerResponseDef;
      
      public var trigger:BattleBoardTrigger;
      
      public var board:IBattleBoard;
      
      public var logger:ILogger;
      
      public function BattleBoardTriggerResponse(param1:BattleBoardTrigger, param2:IBattleAbilityDefFactory, param3:BattleBoardTriggerResponseDef)
      {
         this.entitiesHitThisTurn = new Array();
         super();
         this._def = param3;
         this.trigger = param1;
         this.board = param1.board;
         this.logger = this.board.logger;
         if(this._def.ability)
         {
            this._battleAbilityDef = param2.fetch(this._def.ability) as IBattleAbilityDef;
         }
         if(this._def.abilityStringId)
         {
            this._displayAbilityDef = param2.fetch(this._def.abilityStringId) as IBattleAbilityDef;
         }
         else
         {
            this._displayAbilityDef = this._battleAbilityDef;
         }
      }
      
      public function validate() : void
      {
         if(this._def.happening)
         {
            if(!SagaInstance.instance.getHappeningDefById(this._def.happening,null))
            {
               this.logger.error("No such happening id [" + this._def.happening + "] for " + this._def);
            }
         }
      }
      
      public function get happening() : String
      {
         return this._def.happening;
      }
      
      public function get pulsesEveryTurn() : Boolean
      {
         return this._def.pulse;
      }
      
      public function isHazardToEntity(param1:IBattleEntity) : Boolean
      {
         return this._def.hazard;
      }
      
      public function get battleAbilityDef() : IBattleAbilityDef
      {
         return this._battleAbilityDef;
      }
      
      public function checkTriggerResponse(param1:IBattleEntity, param2:String, param3:Tile) : Boolean
      {
         var r:Boolean = false;
         var abl:BattleAbility = null;
         var ent:IBattleEntity = param1;
         var pfx:String = param2;
         var triggerTile:Tile = param3;
         if(this._def.triggeringEntityConditions)
         {
            if(!this._def.triggeringEntityConditions.checkExecutionConditions(ent,this.logger,true))
            {
               if(this.logger.isDebugEnabled)
               {
                  this.logger.debug(pfx + "SKIP triggeringEntityConditions");
               }
               return false;
            }
         }
         ent.triggering = true;
         this._setTriggeringVars();
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug(pfx + "GO!");
         }
         try
         {
            if(this._def.callback != null)
            {
               r = this._def.callback(ent,triggerTile);
            }
            else if(this._battleAbilityDef != null)
            {
               abl = new BattleAbility(ent,this._battleAbilityDef,ent.board.abilityManager);
               abl.targetSet.setTarget(ent);
               if(this._def.useTileForAbility)
               {
                  abl.targetSet.setTile(triggerTile);
               }
               abl.execute(null);
               r = true;
            }
            else if(this._def.happening)
            {
               if(this._performHappening())
               {
                  r = true;
               }
            }
         }
         catch(e:Error)
         {
            ent.logger.error("BattleBoardTrigger.check: " + e.getStackTrace());
         }
         this._unsetTriggeringVars();
         ent.triggering = false;
         return r;
      }
      
      private function _setTriggeringVars() : void
      {
         var _loc2_:ISaga = null;
         var _loc3_:IBattleEntity = null;
         var _loc4_:String = null;
         var _loc1_:IBattleBoardTriggers = this.board.triggers;
         if(Boolean(_loc1_) && Boolean(_loc1_.triggering))
         {
            _loc2_ = SagaInstance.instance;
            _loc2_.setVar(SagaVar.VAR_BATTLE_TRIGGERING_UNIT,_loc1_.triggeringEntityId);
            _loc3_ = _loc1_.triggeringEntity;
            _loc4_ = !!_loc3_ ? _loc3_.team : "";
            _loc4_ = !!_loc4_ ? _loc4_ : "";
            _loc2_.setVar(SagaVar.VAR_BATTLE_TRIGGERING_UNIT_TEAM,_loc4_);
            _loc2_.setVar(SagaVar.VAR_BATTLE_TRIGGERING_ID,_loc1_.triggering.id);
         }
         else
         {
            this._unsetTriggeringVars();
         }
      }
      
      private function _unsetTriggeringVars() : void
      {
         var _loc1_:ISaga = SagaInstance.instance;
         _loc1_.setVar(SagaVar.VAR_BATTLE_TRIGGERING_UNIT,"");
         _loc1_.setVar(SagaVar.VAR_BATTLE_TRIGGERING_UNIT_TEAM,"");
         _loc1_.setVar(SagaVar.VAR_BATTLE_TRIGGERING_ID,"");
      }
      
      private function _performHappening() : Boolean
      {
         if(!this._def.happening)
         {
            return false;
         }
         var _loc1_:ISaga = SagaInstance.instance;
         if(!_loc1_)
         {
            return false;
         }
         var _loc2_:HappeningDef = _loc1_.getHappeningDefById(this._def.happening,null);
         if(!_loc2_.checkPrereq(_loc1_,_prereqReasons))
         {
            return false;
         }
         var _loc3_:IHappening = _loc1_.executeHappeningDef(_loc2_,this);
         return _loc3_ != null;
      }
   }
}

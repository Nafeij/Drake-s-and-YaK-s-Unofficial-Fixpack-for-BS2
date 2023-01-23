package game.session.states
{
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.battle.ability.model.IBattleAbility;
   import engine.battle.board.BattleBoardEvent;
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.BattlePartyType;
   import engine.battle.board.model.BattleScenario;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.entity.model.BattleEntity;
   import engine.battle.entity.model.BattleEntityEvent;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.sim.IBattleParty;
   import engine.core.fsm.FsmEvent;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.ILegend;
   import engine.saga.Saga;
   import engine.scene.model.SceneEvent;
   import engine.stat.def.StatType;
   import engine.stat.model.Stat;
   import engine.tile.def.TileLocation;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class SceneStateBattleHandler extends EventDispatcher
   {
      
      public static var EVENT_UNIT_INFO_SHOWN:String = "SceneStateBattleHandler.EVENT_UNIT_INFO_SHOWN";
       
      
      public var state:SceneState;
      
      public var _fsm:BattleFsm;
      
      private var _board:BattleBoard;
      
      public function SceneStateBattleHandler(param1:SceneState)
      {
         super();
         this.state = param1;
         param1.scene.addEventListener(SceneEvent.FOCUSED_BOARD,this.sceneFocusedBoardHandler);
         this.sceneFocusedBoardHandler(null);
      }
      
      public function cleanup() : void
      {
         this.fsm = null;
         this.board = null;
         this.state.scene.removeEventListener(SceneEvent.FOCUSED_BOARD,this.sceneFocusedBoardHandler);
      }
      
      public function get board() : BattleBoard
      {
         return this._board;
      }
      
      public function set board(param1:BattleBoard) : void
      {
         if(this._board == param1)
         {
            return;
         }
         if(this._board)
         {
            this._board.removeEventListener(BattleBoardEvent.BOARD_ENTITY_KILLING_EFFECT,this.onEntityKilled);
            this._board.removeEventListener(BattleBoardEvent.BOARDSETUP,this.boardSetupHandler);
         }
         this._board = param1;
         if(this._board)
         {
            this._board.addEventListener(BattleBoardEvent.BOARD_ENTITY_KILLING_EFFECT,this.onEntityKilled);
            this._board.addEventListener(BattleBoardEvent.BOARDSETUP,this.boardSetupHandler);
         }
      }
      
      protected function sceneFocusedBoardHandler(param1:SceneEvent) : void
      {
         var id:int = 0;
         var name:String = null;
         var team:String = null;
         var deployment:String = null;
         var scenario:BattleScenario = null;
         var ids:String = null;
         var loc:TileLocation = null;
         var facing:BattleFacing = null;
         var saga:Saga = null;
         var bp:IBattleParty = null;
         var i:int = 0;
         var ed:IEntityDef = null;
         var eid:String = null;
         var legend:ILegend = null;
         var event:SceneEvent = param1;
         if(!this.state || !this.state.scene)
         {
            return;
         }
         this.board = this.state.scene.focusedBoard;
         if(this._board)
         {
            this.state.gameFsm.updateGameLocation("loc_battle");
            id = this.state.config.fsm.credentials.userId;
            name = this.state.config.fsm.credentials.displayName;
            team = this.state.config.fsm.credentials.userId.toString();
            if(this._board.def.deploymentAreas.length > this.state.playerOrder)
            {
               deployment = this._board.def.getDeploymentAreaIdByIndex(this.state.playerOrder);
            }
            this.fsm = this._board.sim.fsm;
            scenario = this._board._scenario;
            ids = id.toString();
            facing = this._board.def.getDeploymentFacing(deployment);
            if(!scenario || !scenario.def.clearParty)
            {
               if(this.state.party)
               {
                  i = 0;
                  for(; i < this.state.party.numEntityDefs; i++)
                  {
                     ed = this.state.party.getEntityDef(i);
                     try
                     {
                        if(!scenario || scenario.def.allowPartyMember(ed.id))
                        {
                           this._board.addPartyMember(name,null,ids,team,deployment,ed,BattlePartyType.LOCAL,this.state.timer,false,facing,loc,true);
                        }
                     }
                     catch(err:Error)
                     {
                        state.logger.error("Unable to add player party member " + ed + " as name=[" + name + "]");
                        state.logger.error(err.getStackTrace());
                        continue;
                     }
                  }
               }
            }
            saga = this.state.scene._context.saga as Saga;
            if(Boolean(scenario) && Boolean(saga))
            {
               for each(eid in scenario.def.castMembers)
               {
                  ed = saga.getCastMember(eid);
                  if(!ed)
                  {
                     this.state.logger.error("Invalid cast member [" + eid + "] in scenario " + scenario);
                  }
                  else
                  {
                     this._board.addPartyMember(name,null,ids,team,deployment,ed,BattlePartyType.LOCAL,this.state.timer,false,facing,loc,true);
                  }
               }
               legend = !!saga.caravan ? saga.icaravan.legend : null;
               if(legend)
               {
                  for each(eid in scenario.def.rosterMembers)
                  {
                     ed = saga.getCastMember(eid);
                     if(!ed)
                     {
                        this.state.logger.error("Invalid roster member [" + eid + "] in scenario " + scenario);
                     }
                     else
                     {
                        ed = legend.roster.getEntityDefById(ed.id);
                        if(ed)
                        {
                           this._board.addPartyMember(name,null,ids,team,deployment,ed,BattlePartyType.LOCAL,this.state.timer,false,facing,loc,true);
                        }
                     }
                  }
               }
            }
            bp = this._board.getPartyById(ids);
            if(!bp.numMembers)
            {
               if(!scenario || scenario.def.requiresPartyMembers)
               {
                  this.state.logger.error("Can\'t enter the board with no party members");
                  this._board.fsm.abortBattle(false);
                  return;
               }
            }
         }
      }
      
      private function boardSetupHandler(param1:BattleBoardEvent) : void
      {
         var _loc2_:Saga = this.state.config.saga;
         if(_loc2_)
         {
            _loc2_.triggerBattleBoardSetup(this.state.loader.url);
         }
      }
      
      private function onEntityKilled(param1:BattleBoardEvent) : void
      {
         var _loc2_:IBattleEntity = param1.entity;
         if(!_loc2_ || !_loc2_.killingEffect)
         {
            return;
         }
         var _loc3_:IBattleAbility = _loc2_.killingEffect.ability;
         var _loc4_:IBattleAbility = !!_loc3_ ? _loc3_.root : null;
         var _loc5_:IBattleEntity = !!_loc4_ ? _loc4_.caster : null;
         if(!_loc5_)
         {
            return;
         }
         var _loc6_:Saga = this.state.config.saga;
         if(_loc6_)
         {
            if(_loc5_.isPlayer)
            {
               if(!_loc5_.visible)
               {
                  _loc6_.incrementGlobalVar("prg_sneaky_kills");
               }
               if(!_loc2_.mobile)
               {
                  _loc6_.incrementGlobalVar("prg_demolition");
               }
            }
         }
         var _loc7_:IBattleParty = _loc5_.party;
         var _loc8_:IBattleParty = _loc2_.party;
         if(!_loc7_ || !_loc8_)
         {
            return;
         }
         if(_loc7_.id != this.state.config.fsm.credentials.userId.toString())
         {
            return;
         }
         if(_loc5_.party.team == _loc2_.party.team)
         {
            return;
         }
         if(Boolean(this.fsm.battleCreateData) && this.fsm.battleCreateData.friendly)
         {
            return;
         }
         var _loc9_:IBattleEntity = _loc3_.caster;
         this.applyKillerResults(_loc9_);
         if(_loc5_ != _loc9_)
         {
            this.applyKillerResults(_loc5_);
         }
      }
      
      private function applyKillerResults(param1:IBattleEntity) : void
      {
         var _loc3_:Stat = null;
         var _loc4_:Saga = null;
         var _loc5_:int = 0;
         var _loc2_:IEntityDef = this.state.config.legend.roster.getEntityDefById(param1.def.id);
         if(_loc2_)
         {
            _loc3_ = _loc2_.stats.getStat(StatType.KILLS,false);
            if(_loc3_)
            {
               ++_loc3_.base;
               _loc4_ = Saga.instance;
               if(_loc4_ && _loc4_.caravan && !_loc4_.caravan.legend.roster.getEntityDefById(_loc2_.id))
               {
                  this.state.logger.info("SceneStateBattleHandler.applyKillerResults IGNORING PROMOTION for non-roster member " + _loc2_.id);
               }
               else if(!_loc4_ || !_loc4_.isSurvival)
               {
                  _loc5_ = this.state.config.gameGuiContext.statCosts.getKillsRequiredToPromote(_loc2_.stats.rank);
                  if(_loc5_ == _loc3_.base)
                  {
                     if(this._fsm.unitsReadyToPromote.indexOf(_loc2_.id) == -1)
                     {
                        this._fsm.unitsReadyToPromote.push(_loc2_.id);
                        param1.dispatchEvent(new BattleEntityEvent(BattleEntityEvent.ENOUGH_KILLS_TO_PROMOTE_VFX,param1 as BattleEntity));
                     }
                  }
               }
            }
            else
            {
               _loc2_.stats.addStat(StatType.KILLS,1);
            }
         }
      }
      
      public function get fsm() : BattleFsm
      {
         return this._fsm;
      }
      
      public function set fsm(param1:BattleFsm) : void
      {
         if(this._fsm == param1)
         {
            return;
         }
         if(this._fsm)
         {
            this._fsm.removeEventListener(FsmEvent.STOP,this.fsmStopHandler);
            this._fsm.stopFsm(false);
         }
         this._fsm = param1;
         if(this._fsm)
         {
            if(this.state.playerOrder == 0)
            {
               this._fsm.config.startPartyId = this.state.config.fsm.credentials.userId.toString();
            }
            else
            {
               this._fsm.config.startPartyId = this.state.opponentId.toString();
            }
            this._fsm.startFsm(null);
            this._fsm.addEventListener(FsmEvent.STOP,this.fsmStopHandler);
         }
      }
      
      private function fsmStopHandler(param1:FsmEvent) : void
      {
      }
      
      public function respawnBattle(param1:int, param2:String, param3:String, param4:String) : void
      {
         if(this._fsm)
         {
            this._fsm.respawnBattle(param1,param2,param3,param4);
         }
      }
      
      public function notifyUnitInfoShown() : void
      {
         dispatchEvent(new Event(EVENT_UNIT_INFO_SHOWN));
      }
   }
}

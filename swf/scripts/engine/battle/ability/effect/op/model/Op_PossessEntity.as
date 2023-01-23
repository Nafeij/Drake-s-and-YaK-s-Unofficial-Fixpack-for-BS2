package engine.battle.ability.effect.op.model
{
   import com.greensock.TweenMax;
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.board.model.BattleBoard;
   import engine.battle.entity.model.BattleEntity;
   import engine.battle.entity.model.BattleEntityEvent;
   import engine.battle.fsm.IBattleFsm;
   import engine.battle.fsm.IBattleTurnOrder;
   import engine.battle.sim.BattleParty;
   import engine.core.util.ArrayUtil;
   import engine.entity.def.IEntityDef;
   import engine.saga.Saga;
   import engine.stat.def.StatType;
   import engine.stat.model.Stats;
   import engine.tile.Tile;
   import engine.tile.Tiles;
   import engine.tile.def.TileLocation;
   import engine.tile.def.TileRect;
   
   public class Op_PossessEntity extends Op
   {
       
      
      public function Op_PossessEntity(param1:EffectDefOp, param2:Effect)
      {
         super(param1,param2);
      }
      
      override public function execute() : EffectResult
      {
         return EffectResult.OK;
      }
      
      override public function remove() : void
      {
         TweenMax.killDelayedCallsTo(this._visibleCompleteHandler);
         target.removeEventListener(BattleEntityEvent.ALIVE,this.aliveHandler);
      }
      
      override public function apply() : void
      {
         if(ability.fake || manager.faking)
         {
            return;
         }
         var _loc1_:IEntityDef = target.def;
         var _loc2_:Stats = target.stats;
         _loc2_.setBase(StatType.STRENGTH,Number(_loc1_.stats.getValue(StatType.STRENGTH)) / 2);
         _loc2_.setBase(StatType.WILLPOWER,caster.stats.getValue(StatType.WILLPOWER));
         var _loc3_:BattleEntity = target as BattleEntity;
         _loc3_.active = true;
         _loc3_.alive = true;
         _loc3_.resetKillingEffect();
         var _loc4_:Boolean = true;
         var _loc5_:Number = 1;
         _loc3_.animController.playAnim("die",1,false,false,_loc4_,_loc5_);
         var _loc6_:BattleBoard = board as BattleBoard;
         var _loc7_:BattleParty = caster.party as BattleParty;
         var _loc8_:BattleParty = target.party as BattleParty;
         var _loc9_:IBattleTurnOrder = board.fsm.order;
         _loc9_.removeEntity(target);
         if(_loc8_ != _loc7_)
         {
            _loc8_.removeMember(target);
            _loc7_.addMember(target);
         }
         _loc9_.addEntity(target);
         if(board.fsm.participants.indexOf(target) < 0)
         {
            board.fsm.participants.push(target);
         }
         _loc3_.addEventListener(BattleEntityEvent.ALIVE,this.aliveHandler,false,255);
         target.centerCameraOnEntity();
         effect.blockComplete();
         var _loc10_:int = 1000;
         caster.setVisible(false,_loc10_);
         TweenMax.delayedCall(_loc10_ * 0.001,this._visibleCompleteHandler);
         if(Saga.instance)
         {
            if(caster.def.id == "eyeless")
            {
               Saga.instance.incrementGlobalVar("prg_eyeless_possess");
            }
         }
      }
      
      private function aliveHandler(param1:BattleEntityEvent) : void
      {
         if(target.alive)
         {
            return;
         }
         target.removeEventListener(BattleEntityEvent.ALIVE,this.aliveHandler);
         var _loc2_:TileRect = this._findReappearanceRect();
         if(_loc2_)
         {
            caster.setPos(_loc2_.loc.x,_loc2_.loc.y);
         }
         var _loc3_:IBattleFsm = !!board ? board.fsm : null;
         if(!_loc3_ || _loc3_.cleanedup)
         {
            return;
         }
         var _loc4_:IBattleTurnOrder = _loc3_.order;
         if(!_loc4_)
         {
            return;
         }
         caster.enabled = true;
         caster.setVisible(true,1000);
         _loc4_.addEntity(caster);
         _loc4_.resetTurnOrder();
         _loc4_.pruneDeadEntities();
         if(_loc3_.participants.indexOf(caster) < 0)
         {
            _loc3_.participants.push(caster);
         }
         ability.forceExpiration();
         var _loc5_:BattleAbilityDef = manager.factory.fetch("_abl_eyeless_dispossess") as BattleAbilityDef;
         var _loc6_:BattleAbility = new BattleAbility(caster,_loc5_,manager);
         _loc6_.targetSet.setTarget(target);
         _loc6_.execute(null);
      }
      
      private function _visibleCompleteHandler() : void
      {
         var _loc1_:IBattleTurnOrder = board.fsm.order;
         caster.enabled = false;
         _loc1_.removeEntity(caster);
         _loc1_.resetTurnOrder();
         effect.unblockComplete();
      }
      
      private function _findReappearanceRect() : TileRect
      {
         var _loc6_:int = 0;
         var _loc7_:Tile = null;
         var _loc1_:TileRect = caster.rect.clone();
         var _loc2_:TileLocation = target.rect.loc;
         _loc1_.setLocation(_loc2_);
         var _loc3_:BattleBoard = target.board as BattleBoard;
         var _loc4_:Tiles = target.board.tiles;
         var _loc5_:Array = [];
         _loc6_ = 0;
         while(_loc6_ < _loc4_.tiles.length)
         {
            _loc5_.push(_loc6_);
            _loc6_++;
         }
         _loc5_ = ArrayUtil.shuffle(_loc5_,manager.rng);
         for each(_loc6_ in _loc5_)
         {
            _loc7_ = _loc4_.tiles[_loc6_];
            if(_loc7_.getWalkableFor(caster))
            {
               if(this._checkReappearanceRect(_loc7_.x,_loc7_.y,_loc1_))
               {
                  return _loc1_;
               }
            }
         }
         return null;
      }
      
      private function _checkReappearanceRect(param1:int, param2:int, param3:TileRect) : Boolean
      {
         var _loc4_:BattleBoard = target.board as BattleBoard;
         var _loc5_:TileLocation = TileLocation.fetch(param1,param2);
         param3.setLocation(_loc5_);
         if(!_loc4_.tiles.hasTilesForRect(param3))
         {
            return false;
         }
         if(!_loc4_.findAllRectIntersectionEntities(param3,caster,null))
         {
            return true;
         }
         return false;
      }
      
      private function addListeners() : void
      {
      }
      
      private function removeListeners() : void
      {
      }
   }
}

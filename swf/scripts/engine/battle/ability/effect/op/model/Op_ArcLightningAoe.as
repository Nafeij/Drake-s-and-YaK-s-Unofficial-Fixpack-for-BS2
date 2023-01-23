package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.BattleAbilityDefFactory;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.ability.effect.op.def.EffectDirectionalFlag;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.BattleTile;
   import engine.battle.board.model.IBattleEntity;
   import engine.stat.def.StatType;
   import engine.tile.def.TileRect;
   import flash.utils.Dictionary;
   
   public class Op_ArcLightningAoe extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_ArcLightningAoe",
         "properties":{
            "ability":{"type":"string"},
            "level":{"type":"number"}
         }
      };
      
      private static const cornerFlags:Array = [EffectDirectionalFlag.N,EffectDirectionalFlag.E,EffectDirectionalFlag.W,EffectDirectionalFlag.S];
       
      
      public var abilityDef:BattleAbilityDef;
      
      public var abilityLevel:int;
      
      private var others:Vector.<IBattleEntity>;
      
      public function Op_ArcLightningAoe(param1:EffectDefOp, param2:Effect)
      {
         this.others = new Vector.<IBattleEntity>();
         super(param1,param2);
         this.abilityLevel = param1.params.level;
         var _loc3_:BattleAbilityDefFactory = manager.factory;
         var _loc4_:BattleAbilityDef = _loc3_.fetchBattleAbilityDef(param1.params.ability);
         this.abilityDef = _loc4_.getAbilityDefForLevel(this.abilityLevel) as BattleAbilityDef;
      }
      
      public static function computeAssociatedTargets(param1:IBattleEntity, param2:Dictionary, param3:Boolean = true) : Dictionary
      {
         param2[param1] = {
            "target":param1,
            "depth":0
         };
         var _loc4_:Dictionary = new Dictionary();
         var _loc5_:Object = {
            "bt":param1,
            "visited":_loc4_,
            "associatedTargets":param2,
            "depth":1
         };
         _loc5_.recurse = param3;
         param1.rect.visitAdjacentTileCorners(_visitCorners,_loc5_);
         return param2;
      }
      
      private static function _visitCorners(param1:int, param2:int, param3:Object) : void
      {
         var _loc16_:IBattleEntity = null;
         var _loc17_:TileRect = null;
         var _loc18_:int = 0;
         var _loc19_:int = 0;
         var _loc20_:int = 0;
         var _loc21_:int = 0;
         var _loc4_:IBattleEntity = param3.bt;
         var _loc5_:Dictionary = param3.associatedTargets;
         var _loc6_:Dictionary = param3.visited;
         var _loc7_:Boolean = Boolean(param3.recurse);
         var _loc8_:BattleBoard = _loc4_.board as BattleBoard;
         var _loc9_:BattleTile = _loc8_.tiles.getTile(param1,param2) as BattleTile;
         var _loc10_:int = int(param3.depth);
         var _loc11_:TileRect = _loc4_.rect;
         var _loc12_:int = _loc11_.left;
         var _loc13_:int = _loc11_.right;
         var _loc14_:int = _loc11_.front;
         var _loc15_:int = _loc11_.back;
         if(_loc9_)
         {
            for each(_loc16_ in _loc9_.residents)
            {
               if(!(!_loc16_.alive || !_loc16_.active || !_loc16_.enabled || !_loc16_.attackable))
               {
                  if(!(Boolean(_loc6_[_loc16_]) || Boolean(_loc5_[_loc16_])))
                  {
                     _loc17_ = _loc16_.rect;
                     _loc18_ = _loc17_.left;
                     _loc19_ = _loc17_.right;
                     _loc20_ = _loc17_.front;
                     _loc21_ = _loc17_.back;
                     if((_loc12_ >= _loc19_ || _loc13_ <= _loc18_) && (_loc14_ >= _loc21_ || _loc15_ <= _loc20_))
                     {
                        _loc5_[_loc16_] = {
                           "target":_loc16_,
                           "depth":_loc10_
                        };
                        _loc6_[_loc16_] = true;
                        if(_loc7_)
                        {
                           param3 = {
                              "bt":_loc16_,
                              "visited":_loc6_,
                              "associatedTargets":_loc5_,
                              "depth":_loc10_ + 1
                           };
                           param3.recurse = _loc7_;
                           _loc16_.rect.visitAdjacentTileCorners(_visitCorners,param3);
                        }
                     }
                  }
               }
            }
         }
      }
      
      override public function execute() : EffectResult
      {
         var _loc3_:Object = null;
         var _loc4_:IBattleEntity = null;
         var _loc5_:int = 0;
         if(!target)
         {
            return EffectResult.FAIL;
         }
         var _loc1_:int = int(target.stats.getValue(StatType.ARC_LIGHTNING_DEPTH));
         var _loc2_:Dictionary = new Dictionary();
         _loc2_ = computeAssociatedTargets(target,_loc2_,false);
         for each(_loc3_ in _loc2_)
         {
            _loc4_ = _loc3_.target;
            if(_loc4_ != target)
            {
               _loc5_ = int(_loc4_.stats.getValue(StatType.ARC_LIGHTNING_DEPTH));
               if(_loc5_ == 0)
               {
                  _loc4_.stats.setBase(StatType.ARC_LIGHTNING_DEPTH,_loc1_ + 1);
                  this.others.push(_loc4_);
               }
            }
         }
         return EffectResult.OK;
      }
      
      override public function apply() : void
      {
         var _loc1_:IBattleEntity = null;
         if(!target)
         {
            return;
         }
         for each(_loc1_ in this.others)
         {
            if(Boolean(_loc1_) && _loc1_.alive)
            {
               this.applyOnTarget(_loc1_);
            }
         }
         effect.handleOpUsed(this);
      }
      
      public function applyOnTarget(param1:IBattleEntity) : void
      {
         if(!this.checkPeers(param1,this.abilityDef))
         {
            return;
         }
         var _loc2_:BattleAbility = new BattleAbility(caster,this.abilityDef,manager);
         logger.info("ARC-LIGHTNING-CHAIN " + this + " to " + _loc2_);
         _loc2_.targetSet.setTarget(param1);
         effect.ability.addChildAbility(_loc2_);
      }
      
      private function checkPeers(param1:IBattleEntity, param2:BattleAbilityDef) : Boolean
      {
         var _loc5_:int = 0;
         var _loc6_:BattleAbility = null;
         var _loc3_:BattleAbility = effect.ability.root as BattleAbility;
         var _loc4_:Array = [];
         _loc4_.push(_loc3_);
         while(_loc4_.length > 0)
         {
            _loc3_ = _loc4_.pop();
            if(_loc3_ != effect.ability)
            {
               if(_loc3_.def == param2)
               {
                  if(_loc3_.caster == param1 || _loc3_.targetSet.hasTarget(param1))
                  {
                     return false;
                  }
               }
               _loc5_ = 0;
               while(_loc5_ < _loc3_.children.length)
               {
                  _loc6_ = _loc3_.children[_loc5_];
                  _loc4_.push(_loc6_);
                  _loc5_++;
               }
            }
         }
         return true;
      }
   }
}

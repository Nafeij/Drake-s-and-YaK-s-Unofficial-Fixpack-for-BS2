package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.board.def.BattleBoardTriggerDef;
   import engine.battle.board.def.BattleBoardTriggerResponseDef;
   import engine.battle.board.model.BattleBoardTrigger;
   import engine.battle.board.model.IBattleEntity;
   import engine.core.util.Enum;
   import engine.def.BooleanVars;
   import engine.tile.ITileResident;
   import engine.tile.Tile;
   import engine.tile.TileTrigger;
   import engine.tile.TileTriggerType;
   import engine.tile.def.TileRect;
   
   public class Op_SlagAndBurnTileCross extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_SlagAndBurnTileCross",
         "properties":{
            "triggerType":{"type":"string"},
            "damageAbility":{"type":"string"},
            "vfxAbility":{"type":"string"},
            "pulsePerTurn":{"type":"boolean"},
            "maxNumberOfTriggers":{"type":"number"},
            "triggerStringId":{"type":"string"}
         }
      };
       
      
      protected var triggerType:TileTriggerType;
      
      protected var damageAbilityDef:BattleAbilityDef = null;
      
      protected var vfxAbilityDef:BattleAbilityDef = null;
      
      protected var pulsePerTurn:Boolean;
      
      protected var maxNumberOfTriggers:int;
      
      protected var triggerStringId:String;
      
      protected var tileTriggers:Array;
      
      public function Op_SlagAndBurnTileCross(param1:EffectDefOp, param2:Effect)
      {
         this.tileTriggers = new Array();
         super(param1,param2);
         this.triggerType = Enum.parse(TileTriggerType,param1.params.triggerType) as TileTriggerType;
         this.damageAbilityDef = manager.factory.fetchBattleAbilityDef(param1.params.damageAbility);
         this.vfxAbilityDef = manager.factory.fetchBattleAbilityDef(param1.params.vfxAbility);
         this.pulsePerTurn = BooleanVars.parse(param1.params.pulsePerTurn);
         this.maxNumberOfTriggers = param1.params.maxNumberOfTriggers;
         this.triggerStringId = param1.params.triggerStringId;
      }
      
      override public function apply() : void
      {
         var _loc3_:Tile = null;
         var _loc4_:int = 0;
         var _loc5_:Tile = null;
         var _loc6_:BattleBoardTriggerDef = null;
         var _loc7_:BattleBoardTriggerResponseDef = null;
         var _loc8_:TileRect = null;
         var _loc9_:TileTrigger = null;
         var _loc10_:BattleAbility = null;
         var _loc11_:BattleBoardTrigger = null;
         var _loc12_:Vector.<BattleBoardTrigger> = null;
         var _loc13_:BattleBoardTrigger = null;
         var _loc14_:BattleBoardTrigger = null;
         var _loc1_:Array = new Array();
         var _loc2_:Tile = this.getPotentialTile(tile.x,tile.y);
         if(_loc2_ != null)
         {
            _loc1_.push(_loc2_);
         }
         _loc2_ = this.getPotentialTile(tile.x + 1,tile.y);
         if(_loc2_ != null)
         {
            _loc1_.push(_loc2_);
         }
         _loc2_ = this.getPotentialTile(tile.x - 1,tile.y);
         if(_loc2_ != null)
         {
            _loc1_.push(_loc2_);
         }
         _loc2_ = this.getPotentialTile(tile.x,tile.y + 1);
         if(_loc2_ != null)
         {
            _loc1_.push(_loc2_);
         }
         _loc2_ = this.getPotentialTile(tile.x,tile.y - 1);
         if(_loc2_ != null)
         {
            _loc1_.push(_loc2_);
         }
         while(_loc1_.length > this.maxNumberOfTriggers)
         {
            _loc4_ = effect.ability.manager.rng.nextMax(_loc1_.length);
            if(_loc4_ > _loc1_.length - 1)
            {
               _loc4_ = _loc1_.length - 1;
            }
            if(logger.isDebugEnabled)
            {
               logger.debug("$$$ indexToRemove is " + _loc4_ + " and tilesToAffect.length = " + _loc1_.length);
            }
            _loc5_ = _loc1_[_loc4_] as Tile;
            if(!(_loc5_.x == tile.x && _loc5_.y == tile.y))
            {
               _loc1_.splice(_loc4_,1);
            }
         }
         for each(_loc3_ in _loc1_)
         {
            _loc6_ = new BattleBoardTriggerDef();
            _loc6_.id = this.toString();
            _loc6_.stringId = this.triggerStringId;
            _loc7_ = new BattleBoardTriggerResponseDef();
            _loc7_.hazard = true;
            _loc7_.pulse = this.pulsePerTurn;
            _loc7_.callback = this.triggerCallbackDamage;
            _loc6_.addResponse(_loc7_);
            _loc8_ = _loc3_.rect.clone();
            _loc8_.facing = caster.facing;
            _loc9_ = tile.tiles.addTrigger(null,_loc6_,_loc8_,false,effect,false);
            _loc9_.type = this.triggerType;
            this.tileTriggers.push(_loc9_);
            if(logger.isDebugEnabled)
            {
               logger.debug("$$$ adding tile trigger at " + _loc3_.x + ", " + _loc3_.y);
            }
            _loc10_ = new BattleAbility(caster,this.vfxAbilityDef,manager);
            _loc10_.targetSet.setTile(_loc3_);
            effect.ability.addChildAbility(_loc10_);
            _loc12_ = new Vector.<BattleBoardTrigger>();
            for each(_loc13_ in caster.board.triggers.triggers)
            {
               if(_loc13_ != null && _loc13_.rect == _loc9_.rect && _loc13_ != _loc9_ && _loc13_.type == _loc9_.type)
               {
                  _loc12_.push(_loc13_);
               }
            }
            for each(_loc14_ in _loc12_)
            {
               tile.tiles.removeTrigger(_loc14_);
            }
         }
      }
      
      override public function remove() : void
      {
         var _loc1_:TileTrigger = null;
         if(logger.isDebugEnabled)
         {
            logger.debug("$$$$ Op_SlagAndBurnTileCross().remove()");
         }
         for each(_loc1_ in this.tileTriggers)
         {
            tile.tiles.removeTrigger(_loc1_);
         }
      }
      
      protected function getPotentialTile(param1:int, param2:int) : Tile
      {
         var _loc4_:ITileResident = null;
         var _loc5_:IBattleEntity = null;
         var _loc3_:Tile = tile.tiles.getTile(param1,param2);
         if(_loc3_ != null)
         {
            for each(_loc4_ in _loc3_.residents)
            {
               if(_loc4_ is IBattleEntity)
               {
                  _loc5_ = _loc4_ as IBattleEntity;
                  if(_loc5_.alive == true || _loc5_.mobile == false)
                  {
                     return null;
                  }
               }
            }
         }
         return _loc3_;
      }
      
      private function triggerCallbackDamage(param1:IBattleEntity, param2:Tile) : Boolean
      {
         if(logger.isDebugEnabled)
         {
            logger.debug("$$$$ Op_SlagAndBurnTileCross().triggerCallbackDamage()");
         }
         var _loc3_:BattleAbility = new BattleAbility(caster,this.damageAbilityDef,manager);
         _loc3_.targetSet.setTarget(param1);
         _loc3_.execute(null);
         return true;
      }
   }
}

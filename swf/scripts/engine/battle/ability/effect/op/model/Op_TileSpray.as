package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.board.def.BattleBoardTriggerDef;
   import engine.battle.board.def.BattleBoardTriggerResponseDef;
   import engine.battle.board.model.BattleBoardTrigger;
   import engine.battle.board.model.IBattleEntity;
   import engine.core.util.Enum;
   import engine.def.BooleanVars;
   import engine.tile.Tile;
   import engine.tile.TileTrigger;
   import engine.tile.TileTriggerType;
   import engine.tile.def.TileLocation;
   import engine.tile.def.TileRect;
   import flash.utils.Dictionary;
   
   public class Op_TileSpray extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_TileSpray",
         "properties":{
            "triggerType":{
               "type":"string",
               "optional":true
            },
            "triggerEntityAbility":{
               "type":"string",
               "optional":true
            },
            "initialTileAbility":{
               "type":"string",
               "optional":true
            },
            "initialEntityAbility":{
               "type":"string",
               "optional":true
            },
            "pulsePerTurn":{"type":"boolean"},
            "sprayDistance":{"type":"number"},
            "sprayWidth":{"type":"number"},
            "triggerStringId":{"type":"string"}
         }
      };
       
      
      protected var triggerType:TileTriggerType;
      
      protected var triggerEntityAbilityDef:BattleAbilityDef = null;
      
      protected var initialTileAbilityDef:BattleAbilityDef = null;
      
      protected var initialEntityAbilityDef:BattleAbilityDef = null;
      
      protected var pulsePerTurn:Boolean;
      
      protected var sprayDistance:int;
      
      protected var sprayWidth:int;
      
      protected var triggerStringId:String;
      
      protected var ablLevel:int = 1;
      
      protected var tileTriggers:Array;
      
      public var facing:BattleFacing;
      
      public function Op_TileSpray(param1:EffectDefOp, param2:Effect)
      {
         var _loc3_:IBattleAbilityDef = null;
         this.triggerType = TileTriggerType.NO_TYPE;
         this.tileTriggers = new Array();
         super(param1,param2);
         if(param1.params.triggerType)
         {
            this.triggerType = Enum.parse(TileTriggerType,param1.params.triggerType) as TileTriggerType;
         }
         this.triggerStringId = param1.params.triggerStringId;
         if(param2 && param2.ability && Boolean(param2.ability.def))
         {
            this.ablLevel = param2.ability.def.level;
         }
         if(param1.params.triggerEntityAbility)
         {
            _loc3_ = manager.factory.fetchIBattleAbilityDef(param1.params.triggerEntityAbility);
            this.triggerEntityAbilityDef = _loc3_.getBattleAbilityDefLevel(_loc3_.maxLevel < this.ablLevel ? int(_loc3_.maxLevel) : this.ablLevel) as BattleAbilityDef;
         }
         if(param1.params.initialTileAbility)
         {
            _loc3_ = manager.factory.fetchIBattleAbilityDef(param1.params.initialTileAbility);
            this.initialTileAbilityDef = _loc3_.getBattleAbilityDefLevel(_loc3_.maxLevel < this.ablLevel ? int(_loc3_.maxLevel) : this.ablLevel) as BattleAbilityDef;
         }
         if(param1.params.initialEntityAbility)
         {
            _loc3_ = manager.factory.fetchIBattleAbilityDef(param1.params.initialEntityAbility);
            this.initialEntityAbilityDef = _loc3_.getBattleAbilityDefLevel(_loc3_.maxLevel < this.ablLevel ? int(_loc3_.maxLevel) : this.ablLevel) as BattleAbilityDef;
         }
         this.pulsePerTurn = BooleanVars.parse(param1.params.pulsePerTurn);
         this.sprayDistance = param1.params.sprayDistance;
         this.sprayWidth = param1.params.sprayWidth;
      }
      
      public static function getSprayTiles(param1:IBattleEntity, param2:BattleFacing, param3:int, param4:int) : Array
      {
         var _loc10_:Tile = null;
         var _loc12_:int = 0;
         var _loc13_:TileLocation = null;
         var _loc5_:Array = new Array();
         if(!param2)
         {
            param2 = param1.facing;
         }
         var _loc6_:Tile = param1.tile;
         var _loc7_:TileLocation = TileLocation.fetch(_loc6_.x,_loc6_.y);
         var _loc8_:int = (param3 + 1) / 4;
         var _loc9_:BattleFacing = null;
         if(param2 == BattleFacing.SE)
         {
            _loc9_ = BattleFacing.SW;
            _loc7_ = TileLocation.fetch(_loc7_.x + param1.boardWidth,_loc7_.y);
         }
         else if(param2 == BattleFacing.SW)
         {
            _loc9_ = BattleFacing.SE;
            _loc7_ = TileLocation.fetch(_loc7_.x,_loc7_.y + param1.boardLength);
         }
         else if(param2 == BattleFacing.NW)
         {
            _loc9_ = BattleFacing.SW;
            _loc7_ = TileLocation.fetch(_loc7_.x + param2.x,_loc7_.y + param2.y);
         }
         else if(param2 == BattleFacing.NE)
         {
            _loc9_ = BattleFacing.SE;
            _loc7_ = TileLocation.fetch(_loc7_.x + param2.x,_loc7_.y + param2.y);
         }
         _loc7_ = TileLocation.fetch(_loc7_.x - _loc8_ * _loc9_.x,_loc7_.y - _loc8_ * _loc9_.y);
         var _loc11_:int = 0;
         while(_loc11_ < param4)
         {
            _loc12_ = 0;
            while(_loc12_ < param3)
            {
               _loc13_ = TileLocation.fetch(_loc7_.x + param2.x * _loc11_ + _loc9_.x * _loc12_,_loc7_.y + param2.y * _loc11_ + _loc9_.y * _loc12_);
               _loc10_ = param1.board.tiles.getTileByLocation(_loc13_);
               if(_loc10_)
               {
                  _loc5_.push(_loc10_);
               }
               _loc12_++;
            }
            _loc11_++;
         }
         return _loc5_;
      }
      
      override public function apply() : void
      {
         var _loc2_:Tile = null;
         var _loc3_:BattleBoardTriggerDef = null;
         var _loc4_:BattleBoardTriggerResponseDef = null;
         var _loc5_:TileRect = null;
         var _loc6_:TileTrigger = null;
         var _loc7_:Vector.<BattleBoardTrigger> = null;
         var _loc8_:BattleBoardTrigger = null;
         var _loc9_:BattleBoardTrigger = null;
         if(effect.ability.fake || manager.faking)
         {
            return;
         }
         this.facing = caster.facing;
         var _loc1_:Array = getSprayTiles(caster,this.facing,this.sprayWidth,this.sprayDistance);
         this.createInitialAbilities(_loc1_);
         for each(_loc2_ in _loc1_)
         {
            _loc3_ = new BattleBoardTriggerDef();
            _loc3_.id = this.toString();
            _loc3_.stringId = this.triggerStringId;
            _loc4_ = new BattleBoardTriggerResponseDef();
            _loc4_.hazard = true;
            _loc4_.pulse = this.pulsePerTurn;
            _loc4_.callback = this.triggerCallbackDamage;
            _loc3_.addResponse(_loc4_);
            _loc5_ = _loc2_.rect.clone();
            _loc5_.facing = caster.facing;
            _loc6_ = board.tiles.addTrigger(null,_loc3_,_loc5_,false,effect,false);
            _loc6_.type = this.triggerType;
            this.tileTriggers.push(_loc6_);
            if(logger.isDebugEnabled)
            {
               logger.debug("$$$ adding tile trigger at " + _loc2_.x + ", " + _loc2_.y);
            }
            if(this.triggerType != TileTriggerType.NO_TYPE)
            {
               _loc7_ = new Vector.<BattleBoardTrigger>();
               for each(_loc8_ in caster.board.triggers.triggers)
               {
                  if(_loc8_ != null && _loc8_.rect == _loc6_.rect && _loc8_ != _loc6_ && _loc8_.type == _loc6_.type)
                  {
                     _loc7_.push(_loc8_);
                  }
               }
               for each(_loc9_ in _loc7_)
               {
                  tile.tiles.removeTrigger(_loc9_);
               }
            }
         }
      }
      
      private function createInitialAbilities(param1:Array) : void
      {
         var _loc5_:Tile = null;
         var _loc6_:BattleAbility = null;
         var _loc7_:BattleAbility = null;
         var _loc8_:IBattleEntity = null;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         if(!param1)
         {
            return;
         }
         if(!this.initialTileAbilityDef && !this.initialEntityAbilityDef)
         {
            return;
         }
         var _loc2_:Dictionary = !!this.initialEntityAbilityDef ? new Dictionary() : null;
         var _loc3_:Tile = Boolean(param1) && Boolean(param1.length) ? param1[0] : null;
         var _loc4_:TileLocation = !!_loc3_ ? _loc3_.location : null;
         for each(_loc5_ in param1)
         {
            if(this.initialTileAbilityDef)
            {
               _loc6_ = new BattleAbility(caster,this.initialTileAbilityDef,manager);
               _loc6_.targetSet.setTile(_loc5_);
               ability.addChildAbility(_loc6_);
            }
            if(this.initialEntityAbilityDef)
            {
               _loc7_ = new BattleAbility(caster,this.initialEntityAbilityDef,manager);
               _loc8_ = _loc5_.findResident(caster) as IBattleEntity;
               if(_loc8_)
               {
                  if(!_loc2_[_loc8_])
                  {
                     _loc9_ = (_loc4_.x - _loc5_.x) * this.facing.x;
                     _loc10_ = (_loc4_.y - _loc5_.y) * this.facing.y;
                     _loc11_ = Math.abs(_loc9_) + Math.abs(_loc10_);
                     _loc2_[_loc8_] = true;
                     _loc7_.targetSet.setTarget(_loc8_);
                     _loc7_.targetDelayStart = _loc7_.def.targetDelay * _loc11_;
                     ability.addChildAbility(_loc7_);
                  }
               }
            }
         }
      }
      
      private function createInitialEntityAbility(param1:Tile, param2:IBattleEntity) : void
      {
      }
      
      override public function remove() : void
      {
         var _loc1_:TileTrigger = null;
         if(logger.isDebugEnabled)
         {
            logger.debug("$$$$ Op_TileSpray.remove()");
         }
         for each(_loc1_ in this.tileTriggers)
         {
            tile.tiles.removeTrigger(_loc1_);
         }
      }
      
      private function triggerCallbackDamage(param1:IBattleEntity, param2:Tile) : Boolean
      {
         var _loc3_:BattleAbility = null;
         if(logger.isDebugEnabled)
         {
            logger.debug("$$$$ Op_TileSpray.triggerCallbackDamage()");
         }
         if(this.triggerEntityAbilityDef)
         {
            _loc3_ = new BattleAbility(caster,this.triggerEntityAbilityDef,manager);
            _loc3_.targetSet.setTarget(param1);
            _loc3_.execute(null);
         }
         return true;
      }
   }
}

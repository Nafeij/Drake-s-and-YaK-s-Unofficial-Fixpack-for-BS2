package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.BattleAbilityTargetRule;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectRemoveReason;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.ability.phantasm.def.VfxSequenceDef;
   import engine.battle.ability.phantasm.def.VfxSequenceDefs;
   import engine.battle.board.def.BattleBoardTriggerDef;
   import engine.battle.board.def.BattleBoardTriggerResponseDef;
   import engine.battle.board.def.BattleBoardTriggerResponseDefs;
   import engine.battle.board.model.BattleBoardTrigger;
   import engine.battle.board.model.IBattleEntity;
   import engine.core.util.Enum;
   import engine.def.BooleanVars;
   import engine.entity.def.IAbilityAssetBundle;
   import engine.resource.BitmapResource;
   import engine.tile.ITileResident;
   import engine.tile.Tile;
   import engine.tile.TileTrigger;
   import engine.tile.TileTriggerVisibleRule;
   import engine.tile.def.TileRect;
   
   public class Op_TileTrigger extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_TileTrigger",
         "properties":{
            "abilityDamageEnemy":{
               "type":"string",
               "optional":true
            },
            "abilityDamageFriend":{
               "type":"string",
               "optional":true
            },
            "abilityEmptyTile":{
               "type":"string",
               "optional":true
            },
            "abilityInitialHitEntity":{
               "type":"string",
               "optional":true
            },
            "abilityRankInitialHitEntity":{
               "type":"number",
               "optional":true
            },
            "abilityInitialHitEmptyTile":{
               "type":"string",
               "optional":true
            },
            "abilityRankInitialHitEmptyTile":{
               "type":"number",
               "optional":true
            },
            "targetRule":{"type":"string"},
            "triggerOnExpirationTargetRule":{"type":"string"},
            "triggerOnTileEnter":{
               "type":"boolean",
               "optional":true
            },
            "pulse":{
               "type":"boolean",
               "optional":true
            },
            "sizeOfCaster":{
               "type":"boolean",
               "optional":true
            },
            "triggerDef":{
               "type":BattleBoardTriggerDef.schema,
               "optional":true
            },
            "visibleRule":{"type":"string"},
            "vfx":{
               "type":"array",
               "optional":true,
               "items":VfxSequenceDef.schema
            },
            "hazard":{
               "type":"boolean",
               "optional":true
            },
            "tileIconUrl":{
               "type":"string",
               "optional":true
            },
            "stringId":{
               "type":"string",
               "optional":true
            },
            "triggerIncorporeal":{
               "type":"boolean",
               "optional":true
            },
            "ignoreIncorporealOnFadeIn":{
               "type":"boolean",
               "optional":true
            },
            "incorporealFadeAlpha":{
               "type":"number",
               "optional":true
            },
            "duration":{
               "type":"number",
               "optional":true
            },
            "checkTriggerOnEnable":{
               "type":"boolean",
               "optional":true
            }
         }
      };
       
      
      private var trig:BattleBoardTrigger;
      
      private var ablDamageEnemyDef:BattleAbilityDef = null;
      
      private var ablDamageFriendDef:BattleAbilityDef = null;
      
      private var ablEmptyTileDef:BattleAbilityDef = null;
      
      private var ablInitialHitEntity:BattleAbilityDef = null;
      
      private var ablInitialHitEmptyTile:BattleAbilityDef = null;
      
      private var targetRule:BattleAbilityTargetRule;
      
      private var triggerOnExpirationTargetRule:BattleAbilityTargetRule;
      
      private var handlingExecuteOnRemove:Boolean = false;
      
      private var visibleRule:TileTriggerVisibleRule;
      
      private var triggerOnTileEnter:Boolean = true;
      
      private var sizeOfCaster:Boolean;
      
      private var triggerDef:BattleBoardTriggerDef;
      
      private var triggerIncorporeal:Boolean;
      
      private var ignoreIncorporealOnFadeIn:Boolean = false;
      
      private var incorporealFadeAlpha:Number = -1;
      
      public function Op_TileTrigger(param1:EffectDefOp, param2:Effect)
      {
         var _loc4_:BattleAbilityDef = null;
         var _loc5_:int = 0;
         var _loc6_:BattleAbilityDef = null;
         var _loc7_:int = 0;
         this.visibleRule = TileTriggerVisibleRule.ANY;
         super(param1,param2);
         this.targetRule = Enum.parse(BattleAbilityTargetRule,param1.params.targetRule) as BattleAbilityTargetRule;
         this.triggerOnExpirationTargetRule = Enum.parse(BattleAbilityTargetRule,param1.params.triggerOnExpirationTargetRule) as BattleAbilityTargetRule;
         this.visibleRule = Enum.parse(TileTriggerVisibleRule,param1.params.visibleRule) as TileTriggerVisibleRule;
         if(param1.params.abilityInitialHitEntity != undefined)
         {
            _loc4_ = manager.factory.fetchBattleAbilityDef(param1.params.abilityInitialHitEntity);
            this.ablInitialHitEntity = _loc4_;
            if(param1.params.abilityRankInitialHitEntity != undefined)
            {
               _loc5_ = int(param1.params.abilityRankInitialHitEntity);
               this.ablInitialHitEntity = _loc4_.getAbilityDefForLevel(_loc5_) as BattleAbilityDef;
            }
         }
         if(param1.params.abilityInitialHitEmptyTile != undefined)
         {
            _loc6_ = manager.factory.fetchBattleAbilityDef(param1.params.abilityInitialHitEmptyTile);
            this.ablInitialHitEmptyTile = _loc6_;
            if(param1.params.abilityRankInitialHitEmptyTile != undefined)
            {
               _loc7_ = int(param1.params.abilityRankInitialHitEmptyTile);
               this.ablInitialHitEmptyTile = _loc6_.getAbilityDefForLevel(_loc7_) as BattleAbilityDef;
            }
         }
         var _loc3_:BattleAbilityDef = null;
         if(param1.params.abilityDamageEnemy)
         {
            _loc3_ = manager.factory.fetchBattleAbilityDef(param1.params.abilityDamageEnemy);
            this.ablDamageEnemyDef = _loc3_.getAbilityDefForLevel(param2.ability.def.level) as BattleAbilityDef;
         }
         if(param1.params.abilityDamageFriend)
         {
            _loc3_ = manager.factory.fetchBattleAbilityDef(param1.params.abilityDamageFriend);
            this.ablDamageFriendDef = _loc3_.getAbilityDefForLevel(param2.ability.def.level) as BattleAbilityDef;
         }
         if(param1.params.abilityEmptyTile)
         {
            this.ablEmptyTileDef = manager.factory.fetchBattleAbilityDef(param1.params.abilityEmptyTile);
         }
         this.triggerOnTileEnter = BooleanVars.parse(param1.params.triggerOnTileEnter,this.triggerOnTileEnter);
         this.sizeOfCaster = BooleanVars.parse(param1.params.sizeOfCaster,this.sizeOfCaster);
         this.triggerDef = new BattleBoardTriggerDef();
         if(param1.params.triggerDef)
         {
            this.triggerDef.fromJson(param1.params.triggerDef,logger);
            this._checkTriggerRedundancies();
         }
         else
         {
            this._setupTriggerDef();
         }
         this._configureTriggerDef();
      }
      
      public static function preloadAssets(param1:EffectDefOp, param2:IAbilityAssetBundle) : void
      {
         var _loc3_:String = String(param1.params.tileIconUrl);
         if(_loc3_)
         {
            param2.addExtraResource(_loc3_,BitmapResource);
         }
         _maybeLoadAbility(param2,param1.params.abilityDamageEnemy);
         _maybeLoadAbility(param2,param1.params.abilityDamageFriend);
         _maybeLoadAbility(param2,param1.params.abilityEmptyTile);
      }
      
      private static function _maybeLoadAbility(param1:IAbilityAssetBundle, param2:String) : void
      {
         if(!param2)
         {
            return;
         }
         param1.preloadAbilityDefById(param2);
      }
      
      private function _configureTriggerDef() : void
      {
         var _loc4_:BattleBoardTriggerResponseDef = null;
         var _loc1_:Function = this.triggerOnTileEnter ? this.triggerCallbackDamage : null;
         var _loc2_:* = true;
         if(this.visibleRule == TileTriggerVisibleRule.NONE)
         {
            _loc2_ = false;
         }
         else if(this.visibleRule == TileTriggerVisibleRule.FRIENDLY)
         {
            _loc2_ = Boolean(caster.playerControlled);
         }
         else if(this.visibleRule == TileTriggerVisibleRule.ENEMY)
         {
            _loc2_ = !caster.playerControlled;
         }
         if(ability.def.targetRule == BattleAbilityTargetRule.SPECIAL_PLAYER_DRUMFIRE)
         {
            tile = board.tiles.getTileByLocation(caster.rect.loc);
         }
         if(!this.triggerDef.id)
         {
            this.triggerDef.id = this.toString();
         }
         this.triggerDef.visible = _loc2_;
         var _loc3_:BattleBoardTriggerResponseDefs = this.triggerDef.responses;
         if(Boolean(_loc3_) && Boolean(_loc3_.responses))
         {
            for each(_loc4_ in _loc3_.responses)
            {
               if(!_loc4_.happening && !_loc4_.ability)
               {
                  _loc4_.callback = _loc1_;
               }
            }
         }
      }
      
      private function _checkTriggerRedundancy(param1:String) : void
      {
         if(def.params[param1])
         {
            logger.error("params has triggerDef but also redundant " + param1);
         }
      }
      
      private function _checkTriggerRedundancies() : void
      {
         this._checkTriggerRedundancy("vfx");
         this._checkTriggerRedundancy("hazard");
         this._checkTriggerRedundancy("pulse");
         this._checkTriggerRedundancy("stringId");
         this._checkTriggerRedundancy("tileIconUrl");
      }
      
      private function _setupTriggerDef() : void
      {
         var _loc1_:VfxSequenceDefs = null;
         if(def.params.vfx)
         {
            _loc1_ = new VfxSequenceDefs();
            _loc1_.fromJson(def.params.vfx,logger);
         }
         var _loc2_:Boolean = Boolean(def.params.hazard);
         var _loc3_:Boolean = Boolean(def.params.pulse);
         var _loc4_:String = String(def.params.stringId);
         var _loc5_:String = String(def.params.tileIconUrl);
         this.triggerDef.id = this.toString();
         this.triggerDef.tileIconUrl = _loc5_;
         this.triggerDef.stringId = _loc4_;
         this.triggerDef.vfxds = _loc1_;
         this.triggerDef.incorporeal = def.params.triggerIncorporeal;
         this.triggerDef.ignoreIncorporealOnFadeIn = def.params.ignoreIncorporealOnFadeIn;
         this.triggerDef.duration = def.params.duration;
         this.triggerDef.checkTriggerOnEnable = def.params.checkTriggerOnEnable;
         if(def.params.incorporealFadeAlpha >= 0)
         {
            this.triggerDef.incorporealFadeAlpha = def.params.incorporealFadeAlpha;
         }
         var _loc6_:BattleBoardTriggerResponseDef = new BattleBoardTriggerResponseDef();
         _loc6_.pulse = _loc3_;
         _loc6_.hazard = _loc2_;
         if(!_loc4_)
         {
            _loc6_.abilityStringId = ability.def.id;
         }
         this.triggerDef.addResponse(_loc6_);
      }
      
      override public function apply() : void
      {
         var _loc2_:BattleAbility = null;
         if(effect.ability.fake || manager.faking)
         {
            return;
         }
         var _loc1_:TileRect = tile.rect.clone();
         if(this.sizeOfCaster)
         {
            _loc1_ = caster.rect.clone();
         }
         _loc1_.facing = caster.facing;
         this.trig = tile.tiles.addTrigger(null,this.triggerDef,_loc1_,this.triggerDef.visible,effect,false) as BattleBoardTrigger;
         var _loc3_:IBattleEntity = caster.board.findEntityOnTile(tile.x,tile.y,true,caster);
         if(_loc3_ != null)
         {
            if(this.ablInitialHitEntity != null)
            {
               _loc2_ = new BattleAbility(caster,this.ablInitialHitEntity,manager);
               _loc2_.targetSet.setTarget(_loc3_);
               _loc2_.targetSet.setTile(tile);
               effect.ability.addChildAbility(_loc2_);
            }
         }
         else if(this.ablInitialHitEmptyTile != null)
         {
            _loc2_ = new BattleAbility(caster,this.ablInitialHitEmptyTile,manager);
            _loc2_.targetSet.setTile(tile);
            effect.ability.addChildAbility(_loc2_);
         }
      }
      
      override public function remove() : void
      {
         var _loc1_:ITileResident = null;
         var _loc2_:IBattleEntity = null;
         if(this.trig)
         {
            if(this.handlingExecuteOnRemove == false)
            {
               if(effect.removeReason == EffectRemoveReason.CASTER_DURATION || effect.removeReason == EffectRemoveReason.CASTER_DEATH || effect.removeReason == EffectRemoveReason.FORCED_EXPIRATION)
               {
                  if(this.triggerOnExpirationTargetRule == BattleAbilityTargetRule.ENEMY || this.triggerOnExpirationTargetRule == BattleAbilityTargetRule.FRIENDLY || this.triggerOnExpirationTargetRule == BattleAbilityTargetRule.ANY)
                  {
                     this.handlingExecuteOnRemove = true;
                     this.targetRule = this.triggerOnExpirationTargetRule;
                     _loc1_ = tile.findResident(null);
                     if(_loc1_ != null && _loc1_ is IBattleEntity)
                     {
                        _loc2_ = _loc1_ as IBattleEntity;
                        this.triggerCallbackDamage(_loc2_,tile);
                     }
                     else
                     {
                        this.handleEmptyTile(this.trig,tile);
                     }
                  }
               }
            }
            tile.tiles.removeTrigger(this.trig);
         }
      }
      
      private function triggerCallbackDamage(param1:IBattleEntity, param2:Tile) : Boolean
      {
         var _loc4_:BattleAbilityDef = null;
         var _loc5_:BattleAbility = null;
         if(!param1)
         {
            return false;
         }
         var _loc3_:Boolean = true;
         if(this.targetRule == BattleAbilityTargetRule.ENEMY && caster.team == param1.team)
         {
            _loc3_ = false;
         }
         else if(this.targetRule == BattleAbilityTargetRule.FRIENDLY && caster.team != param1.team)
         {
            _loc3_ = false;
         }
         else if(this.targetRule == BattleAbilityTargetRule.NONE)
         {
            _loc3_ = false;
         }
         else if(this.targetRule == BattleAbilityTargetRule.SELF && caster != param1)
         {
            _loc3_ = false;
         }
         if(!_loc3_)
         {
            return false;
         }
         if(caster.team != param1.team)
         {
            _loc4_ = this.ablDamageEnemyDef;
         }
         else
         {
            _loc4_ = this.ablDamageFriendDef;
         }
         if(!_loc4_)
         {
            return false;
         }
         if(!_loc4_.checkTargetExecutionConditions(target,logger,true))
         {
            logger.info("Op_TileTrigger target executions skips " + target + " for " + this);
            return false;
         }
         _loc5_ = new BattleAbility(caster,_loc4_,manager);
         _loc5_.targetSet.setTarget(param1);
         _loc5_.targetSet.setTile(param2);
         effect.ability.addChildAbility(_loc5_);
         effect.handleOpUsed(this);
         return true;
      }
      
      private function handleEmptyTile(param1:TileTrigger, param2:Tile) : void
      {
         var _loc3_:BattleAbility = null;
         if(this.ablEmptyTileDef)
         {
            _loc3_ = new BattleAbility(caster,this.ablEmptyTileDef,manager);
            _loc3_.targetSet.setTile(param2);
            effect.ability.addChildAbility(_loc3_);
         }
         effect.handleOpUsed(this);
      }
   }
}

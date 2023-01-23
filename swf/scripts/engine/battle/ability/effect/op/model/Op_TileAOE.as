package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.board.model.IBattleEntity;
   import engine.def.BooleanVars;
   import engine.tile.Tile;
   import engine.tile.def.TileLocation;
   import flash.utils.Dictionary;
   
   public class Op_TileAOE extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_TileAOE",
         "properties":{
            "ranges":{
               "type":"array",
               "items":{"properties":{
                  "distance":{"type":"number"},
                  "abilityEntity":{"type":"string"},
                  "abilityTile":{
                     "type":"string",
                     "optional":true
                  }
               }}
            },
            "entityHitOnce":{
               "type":"boolean",
               "defaultValue":false,
               "optional":true
            },
            "abilityEntityRank":{
               "type":"number",
               "optional":true
            }
         }
      };
       
      
      protected var hits:Dictionary;
      
      public var ranges:Vector.<Range_TileAOE>;
      
      protected var entityHitOnce:Boolean = false;
      
      private var centerTile:Tile;
      
      public function Op_TileAOE(param1:EffectDefOp, param2:Effect)
      {
         var _loc4_:Object = null;
         var _loc5_:Range_TileAOE = null;
         this.hits = new Dictionary();
         this.ranges = new Vector.<Range_TileAOE>();
         super(param1,param2);
         var _loc3_:int = 1;
         if(param1.params.abilityEntityRank != undefined)
         {
            _loc3_ = int(param1.params.abilityEntityRank);
         }
         for each(_loc4_ in param1.params.ranges)
         {
            _loc5_ = new Range_TileAOE(_loc4_,manager.factory,param2.ability.caster.logger,_loc3_);
            if(this.ranges.length > 0)
            {
               if(_loc5_.distance <= this.ranges[this.ranges.length - 1].distance)
               {
                  param2.ability.caster.logger.error("Op_TileAOE range out of order in " + param1);
               }
            }
            this.ranges.push(_loc5_);
         }
         if(this.ranges.length == 0)
         {
            param2.ability.caster.logger.error("Op_TileAOE has no ranges: " + param1);
         }
         this.entityHitOnce = BooleanVars.parse(param1.params.entityHitOnce,false);
      }
      
      override public function execute() : EffectResult
      {
         return EffectResult.OK;
      }
      
      override public function apply() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         this.centerTile = tile;
         if(!this.centerTile && Boolean(target))
         {
            this.centerTile = target.tile;
         }
         if(this.centerTile)
         {
            _loc1_ = this.centerTile.x;
            _loc2_ = this.centerTile.y;
            this.applyOn(_loc1_ + 0,_loc2_ + 0);
            this.applyOn(_loc1_ + 0,_loc2_ + 1);
            this.applyOn(_loc1_ + 1,_loc2_ + 0);
            this.applyOn(_loc1_ + 0,_loc2_ - 1);
            this.applyOn(_loc1_ - 1,_loc2_ + 0);
         }
      }
      
      private function getRange_TileAOE(param1:int) : Range_TileAOE
      {
         var _loc3_:Range_TileAOE = null;
         if(this.ranges.length == 0)
         {
            return null;
         }
         var _loc2_:int = 0;
         while(_loc2_ < this.ranges.length)
         {
            _loc3_ = this.ranges[_loc2_];
            if(_loc3_.distance > param1)
            {
               return this.ranges[Math.max(0,_loc2_ - 1)];
            }
            _loc2_++;
         }
         return this.ranges[this.ranges.length - 1];
      }
      
      private function applyOn(param1:int, param2:int) : void
      {
         var _loc3_:Number = NaN;
         var _loc6_:BattleAbility = null;
         var _loc7_:IBattleEntity = null;
         var _loc8_:Boolean = false;
         _loc3_ = TileLocation.manhattanDistance(param1,param2,this.centerTile.x,this.centerTile.y);
         var _loc4_:Range_TileAOE = this.getRange_TileAOE(_loc3_);
         if(!_loc4_)
         {
            return;
         }
         var _loc5_:Tile = this.centerTile.tiles.getTile(param1,param2);
         if(_loc5_ != null)
         {
            _loc6_ = null;
            _loc7_ = caster.board.findEntityOnTile(param1,param2,true,caster);
            if(_loc7_ != null && Boolean(_loc7_.attackable))
            {
               if(_loc4_.abilityEntityDef)
               {
                  _loc8_ = true;
                  if(this.hits[_loc7_])
                  {
                     if(this.entityHitOnce == true)
                     {
                        _loc8_ = false;
                     }
                  }
                  if(_loc8_ == true)
                  {
                     this.hits[_loc7_] = _loc7_;
                     _loc6_ = new BattleAbility(caster,_loc4_.abilityEntityDef,manager);
                     _loc6_.targetSet.setTarget(_loc7_);
                  }
               }
            }
            else if(_loc4_.abilityTileDef)
            {
               _loc6_ = new BattleAbility(caster,_loc4_.abilityTileDef,manager);
            }
            if(_loc6_)
            {
               _loc6_.targetSet.setTile(_loc5_);
               effect.ability.addChildAbility(_loc6_);
            }
            effect.handleOpUsed(this);
         }
      }
   }
}

import engine.battle.ability.def.BattleAbilityDef;
import engine.battle.ability.def.BattleAbilityDefFactory;
import engine.core.logging.ILogger;

class Range_TileAOE
{
   
   public static const schema:Object = {
      "name":"Op_TileAOE.Range",
      "properties":{
         "distance":{"type":"number"},
         "abilityEntity":{"type":"string"},
         "abilityTile":{
            "type":"string",
            "optional":true
         }
      }
   };
    
   
   public var distance:Number;
   
   public var abilityEntityDef:BattleAbilityDef;
   
   public var abilityTileDef:BattleAbilityDef;
   
   public function Range_TileAOE(param1:Object, param2:BattleAbilityDefFactory, param3:ILogger, param4:int)
   {
      var _loc5_:BattleAbilityDef = null;
      var _loc6_:BattleAbilityDef = null;
      super();
      this.distance = param1.distance;
      if(param1.abilityEntity)
      {
         _loc5_ = param2.fetchBattleAbilityDef(param1.abilityEntity);
         this.abilityEntityDef = _loc5_.getAbilityDefForLevel(param4) as BattleAbilityDef;
      }
      if(param1.abilityTile != undefined)
      {
         _loc6_ = param2.fetchBattleAbilityDef(param1.abilityTile);
         this.abilityTileDef = _loc6_.getAbilityDefForLevel(param4) as BattleAbilityDef;
      }
   }
}

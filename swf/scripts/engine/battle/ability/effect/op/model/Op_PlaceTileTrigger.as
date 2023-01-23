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
   import engine.tile.Tile;
   import engine.tile.TileLocationVars;
   import engine.tile.TileTrigger;
   import engine.tile.TileTriggerType;
   import engine.tile.def.TileLocation;
   import engine.tile.def.TileRect;
   import flash.geom.Point;
   
   public class Op_PlaceTileTrigger extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_PlaceTileTrigger",
         "properties":{
            "triggerType":{"type":"string"},
            "damageAbility":{"type":"string"},
            "pulsePerTurn":{"type":"boolean"},
            "offset":{"type":TileLocationVars.schema}
         }
      };
       
      
      protected var triggerType:TileTriggerType;
      
      protected var damageAbilityDef:BattleAbilityDef = null;
      
      protected var pulsePerTurn:Boolean;
      
      protected var offset:TileLocation;
      
      protected var tileTrigger:TileTrigger = null;
      
      public function Op_PlaceTileTrigger(param1:EffectDefOp, param2:Effect)
      {
         super(param1,param2);
         this.triggerType = Enum.parse(TileTriggerType,param1.params.triggerType) as TileTriggerType;
         this.damageAbilityDef = manager.factory.fetchBattleAbilityDef(param1.params.damageAbility);
         this.pulsePerTurn = BooleanVars.parse(param1.params.pulsePerTurn);
         this.offset = TileLocationVars.parse(param1.params.offset,manager.logger);
      }
      
      override public function apply() : void
      {
         var _loc3_:BattleBoardTriggerDef = null;
         var _loc4_:BattleBoardTriggerResponseDef = null;
         var _loc5_:TileRect = null;
         var _loc6_:Vector.<BattleBoardTrigger> = null;
         var _loc7_:BattleBoardTrigger = null;
         var _loc8_:BattleBoardTrigger = null;
         logger.debug("$$$$ Op_PlaceTileTrigger().apply()");
         var _loc1_:Point = new Point(tile.x + this.offset.x,tile.y + this.offset.y);
         var _loc2_:Tile = tile.tiles.getTile(_loc1_.x,_loc1_.y);
         if(_loc2_ != null)
         {
            _loc3_ = new BattleBoardTriggerDef();
            _loc3_.id = this.toString();
            _loc4_ = new BattleBoardTriggerResponseDef();
            _loc4_.pulse = this.pulsePerTurn;
            _loc4_.callback = this.triggerCallbackDamage;
            _loc3_.addResponse(_loc4_);
            _loc5_ = _loc2_.rect.clone();
            _loc5_.facing = caster.facing;
            this.tileTrigger = tile.tiles.addTrigger(null,_loc3_,_loc5_,false,effect,false);
            this.tileTrigger.type = this.triggerType;
            _loc6_ = new Vector.<BattleBoardTrigger>();
            for each(_loc7_ in caster.board.triggers.triggers)
            {
               if(_loc7_ != null && _loc7_.rect == this.tileTrigger.rect && _loc7_ != this.tileTrigger && _loc7_.type == this.tileTrigger.type)
               {
                  _loc6_.push(_loc7_);
               }
            }
            for each(_loc8_ in _loc6_)
            {
               tile.tiles.removeTrigger(_loc8_);
            }
         }
      }
      
      override public function remove() : void
      {
         logger.debug("$$$$ Op_PlaceTileTrigger().remove()");
         tile.tiles.removeTrigger(this.tileTrigger);
      }
      
      private function triggerCallbackDamage(param1:IBattleEntity, param2:Tile) : Boolean
      {
         logger.debug("$$$$ Op_PlaceTileTrigger().triggerCallbackDamage()");
         var _loc3_:BattleAbility = new BattleAbility(caster,this.damageAbilityDef,manager);
         _loc3_.targetSet.setTarget(param1);
         _loc3_.execute(null);
         return true;
      }
   }
}

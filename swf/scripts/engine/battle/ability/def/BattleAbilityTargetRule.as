package engine.battle.ability.def
{
   import engine.battle.BattleUtilFunctions;
   import engine.battle.ability.effect.op.model.Op_KnockbackHelper;
   import engine.battle.ability.effect.op.model.Op_RunThroughHelper;
   import engine.battle.board.model.IBattleEntity;
   import engine.core.util.Enum;
   import engine.tile.Tile;
   import engine.tile.Tiles;
   import engine.tile.def.TileRect;
   
   public class BattleAbilityTargetRule extends Enum
   {
      
      public static const NONE:BattleAbilityTargetRule = new BattleAbilityTargetRule("NONE",enumCtorKey);
      
      public static const DEAD:BattleAbilityTargetRule = new BattleAbilityTargetRule("DEAD",enumCtorKey);
      
      public static const FRIENDLY:BattleAbilityTargetRule = new BattleAbilityTargetRule("FRIENDLY",enumCtorKey);
      
      public static const SELF:BattleAbilityTargetRule = new BattleAbilityTargetRule("SELF",enumCtorKey);
      
      public static const SELF_AOE_1:BattleAbilityTargetRule = new BattleAbilityTargetRule("SELF_AOE_1",enumCtorKey);
      
      public static const SELF_AOE_ENEMY_1:BattleAbilityTargetRule = new BattleAbilityTargetRule("SELF_AOE_ENEMY_1",enumCtorKey);
      
      public static const OTHER:BattleAbilityTargetRule = new BattleAbilityTargetRule("OTHER",enumCtorKey);
      
      public static const FRIENDLY_OTHER:BattleAbilityTargetRule = new BattleAbilityTargetRule("FRIENDLY_OTHER",enumCtorKey);
      
      public static const ENEMY:BattleAbilityTargetRule = new BattleAbilityTargetRule("ENEMY",enumCtorKey);
      
      public static const TILE_ANY:BattleAbilityTargetRule = new BattleAbilityTargetRule("TILE_ANY",enumCtorKey);
      
      public static const TILE_EMPTY:BattleAbilityTargetRule = new BattleAbilityTargetRule("TILE_EMPTY",enumCtorKey);
      
      public static const TILE_EMPTY_RANDOM:BattleAbilityTargetRule = new BattleAbilityTargetRule("TILE_EMPTY_RANDOM",enumCtorKey);
      
      public static const TILE_EMPTY_1x2_FACING_CASTER:BattleAbilityTargetRule = new BattleAbilityTargetRule("TILE_EMPTY_1x2_FACING_CASTER",enumCtorKey);
      
      public static const ANY:BattleAbilityTargetRule = new BattleAbilityTargetRule("ANY",enumCtorKey);
      
      public static const ADJACENT_BATTLEENTITY:BattleAbilityTargetRule = new BattleAbilityTargetRule("ADJACENT_BATTLEENTITY",enumCtorKey);
      
      public static const ENEMY_NEIGHBORS:BattleAbilityTargetRule = new BattleAbilityTargetRule("ENEMY_NEIGHBORS",enumCtorKey);
      
      public static const ALL_ENEMIES:BattleAbilityTargetRule = new BattleAbilityTargetRule("ALL_ENEMIES",enumCtorKey);
      
      public static const ALL_ALLIES:BattleAbilityTargetRule = new BattleAbilityTargetRule("ALL_ALLIES",enumCtorKey);
      
      public static const FORWARD_ARC:BattleAbilityTargetRule = new BattleAbilityTargetRule("FORWARD_ARC",enumCtorKey);
      
      public static const ARC_LIGHTNING:BattleAbilityTargetRule = new BattleAbilityTargetRule("ARC_LIGHTNING",enumCtorKey);
      
      public static const NEEDLE_TARGET_ENEMY_OTHER_ALL:BattleAbilityTargetRule = new BattleAbilityTargetRule("NEEDLE_TARGET_ENEMY_OTHER_ALL",enumCtorKey);
      
      public static const CROSS_TARGET_ENEMY_OTHER_ALL:BattleAbilityTargetRule = new BattleAbilityTargetRule("CROSS_TARGET_ENEMY_OTHER_ALL",enumCtorKey);
      
      public static const SPECIAL_RUN_THROUGH:BattleAbilityTargetRule = new BattleAbilityTargetRule("SPECIAL_RUN_THROUGH",enumCtorKey);
      
      public static const SPECIAL_RUN_TO:BattleAbilityTargetRule = new BattleAbilityTargetRule("SPECIAL_RUN_TO",enumCtorKey);
      
      public static const SPECIAL_TRAMPLE:BattleAbilityTargetRule = new BattleAbilityTargetRule("SPECIAL_TRAMPLE",enumCtorKey);
      
      public static const SPECIAL_BATTERING_RAM:BattleAbilityTargetRule = new BattleAbilityTargetRule("SPECIAL_BATTERING_RAM",enumCtorKey);
      
      public static const SPECIAL_SLAG_AND_BURN:BattleAbilityTargetRule = new BattleAbilityTargetRule("SPECIAL_SLAG_AND_BURN",enumCtorKey);
      
      public static const USABLE:BattleAbilityTargetRule = new BattleAbilityTargetRule("USABLE",enumCtorKey);
      
      public static const SPECIAL_PLAYER_DRUMFIRE:BattleAbilityTargetRule = new BattleAbilityTargetRule("SPECIAL_PLAYER_DRUMFIRE",enumCtorKey);
       
      
      public function BattleAbilityTargetRule(param1:String, param2:Object)
      {
         super(param1,param2);
      }
      
      public function get isTile() : Boolean
      {
         return this == TILE_ANY || this == TILE_EMPTY || this == TILE_EMPTY_RANDOM || this == TILE_EMPTY_1x2_FACING_CASTER || this == FORWARD_ARC || this == SPECIAL_PLAYER_DRUMFIRE;
      }
      
      public function get isAxial() : Boolean
      {
         return this == SPECIAL_RUN_TO || this == SPECIAL_RUN_THROUGH || this == SPECIAL_BATTERING_RAM || this == SPECIAL_TRAMPLE || this == SPECIAL_PLAYER_DRUMFIRE;
      }
      
      private function _visitForwardArcTileHandler(param1:int, param2:int, param3:*) : Boolean
      {
         var _loc4_:IBattleEntity = param3 as IBattleEntity;
         var _loc5_:Tile = param3 as Tile;
         var _loc6_:Tiles = !!_loc4_ ? _loc4_.tiles : _loc5_.tiles;
         var _loc7_:Tile = _loc6_.getTile(param1,param2);
         if(_loc7_)
         {
            if(_loc5_ == _loc7_)
            {
               return true;
            }
            if(_loc4_)
            {
               if(_loc7_.hasResident(_loc4_))
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function isValid(param1:IBattleEntity, param2:TileRect, param3:IBattleEntity, param4:Tile, param5:Boolean, param6:IBattleAbilityDef = null, param7:Boolean = true) : Boolean
      {
         var _loc10_:* = false;
         var _loc11_:* = false;
         var _loc12_:* = false;
         var _loc13_:Tile = null;
         var _loc14_:Tile = null;
         if(param3 != null && param1 != param3 && param3.attackable == false)
         {
            return false;
         }
         var _loc8_:Boolean = !param7 || Boolean(param3) && param3.alive;
         var _loc9_:TileRect = !!param3 ? param3.rect : null;
         switch(this)
         {
            case NONE:
               return true;
            case DEAD:
               if(param3 != null && !param3.alive && Boolean(param3.mobile))
               {
                  if(!param3.board.findAllRectIntersectionEntities(param3.rect,param3,null))
                  {
                     return true;
                  }
               }
               return false;
            case FRIENDLY:
               return param3 != null && param1.team == param3.team;
            case ENEMY:
            case ARC_LIGHTNING:
            case ALL_ENEMIES:
               if(_loc8_ && param1.canAttack(param3))
               {
                  return true;
               }
               return false;
               break;
            case ADJACENT_BATTLEENTITY:
               if(param3 == param1)
               {
                  return true;
               }
               if(param3 != null && param3 != param1 && _loc8_)
               {
                  return true;
               }
               return false;
               break;
            case ENEMY_NEIGHBORS:
               if(param3 != null && param1.team != param3.team)
               {
                  return true;
               }
               return false;
               break;
            case SELF:
            case SELF_AOE_1:
            case SELF_AOE_ENEMY_1:
               return param3 != null && param1 == param3;
            case OTHER:
               return param3 != null && param1 != param3;
            case FRIENDLY_OTHER:
            case ALL_ALLIES:
               return param3 != null && param1.team == param3.team && param1 != param3;
            case FORWARD_ARC:
               if(!param3 && !param4)
               {
                  return param5;
               }
               return true;
               break;
            case TILE_ANY:
            case TILE_EMPTY:
            case TILE_EMPTY_RANDOM:
            case TILE_EMPTY_1x2_FACING_CASTER:
               if(Boolean(param4) && !param4.getWalkableFor(null))
               {
                  return false;
               }
               return param5 || param4 != null;
               break;
            case SPECIAL_PLAYER_DRUMFIRE:
               if(Boolean(param4) && !param4.getWalkableFor(null))
               {
                  return false;
               }
               if(!param5 && param4 == null)
               {
                  return false;
               }
               return BattleUtilFunctions.isAxialEntity2Tile(param2,param4);
               break;
            case ANY:
               return param3 != null;
            case NEEDLE_TARGET_ENEMY_OTHER_ALL:
            case CROSS_TARGET_ENEMY_OTHER_ALL:
               if(param3)
               {
                  return BattleUtilFunctions.isAxialEntity2Entity(param2,param3);
               }
               return false;
               break;
            case SPECIAL_RUN_THROUGH:
            case SPECIAL_RUN_TO:
               if(param1.canAttack(param3))
               {
                  if(BattleUtilFunctions.isAxialEntity2Entity(param2,param3) == false)
                  {
                     return false;
                  }
                  _loc10_ = this == SPECIAL_RUN_THROUGH;
                  _loc11_ = this != SPECIAL_RUN_TO;
                  _loc12_ = this == SPECIAL_RUN_TO;
                  _loc13_ = Op_RunThroughHelper.findLandingTile(param1,param2,_loc9_,_loc11_,_loc10_,_loc12_);
                  if(_loc13_)
                  {
                     if(BattleUtilFunctions.axialPathClearOfBlockers(param1,param2,_loc13_.x,_loc13_.y) == true)
                     {
                        return true;
                     }
                  }
               }
               return false;
            case SPECIAL_TRAMPLE:
               return this._checkTrample(param1,param2,param3,_loc9_);
            case SPECIAL_BATTERING_RAM:
               if(param3 != null)
               {
                  if(!param1.canAttack(param3) && param1.team != param3.team)
                  {
                     return false;
                  }
                  if(!param3.mobile)
                  {
                     return false;
                  }
                  if(BattleUtilFunctions.isAxialEntity2Entity(param2,param3) == false)
                  {
                     return false;
                  }
                  if(param6 != null)
                  {
                     _loc14_ = null;
                     _loc14_ = Op_KnockbackHelper.getKnockbackStopTile(param6,param1,param2,param3,true);
                     if(_loc14_)
                     {
                        return true;
                     }
                  }
               }
               return false;
            default:
               return false;
         }
      }
      
      private function _checkTrample(param1:IBattleEntity, param2:TileRect, param3:IBattleEntity, param4:TileRect) : Boolean
      {
         var _loc5_:Tile = null;
         if(param1.canAttack(param3))
         {
            if(BattleUtilFunctions.isAxialEntity2Entity(param2,param3) == false)
            {
               return false;
            }
            _loc5_ = Op_RunThroughHelper.findLandingTileBehind(param1,param2,param4,false);
            if(_loc5_)
            {
               if(BattleUtilFunctions.axialPathClearOfBlockers(param1,param2,_loc5_.x,_loc5_.y) == true)
               {
                  return true;
               }
            }
         }
         return false;
      }
   }
}

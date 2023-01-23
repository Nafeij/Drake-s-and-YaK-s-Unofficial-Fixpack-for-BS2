package engine.battle.ability.effect.op.def
{
   import engine.core.util.Enum;
   import flash.errors.IllegalOperationError;
   
   public class IdEffectOp extends Enum
   {
      
      public static const ADJACENT_ARMOR_BONUS:IdEffectOp = new IdEffectOp("ADJACENT_ARMOR_BONUS",enumCtorKey);
      
      public static const BATTERING_RAM:IdEffectOp = new IdEffectOp("BATTERING_RAM",enumCtorKey);
      
      public static const BLOODYFLAIL_DAMAGE:IdEffectOp = new IdEffectOp("BLOODYFLAIL_DAMAGE",enumCtorKey);
      
      public static const CHANGE_STAT:IdEffectOp = new IdEffectOp("CHANGE_STAT",enumCtorKey);
      
      public static const DAMAGE_ARM:IdEffectOp = new IdEffectOp("DAMAGE_ARM",enumCtorKey);
      
      public static const DAMAGE_STR:IdEffectOp = new IdEffectOp("DAMAGE_STR",enumCtorKey);
      
      public static const END_TURN:IdEffectOp = new IdEffectOp("END_TURN",enumCtorKey);
      
      public static const EXEC_ABILITY:IdEffectOp = new IdEffectOp("EXEC_ABILITY",enumCtorKey);
      
      public static const EXPIRE_EFFECTS:IdEffectOp = new IdEffectOp("EXPIRE_EFFECTS",enumCtorKey);
      
      public static const HEAVYIMPACT_DAMAGE:IdEffectOp = new IdEffectOp("HEAVYIMPACT_DAMAGE",enumCtorKey);
      
      public static const INITIATIVE:IdEffectOp = new IdEffectOp("INITIATIVE",enumCtorKey);
      
      public static const INT_STAT_MOD:IdEffectOp = new IdEffectOp("INT_STAT_MOD",enumCtorKey);
      
      public static const PLACE_TILE_TRIGGER:IdEffectOp = new IdEffectOp("PLACE_TILE_TRIGGER",enumCtorKey);
      
      public static const POSSESS_ENTITY:IdEffectOp = new IdEffectOp("POSSESS_ENTITY",enumCtorKey);
      
      public static const RESURRECT_ENTITY:IdEffectOp = new IdEffectOp("RESURRECT_ENTITY",enumCtorKey);
      
      public static const RETARGET:IdEffectOp = new IdEffectOp("RETARGET",enumCtorKey);
      
      public static const RUN_THROUGH:IdEffectOp = new IdEffectOp("RUN_THROUGH",enumCtorKey);
      
      public static const STOP_MOVING:IdEffectOp = new IdEffectOp("STOP_MOVING",enumCtorKey);
      
      public static const SUSPEND_TARGET:IdEffectOp = new IdEffectOp("SUSPEND_TARGET",enumCtorKey);
      
      public static const TILE_TRIGGER:IdEffectOp = new IdEffectOp("TILE_TRIGGER",enumCtorKey);
      
      public static const TILE_AOE:IdEffectOp = new IdEffectOp("TILE_AOE",enumCtorKey);
      
      public static const TARGET_AOE:IdEffectOp = new IdEffectOp("TARGET_AOE",enumCtorKey);
      
      public static const TARGET_FORWARD_ARC:IdEffectOp = new IdEffectOp("TARGET_FORWARD_ARC",enumCtorKey);
      
      public static const WAIT_FOR_ACTION_COMPLETE:IdEffectOp = new IdEffectOp("WAIT_FOR_ACTION_COMPLETE",enumCtorKey);
      
      public static const WAIT_FOR_DAMAGE_STR:IdEffectOp = new IdEffectOp("WAIT_FOR_DAMAGE_STR",enumCtorKey);
      
      public static const WAIT_FOR_CHANGE_STAT:IdEffectOp = new IdEffectOp("WAIT_FOR_CHANGE_STAT",enumCtorKey);
      
      public static const WAIT_FOR_START_TURN:IdEffectOp = new IdEffectOp("WAIT_FOR_START_TURN",enumCtorKey);
      
      public static const WAIT_FOR_KILL:IdEffectOp = new IdEffectOp("WAIT_FOR_KILL",enumCtorKey);
      
      public static const AURA:IdEffectOp = new IdEffectOp("AURA",enumCtorKey);
      
      public static const NONE_ADJACENT:IdEffectOp = new IdEffectOp("NONE_ADJACENT",enumCtorKey);
      
      public static const SLAGANDBURN_TILECROSS:IdEffectOp = new IdEffectOp("SLAGANDBURN_TILECROSS",enumCtorKey);
      
      public static const MOVE_TO_RANGE:IdEffectOp = new IdEffectOp("MOVE_TO_RANGE",enumCtorKey);
      
      public static const RUNAWAY:IdEffectOp = new IdEffectOp("RUNAWAY",enumCtorKey);
      
      public static const KINDLE_KNOCKBACK:IdEffectOp = new IdEffectOp("KINDLE_KNOCKBACK",enumCtorKey);
      
      public static const KNOCKBACK:IdEffectOp = new IdEffectOp("KNOCKBACK",enumCtorKey);
      
      public static const NEEDLE:IdEffectOp = new IdEffectOp("NEEDLE",enumCtorKey);
      
      public static const SPAWN:IdEffectOp = new IdEffectOp("SPAWN",enumCtorKey);
      
      public static const WAIT_FOR_MOVE:IdEffectOp = new IdEffectOp("WAIT_FOR_MOVE",enumCtorKey);
      
      public static const WAIT_FOR_ANY_MOVE:IdEffectOp = new IdEffectOp("WAIT_FOR_ANY_MOVE",enumCtorKey);
      
      public static const WAIT_FOR_MOVE_FINISHING:IdEffectOp = new IdEffectOp("WAIT_FOR_MOVE_FINISHING",enumCtorKey);
      
      public static const WAIT_FOR_MOVE_STATES:IdEffectOp = new IdEffectOp("WAIT_FOR_MOVE_STATES",enumCtorKey);
      
      public static const ADD_TAG:IdEffectOp = new IdEffectOp("ADD_TAG",enumCtorKey);
      
      public static const REMOVE_TAG:IdEffectOp = new IdEffectOp("REMOVE_TAG",enumCtorKey);
      
      public static const ARC_LIGHTNING_AOE:IdEffectOp = new IdEffectOp("ARC_LIGHTNING_AOE",enumCtorKey);
      
      public static const SET_ALL_UNIT_STAT:IdEffectOp = new IdEffectOp("SET_ALL_UNIT_STAT",enumCtorKey);
      
      public static const AWARD_RENOWN:IdEffectOp = new IdEffectOp("AWARD_RENOWN",enumCtorKey);
      
      public static const SET_ANIM_LAYER:IdEffectOp = new IdEffectOp("SET_ANIM_LAYER",enumCtorKey);
      
      public static const SHIELD_SMASH_DAMAGE:IdEffectOp = new IdEffectOp("SHIELD_SMASH_DAMAGE",enumCtorKey);
      
      public static const REMOVE_PASSIVE:IdEffectOp = new IdEffectOp("REMOVE_PASSIVE",enumCtorKey);
      
      public static const PILLAGE:IdEffectOp = new IdEffectOp("PILLAGE",enumCtorKey);
      
      public static const TILE_SPRAY:IdEffectOp = new IdEffectOp("TILE_SPRAY",enumCtorKey);
      
      public static const MOVE_TELEPORT:IdEffectOp = new IdEffectOp("MOVE_TELEPORT",enumCtorKey);
      
      public static const SET_TRAVERSABLE:IdEffectOp = new IdEffectOp("SET_TRAVERSABLE",enumCtorKey);
      
      public static const SET_INCORPOREAL:IdEffectOp = new IdEffectOp("SET_INCORPOREAL",enumCtorKey);
      
      public static const SET_SUBMERGED:IdEffectOp = new IdEffectOp("SET_SUBMERGED",enumCtorKey);
      
      public static const SET_FACING:IdEffectOp = new IdEffectOp("SET_FACING",enumCtorKey);
      
      public static const SET_VISIBLE:IdEffectOp = new IdEffectOp("SET_VISIBLE",enumCtorKey);
      
      public static const FLASH_VISIBLE:IdEffectOp = new IdEffectOp("FLASH_VISIBLE",enumCtorKey);
      
      public static const WAIT_FOR_COLLISION:IdEffectOp = new IdEffectOp("WAIT_FOR_COLLISION",enumCtorKey);
      
      public static const FREE_TURN:IdEffectOp = new IdEffectOp("FREE_TURN",enumCtorKey);
      
      public static const SET_ATTACKABLE:IdEffectOp = new IdEffectOp("SET_ATTACKABLE",enumCtorKey);
      
      public static const SET_BATTLE_HUD_INDICATOR_VISIBLE:IdEffectOp = new IdEffectOp("SET_BATTLE_HUD_INDICATOR_VISIBLE",enumCtorKey);
      
      public static const MIND_DEVOUR:IdEffectOp = new IdEffectOp("MIND_DEVOUR",enumCtorKey);
      
      public static const DAMAGE_RECOURSE:IdEffectOp = new IdEffectOp("DAMAGE_RECOURSE",enumCtorKey);
      
      public static const SOUL_BOND:IdEffectOp = new IdEffectOp("SOUL_BOND",enumCtorKey);
      
      public static const TRANSFER_DAMAGE:IdEffectOp = new IdEffectOp("TRANSFER_DAMAGE",enumCtorKey);
      
      public static const PULL_TO_TILE_AOE:IdEffectOp = new IdEffectOp("PULL_TO_TILE_AOE",enumCtorKey);
      
      public static const ON_TURN_CHANGED:IdEffectOp = new IdEffectOp("ON_TURN_CHANGED",enumCtorKey);
      
      public static const SAGA_HAPPENING:IdEffectOp = new IdEffectOp("SAGA_HAPPENING",enumCtorKey);
      
      public static const SAGA_VAR:IdEffectOp = new IdEffectOp("SAGA_VAR",enumCtorKey);
      
      public static const SET_STAT:IdEffectOp = new IdEffectOp("SET_STAT",enumCtorKey);
      
      public static const WAIT_FOR_ENTITY_EVENT:IdEffectOp = new IdEffectOp("WAIT_FOR_ENTITY_EVENT",enumCtorKey);
      
      public static const SPECIAL_BORUR_MAW:IdEffectOp = new IdEffectOp("SPECIAL_BORUR_MAW",enumCtorKey);
      
      public static const SET_ALIVE:IdEffectOp = new IdEffectOp("SET_ALIVE",enumCtorKey);
       
      
      public var clazz:Class;
      
      public var defClazz:Class;
      
      private var _schema:Object;
      
      public function IdEffectOp(param1:String, param2:Object)
      {
         super(param1,param2);
      }
      
      public static function ensureRegistrations() : void
      {
         var _loc1_:IdEffectOp = null;
         for each(_loc1_ in getVector(IdEffectOp))
         {
            if(_loc1_.clazz == null)
            {
               throw new IllegalOperationError("IdEffectOp Did not register " + _loc1_);
            }
         }
      }
      
      public function get schema() : Object
      {
         if(!this._schema)
         {
            this._schema = this.clazz["schema"];
         }
         return this._schema;
      }
      
      public function register(param1:Class, param2:Class) : void
      {
         if(!param2 || !param1)
         {
            throw new ArgumentError("No... need not be non-null");
         }
         this.defClazz = param2;
         this.clazz = param1;
      }
   }
}

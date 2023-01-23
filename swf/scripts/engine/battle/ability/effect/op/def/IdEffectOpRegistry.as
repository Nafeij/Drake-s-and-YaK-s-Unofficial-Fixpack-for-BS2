package engine.battle.ability.effect.op.def
{
   import engine.battle.ability.effect.op.model.Op_AddTag;
   import engine.battle.ability.effect.op.model.Op_AdjacentArmorBonus;
   import engine.battle.ability.effect.op.model.Op_ArcLightningAoe;
   import engine.battle.ability.effect.op.model.Op_Aura;
   import engine.battle.ability.effect.op.model.Op_AwardRenown;
   import engine.battle.ability.effect.op.model.Op_BatteringRam;
   import engine.battle.ability.effect.op.model.Op_BloodyFlail;
   import engine.battle.ability.effect.op.model.Op_BreakArm;
   import engine.battle.ability.effect.op.model.Op_ChangeStat;
   import engine.battle.ability.effect.op.model.Op_DamageRecourse;
   import engine.battle.ability.effect.op.model.Op_DamageStr;
   import engine.battle.ability.effect.op.model.Op_EndTurn;
   import engine.battle.ability.effect.op.model.Op_ExecAbility;
   import engine.battle.ability.effect.op.model.Op_ExpireEffects;
   import engine.battle.ability.effect.op.model.Op_FlashVisible;
   import engine.battle.ability.effect.op.model.Op_FreeTurn;
   import engine.battle.ability.effect.op.model.Op_HeavyImpactDamage;
   import engine.battle.ability.effect.op.model.Op_Initiative;
   import engine.battle.ability.effect.op.model.Op_IntStatMod;
   import engine.battle.ability.effect.op.model.Op_KindleKnockback;
   import engine.battle.ability.effect.op.model.Op_Knockback;
   import engine.battle.ability.effect.op.model.Op_MindDevour;
   import engine.battle.ability.effect.op.model.Op_MoveTeleport;
   import engine.battle.ability.effect.op.model.Op_MoveToRange;
   import engine.battle.ability.effect.op.model.Op_Needle;
   import engine.battle.ability.effect.op.model.Op_NoneAdjacent;
   import engine.battle.ability.effect.op.model.Op_OnTurnChanged;
   import engine.battle.ability.effect.op.model.Op_Pillage;
   import engine.battle.ability.effect.op.model.Op_PlaceTileTrigger;
   import engine.battle.ability.effect.op.model.Op_PossessEntity;
   import engine.battle.ability.effect.op.model.Op_PullToTileAoe;
   import engine.battle.ability.effect.op.model.Op_RemovePassive;
   import engine.battle.ability.effect.op.model.Op_RemoveTag;
   import engine.battle.ability.effect.op.model.Op_ResurrectEntity;
   import engine.battle.ability.effect.op.model.Op_Retarget;
   import engine.battle.ability.effect.op.model.Op_RunThrough;
   import engine.battle.ability.effect.op.model.Op_Runaway;
   import engine.battle.ability.effect.op.model.Op_SagaHappening;
   import engine.battle.ability.effect.op.model.Op_SagaVar;
   import engine.battle.ability.effect.op.model.Op_SetAlive;
   import engine.battle.ability.effect.op.model.Op_SetAllUnitStat;
   import engine.battle.ability.effect.op.model.Op_SetAnimLayer;
   import engine.battle.ability.effect.op.model.Op_SetAttackable;
   import engine.battle.ability.effect.op.model.Op_SetBattleHudIndicatorVisible;
   import engine.battle.ability.effect.op.model.Op_SetFacing;
   import engine.battle.ability.effect.op.model.Op_SetIncorporeal;
   import engine.battle.ability.effect.op.model.Op_SetStat;
   import engine.battle.ability.effect.op.model.Op_SetSubmerged;
   import engine.battle.ability.effect.op.model.Op_SetTraversable;
   import engine.battle.ability.effect.op.model.Op_SetVisible;
   import engine.battle.ability.effect.op.model.Op_ShieldSmashDamage;
   import engine.battle.ability.effect.op.model.Op_SlagAndBurnTileCross;
   import engine.battle.ability.effect.op.model.Op_SoulBond;
   import engine.battle.ability.effect.op.model.Op_SpawnUnit;
   import engine.battle.ability.effect.op.model.Op_SpecialBorurMaw;
   import engine.battle.ability.effect.op.model.Op_StopMoving;
   import engine.battle.ability.effect.op.model.Op_SuspendTarget;
   import engine.battle.ability.effect.op.model.Op_TargetAoe;
   import engine.battle.ability.effect.op.model.Op_TargetForwardArc;
   import engine.battle.ability.effect.op.model.Op_TileAOE;
   import engine.battle.ability.effect.op.model.Op_TileSpray;
   import engine.battle.ability.effect.op.model.Op_TileTrigger;
   import engine.battle.ability.effect.op.model.Op_TransferDamage;
   import engine.battle.ability.effect.op.model.Op_WaitForActionComplete;
   import engine.battle.ability.effect.op.model.Op_WaitForAnyMove;
   import engine.battle.ability.effect.op.model.Op_WaitForChangeStat;
   import engine.battle.ability.effect.op.model.Op_WaitForCollision;
   import engine.battle.ability.effect.op.model.Op_WaitForDamageStr;
   import engine.battle.ability.effect.op.model.Op_WaitForEntityEvent;
   import engine.battle.ability.effect.op.model.Op_WaitForKill;
   import engine.battle.ability.effect.op.model.Op_WaitForMove;
   import engine.battle.ability.effect.op.model.Op_WaitForMoveFinishing;
   import engine.battle.ability.effect.op.model.Op_WaitForMoveStates;
   import engine.battle.ability.effect.op.model.Op_WaitForStartTurn;
   
   public class IdEffectOpRegistry
   {
      
      private static var registered:Boolean;
       
      
      public function IdEffectOpRegistry()
      {
         super();
      }
      
      public static function register() : void
      {
         if(registered)
         {
            return;
         }
         registered = true;
         IdEffectOp.ADJACENT_ARMOR_BONUS.register(Op_AdjacentArmorBonus,EffectDefOpVars);
         IdEffectOp.BATTERING_RAM.register(Op_BatteringRam,EffectDefOpVars);
         IdEffectOp.BLOODYFLAIL_DAMAGE.register(Op_BloodyFlail,EffectDefOpVars);
         IdEffectOp.CHANGE_STAT.register(Op_ChangeStat,EffectDefOpVars);
         IdEffectOp.DAMAGE_STR.register(Op_DamageStr,EffectDefOpVars);
         IdEffectOp.DAMAGE_ARM.register(Op_BreakArm,OpDef_DamageArm);
         IdEffectOp.END_TURN.register(Op_EndTurn,EffectDefOpVars);
         IdEffectOp.EXEC_ABILITY.register(Op_ExecAbility,OpDef_ExecAbility);
         IdEffectOp.EXPIRE_EFFECTS.register(Op_ExpireEffects,EffectDefOpVars);
         IdEffectOp.HEAVYIMPACT_DAMAGE.register(Op_HeavyImpactDamage,EffectDefOpVars);
         IdEffectOp.INITIATIVE.register(Op_Initiative,EffectDefOpVars);
         IdEffectOp.INT_STAT_MOD.register(Op_IntStatMod,EffectDefOpVars);
         IdEffectOp.POSSESS_ENTITY.register(Op_PossessEntity,EffectDefOpVars);
         IdEffectOp.RESURRECT_ENTITY.register(Op_ResurrectEntity,EffectDefOpVars);
         IdEffectOp.RETARGET.register(Op_Retarget,EffectDefOpVars);
         IdEffectOp.RUN_THROUGH.register(Op_RunThrough,EffectDefOpVars);
         IdEffectOp.STOP_MOVING.register(Op_StopMoving,EffectDefOpVars);
         IdEffectOp.SUSPEND_TARGET.register(Op_SuspendTarget,EffectDefOpVars);
         IdEffectOp.TILE_TRIGGER.register(Op_TileTrigger,EffectDefOpVars);
         IdEffectOp.PLACE_TILE_TRIGGER.register(Op_PlaceTileTrigger,EffectDefOpVars);
         IdEffectOp.TILE_AOE.register(Op_TileAOE,EffectDefOpVars);
         IdEffectOp.TARGET_AOE.register(Op_TargetAoe,EffectDefOpVars);
         IdEffectOp.TARGET_FORWARD_ARC.register(Op_TargetForwardArc,EffectDefOpVars);
         IdEffectOp.WAIT_FOR_ACTION_COMPLETE.register(Op_WaitForActionComplete,EffectDefOpVars);
         IdEffectOp.WAIT_FOR_DAMAGE_STR.register(Op_WaitForDamageStr,EffectDefOpVars);
         IdEffectOp.WAIT_FOR_CHANGE_STAT.register(Op_WaitForChangeStat,EffectDefOpVars);
         IdEffectOp.WAIT_FOR_START_TURN.register(Op_WaitForStartTurn,EffectDefOpVars);
         IdEffectOp.AURA.register(Op_Aura,EffectDefOpVars);
         IdEffectOp.NONE_ADJACENT.register(Op_NoneAdjacent,EffectDefOpVars);
         IdEffectOp.SLAGANDBURN_TILECROSS.register(Op_SlagAndBurnTileCross,EffectDefOpVars);
         IdEffectOp.MOVE_TO_RANGE.register(Op_MoveToRange,EffectDefOpVars);
         IdEffectOp.RUNAWAY.register(Op_Runaway,EffectDefOpVars);
         IdEffectOp.WAIT_FOR_KILL.register(Op_WaitForKill,EffectDefOpVars);
         IdEffectOp.KINDLE_KNOCKBACK.register(Op_KindleKnockback,EffectDefOpVars);
         IdEffectOp.KNOCKBACK.register(Op_Knockback,EffectDefOpVars);
         IdEffectOp.NEEDLE.register(Op_Needle,EffectDefOpVars);
         IdEffectOp.SPAWN.register(Op_SpawnUnit,EffectDefOpVars);
         IdEffectOp.WAIT_FOR_MOVE.register(Op_WaitForMove,EffectDefOpVars);
         IdEffectOp.ADD_TAG.register(Op_AddTag,EffectDefOpVars);
         IdEffectOp.REMOVE_TAG.register(Op_RemoveTag,EffectDefOpVars);
         IdEffectOp.ARC_LIGHTNING_AOE.register(Op_ArcLightningAoe,EffectDefOpVars);
         IdEffectOp.SET_ALL_UNIT_STAT.register(Op_SetAllUnitStat,EffectDefOpVars);
         IdEffectOp.AWARD_RENOWN.register(Op_AwardRenown,EffectDefOpVars);
         IdEffectOp.SET_ANIM_LAYER.register(Op_SetAnimLayer,EffectDefOpVars);
         IdEffectOp.SHIELD_SMASH_DAMAGE.register(Op_ShieldSmashDamage,EffectDefOpVars);
         IdEffectOp.REMOVE_PASSIVE.register(Op_RemovePassive,EffectDefOpVars);
         IdEffectOp.PILLAGE.register(Op_Pillage,EffectDefOpVars);
         IdEffectOp.WAIT_FOR_ANY_MOVE.register(Op_WaitForAnyMove,EffectDefOpVars);
         IdEffectOp.WAIT_FOR_MOVE_FINISHING.register(Op_WaitForMoveFinishing,EffectDefOpVars);
         IdEffectOp.WAIT_FOR_MOVE_STATES.register(Op_WaitForMoveStates,EffectDefOpVars);
         IdEffectOp.TILE_SPRAY.register(Op_TileSpray,EffectDefOpVars);
         IdEffectOp.SET_TRAVERSABLE.register(Op_SetTraversable,EffectDefOpVars);
         IdEffectOp.SET_INCORPOREAL.register(Op_SetIncorporeal,EffectDefOpVars);
         IdEffectOp.SET_SUBMERGED.register(Op_SetSubmerged,EffectDefOpVars);
         IdEffectOp.SET_FACING.register(Op_SetFacing,EffectDefOpVars);
         IdEffectOp.SET_VISIBLE.register(Op_SetVisible,EffectDefOpVars);
         IdEffectOp.FLASH_VISIBLE.register(Op_FlashVisible,EffectDefOpVars);
         IdEffectOp.MOVE_TELEPORT.register(Op_MoveTeleport,EffectDefOpVars);
         IdEffectOp.WAIT_FOR_COLLISION.register(Op_WaitForCollision,EffectDefOpVars);
         IdEffectOp.FREE_TURN.register(Op_FreeTurn,EffectDefOpVars);
         IdEffectOp.SET_ATTACKABLE.register(Op_SetAttackable,EffectDefOpVars);
         IdEffectOp.SET_BATTLE_HUD_INDICATOR_VISIBLE.register(Op_SetBattleHudIndicatorVisible,EffectDefOpVars);
         IdEffectOp.MIND_DEVOUR.register(Op_MindDevour,EffectDefOpVars);
         IdEffectOp.DAMAGE_RECOURSE.register(Op_DamageRecourse,EffectDefOpVars);
         IdEffectOp.SOUL_BOND.register(Op_SoulBond,EffectDefOpVars);
         IdEffectOp.TRANSFER_DAMAGE.register(Op_TransferDamage,EffectDefOpVars);
         IdEffectOp.PULL_TO_TILE_AOE.register(Op_PullToTileAoe,EffectDefOpVars);
         IdEffectOp.SAGA_HAPPENING.register(Op_SagaHappening,EffectDefOpVars);
         IdEffectOp.SAGA_VAR.register(Op_SagaVar,EffectDefOpVars);
         IdEffectOp.SET_STAT.register(Op_SetStat,EffectDefOpVars);
         IdEffectOp.WAIT_FOR_ENTITY_EVENT.register(Op_WaitForEntityEvent,EffectDefOpVars);
         IdEffectOp.ON_TURN_CHANGED.register(Op_OnTurnChanged,EffectDefOpVars);
         IdEffectOp.SPECIAL_BORUR_MAW.register(Op_SpecialBorurMaw,EffectDefOpVars);
         IdEffectOp.SET_ALIVE.register(Op_SetAlive,EffectDefOpVars);
         IdEffectOp.ensureRegistrations();
      }
   }
}

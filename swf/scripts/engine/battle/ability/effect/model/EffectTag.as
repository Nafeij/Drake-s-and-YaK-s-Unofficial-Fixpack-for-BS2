package engine.battle.ability.effect.model
{
   import engine.core.util.Enum;
   
   public class EffectTag extends Enum
   {
      
      public static const DAMAGED_ARM:EffectTag = new EffectTag("DAMAGED_ARM",enumCtorKey);
      
      public static const DAMAGED_STR:EffectTag = new EffectTag("DAMAGED_STR",enumCtorKey);
      
      public static const DAMAGED_WIL:EffectTag = new EffectTag("DAMAGED_WIL",enumCtorKey);
      
      public static const NEGATIVE:EffectTag = new EffectTag("NEGATIVE",enumCtorKey);
      
      public static const KILLING:EffectTag = new EffectTag("KILLING",enumCtorKey);
      
      public static const RESISTING_STRENGTH:EffectTag = new EffectTag("RESISTING_STRENGTH",enumCtorKey);
      
      public static const RESISTING_ARMOR:EffectTag = new EffectTag("RESISTING_ARMOR",enumCtorKey);
      
      public static const RESISTING_WILLPOWER:EffectTag = new EffectTag("RESISTING_WILLPOWER",enumCtorKey);
      
      public static const DIVERTING:EffectTag = new EffectTag("DIVERTING",enumCtorKey);
      
      public static const KILL_STOP:EffectTag = new EffectTag("KILL_STOP",enumCtorKey);
      
      public static const IMMORTAL_STOPPED:EffectTag = new EffectTag("IMMORTAL_STOPPED",enumCtorKey);
      
      public static const ABSORBING:EffectTag = new EffectTag("ABSORBING",enumCtorKey);
      
      public static const CRIT:EffectTag = new EffectTag("CRIT",enumCtorKey);
      
      public static const DODGE:EffectTag = new EffectTag("DODGE",enumCtorKey);
      
      public static const NO_FAKING:EffectTag = new EffectTag("NO_FAKING",enumCtorKey);
      
      public static const TEMPEST:EffectTag = new EffectTag("TEMPEST",enumCtorKey);
      
      public static const POSSESSED_MOVE:EffectTag = new EffectTag("POSSESSED_MOVE",enumCtorKey);
      
      public static const NO_RETALIATE:EffectTag = new EffectTag("NO_RETALIATE",enumCtorKey);
      
      public static const NO_BEAR_RAGE:EffectTag = new EffectTag("NO_BEAR_RAGE",enumCtorKey);
      
      public static const MOVED_THIS_TURN:EffectTag = new EffectTag("MOVED_THIS_TURN",enumCtorKey);
      
      public static const SPECIAL_SUNDERINGIMPACT_ACTIVE:EffectTag = new EffectTag("SPECIAL_SUNDERINGIMPACT_ACTIVE",enumCtorKey);
      
      public static const SPECIAL_BRINGTHEPAIN_ACTIVE:EffectTag = new EffectTag("SPECIAL_BRINGTHEPAIN_ACTIVE",enumCtorKey);
      
      public static const SPECIAL_PUNCTURE_BONUS:EffectTag = new EffectTag("SPECIAL_PUNCTURE_BONUS",enumCtorKey);
      
      public static const FLAMMABLE:EffectTag = new EffectTag("FLAMMABLE",enumCtorKey);
      
      public static const ONFIRE:EffectTag = new EffectTag("ONFIRE",enumCtorKey);
      
      public static const DEFLECT:EffectTag = new EffectTag("DEFLECT",enumCtorKey);
      
      public static const MALICE_RESPONSE:EffectTag = new EffectTag("MALICE_RESPONSE",enumCtorKey);
      
      public static const SPLINTER_RESPONSE:EffectTag = new EffectTag("SPLINTER_RESPONSE",enumCtorKey);
      
      public static const KNOCKBACK_SOMEWHERE:EffectTag = new EffectTag("KNOCKBACK_SOMEWHERE",enumCtorKey);
      
      public static const BACKOFF_IGNORE:EffectTag = new EffectTag("BACKOFF_IGNORE",enumCtorKey);
      
      public static const BACKOFFS:EffectTag = new EffectTag("BACKOFFS",enumCtorKey);
      
      public static const BACKOFF_TRIGGER:EffectTag = new EffectTag("BACKOFF_TRIGGER",enumCtorKey);
      
      public static const LIGHT_STEPPING:EffectTag = new EffectTag("LIGHT_STEPPING",enumCtorKey);
      
      public static const KING_STEPPING:EffectTag = new EffectTag("KING_STEPPING",enumCtorKey);
      
      public static const KING_STEPPABLE:EffectTag = new EffectTag("KING_STEPPABLE",enumCtorKey);
      
      public static const EXTRA_MOVE:EffectTag = new EffectTag("EXTRA_MOVE",enumCtorKey);
      
      public static const TREMBLED:EffectTag = new EffectTag("TREMBLED",enumCtorKey);
      
      public static const DISEASED:EffectTag = new EffectTag("DISEASED",enumCtorKey);
      
      public static const STUNNED:EffectTag = new EffectTag("STUNNED",enumCtorKey);
      
      public static const ROOTED:EffectTag = new EffectTag("ROOTED",enumCtorKey);
      
      public static const FRENZY:EffectTag = new EffectTag("FRENZY",enumCtorKey);
      
      public static const BELLOWER:EffectTag = new EffectTag("BELLOWER",enumCtorKey);
      
      public static const RANAWAY:EffectTag = new EffectTag("RANAWAY",enumCtorKey);
      
      public static const SHIELD_SMASH_IMMUNE:EffectTag = new EffectTag("SHIELD_SMASH_IMMUNE",enumCtorKey);
      
      public static const ARMOR_ZEROING:EffectTag = new EffectTag("ARMOR_ZEROING",enumCtorKey);
      
      public static const UNPOSSESSABLE:EffectTag = new EffectTag("UNPOSSESSABLE",enumCtorKey);
      
      public static const WARPED_POSSESSED:EffectTag = new EffectTag("WARPED_POSSESSED",enumCtorKey);
      
      public static const EYELESS:EffectTag = new EffectTag("EYELESS",enumCtorKey);
      
      public static const SOUL_BOUND:EffectTag = new EffectTag("SOUL_BOUND",enumCtorKey);
      
      public static const HAS_DAMAGE_RECOURSE_TARGET:EffectTag = new EffectTag("HAS_DAMAGE_RECOURSE_TARGET",enumCtorKey);
      
      public static const IS_DAMAGE_RECOURSE_TARGET:EffectTag = new EffectTag("IS_DAMAGE_RECOURSE_TARGET",enumCtorKey);
      
      public static const NO_ROTATE_ON_HIT:EffectTag = new EffectTag("NO_ROTATE_ON_HIT",enumCtorKey);
      
      public static const SPLINTERS:EffectTag = new EffectTag("SPLINTERS",enumCtorKey);
      
      public static const BEAR_OUT:EffectTag = new EffectTag("BEAR_OUT",enumCtorKey);
      
      public static const TRACK_ATTACK:EffectTag = new EffectTag("TRACK_ATTACK",enumCtorKey);
      
      public static const TRACK_BREAKING_CASTER:EffectTag = new EffectTag("TRACK_BREAKING_CASTER",enumCtorKey);
      
      public static const TRACKING:EffectTag = new EffectTag("TRACKING",enumCtorKey);
      
      public static const HEAVYIMPACT_IGNORE:EffectTag = new EffectTag("HEAVYIMPACT_IGNORE",enumCtorKey);
      
      public static const TRANSFER_DAMAGE_IGNORE:EffectTag = new EffectTag("TRANSFER_DAMAGE_IGNORE",enumCtorKey);
      
      public static const NO_KNOCKBACK:EffectTag = new EffectTag("NO_KNOCKBACK",enumCtorKey);
      
      public static const FRENZY2:EffectTag = new EffectTag("FRENZY2",enumCtorKey);
      
      public static const ICE_COLUMN:EffectTag = new EffectTag("ICE_COLUMN",enumCtorKey);
      
      public static const DYTCH_STUCK:EffectTag = new EffectTag("DYTCH_STUCK",enumCtorKey);
      
      public static const DISABLE_MOVE:EffectTag = new EffectTag("DISABLE_MOVE",enumCtorKey);
      
      public static const DOTTED:EffectTag = new EffectTag("DOTTED",enumCtorKey);
      
      public static const PLAYER_DISEASED:EffectTag = new EffectTag("PLAYER_DISEASED",enumCtorKey);
      
      public static const GHOSTED:EffectTag = new EffectTag("GHOSTED",enumCtorKey);
      
      public static const GHOST_IN_PROGRESS:EffectTag = new EffectTag("GHOST_IN_PROGRESS",enumCtorKey);
      
      public static const GUARD_OUT:EffectTag = new EffectTag("GUARD_OUT",enumCtorKey);
      
      public static const TWICEBORN_FIRED:EffectTag = new EffectTag("TWICEBORN_FIRED",enumCtorKey);
      
      public static const MARKED_FOR_DEATH:EffectTag = new EffectTag("MARKED_FOR_DEATH",enumCtorKey);
      
      public static const SUPPRESS_MARKED_FOR_DEATH:EffectTag = new EffectTag("SUPPRESS_MARKED_FOR_DEATH",enumCtorKey);
      
      public static const ARTIFACT_DAMAGE:EffectTag = new EffectTag("ARTIFACT_DAMAGE",enumCtorKey);
      
      public static const WARPING:EffectTag = new EffectTag("WARPING",enumCtorKey);
      
      public static const DREDGE_SPLINTER:EffectTag = new EffectTag("DREDGE_SPLINTER",enumCtorKey);
      
      public static const BLOODY_FLAIL_STR_DAMAGE:EffectTag = new EffectTag("BLOODY_FLAIL_STR_DAMAGE",enumCtorKey);
      
      public static const END_TURN_IF_NO_ENEMIES_REMAIN:EffectTag = new EffectTag("END_TURN_IF_NO_ENEMIES_REMAIN",enumCtorKey);
      
      public static const CONFUSED:EffectTag = new EffectTag("CONFUSED",enumCtorKey);
      
      public static const SINKHOLE:EffectTag = new EffectTag("SINKHOLE",enumCtorKey);
       
      
      public function EffectTag(param1:String, param2:Object)
      {
         super(param1,param2);
      }
   }
}

package engine.stat.def
{
   import engine.core.util.Enum;
   import flash.utils.Dictionary;
   
   public class StatType extends Enum
   {
      
      public static var DEBUG_INJURY:Boolean;
      
      public static const STRENGTH:StatType = new StatType("STRENGTH","STR",true,enumCtorKey,12070400,12061440);
      
      public static const ARMOR:StatType = new StatType("ARMOR","ARM",true,enumCtorKey,4687319,19651);
      
      public static const WILLPOWER:StatType = new StatType("WILLPOWER","WIL",true,enumCtorKey,13281836,15776512);
      
      public static const MOVEMENT:StatType = new StatType("MOVEMENT","MOV",false,enumCtorKey);
      
      public static const EXERTION:StatType = new StatType("EXERTION","EXE",true,enumCtorKey,5480001,4423716);
      
      public static const KILLS:StatType = new StatType("KILLS","KIL",true,enumCtorKey);
      
      public static const BATTLES:StatType = new StatType("BATTLES","BAT",false,enumCtorKey);
      
      public static const ARMOR_BREAK:StatType = new StatType("ARMOR_BREAK","ABK",true,enumCtorKey,8828094,1863880);
      
      public static const STRENGTH_ATTACK:StatType = new StatType("STRENGTH_ATTACK","SAK",true,enumCtorKey);
      
      public static const MIN_STRENGTH_ATTACK:StatType = new StatType("MIN_STRENGTH_ATTACK","MSA",true,enumCtorKey);
      
      public static const PUNCTURE_CHANCE:StatType = new StatType("PUNCTURE_CHANCE","PCH",true,enumCtorKey);
      
      public static const PUNCTURE_ATTACK_BONUS:StatType = new StatType("PUNCTURE_ATTACK_BONUS","PAB",true,enumCtorKey);
      
      public static const MALICE_ATTACK_BONUS:StatType = new StatType("MALICE_ATTACK_BONUS","MAB",true,enumCtorKey);
      
      public static const BRINGTHEPAIN_COUNTER_BONUS:StatType = new StatType("BRINGTHEPAIN_COUNTER_BONUS","BCB",true,enumCtorKey);
      
      public static const FAKE_MISS_CHANCE:StatType = new StatType("FAKE_MISS_CHANCE","FMC",false,enumCtorKey);
      
      public static const RANK:StatType = new StatType("RANK","RNK",false,enumCtorKey);
      
      public static const MASTER_ABILITY_SUNDERING_IMPACT:StatType = new StatType("MASTER_ABILITY_SUNDERING_IMPACT","SUI",true,enumCtorKey);
      
      public static const RESIST_STRENGTH:StatType = new StatType("RESIST_STRENGTH","RST",true,enumCtorKey);
      
      public static const RESIST_ARMOR:StatType = new StatType("RESIST_ARMOR","RAR",true,enumCtorKey);
      
      public static const RESIST_WILLPOWER:StatType = new StatType("RESIST_WILLPOWER","RWP",true,enumCtorKey);
      
      public static const NEVER_MISS:StatType = new StatType("NEVER_MISS","NVM",true,enumCtorKey);
      
      public static const ALWAYS_MISS:StatType = new StatType("ALWAYS_MISS","AWM",true,enumCtorKey);
      
      public static const INJURY_DAYS:StatType = new StatType("INJURY_DAYS","IJD",true,enumCtorKey);
      
      public static const INJURY:StatType = new StatType("INJURY","INJ",true,enumCtorKey);
      
      public static const ARMOR_NEGATION:StatType = new StatType("ARMOR_NEGATION","ANG",true,enumCtorKey);
      
      public static const DAMAGE_ABSORPTION_SHIELD:StatType = new StatType("DAMAGE_ABSORPTION_SHIELD","DAS",true,enumCtorKey);
      
      public static const RANGEMOD_MELEE:StatType = new StatType("RANGEMOD_MELEE","RMM",false,enumCtorKey);
      
      public static const RANGEMOD_RANGED:StatType = new StatType("RANGEMOD_RANGED","RMR",false,enumCtorKey);
      
      public static const RANGEMOD_GLOBAL:StatType = new StatType("RANGEMOD_GLOBAL","RMG",false,enumCtorKey);
      
      public static const KILL_WILLPOWER:StatType = new StatType("KILL_WILLPOWER","KWI",false,enumCtorKey);
      
      public static const KILL_STR:StatType = new StatType("KILL_STR","KST",false,enumCtorKey);
      
      public static const DODGE_BONUS:StatType = new StatType("DODGE_BONUS","DDG",false,enumCtorKey);
      
      public static const DIVERT_CHANCE:StatType = new StatType("DIVERT_CHANCE","DVT",false,enumCtorKey);
      
      public static const AI_AGGRO_MOD:StatType = new StatType("AI_AGGRO_MOD","AIA",false,enumCtorKey);
      
      public static const AI_IGNORE:StatType = new StatType("AI_IGNORE","AIG",false,enumCtorKey);
      
      public static const REGEN_WILLPOWER:StatType = new StatType("REGEN_WILLPOWER","RGW",false,enumCtorKey);
      
      public static const REGEN_ARMOR:StatType = new StatType("REGEN_ARMOR","RGA",false,enumCtorKey);
      
      public static const REGEN_STR:StatType = new StatType("REGEN_STR","RES",false,enumCtorKey);
      
      public static const REST_WILLPOWER:StatType = new StatType("REST_WILLPOWER","REW",false,enumCtorKey);
      
      public static const REST_ARMOR:StatType = new StatType("REST_ARMOR","REA",false,enumCtorKey);
      
      public static const CRIT_CHANCE:StatType = new StatType("CRIT_CHANCE","CRT",false,enumCtorKey);
      
      public static const KILL_STOP:StatType = new StatType("KILL_STOP","KSP",false,enumCtorKey);
      
      public static const KNOCKBACK_STR:StatType = new StatType("KNOCKBACK_STR","KBS",false,enumCtorKey);
      
      public static const KNOCKBACK_DEFERRED:StatType = new StatType("KNOCKBACK_DEFERRED","KBD",false,enumCtorKey);
      
      public static const BASE_UPGRADES:StatType = new StatType("BASE_UPGRADES","BUP",false,enumCtorKey);
      
      public static const IMMORTAL:StatType = new StatType("IMMORTAL","IMM",false,enumCtorKey);
      
      public static const TWICEBORN:StatType = new StatType("TWICEBORN","TWB",false,enumCtorKey);
      
      public static const WILLPOWER_MOVE:StatType = new StatType("WILLPOWER_MOVE","WPM",false,enumCtorKey);
      
      public static const MISS_CHANCE_OVERRIDE:StatType = new StatType("MISS_CHANCE_OVERRIDE","MCO",false,enumCtorKey);
      
      public static const MISS_CHANCE_MINIMUM:StatType = new StatType("MISS_CHANCE_MINIMUM","MCM",false,enumCtorKey);
      
      public static const HIT_CHANCE_BONUS:StatType = new StatType("HIT_CHANCE_BONUS","HCB",false,enumCtorKey);
      
      public static const DAMAGE_REDUCTION:StatType = new StatType("DAMAGE_REDUCTION","DMR",true,enumCtorKey);
      
      public static const ARC_LIGHTNING_DEPTH:StatType = new StatType("ARC_LIGHTNING_DEPTH","SLD",false,enumCtorKey);
      
      public static const SPLINTER_DEPTH:StatType = new StatType("SPLINTER_DEPTH","SPD",false,enumCtorKey);
      
      public static const ARMOR_ABSORPTION:StatType = new StatType("ARMOR_ABSORPTION","AAB",false,enumCtorKey);
      
      public static const WILLPOWER_ABSORPTION:StatType = new StatType("WILLPOWER_ABSORPTION","WAB",false,enumCtorKey);
      
      public static const UNDERDOG_BONUS:StatType = new StatType("UNDERDOG_BONUS","UBN",false,enumCtorKey);
      
      public static const SHIELD_SMASH_DAMAGE:StatType = new StatType("SHIELD_SMASH_DAMAGE","SSD",false,enumCtorKey);
      
      public static const RUNTHROUGH_DISTANCE:StatType = new StatType("RUNTHROUGH_DISTANCE","RTD",false,enumCtorKey);
      
      public static const TRANSFER_DAMAGE_COUNT:StatType = new StatType("TRANSFER_DAMAGE_COUNT","TDC",false,enumCtorKey);
      
      public static const TRANSFER_DAMAGE_AMOUNT:StatType = new StatType("TRANSFER_DAMAGE_AMOUNT","TDA",false,enumCtorKey);
      
      public static const RESIST_STRENGTH_DREDGE:StatType = new StatType("RESIST_STRENGTH_DREDGE","RSD",false,enumCtorKey);
      
      public static const STRENGTH_BONUS_DREDGE:StatType = new StatType("STRENGTH_BONUS_DREDGE","SBD",false,enumCtorKey);
      
      public static const STRENGTH_BONUS_MARKED_FOR_DEATH:StatType = new StatType("STRENGTH_BONUS_MARKED_FOR_DEATH","MFD",false,enumCtorKey);
      
      public static const DISABLE_MOVE:StatType = new StatType("DISABLE_MOVE","DSM",false,enumCtorKey);
      
      public static const TITLE_RANK:StatType = new StatType("TITLE_RANK","TTR",false,enumCtorKey);
      
      public static const TAL_BONUS_ARM:StatType = new StatType("TAL_BONUS_ARM","TBA",true,enumCtorKey);
      
      public static const TAL_BONUS_STR:StatType = new StatType("TAL_BONUS_STR","TBS",true,enumCtorKey);
      
      public static const TAL_BONUS_WIL:StatType = new StatType("TAL_BONUS_WIL","TBW",true,enumCtorKey);
      
      public static const TAL_BONUS_EXE:StatType = new StatType("TAL_BONUS_EXE","TBE",true,enumCtorKey);
      
      public static const TAL_BONUS_BRK:StatType = new StatType("TAL_BONUS_BRK","TBB",true,enumCtorKey);
      
      public static const TAL_BONUS_ALL:StatType = new StatType("TAL_BONUS_ALL","TBL",true,enumCtorKey);
      
      public static const WEAVED_ENERGY_NEXT:StatType = new StatType("WEAVED_ENERGY_NEXT","WEX",false,enumCtorKey);
      
      private static var abbrevs:Dictionary;
       
      
      public var volatile:Boolean;
      
      public var abbrev:String;
      
      public var abbrev_lower:String;
      
      public var color:uint;
      
      public var brightColor:uint;
      
      public function StatType(param1:String, param2:String, param3:Boolean, param4:Object, param5:uint = 16777215, param6:uint = 16777215)
      {
         super(param1,param4);
         if(!abbrevs)
         {
            abbrevs = new Dictionary();
         }
         this.color = param5;
         this.brightColor = param6;
         var _loc7_:StatType = abbrevs[param2];
         if(_loc7_)
         {
            throw new ArgumentError("StatType re-use abbrev " + param2 + " from " + _loc7_ + " to " + param1);
         }
         abbrevs[param2] = this;
         this.abbrev = param2;
         this.abbrev_lower = param2.toLowerCase();
         this.volatile = param3;
      }
      
      public function get allowNegative() : Boolean
      {
         if(this == ARMOR || this == EXERTION || this == MOVEMENT || this == WILLPOWER)
         {
            return false;
         }
         return true;
      }
      
      public function get upgradeable() : Boolean
      {
         return this == ARMOR || this == EXERTION || this == STRENGTH || this == ARMOR_BREAK || this == WILLPOWER;
      }
   }
}

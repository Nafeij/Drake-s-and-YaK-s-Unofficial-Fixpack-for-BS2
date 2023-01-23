package engine.entity.def
{
   import engine.ability.IAbilityDef;
   import engine.ability.IAbilityDefLevel;
   import engine.ability.IAbilityDefLevels;
   import engine.battle.ability.effect.model.EffectTag;
   import engine.battle.board.def.UsabilityDef;
   import engine.core.IId;
   import engine.core.INamed;
   import engine.core.logging.ILogger;
   import engine.entity.UnitStatCosts;
   import engine.saga.IVariableDefProvider;
   import engine.saga.vars.IVariableBag;
   import engine.stat.def.StatRanges;
   import engine.stat.model.IStatsProvider;
   import engine.talent.Talents;
   import flash.events.IEventDispatcher;
   
   public interface IEntityDef extends IId, INamed, IStatsProvider, IEventDispatcher, IVariableDefProvider
   {
       
      
      function get entityClass() : IEntityClassDef;
      
      function get power() : int;
      
      function get attacks() : IAbilityDefLevels;
      
      function get actives() : IAbilityDefLevels;
      
      function get passives() : IAbilityDefLevels;
      
      function addActiveAbilityDefLevel(param1:IAbilityDefLevel, param2:ILogger) : IAbilityDefLevel;
      
      function setActiveAbilityDefLevel(param1:IAbilityDef, param2:int, param3:int, param4:ILogger) : IAbilityDefLevel;
      
      function get upgrades() : int;
      
      function get appearanceIndex() : int;
      
      function set appearanceIndex(param1:int) : void;
      
      function get appearanceId() : String;
      
      function get originalAppearanceIndex() : int;
      
      function get startDate() : Number;
      
      function duplicate(param1:String, param2:ILogger) : IEntityDef;
      
      function get additionalActives() : Vector.<String>;
      
      function isAppearanceAcquired(param1:int) : Boolean;
      
      function acquireAppearance(param1:int) : void;
      
      function readyToPromote(param1:int) : Boolean;
      
      function get appearance() : IEntityAppearanceDef;
      
      function get vars() : IVariableBag;
      
      function synchronizeToVars() : void;
      
      function get statRanges() : StatRanges;
      
      function get description() : String;
      
      function get combatant() : Boolean;
      
      function get saves() : Boolean;
      
      function get defItem() : Item;
      
      function set defItem(param1:Item) : void;
      
      function getMaxUpgrades(param1:EntitiesMetadata, param2:UnitStatCosts) : int;
      
      function get partyRequired() : Boolean;
      
      function set partyRequired(param1:Boolean) : void;
      
      function get useClassAppearanceDesc() : Boolean;
      
      function get unitVarNames() : Vector.<String>;
      
      function get talents() : Talents;
      
      function set talents(param1:Talents) : void;
      
      function get isPromotable() : Boolean;
      
      function get isUpgradeable() : Boolean;
      
      function get isSurvivalPromotable() : Boolean;
      
      function get isSurvivalDead() : Boolean;
      
      function get isSurvivalRecruited() : Boolean;
      
      function get isSurvivalRecruitable() : Boolean;
      
      function set isSurvivalRecruited(param1:Boolean) : void;
      
      function get survivalRecruitCostRenown() : int;
      
      function get survivalFuneralRewardRenown() : int;
      
      function get survivalFuneralRewardItemRenown() : int;
      
      function get addDifficultyStatsAsMods() : Boolean;
      
      function get tags() : Vector.<EffectTag>;
      
      function get usabilityDef() : UsabilityDef;
      
      function get isWarped() : Boolean;
      
      function get isInjured() : Boolean;
      
      function getSummaryLine() : String;
      
      function get defTitle() : ITitleDef;
      
      function set defTitle(param1:ITitleDef) : void;
      
      function get gender() : String;
   }
}

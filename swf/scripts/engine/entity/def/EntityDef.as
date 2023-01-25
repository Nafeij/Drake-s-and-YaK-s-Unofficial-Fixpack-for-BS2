package engine.entity.def
{
   import engine.ability.IAbilityDef;
   import engine.ability.IAbilityDefLevel;
   import engine.ability.IAbilityDefLevels;
   import engine.ability.def.AbilityDef;
   import engine.ability.def.AbilityDefFactory;
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.BattleAbilityDefLevels;
   import engine.battle.ability.def.BattleAbilityTag;
   import engine.battle.ability.effect.model.EffectTag;
   import engine.battle.board.def.UsabilityDef;
   import engine.core.locale.Locale;
   import engine.core.locale.LocaleCategory;
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   import engine.core.util.StringUtil;
   import engine.entity.UnitStatCosts;
   import engine.math.MathUtil;
   import engine.saga.Saga;
   import engine.saga.SagaVar;
   import engine.saga.vars.IVariable;
   import engine.saga.vars.IVariableBag;
   import engine.saga.vars.VariableBag;
   import engine.saga.vars.VariableDef;
   import engine.saga.vars.VariableType;
   import engine.stat.def.StatRange;
   import engine.stat.def.StatRanges;
   import engine.stat.def.StatType;
   import engine.stat.model.Stat;
   import engine.stat.model.Stats;
   import engine.talent.Talents;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class EntityDef extends EventDispatcher implements IEntityDef
   {
      
      private static var speakingRaces:Array = ["human","varl","horseborn"];
       
      
      protected var _id:String;
      
      protected var _name:String;
      
      protected var _entityClass:IEntityClassDef;
      
      protected var _stats:Stats;
      
      protected var _actives:IAbilityDefLevels = null;
      
      protected var _attacks:IAbilityDefLevels = null;
      
      protected var _passives:IAbilityDefLevels = null;
      
      protected var _appearanceIndex:int = 0;
      
      protected var _startDate:Number = 0;
      
      protected var _nameToken:String;
      
      protected var _descriptionToken:String;
      
      protected var _description:String;
      
      protected var _appearance_acquires:int = 0;
      
      protected var _appearance:EntityAppearanceDef;
      
      protected var _vars:VariableBag;
      
      public var _additionalActives:Vector.<String>;
      
      protected var _combatant:Boolean = true;
      
      protected var _saves:Boolean = true;
      
      protected var _overrideStatRanges:StatRanges;
      
      protected var _item:Item;
      
      protected var _heroicTitle:ITitleDef;
      
      protected var _heroicTitleRank:int = 0;
      
      protected var _useClassAppearanceDesc:Boolean;
      
      protected var _useClassAppearanceName:Boolean;
      
      protected var _unitVarNames:Vector.<String>;
      
      private var _unitVarNamesCache:Dictionary;
      
      protected var _isSurvivalRecruited:Boolean;
      
      public var _addDifficultyStatsAsMods:Boolean;
      
      protected var _usabilityDef:UsabilityDef;
      
      protected var _talents:Talents;
      
      public var locale:Locale;
      
      public var _originalAppearanceIndex:int = -1;
      
      public var spawner:Boolean;
      
      protected var _tags:Vector.<EffectTag>;
      
      protected var _isWarped:Boolean;
      
      private var nameFromClass:Boolean;
      
      public function EntityDef(param1:Locale)
      {
         super();
         this.locale = param1;
         this._stats = new Stats(this,true);
      }
      
      public static function canSpeak(param1:IEntityDef) : Boolean
      {
         if(!param1 || !param1.entityClass || !param1.entityClass.race)
         {
            return false;
         }
         if(speakingRaces.indexOf(param1.entityClass.race) > 0)
         {
            return true;
         }
         return false;
      }
      
      public function get tags() : Vector.<EffectTag>
      {
         return this._tags;
      }
      
      override public function toString() : String
      {
         return this._id;
      }
      
      public function get startDate() : Number
      {
         return this._startDate;
      }
      
      public function set startDate(param1:Number) : void
      {
         this._startDate = param1;
      }
      
      public function duplicate(param1:String, param2:ILogger) : IEntityDef
      {
         var _loc3_:EntityDef = new EntityDef(this.locale);
         _loc3_._id = param1;
         param2.debug("EntityDef ctor duplicated [" + param1 + "]");
         this.updateAbilityDefLevelsNames();
         _loc3_._name = this._name;
         _loc3_._entityClass = this._entityClass;
         _loc3_._stats = this._stats.clone(this);
         _loc3_._actives = !!this._actives ? this._actives.clone(param2) : null;
         _loc3_._attacks = !!this._attacks ? this._attacks.clone(param2) : null;
         _loc3_._passives = !!this._passives ? this._passives.clone(param2) : null;
         _loc3_._startDate = this._startDate;
         _loc3_._unitVarNames = !!this._unitVarNames ? this._unitVarNames.concat() : null;
         _loc3_._unitVarNamesCache = null;
         if(this._appearance)
         {
            _loc3_._appearance = this._appearance.clone() as EntityAppearanceDef;
         }
         _loc3_._appearanceIndex = this._appearanceIndex;
         if(this._overrideStatRanges)
         {
            _loc3_._overrideStatRanges = this._overrideStatRanges.clone();
         }
         return _loc3_;
      }
      
      public function get entityClass() : IEntityClassDef
      {
         return this._entityClass;
      }
      
      public function set entityClass(param1:IEntityClassDef) : void
      {
         if(!param1 || param1 == this._entityClass)
         {
            return;
         }
         this._entityClass = param1;
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      protected function updateAbilityDefLevelsNames() : void
      {
         if(this._actives)
         {
            this._actives.name = this._id;
         }
         if(this._attacks)
         {
            this._attacks.name = this._id;
         }
         if(this._passives)
         {
            this._passives.name = this._id;
         }
      }
      
      public function set id(param1:String) : void
      {
         this._id = param1;
         this.updateAbilityDefLevelsNames();
         this._nameToken = this.makeNameToken();
         this._descriptionToken = this.makeDescriptionToken();
         this.localizeName();
         this.localizeDescription();
      }
      
      public function get name() : String
      {
         if(this._useClassAppearanceName)
         {
            return this._entityClass.getAppearanceName(this._appearanceIndex);
         }
         return !!this._name ? this._name : this.id;
      }
      
      public function get description() : String
      {
         if(this._useClassAppearanceDesc)
         {
            return this._entityClass.getAppearanceDesc(this._appearanceIndex);
         }
         return this._description;
      }
      
      public function get nameToken() : String
      {
         return this._nameToken;
      }
      
      public function get descriptionToken() : String
      {
         return this._descriptionToken;
      }
      
      public function makeNameToken() : String
      {
         return "ent_" + this.id;
      }
      
      public function makeDescriptionToken() : String
      {
         return "ent_" + this.id + "_desc";
      }
      
      public function set localizedName(param1:String) : void
      {
         this._name = null;
         if(param1)
         {
            this._nameToken = this.makeNameToken();
            this.locale.getLocalizer(LocaleCategory.ENTITY).setValue(this._nameToken,param1);
         }
         else
         {
            this._nameToken = null;
         }
         this.localizeName();
      }
      
      public function set localizedDescription(param1:String) : void
      {
         if(param1)
         {
            this._descriptionToken = this.makeDescriptionToken();
            this.locale.getLocalizer(LocaleCategory.ENTITY).setValue(this._descriptionToken,param1);
         }
         else
         {
            this._descriptionToken = null;
         }
         this.localizeDescription();
      }
      
      public function set name(param1:String) : void
      {
         this._name = param1;
      }
      
      public function get stats() : Stats
      {
         return this._stats;
      }
      
      public function get power() : int
      {
         return this.stats.totalPower;
      }
      
      public function get addDifficultyStatsAsMods() : Boolean
      {
         return this._addDifficultyStatsAsMods;
      }
      
      public function get appearanceIndex() : int
      {
         return this._appearanceIndex;
      }
      
      public function set appearanceIndex(param1:int) : void
      {
         if(this._appearanceIndex != param1)
         {
            this._appearanceIndex = param1;
            this._appearance_acquires != 1 << param1;
            dispatchEvent(new EntityDefEvent(EntityDefEvent.APPEARANCE,this));
         }
      }
      
      public function get appearanceId() : String
      {
         var _loc1_:IEntityAppearanceDef = this.appearance;
         return !!_loc1_ ? _loc1_.id : "none";
      }
      
      public function get appearance() : IEntityAppearanceDef
      {
         if(this._appearance)
         {
            return this._appearance;
         }
         return this.classAppearance;
      }
      
      public function get classAppearance() : IEntityAppearanceDef
      {
         return !!this._entityClass ? this._entityClass.getEntityClassAppearanceDef(this.appearanceIndex) : null;
      }
      
      public function get overrideAppearance() : IEntityAppearanceDef
      {
         return this._appearance;
      }
      
      public function set overrideAppearance(param1:IEntityAppearanceDef) : void
      {
         if(this._appearance == param1)
         {
            return;
         }
         this._appearance = param1 as EntityAppearanceDef;
      }
      
      public function clampStats(param1:ILogger) : void
      {
         var _loc3_:Stat = null;
         var _loc4_:StatRange = null;
         if(!this._entityClass)
         {
            return;
         }
         if(!this._entityClass.playerClass)
         {
            return;
         }
         var _loc2_:int = 0;
         while(_loc2_ < this._stats.numStats)
         {
            _loc3_ = this._stats.getStatByIndex(_loc2_);
            if(!(!Stats.isUserChangedStat(_loc3_.type) && _loc3_.type != StatType.RANK))
            {
               _loc4_ = this.statRanges.getStatRange(_loc3_.type);
               if(_loc4_)
               {
                  if(_loc3_.base < _loc4_.min || _loc3_.base > _loc4_.max)
                  {
                     if(param1)
                     {
                        param1.error("EntityDef.clampStats " + this.id + " " + _loc3_.type + " " + _loc3_.base + " was out of range " + _loc4_.min + "," + _loc4_.max);
                     }
                     _loc3_.base = Math.max(_loc4_.min,Math.min(_loc4_.max,_loc3_.base));
                  }
               }
            }
            _loc2_++;
         }
      }
      
      public function applyClassStats(param1:EntitiesMetadata, param2:Number, param3:UnitStatCosts) : void
      {
         var _loc4_:StatRange = null;
         var _loc11_:Boolean = false;
         var _loc12_:StatType = null;
         var _loc13_:Stat = null;
         if(!this.entityClass)
         {
            return;
         }
         var _loc5_:uint = 0;
         var _loc6_:uint = 0;
         var _loc7_:uint = 0;
         if(Enum.getCount(StatType) >= 96)
         {
            throw new ArgumentError("EntityDef.applyClassStats() requires StatType enum to have less than 96 elements.  It has " + Enum.getCount(StatType) + " elements.  Please modify applyClassStats() to handle more StatTypes.");
         }
         var _loc8_:int = 0;
         while(_loc8_ < this.statRanges.numStatRanges)
         {
            _loc4_ = this.statRanges.getStatRangeByIndex(_loc8_);
            if(this._stats.getStat(_loc4_.type,false) == null)
            {
               this._stats.addStat(_loc4_.type,_loc4_.min);
               if(_loc4_.type.value >= 64)
               {
                  _loc7_ |= 1 << _loc4_.type.value - 64;
               }
               else if(_loc4_.type.value >= 32)
               {
                  _loc6_ |= 1 << _loc4_.type.value - 32;
               }
               else
               {
                  _loc5_ |= 1 << _loc4_.type.value;
               }
            }
            _loc8_++;
         }
         var _loc9_:int = this.getMaxUpgrades(param1,param3) - this._stats.GetTotalUpgrades(this.statRanges);
         var _loc10_:int = MathUtil.lerp(0,_loc9_,param2);
         while(_loc10_ > 0)
         {
            _loc11_ = false;
            for each(_loc12_ in Stats.userChangedStatTypes)
            {
               if(_loc12_.value >= 64)
               {
                  if((_loc7_ & 1 << _loc12_.value - 64) == 0)
                  {
                     continue;
                  }
               }
               else if(_loc12_.value >= 32)
               {
                  if((_loc6_ & 1 << _loc12_.value - 32) == 0)
                  {
                     continue;
                  }
               }
               else if((_loc5_ & 1 << _loc12_.value) == 0)
               {
                  continue;
               }
               _loc4_ = this.statRanges.getStatRange(_loc12_);
               _loc13_ = this._stats.getStat(_loc12_);
               if(_loc13_.value < _loc4_.max)
               {
                  _loc11_ = true;
                  ++_loc13_.base;
                  _loc10_--;
               }
               if(_loc10_ <= 0)
               {
                  break;
               }
            }
            if(!_loc11_)
            {
               break;
            }
         }
         if(this.saves && this.entityClass && this.entityClass.playerClass)
         {
            if(!this._stats.hasStat(StatType.INJURY))
            {
               this._stats.addStat(StatType.INJURY,0);
            }
         }
      }
      
      public function get attacks() : IAbilityDefLevels
      {
         return this._attacks;
      }
      
      public function get actives() : IAbilityDefLevels
      {
         return this._actives;
      }
      
      public function get passives() : IAbilityDefLevels
      {
         return this._passives;
      }
      
      public function get upgrades() : int
      {
         return this.stats.GetTotalUpgrades(this.statRanges);
      }
      
      public function resetAbilities() : void
      {
         this._attacks = !!this._attacks ? new BattleAbilityDefLevels(this._id + "_reset") : null;
         this._passives = !!this._passives ? new BattleAbilityDefLevels(this._id + "_reset") : null;
         this._actives = !!this._actives ? new BattleAbilityDefLevels(this._id + "_reset") : null;
      }
      
      public function setupClassAbilities(param1:AbilityDefFactory, param2:ILogger, param3:UnitStatCosts) : void
      {
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:BattleAbilityDef = null;
         var _loc9_:IAbilityDefLevel = null;
         var _loc10_:int = 0;
         var _loc11_:AbilityDef = null;
         if(!this.entityClass)
         {
            return;
         }
         var _loc4_:int = 2;
         var _loc5_:int = this.stats.rank;
         for each(_loc6_ in this._entityClass.actives)
         {
            _loc8_ = param1.fetch(_loc6_,false) as BattleAbilityDef;
            if(!_loc8_)
            {
               param2.error("EntityDef [" + this.id + "] unable to fetch active ability [" + _loc6_ + "]");
            }
            else
            {
               this.getOrConstructActives();
               _loc9_ = this._actives.getAbilityDefLevelById(_loc8_.id);
               if(!_loc9_)
               {
                  _loc10_ = Math.min(1,_loc8_.maxLevel);
                  if(param3)
                  {
                     _loc10_ = param3.getAbilityLevel(_loc5_,_loc4_);
                  }
                  if(_loc8_.tag == BattleAbilityTag.SPECIAL && _loc10_ <= 0)
                  {
                     param2.error("Entity " + this + " rank " + _loc5_ + " disabled ability " + _loc8_);
                  }
                  this._actives.setAbilityDefLevel(_loc8_,_loc10_,_loc4_,param2);
               }
               else if(param3)
               {
                  _loc9_.level = param3.getAbilityLevel(_loc5_,_loc9_.rankAcquired);
               }
            }
         }
         for each(_loc7_ in this._entityClass.attacks)
         {
            this.getOrConstructAttacks();
            _loc11_ = param1.fetch(_loc7_);
            this._attacks.setAbilityDefLevel(_loc11_,_loc11_.maxLevel,_loc4_,param2);
         }
         if(this._entityClass.passive)
         {
            this.getOrConstructPassives();
            if(!this._passives.hasAbility(this._entityClass.passive))
            {
               this._passives.setAbilityDefLevel(param1.fetch(this._entityClass.passive),1,_loc4_,param2);
            }
         }
      }
      
      public function isAppearanceAcquired(param1:int) : Boolean
      {
         if(param1 == 0)
         {
            return true;
         }
         return (this._appearance_acquires & 1 << param1) != 0;
      }
      
      public function acquireAppearance(param1:int) : void
      {
         this._appearance_acquires |= 1 << param1;
      }
      
      public function readyToPromote(param1:int) : Boolean
      {
         var _loc2_:Saga = Saga.instance;
         if(!this.isSurvivalPromotable)
         {
            return false;
         }
         var _loc3_:int = this.stats.getValue(StatType.KILLS);
         if(this.stats.rank < this.statRanges.getStatRange(StatType.RANK).max || Boolean(this._entityClass.playerOnlyChildEntityClasses.length))
         {
            if(Boolean(_loc2_) && Boolean(_loc2_.def.survival))
            {
               return true;
            }
            if(_loc3_ >= param1)
            {
               return true;
            }
         }
         return false;
      }
      
      public function get vars() : IVariableBag
      {
         return this._vars;
      }
      
      public function synchronizeToVars() : void
      {
         var _loc1_:Stat = null;
         var _loc2_:IVariable = null;
         for each(_loc1_ in this.stats)
         {
            _loc2_ = this._vars.fetch(_loc1_.type.name,null);
            if(_loc2_)
            {
               _loc2_.asNumber = _loc1_.value;
            }
         }
      }
      
      public function localizeName() : void
      {
         if(this._nameToken)
         {
            this._name = this.locale.translate(LocaleCategory.ENTITY,this._nameToken);
         }
         if(this.nameFromClass || !this._name && this._entityClass)
         {
            this.nameFromClass = true;
            this._name = this._entityClass.name;
         }
      }
      
      public function localizeDescription() : void
      {
         this._descriptionToken = this.makeDescriptionToken();
         this._description = this.locale.translate(LocaleCategory.ENTITY,this._descriptionToken,false);
      }
      
      public function get statRanges() : StatRanges
      {
         if(this._overrideStatRanges)
         {
            return this._overrideStatRanges;
         }
         return !!this._entityClass ? this._entityClass.statRanges : null;
      }
      
      public function get overrideStatRanges() : StatRanges
      {
         return this._overrideStatRanges;
      }
      
      public function set overrideStatRanges(param1:StatRanges) : void
      {
         this._overrideStatRanges = param1;
      }
      
      public function get combatant() : Boolean
      {
         return this._combatant;
      }
      
      public function set saves(param1:Boolean) : void
      {
         this._saves = param1;
      }
      
      public function get saves() : Boolean
      {
         return this._saves;
      }
      
      public function get defItem() : Item
      {
         return this._item;
      }
      
      public function set defItem(param1:Item) : void
      {
         if(this._item == param1)
         {
            return;
         }
         this._item = param1;
         dispatchEvent(new EntityDefEvent(EntityDefEvent.ITEM,this));
      }
      
      public function get defTitle() : ITitleDef
      {
         return this._heroicTitle;
      }
      
      public function set defTitle(param1:ITitleDef) : void
      {
         if(this._heroicTitle == param1)
         {
            return;
         }
         this._heroicTitle = param1;
      }
      
      public function getMaxUpgrades(param1:EntitiesMetadata, param2:UnitStatCosts) : int
      {
         var _loc3_:int = this.stats.rank;
         var _loc4_:StatRange = this.statRanges.getStatRange(StatType.RANK);
         if(UnitStatCosts.USE_REBUILD_STATS && param2 && _loc3_ >= param2.RANK_REBUILD)
         {
            _loc3_ -= param2.RANK_REBUILD;
            _loc3_++;
         }
         else if(_loc4_)
         {
            _loc3_ -= _loc4_.min;
         }
         var _loc5_:int = 2;
         var _loc6_:int = 0;
         if(param1)
         {
            _loc6_ = param1.getBaseUpgrades(this);
         }
         else
         {
            _loc6_ = EntitiesMetadata._getBaseUpgrades(this,true,EntitiesMetadata.DEFAULT_BASE_UPGRADES);
         }
         return _loc6_ + _loc3_ * _loc5_;
      }
      
      public function get partyRequired() : Boolean
      {
         var _loc1_:IVariable = !!this._vars ? this._vars.fetch(SagaVar.VAR_UNIT_PARTY_REQUIRED,VariableType.BOOLEAN) : null;
         return Boolean(_loc1_) && _loc1_.asBoolean;
      }
      
      public function set partyRequired(param1:Boolean) : void
      {
         var _loc2_:IVariable = null;
         if(this._vars)
         {
            _loc2_ = this._vars.fetch(SagaVar.VAR_UNIT_PARTY_REQUIRED,VariableType.BOOLEAN);
            _loc2_.asBoolean = param1;
         }
      }
      
      public function changeLocale(param1:Locale) : void
      {
         this.locale = param1;
         this.localizeName();
         this.localizeDescription();
      }
      
      public function get useClassAppearanceDesc() : Boolean
      {
         return this._useClassAppearanceDesc;
      }
      
      public function set useClassAppearanceDesc(param1:Boolean) : void
      {
         this._useClassAppearanceDesc = param1;
      }
      
      public function get useClassAppearanceName() : Boolean
      {
         return this._useClassAppearanceName;
      }
      
      public function set useClassAppearanceName(param1:Boolean) : void
      {
         this._useClassAppearanceName = param1;
      }
      
      public function get unitVarNames() : Vector.<String>
      {
         return this._unitVarNames;
      }
      
      public function set unitVarNames(param1:Vector.<String>) : void
      {
         this._unitVarNames = !!param1 ? param1.concat() : null;
         if(this._unitVarNames)
         {
            this._unitVarNames.sort(this.varNameComparator);
         }
         this._unitVarNamesCache = null;
      }
      
      public function hasUnitVarName(param1:String) : Boolean
      {
         var _loc2_:String = null;
         if(!this._unitVarNamesCache && Boolean(this._unitVarNames))
         {
            this._unitVarNamesCache = new Dictionary();
            for each(_loc2_ in this._unitVarNames)
            {
               this._unitVarNamesCache[_loc2_] = true;
            }
         }
         return Boolean(this._unitVarNamesCache) && Boolean(this._unitVarNamesCache[param1]);
      }
      
      public function setPerUnitVarName(param1:String, param2:Boolean) : void
      {
         var _loc3_:int = 0;
         if(param2 && !this.hasUnitVarName(param1))
         {
            if(!this._unitVarNames)
            {
               this._unitVarNames = new Vector.<String>();
            }
            this._unitVarNames.push(param1);
            this._unitVarNames.sort(this.varNameComparator);
            if(this._unitVarNamesCache)
            {
               this._unitVarNamesCache[param1] = true;
            }
         }
         else if(!param2 && this.hasUnitVarName(param1))
         {
            _loc3_ = this._unitVarNames.indexOf(param1);
            if(_loc3_ >= 0)
            {
               this._unitVarNames.splice(_loc3_,1);
            }
            if(this._unitVarNamesCache)
            {
               delete this._unitVarNamesCache[param1];
            }
         }
      }
      
      private function varNameComparator(param1:String, param2:String) : int
      {
         if(param1 < param2)
         {
            return -1;
         }
         if(param2 < param1)
         {
            return 1;
         }
         return 0;
      }
      
      public function get talents() : Talents
      {
         return this._talents;
      }
      
      public function set talents(param1:Talents) : void
      {
         this._talents = param1;
      }
      
      public function get originalAppearanceIndex() : int
      {
         return this._originalAppearanceIndex;
      }
      
      public function get isPromotable() : Boolean
      {
         if(!UnitStatCosts.instance)
         {
            return false;
         }
         if(!this.isSurvivalPromotable)
         {
            return false;
         }
         var _loc1_:int = this._stats.rank;
         var _loc2_:int = UnitStatCosts.instance.getKillsRequiredToPromote(_loc1_);
         return this.readyToPromote(_loc2_);
      }
      
      public function get isUpgradeable() : Boolean
      {
         if(!UnitStatCosts.instance || !EntitiesMetadata.instance)
         {
            return false;
         }
         if(!this.isSurvivalPromotable)
         {
            return false;
         }
         var _loc1_:int = this._stats.GetTotalUpgrades(this.statRanges);
         var _loc2_:int = this.getMaxUpgrades(EntitiesMetadata.instance,UnitStatCosts.instance);
         if(_loc1_ < _loc2_)
         {
            return true;
         }
         return false;
      }
      
      public function get isSurvivalDead() : Boolean
      {
         var _loc1_:Saga = Saga.instance;
         if(Boolean(_loc1_) && Boolean(_loc1_.def.survival))
         {
            return this.stats.getValue(StatType.INJURY) > 0;
         }
         return false;
      }
      
      public function get isSurvivalPromotable() : Boolean
      {
         var _loc1_:Saga = Saga.instance;
         if(Boolean(_loc1_) && Boolean(_loc1_.def.survival))
         {
            if(_loc1_.isSurvivalSettingUp)
            {
               return false;
            }
            if(!this._isSurvivalRecruited)
            {
               return false;
            }
            return !this.isSurvivalDead;
         }
         return true;
      }
      
      public function get isSurvivalRecruited() : Boolean
      {
         return this._isSurvivalRecruited;
      }
      
      public function get isSurvivalRecruitable() : Boolean
      {
         var _loc1_:Saga = Saga.instance;
         return Boolean(_loc1_) && Boolean(_loc1_.def.survival) && !this._isSurvivalRecruited;
      }
      
      public function set isSurvivalRecruited(param1:Boolean) : void
      {
         var _loc2_:Saga = Saga.instance;
         if(Boolean(_loc2_) && Boolean(_loc2_.def.survival))
         {
            this._isSurvivalRecruited = param1;
         }
      }
      
      public function get survivalRecruitCostRenown() : int
      {
         var _loc1_:Saga = Saga.instance;
         if(_loc1_)
         {
            return _loc1_.getVarInt(SagaVar.VAR_SURVIVAL_RECRUIT_RENOWN);
         }
         return 1;
      }
      
      public function get survivalFuneralRewardRenown() : int
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc1_:Saga = Saga.instance;
         if(_loc1_)
         {
            _loc2_ = _loc1_.getVarInt(SagaVar.VAR_SURVIVAL_FUNERAL_RENOWN_PER_RANK);
            _loc3_ = _loc2_ * (this.stats.rank - 3);
            return int(Math.max(0,_loc3_));
         }
         return 1;
      }
      
      public function get survivalFuneralRewardItemRenown() : int
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc1_:Saga = Saga.instance;
         if(_loc1_)
         {
            if(this._item)
            {
               _loc2_ = _loc1_.getVarInt(SagaVar.VAR_SURVIVAL_FUNERAL_RENOWN_PER_ITEM);
               return _loc2_ * this._item.def.rank;
            }
            return 0;
         }
         return 1;
      }
      
      public function get additionalActives() : Vector.<String>
      {
         if(this._additionalActives)
         {
            return this._additionalActives;
         }
         return this._entityClass.additionalActives;
      }
      
      public function getVariableDefByName(param1:String) : VariableDef
      {
         var _loc2_:Saga = Saga.instance;
         if(_loc2_)
         {
            return _loc2_.getVariableDefByName(param1);
         }
         return null;
      }
      
      public function getVariables() : Vector.<VariableDef>
      {
         var _loc1_:Saga = Saga.instance;
         if(_loc1_)
         {
            return _loc1_.getVariables();
         }
         return null;
      }
      
      public function addActiveAbilityDefLevel(param1:IAbilityDefLevel, param2:ILogger) : IAbilityDefLevel
      {
         this.getOrConstructActives();
         return this._actives.addAbilityDefLevel(param1,param2);
      }
      
      public function setActiveAbilityDefLevel(param1:IAbilityDef, param2:int, param3:int, param4:ILogger) : IAbilityDefLevel
      {
         this.getOrConstructActives();
         return this._actives.setAbilityDefLevel(param1,param2,param3,param4);
      }
      
      protected function getOrConstructActives() : IAbilityDefLevels
      {
         if(!this._actives)
         {
            this._actives = new BattleAbilityDefLevels(!!this._id ? this._id : "entityDef");
         }
         return this._actives;
      }
      
      protected function getOrConstructPassives() : IAbilityDefLevels
      {
         if(!this._passives)
         {
            this._passives = new BattleAbilityDefLevels(!!this._id ? this._id : "entityDef");
         }
         return this._passives;
      }
      
      protected function getOrConstructAttacks() : IAbilityDefLevels
      {
         if(!this._attacks)
         {
            this._attacks = new BattleAbilityDefLevels(!!this._id ? this._id : "entityDef");
         }
         return this._attacks;
      }
      
      public function get usabilityDef() : UsabilityDef
      {
         return this._usabilityDef;
      }
      
      public function get isWarped() : Boolean
      {
         return this._isWarped || Boolean(this._entityClass) && this._entityClass.isWarped;
      }
      
      public function get isInjured() : Boolean
      {
         return Boolean(this._stats) && this._stats.getValue(StatType.INJURY) > 0;
      }
      
      private function printFlag(param1:Boolean, param2:String) : String
      {
         if(param1)
         {
            return "  " + param2;
         }
         return " !" + param2.toLowerCase();
      }
      
      public function getSummaryLine() : String
      {
         var _loc1_:int = this.stats.rank;
         return StringUtil.padLeft(this.id," ",30) + "  R " + StringUtil.padLeft(_loc1_.toString()," ",2) + this.printFlag(this.isInjured,"INJ") + this.printFlag(this.combatant,"CBT");
      }
      
      public function get gender() : String
      {
         return !!this._entityClass ? this._entityClass.gender : null;
      }
   }
}

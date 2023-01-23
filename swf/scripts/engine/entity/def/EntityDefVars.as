package engine.entity.def
{
   import engine.ability.IAbilityDefLevel;
   import engine.ability.IAbilityDefLevels;
   import engine.ability.def.AbilityDef;
   import engine.ability.def.AbilityDefFactory;
   import engine.ability.def.AbilityDefLevels;
   import engine.battle.ability.effect.model.EffectTag;
   import engine.battle.board.def.UsabilityDef;
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   import engine.core.util.ArrayUtil;
   import engine.core.util.Enum;
   import engine.core.util.StableJson;
   import engine.def.BooleanVars;
   import engine.def.EngineJsonDef;
   import engine.entity.UnitStatCosts;
   import engine.saga.vars.IBattleEntityProvider;
   import engine.saga.vars.VariableBag;
   import engine.stat.def.StatRange;
   import engine.stat.def.StatRanges;
   import engine.stat.def.StatType;
   import engine.stat.model.StatsVars;
   import flash.utils.Dictionary;
   
   public class EntityDefVars extends EntityDef
   {
      
      private static const _schema_actives:Object = {
         "name":"EntityDef_Actives",
         "type":"object",
         "properties":{
            "id":{"type":"string"},
            "level":{"type":"number"},
            "rankAcquired":{"type":"number"},
            "enabled":{"type":"boolean"}
         }
      };
      
      public static const schema:Object = {
         "name":"EntityDef",
         "type":"object",
         "properties":{
            "id":{
               "type":"string",
               "description":"unique entity def id"
            },
            "name":{
               "description":"english name",
               "type":"string",
               "optional":true
            },
            "name_token":{
               "description":"localization token",
               "type":"string",
               "optional":true
            },
            "entityClass":{"type":"string"},
            "stats":{
               "type":"array",
               "optional":true,
               "items":{
                  "type":"object",
                  "properties":{
                     "stat":"string",
                     "value":"number"
                  }
               }
            },
            "actives":{
               "type":"array",
               "optional":true,
               "items":_schema_actives
            },
            "tags":{
               "type":"array",
               "optional":true,
               "items":"string"
            },
            "additionalActives":{
               "type":"array",
               "optional":true,
               "items":"string"
            },
            "passives":{
               "type":"array",
               "optional":true,
               "items":{"properties":{
                  "id":{"type":"string"},
                  "level":{"type":"number"}
               }}
            },
            "autoLevel":{
               "type":"number",
               "optional":true
            },
            "power":{
               "type":"number",
               "skip":true,
               "optional":true
            },
            "class":{
               "type":"string",
               "skip":true,
               "optional":true
            },
            "isSurvivalRecruited":{
               "type":"boolean",
               "optional":true
            },
            "start_date":{
               "type":"number",
               "optional":true
            },
            "combatant":{
               "type":"boolean",
               "optional":true
            },
            "saves":{
               "type":"boolean",
               "optional":true
            },
            "appearance_acquires":{
               "type":"number",
               "optional":true
            },
            "appearance_index":{
               "type":"number",
               "optional":true
            },
            "appearance":{
               "type":EntityAppearanceDefVars.schema,
               "optional":true
            },
            "vars":{
               "type":"array",
               "optional":true
            },
            "useClassAppearanceDesc":{
               "type":"boolean",
               "optional":true
            },
            "unitVarNames":{
               "type":"array",
               "optional":true
            },
            "stat_ranges":{
               "type":"array",
               "optional":true,
               "items":{
                  "type":"object",
                  "properties":{
                     "stat":"string",
                     "min":"number",
                     "max":"number"
                  }
               }
            },
            "item":{
               "optional":true,
               "type":ItemVars.schema
            },
            "itemDef":{
               "optional":true,
               "type":"string"
            },
            "usability":{
               "optional":true,
               "type":UsabilityDef.schema
            },
            "warped":{
               "type":"boolean",
               "optional":true
            },
            "title":{
               "type":"string",
               "optional":true
            },
            "addDifficultyStatsAsMods":{
               "type":"boolean",
               "optional":true
            }
         }
      };
       
      
      public function EntityDefVars(param1:Locale)
      {
         super(param1);
      }
      
      public static function saveStatRanges(param1:EntityDef) : Object
      {
         var _loc5_:StatRange = null;
         var _loc6_:Object = null;
         var _loc2_:StatRanges = param1.overrideStatRanges;
         if(!_loc2_)
         {
            return null;
         }
         var _loc3_:Array = [];
         var _loc4_:int = 0;
         while(_loc4_ < _loc2_.numStatRanges)
         {
            _loc5_ = _loc2_.getStatRangeByIndex(_loc4_);
            _loc6_ = {
               "stat":_loc5_.type.name,
               "min":_loc5_.min,
               "max":_loc5_.max
            };
            _loc3_.push(_loc6_);
            _loc4_++;
         }
         return _loc3_;
      }
      
      private static function saveAbilities(param1:IAbilityDefLevels, param2:Vector.<String>, param3:String) : Object
      {
         var _loc4_:AbilityDefLevels = null;
         var _loc5_:int = 0;
         var _loc6_:IAbilityDefLevel = null;
         var _loc7_:IAbilityDefLevel = null;
         if(Boolean(param1) && param1.numAbilities > 0)
         {
            _loc4_ = new AbilityDefLevels("tmpAbilities");
            _loc5_ = 0;
            while(_loc5_ < param1.numAbilities)
            {
               _loc6_ = param1.getAbilityDefLevel(_loc5_);
               if(_loc6_.level != 1 || param2 && param2.indexOf(_loc6_.id) == -1 || param3 && _loc6_.id != param3)
               {
                  _loc7_ = _loc4_.setAbilityDefLevel(_loc6_.def,_loc6_.level,_loc6_.rankAcquired,null);
                  _loc7_.enabled = _loc6_.enabled;
               }
               _loc5_++;
            }
            if(_loc4_.numAbilities > 0)
            {
               return AbilityDefLevels.save(_loc4_);
            }
         }
         return null;
      }
      
      public static function save(param1:EntityDef, param2:ILogger) : Object
      {
         var _loc7_:EffectTag = null;
         var _loc8_:Array = null;
         var _loc9_:String = null;
         var _loc10_:Dictionary = null;
         var _loc3_:Object = {
            "id":param1.id,
            "entityClass":param1.entityClass.id,
            "appearance_index":param1.appearanceIndex
         };
         if(param1.usabilityDef)
         {
            _loc3_.usability = param1.usabilityDef.save();
         }
         if(Boolean(param1.tags) && Boolean(param1.tags.length))
         {
            _loc3_.tags = [];
            for each(_loc7_ in param1.tags)
            {
               _loc3_.tags.push(_loc7_.name);
            }
         }
         if(param1.isSurvivalRecruited)
         {
            _loc3_.isSurvivalRecruited = true;
         }
         if(param1._additionalActives)
         {
            _loc3_._additionalActives = ArrayUtil.stringVectorToStringArray(param1._additionalActives);
         }
         if(param1.useClassAppearanceDesc)
         {
            _loc3_.useClassAppearanceDesc = true;
         }
         if(Boolean(param1.unitVarNames) && param1.unitVarNames.length > 0)
         {
            _loc8_ = [];
            for each(_loc9_ in param1.unitVarNames)
            {
               _loc8_.push(_loc9_);
            }
            _loc3_.unitVarNames = _loc8_;
         }
         if(!param1.name)
         {
         }
         var _loc4_:Object = saveAbilities(param1.actives,param1.entityClass.actives,null);
         if(_loc4_)
         {
            _loc3_.actives = _loc4_;
         }
         var _loc5_:Object = saveAbilities(param1.passives,null,param1.entityClass.passive);
         if(_loc5_)
         {
            _loc3_.passives = _loc5_;
         }
         _loc3_.stats = StatsVars.save(param1.stats);
         if(param1.nameToken)
         {
            _loc3_.name_token = param1.nameToken;
         }
         if(param1.overrideAppearance)
         {
            _loc3_.appearance = EntityAppearanceDefVars.save(param1.overrideAppearance as EntityAppearanceDef);
         }
         var _loc6_:Object = saveStatRanges(param1);
         if(_loc6_)
         {
            _loc3_.stat_ranges = _loc6_;
         }
         if(!param1.combatant)
         {
            _loc3_.combatant = param1.combatant;
         }
         if(!param1.saves)
         {
            _loc3_.saves = param1.saves;
         }
         if(param1.defItem)
         {
            _loc3_.item = ItemVars.save(param1.defItem);
         }
         if(param1.vars)
         {
            _loc10_ = param1.vars.toDictionary(param2);
            if(_loc10_)
            {
               _loc3_.vars = VariableBag.toJsonFromDictionary(_loc10_);
            }
         }
         if(param1._addDifficultyStatsAsMods)
         {
            _loc3_._addDifficultyStatsAsMods = param1._addDifficultyStatsAsMods;
         }
         return _loc3_;
      }
      
      private static function parseAbilityDefLevels(param1:Array, param2:Function, param3:AbilityDefFactory, param4:int, param5:ILogger) : Boolean
      {
         var errors:int = 0;
         var kvp:Object = null;
         var levels:AbilityDefLevels = null;
         var ad:AbilityDef = null;
         var level:int = 0;
         var rankAcquired:int = 0;
         var enabled:Boolean = false;
         var adl:IAbilityDefLevel = null;
         var vars:Array = param1;
         var levelsFunc:Function = param2;
         var abilityFactory:AbilityDefFactory = param3;
         var rank:int = param4;
         var logger:ILogger = param5;
         if(!vars || !abilityFactory)
         {
            return true;
         }
         for each(kvp in vars)
         {
            try
            {
               levels = levelsFunc();
               ad = abilityFactory.fetch(kvp.id);
               level = int(kvp.level);
               rankAcquired = int(kvp.rankAcquired);
               if(kvp.level == undefined)
               {
                  level = Math.max(1,Math.min(3,rank / 2));
                  rankAcquired = 2;
               }
               if(!rankAcquired)
               {
                  rankAcquired = rank;
               }
               enabled = BooleanVars.parse(kvp.enabled,true);
               adl = levels.setAbilityDefLevel(ad,level,rankAcquired,logger);
               adl.enabled = enabled;
            }
            catch(e:Error)
            {
               logger.error("Character ability [" + kvp.id + "]: " + e);
               errors++;
            }
         }
         return errors == 0;
      }
      
      public function fromJson(param1:Object, param2:ILogger, param3:AbilityDefFactory, param4:EntityClassDefList, param5:IBattleEntityProvider, param6:Boolean, param7:ItemListDef, param8:UnitStatCosts) : EntityDefVars
      {
         var autolevel:Number;
         var rank:int;
         var activesOk:Boolean;
         var passivesOk:Boolean;
         var statvar:Object = null;
         var uva:Array = null;
         var uv:String = null;
         var cn:String = null;
         var sn:String = null;
         var type:StatType = null;
         var d:Dictionary = null;
         var etn:String = null;
         var et:EffectTag = null;
         var json:Object = param1;
         var logger:ILogger = param2;
         var abilityFactory:AbilityDefFactory = param3;
         var classes:EntityClassDefList = param4;
         var bbp:IBattleEntityProvider = param5;
         var warnStats:Boolean = param6;
         var itemDefs:ItemListDef = param7;
         var statCosts:UnitStatCosts = param8;
         EngineJsonDef.validateThrow(json,schema,logger);
         this._id = json.id;
         updateAbilityDefLevelsNames();
         this._vars = new VariableBag(_id,this,bbp,logger);
         this._isWarped = json.warped;
         if(_id == "alette")
         {
            _id = _id;
         }
         this._additionalActives = ArrayUtil.stringArrayToStringVector(json.additionalActives);
         useClassAppearanceDesc = json.useClassAppearanceDesc;
         if(json.unitVarNames)
         {
            this._unitVarNames = new Vector.<String>();
            uva = json.unitVarNames;
            for each(uv in uva)
            {
               this._unitVarNames.push(uv);
            }
         }
         if(classes)
         {
            cn = json.entityClass;
            this._entityClass = classes.fetch(cn);
         }
         this._name = json.name;
         this._nameToken = json.name_token;
         localizeName();
         localizeDescription();
         this.startDate = json.start_date != undefined ? Number(json.start_date) : 0;
         this._isSurvivalRecruited = json.isSurvivalRecruited;
         this._appearance_acquires = json.appearance_acquires;
         this._appearanceIndex = json.appearance_index;
         this._originalAppearanceIndex = this._appearanceIndex;
         this.parseStatRanges(json,logger);
         for each(statvar in json.stats)
         {
            sn = statvar.stat;
            if(!(Boolean(sn) && (sn.indexOf("ABILITY_") == 0 || sn == "RANGE")))
            {
               try
               {
                  type = Enum.parse(StatType,sn) as StatType;
                  _stats.addStat(type,statvar.value);
               }
               catch(e:Error)
               {
                  logger.error("Failed to parse stat for " + _id + " [" + StableJson.stringifyObject(statvar,"  ") + "]: " + e);
               }
            }
         }
         if(json.usability)
         {
            _usabilityDef = new UsabilityDef().fromJson(json.usability,logger);
         }
         autolevel = json.autoLevel != undefined ? Number(json.autoLevel) : 0;
         if(classes)
         {
            applyClassStats(classes.meta,json.autoLevel,statCosts);
         }
         rank = _stats.rank;
         activesOk = parseAbilityDefLevels(json.actives,getOrConstructActives,abilityFactory,rank,logger);
         passivesOk = parseAbilityDefLevels(json.passives,getOrConstructPassives,abilityFactory,rank,logger);
         if(!activesOk || !passivesOk)
         {
            throw new ArgumentError("CharacterDef " + id + " failed loading abilities");
         }
         if(!_entityClass && Boolean(classes))
         {
            throw new ArgumentError("EntityDef " + id + " no such entity class: " + json.entityClass);
         }
         setupClassAbilities(abilityFactory,logger,statCosts);
         if(json.appearance)
         {
            _appearance = new EntityAppearanceDefVars(_entityClass,this).fromJson(json.appearance,logger);
         }
         clampStats(warnStats ? logger : null);
         _combatant = BooleanVars.parse(json.combatant,_combatant);
         _saves = BooleanVars.parse(json.saves,_saves);
         if(json.item)
         {
            defItem = new ItemVars().fromJson(json.item,logger);
            if(itemDefs)
            {
               _item.resolve(itemDefs);
            }
            _item.owner = this;
         }
         if(json.vars)
         {
            d = VariableBag.fromJsonToDictionary(json.vars);
            if(d)
            {
               vars.fromDictionary(d,logger);
            }
         }
         if(json.tags)
         {
            this._tags = new Vector.<EffectTag>();
            for each(etn in json.tags)
            {
               et = Enum.parse(EffectTag,etn) as EffectTag;
               this._tags.push(et);
            }
         }
         _addDifficultyStatsAsMods = BooleanVars.parse(json.addDifficultyStatsAsMods,_addDifficultyStatsAsMods);
         return this;
      }
      
      private function parseStatRanges(param1:Object, param2:ILogger) : void
      {
         var statvar:Object = null;
         var sn:String = null;
         var type:StatType = null;
         var vars:Object = param1;
         var logger:ILogger = param2;
         if(!vars.stat_ranges)
         {
            return;
         }
         _overrideStatRanges = new StatRanges();
         for each(statvar in vars.stat_ranges)
         {
            sn = statvar.stat;
            if(!(Boolean(sn) && (sn.indexOf("ABILITY_") == 0 || sn == "RANGE")))
            {
               try
               {
                  type = Enum.parse(StatType,sn) as StatType;
                  if(_overrideStatRanges.hasStatRange(type))
                  {
                     throw new ArgumentError("EntityDef " + id + " has duplicate stat ranges" + type);
                  }
                  _overrideStatRanges.addStatRange(type,statvar.min,statvar.max);
               }
               catch(e:Error)
               {
                  logger.error("Failed to parse stat range for " + _id + " [" + StableJson.stringifyObject(statvar,"  ") + "]: " + e);
               }
            }
         }
         if(!_overrideStatRanges.hasStatRange(StatType.RANK))
         {
            _overrideStatRanges.addStatRange(StatType.RANK,1,1);
         }
      }
   }
}

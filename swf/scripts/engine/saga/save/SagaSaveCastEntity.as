package engine.saga.save
{
   import engine.ability.IAbilityDefLevel;
   import engine.ability.IAbilityDefLevels;
   import engine.ability.def.AbilityDef;
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   import engine.entity.def.EntityDef;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.ITitleDef;
   import engine.entity.def.Item;
   import engine.saga.Saga;
   import engine.saga.vars.IVariable;
   import engine.stat.def.StatRange;
   import engine.stat.def.StatType;
   import engine.stat.model.Stat;
   import engine.talent.Talent;
   import engine.talent.TalentDef;
   import engine.talent.Talents;
   import flash.utils.Dictionary;
   
   public class SagaSaveCastEntity
   {
       
      
      public var stat_ups:Dictionary;
      
      public var talents:Dictionary;
      
      public var vars:Dictionary;
      
      public var item:String;
      
      public var actives:Array;
      
      public var appearanceIndex:int = -1;
      
      public var survival_recruited:Boolean;
      
      public var heroicTitle:String;
      
      public function SagaSaveCastEntity()
      {
         super();
      }
      
      public function get isEmpty() : Boolean
      {
         return this.stat_ups == null && this.vars == null && this.item == null && this.talents == null && this.heroicTitle == null;
      }
      
      public function fromEntity(param1:IEntityDef, param2:ILogger) : SagaSaveCastEntity
      {
         var _loc5_:* = false;
         var _loc6_:Stat = null;
         var _loc7_:* = 0;
         var _loc8_:StatRange = null;
         var _loc9_:Talent = null;
         var _loc10_:IAbilityDefLevel = null;
         if(param1.isSurvivalRecruited)
         {
            this.survival_recruited = param1.isSurvivalRecruited;
         }
         if(param1.defItem)
         {
            this.item = param1.defItem.id;
         }
         if(param1.defTitle)
         {
            this.heroicTitle = param1.defTitle.id;
         }
         if(param1.appearanceIndex != param1.originalAppearanceIndex && param1.originalAppearanceIndex >= 0)
         {
            this.appearanceIndex = param1.appearanceIndex;
         }
         else
         {
            this.appearanceIndex = -1;
         }
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         while(_loc4_ < param1.stats.numStats)
         {
            _loc6_ = param1.stats.getStatByIndex(_loc4_);
            _loc7_ = _loc6_.base;
            _loc8_ = param1.statRanges.getStatRange(_loc6_.type);
            if(_loc8_)
            {
               _loc7_ = int(Math.max(0,_loc6_.base - _loc8_.min));
            }
            if(_loc7_ > 0)
            {
               _loc3_ += _loc7_;
               if(!this.stat_ups)
               {
                  this.stat_ups = new Dictionary();
               }
               this.stat_ups[_loc6_.type.name] = _loc7_;
            }
            else if(_loc7_ < 0 && _loc8_)
            {
               param2.error("Entity [" + param1.id + "] has stat " + _loc6_.type + " " + _loc6_.base + " below the minimum " + _loc8_.min);
            }
            if(param1.talents)
            {
               _loc9_ = param1.talents.getTalentByParentStatType(_loc6_.type);
               if(_loc9_ && _loc9_.rank > 0)
               {
                  if(!this.talents)
                  {
                     this.talents = new Dictionary();
                  }
                  this.talents[_loc9_.def.id] = _loc9_.rank;
               }
            }
            _loc4_++;
         }
         this.vars = param1.vars.toDictionary(param2);
         if(param1.actives && param1.actives.numAbilities)
         {
            if(!this.actives)
            {
               this.actives = new Array();
            }
            _loc4_ = 0;
            while(_loc4_ < param1.actives.numAbilities)
            {
               _loc10_ = param1.actives.getAbilityDefLevel(_loc4_);
               _loc5_ = param1.entityClass.actives.indexOf(_loc10_.id) >= 0;
               if(!_loc5_)
               {
                  this.actives.push({
                     "id":_loc10_.id,
                     "rankAcquired":_loc10_.rankAcquired,
                     "level":_loc10_.level
                  });
               }
               _loc4_++;
            }
         }
         return this;
      }
      
      public function applyCastInfo(param1:IEntityDef, param2:Saga, param3:ILogger, param4:Dictionary) : void
      {
         this.applyCastInfoStats(param1,param2,param3);
         this.applyCastInfoVars(param1,param3,param4);
         this.applyCastInfoItem(param1,param2,param3);
         this.applyCastInfoHeroicTitle(param1,param2,param3);
         (param1 as EntityDef).setupClassAbilities(param2.abilityFactory,param3,param2.def.unitStatCosts);
         this.applyCastInfoAbilities(param1,param2,param3);
         if(this.appearanceIndex >= 0)
         {
            param1.appearanceIndex = this.appearanceIndex;
         }
         param1.isSurvivalRecruited = this.survival_recruited;
      }
      
      private function applyCastInfoItem(param1:IEntityDef, param2:Saga, param3:ILogger) : void
      {
         var _loc4_:Item = null;
         if(this.item)
         {
            _loc4_ = param2.createItemByName(this.item);
            if(_loc4_)
            {
               param1.defItem = _loc4_;
               _loc4_.owner = param1;
            }
         }
      }
      
      private function applyCastInfoHeroicTitle(param1:IEntityDef, param2:Saga, param3:ILogger) : void
      {
         var _loc4_:ITitleDef = null;
         if(this.heroicTitle && param2.def && param2.def.titleDefs)
         {
            _loc4_ = param2.def.titleDefs.getTitleDef(this.heroicTitle);
            if(_loc4_)
            {
               param1.defTitle = _loc4_;
               param2.def.consumeTitle(_loc4_);
            }
         }
      }
      
      private function applyCastInfoStats(param1:IEntityDef, param2:Saga, param3:ILogger) : void
      {
         var _loc4_:Stat = null;
         var _loc5_:StatType = null;
         var _loc6_:StatRange = null;
         var _loc7_:int = 0;
         var _loc8_:* = null;
         var _loc9_:int = 0;
         var _loc10_:* = null;
         var _loc11_:TalentDef = null;
         var _loc12_:int = 0;
         var _loc13_:Talent = null;
         if(this.stat_ups)
         {
            _loc7_ = 0;
            while(_loc7_ < param1.stats.numStats)
            {
               _loc4_ = param1.stats.getStatByIndex(_loc7_);
               if(_loc4_.type.volatile)
               {
                  if(_loc4_.type != StatType.BASE_UPGRADES)
                  {
                     _loc6_ = param1.statRanges.getStatRange(_loc4_.type);
                     if(_loc6_)
                     {
                        _loc4_.base = _loc6_.min;
                     }
                  }
               }
               _loc7_++;
            }
            for(_loc8_ in this.stat_ups)
            {
               _loc9_ = int(this.stat_ups[_loc8_]);
               if(_loc9_)
               {
                  _loc5_ = Enum.parse(StatType,_loc8_,false) as StatType;
                  if(!_loc5_)
                  {
                     if(!(_loc8_ == "ABILITY_0" || _loc8_ == "RANGE"))
                     {
                        param3.error("No such stat [" + _loc8_ + "] for [" + param1.id + "]");
                     }
                  }
                  else
                  {
                     _loc6_ = param1.statRanges.getStatRange(_loc5_);
                     if(_loc6_)
                     {
                        param1.stats.setBase(_loc5_,_loc6_.min + _loc9_);
                     }
                     else
                     {
                        param1.stats.setBase(_loc5_,_loc9_);
                     }
                  }
               }
            }
         }
         if(this.talents)
         {
            if(!param2.def.talentDefs)
            {
               param3.error("No saga talents but save file had talents for " + param1);
               return;
            }
            if(!param1.talents)
            {
               param1.talents = new Talents(param1.id);
            }
            for(_loc10_ in this.talents)
            {
               _loc11_ = param2.def.talentDefs.getDefById(_loc10_);
               if(!_loc11_)
               {
                  param3.error("Unknown talent [" + _loc10_ + "] for " + param1);
               }
               else
               {
                  _loc12_ = int(this.talents[_loc10_]);
                  _loc13_ = param1.talents.getTalentByDef(_loc11_,true);
                  _loc13_.rank = _loc12_;
               }
            }
            param1.talents.computeTotalRanks();
         }
      }
      
      private function applyCastInfoVars(param1:IEntityDef, param2:ILogger, param3:Dictionary) : void
      {
         var _loc4_:* = null;
         var _loc5_:String = null;
         var _loc6_:IVariable = null;
         for(_loc4_ in this.vars)
         {
            if(!(param3 && !param3[_loc4_]))
            {
               _loc5_ = this.vars[_loc4_];
               if(_loc5_)
               {
                  _loc6_ = param1.vars.fetch(_loc4_,null);
                  if(!_loc6_)
                  {
                     param2.error("No such variable [" + _loc4_ + "] for [" + param1.id + "]");
                  }
                  else if(_loc6_.def.scripted)
                  {
                     param2.info("Skipping load of scripted variable [" + _loc4_ + "] for [" + param1.id + "]");
                  }
                  else
                  {
                     _loc6_.asString = _loc5_;
                  }
               }
            }
         }
      }
      
      private function applyCastInfoAbilities(param1:IEntityDef, param2:Saga, param3:ILogger) : void
      {
         var kvp:Object = null;
         var ad:AbilityDef = null;
         var level:int = 0;
         var rankAcquired:int = 0;
         var adlActs:Vector.<String> = null;
         var adl:IAbilityDefLevel = null;
         var inAddActives:Boolean = false;
         var acts:IAbilityDefLevels = null;
         var index:int = 0;
         var j:int = 0;
         var abDefLev:IAbilityDefLevel = null;
         var e:IEntityDef = param1;
         var saga:Saga = param2;
         var logger:ILogger = param3;
         if(!this.actives)
         {
            return;
         }
         for each(kvp in this.actives)
         {
            try
            {
               ad = saga.abilityFactory.fetch(kvp.id);
               level = int(kvp.level);
               rankAcquired = int(kvp.rankAcquired);
               adlActs = e.additionalActives;
               if(rankAcquired >= 6)
               {
                  inAddActives = false;
                  if(this._stringInStringVector(kvp.id,adlActs))
                  {
                     acts = e.actives;
                     index = int(acts.getAbilityIndex(kvp.id));
                     if(index >= 0)
                     {
                        if(level <= acts.getAbilityDefLevel(index))
                        {
                           continue;
                        }
                     }
                     j = 0;
                     while(j < adlActs.length)
                     {
                        abDefLev = acts.getAbilityDefLevelById(adlActs[j]);
                        if(abDefLev)
                        {
                           if(e.entityClass.id != "horseborn_male" && e.entityClass.id != "horseborn_female")
                           {
                              if(abDefLev.level > level)
                              {
                                 level = int(abDefLev.level);
                              }
                              acts.removeAbility(abDefLev.id);
                           }
                        }
                        j++;
                     }
                  }
               }
               adl = e.setActiveAbilityDefLevel(ad,level,kvp.rankAcquired,logger);
               adl.enabled = true;
            }
            catch(e:Error)
            {
               logger.error("Applying character ability [" + kvp.id + "]: " + e);
            }
         }
      }
      
      private function _stringInStringVector(param1:String, param2:Vector.<String>) : Boolean
      {
         var _loc3_:int = 0;
         while(_loc3_ < param2.length)
         {
            if(param2[_loc3_] == param1)
            {
               return true;
            }
            _loc3_++;
         }
         return false;
      }
      
      public function fromJson(param1:Object) : SagaSaveCastEntity
      {
         var _loc2_:* = null;
         var _loc3_:String = null;
         var _loc4_:* = null;
         var _loc5_:int = 0;
         var _loc6_:* = null;
         var _loc7_:int = 0;
         var _loc8_:Object = null;
         this.item = param1.item;
         if(param1.appearanceIndex != undefined)
         {
            this.appearanceIndex = param1.appearanceIndex;
         }
         this.heroicTitle = param1.title;
         this.survival_recruited = param1.survival_recruited;
         this.vars = new Dictionary();
         if(param1.vars != undefined)
         {
            for(_loc2_ in param1.vars)
            {
               _loc3_ = param1.vars[_loc2_];
               this.vars[_loc2_] = _loc3_;
            }
         }
         if(param1.stat_ups != undefined)
         {
            this.stat_ups = new Dictionary();
            for(_loc4_ in param1.stat_ups)
            {
               _loc5_ = int(param1.stat_ups[_loc4_]);
               this.stat_ups[_loc4_] = _loc5_;
            }
         }
         if(param1.talents != undefined)
         {
            this.talents = new Dictionary();
            for(_loc6_ in param1.talents)
            {
               _loc7_ = int(param1.talents[_loc6_]);
               this.talents[_loc6_] = _loc7_;
            }
         }
         if(param1.actives != undefined)
         {
            this.actives = new Array();
            for each(_loc8_ in param1.actives)
            {
               this.actives.push(_loc8_);
            }
         }
         return this;
      }
      
      public function toJson() : Object
      {
         var _loc2_:* = null;
         var _loc3_:String = null;
         var _loc4_:* = null;
         var _loc5_:int = 0;
         var _loc6_:* = null;
         var _loc7_:int = 0;
         var _loc8_:Object = null;
         var _loc1_:Object = {};
         if(this.survival_recruited)
         {
            _loc1_.survival_recruited = this.survival_recruited;
         }
         if(this.item)
         {
            _loc1_.item = this.item;
         }
         if(this.heroicTitle)
         {
            _loc1_.title = this.heroicTitle;
         }
         if(this.appearanceIndex >= 0)
         {
            _loc1_.appearanceIndex = this.appearanceIndex;
         }
         if(this.vars)
         {
            _loc1_.vars = {};
            for(_loc2_ in this.vars)
            {
               _loc3_ = this.vars[_loc2_];
               _loc1_.vars[_loc2_] = _loc3_;
            }
         }
         if(this.stat_ups)
         {
            _loc1_.stat_ups = {};
            for(_loc4_ in this.stat_ups)
            {
               _loc5_ = int(this.stat_ups[_loc4_]);
               _loc1_.stat_ups[_loc4_] = _loc5_;
            }
         }
         if(this.talents)
         {
            _loc1_.talents = {};
            for(_loc6_ in this.talents)
            {
               _loc7_ = int(this.talents[_loc6_]);
               _loc1_.talents[_loc6_] = _loc7_;
            }
         }
         if(this.actives && this.actives.length)
         {
            _loc1_.actives = [];
            for each(_loc8_ in this.actives)
            {
               _loc1_.actives.push({
                  "id":_loc8_.id,
                  "level":_loc8_.level,
                  "rankAcquired":_loc8_.rankAcquired
               });
            }
         }
         return _loc1_;
      }
   }
}

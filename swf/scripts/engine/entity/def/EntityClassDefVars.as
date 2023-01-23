package engine.entity.def
{
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   import engine.def.BooleanVars;
   import engine.def.BoxVars;
   import engine.def.EngineJsonDef;
   import engine.stat.def.StatRange;
   import engine.stat.def.StatRangeVars;
   import engine.stat.def.StatType;
   
   public class EntityClassDefVars extends EntityClassDef
   {
      
      public static const schema:Object = {
         "name":"EntityClassDefVars",
         "type":"object",
         "properties":{
            "id":{"type":"string"},
            "parent":{
               "type":"string",
               "optional":true
            },
            "passive":{
               "type":"string",
               "optional":true
            },
            "stats":{
               "type":"array",
               "items":StatRangeVars.schema,
               "optional":true
            },
            "actives":{
               "type":"array",
               "items":"string",
               "optional":true
            },
            "additionalActives":{
               "type":"array",
               "items":"string",
               "optional":true
            },
            "attacks":{
               "type":"array",
               "items":"string",
               "optional":true
            },
            "race":{
               "type":"string",
               "optional":true
            },
            "gender":{
               "type":"string",
               "optional":true
            },
            "bounds":{"type":BoxVars.schema},
            "appearances":{
               "type":"array",
               "items":{
                  "type":"object",
                  "properties":{
                     "portrait":"string",
                     "versusPortrait":"string",
                     "promotePortrait":"string",
                     "icon":"string",
                     "sounds":"string",
                     "anims":"string",
                     "vfx":"string",
                     "unlock_id":{
                        "type":"string",
                        "optional":true
                     },
                     "acquire_id":{
                        "type":"string",
                        "optional":true
                     }
                  }
               }
            },
            "propAnimUrl":{
               "type":"string",
               "optional":true
            },
            "partyTag":{
               "type":"string",
               "optional":true
            },
            "mobile":{
               "type":"boolean",
               "optional":true
            },
            "collidable":{
               "type":"boolean",
               "optional":true
            },
            "playerClass":{
               "type":"boolean",
               "optional":true
            },
            "shadowUrl":{
               "type":"string",
               "optional":true
            },
            "disableShadow":{
               "type":"string",
               "optional":true
            },
            "warped":{
               "type":"boolean",
               "optional":true
            },
            "submergedMove":{
               "type":"boolean",
               "optional":true
            }
         }
      };
       
      
      private var _requiredActiveAbilityIds:Array;
      
      public function EntityClassDefVars(param1:Object, param2:ILogger, param3:Locale)
      {
         var _loc4_:Object = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:EntityAppearanceDefVars = null;
         var _loc8_:Object = null;
         var _loc9_:String = null;
         var _loc10_:int = 0;
         this._requiredActiveAbilityIds = ["abl_end","abl_rest"];
         super(param3);
         EngineJsonDef.validateThrow(param1,schema,param2);
         id = param1.id;
         this._isWarped = param1.warped;
         this._hasSubmergedMove = param1.submergedMove;
         if(id == "berserk")
         {
            id = id;
         }
         _parentEntityClassId = param1.parent;
         _passive = param1.passive;
         _shadowUrl = param1.shadowUrl;
         _disableShadow = param1.disableShadow;
         _race = param1.race;
         _gender = param1.gender;
         _bounds = BoxVars.parse(param1.bounds,param2);
         for each(_loc4_ in param1.appearances)
         {
            _loc7_ = new EntityAppearanceDefVars(this,null);
            _loc7_.fromJson(_loc4_,param2);
            _appearanceDefs.push(_loc7_);
         }
         if(param1.propAnimUrl != undefined)
         {
            _propAnimUrl = param1.propAnimUrl;
         }
         if(param1.stats)
         {
            for each(_loc8_ in param1.stats)
            {
               StatRangeVars.parseInto(_statRanges,_loc8_,param2);
            }
         }
         if(!_statRanges.hasStatRange(StatType.RANK))
         {
            _statRanges.addStatRange(StatType.RANK,1,1);
         }
         if(param1.actives)
         {
            for each(_loc9_ in param1.actives)
            {
               _actives.push(_loc9_);
            }
         }
         for each(_loc5_ in this._requiredActiveAbilityIds)
         {
            if(_actives.indexOf(_loc5_) < 0)
            {
               _actives.push(_loc5_);
            }
         }
         if(param1.additionalActives)
         {
            for each(_loc9_ in param1.additionalActives)
            {
               _additionalActives.push(_loc9_);
            }
         }
         for each(_loc6_ in param1.attacks)
         {
            _attacks.push(_loc6_);
         }
         _mobile = BooleanVars.parse(param1.mobile,_mobile);
         _collidable = BooleanVars.parse(param1.collidable,_collidable);
         _playerClass = BooleanVars.parse(param1.playerClass,_playerClass);
         partyTag = param1.partyTag;
         if(_playerClass)
         {
            if(!statRanges.hasStatRange(StatType.INJURY_DAYS))
            {
               _statRanges.addStatRange(StatType.INJURY_DAYS,1,1);
            }
            if(!statRanges.hasStatRange(StatType.BASE_UPGRADES))
            {
               _loc10_ = EntitiesMetadata.DEFAULT_BASE_UPGRADES;
               _statRanges.addStatRange(StatType.BASE_UPGRADES,_loc10_,_loc10_);
            }
         }
      }
      
      public static function save(param1:EntityClassDef) : Object
      {
         var _loc3_:int = 0;
         var _loc4_:String = null;
         var _loc5_:StatRange = null;
         var _loc6_:Object = null;
         var _loc7_:EntityAppearanceDef = null;
         var _loc8_:Object = null;
         var _loc2_:Object = {
            "id":param1.id,
            "mobile":param1.mobile,
            "bounds":BoxVars.save(param1.bounds)
         };
         if(param1.isWarped)
         {
            _loc2_.warped = param1.isWarped;
         }
         if(param1.hasSubmergedMove)
         {
            _loc2_.submergedMove = param1.hasSubmergedMove;
         }
         if(param1.passive)
         {
            _loc2_.passive = param1.passive;
         }
         if(param1.parentEntityClassId)
         {
            _loc2_.parent = param1.parentEntityClassId;
         }
         if(param1.race)
         {
            _loc2_.race = param1.race;
         }
         if(param1.gender)
         {
            _loc2_.gender = param1.gender;
         }
         if(param1.disableShadow)
         {
            _loc2_.disableShadow = param1.disableShadow;
         }
         if(param1.shadowUrl)
         {
            _loc2_.shadowUrl = param1.shadowUrl;
         }
         if(param1.propAnimUrl)
         {
            _loc2_.propAnimUrl = param1.propAnimUrl;
         }
         if(Boolean(param1.actives) && Boolean(param1.actives.length))
         {
            _loc2_.actives = new Array();
            _loc3_ = 0;
            while(_loc3_ < param1.actives.length)
            {
               _loc2_.actives.push(param1.actives[_loc3_]);
               _loc3_++;
            }
         }
         if(Boolean(param1.additionalActives) && Boolean(param1.additionalActives.length))
         {
            _loc2_.additionalActives = [];
            for each(_loc4_ in param1.additionalActives)
            {
               _loc2_.additionalActives.push(_loc4_);
            }
         }
         if(Boolean(param1.attacks) && Boolean(param1.attacks.length))
         {
            _loc2_.attacks = new Array();
            _loc3_ = 0;
            while(_loc3_ < param1.attacks.length)
            {
               _loc2_.attacks.push(param1.attacks[_loc3_]);
               _loc3_++;
            }
         }
         if(Boolean(param1.statRanges) && Boolean(param1.statRanges.numStatRanges))
         {
            _loc2_.stats = new Array();
            _loc3_ = 0;
            while(_loc3_ < param1.statRanges.numStatRanges)
            {
               _loc5_ = param1.statRanges.getStatRangeByIndex(_loc3_);
               _loc6_ = StatRangeVars.save(_loc5_);
               _loc2_.stats.push(_loc6_);
               _loc3_++;
            }
         }
         if(param1.partyTag)
         {
            _loc2_.partyTag = param1.partyTag;
         }
         _loc2_.appearances = new Array();
         _loc3_ = 0;
         while(_loc3_ < param1.appearanceDefs.length)
         {
            _loc7_ = param1.appearanceDefs[_loc3_] as EntityAppearanceDef;
            _loc8_ = EntityAppearanceDefVars.save(_loc7_);
            _loc2_.appearances.push(_loc8_);
            _loc3_++;
         }
         if(!param1.playerClass)
         {
            _loc2_.playerClass = false;
         }
         return _loc2_;
      }
   }
}

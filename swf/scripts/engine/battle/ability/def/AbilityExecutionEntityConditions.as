package engine.battle.ability.def
{
   import engine.battle.ability.effect.def.AbilityReason;
   import engine.battle.ability.effect.def.BooleanValueReqs;
   import engine.battle.ability.effect.def.EffectTagReqs;
   import engine.battle.ability.effect.def.EffectTagReqsVars;
   import engine.battle.ability.effect.def.StringValueReqs;
   import engine.battle.ability.effect.model.IPersistedEffects;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.sim.IBattleParty;
   import engine.core.BoxString;
   import engine.core.logging.ILogger;
   import engine.def.BooleanVars;
   import engine.def.EngineJsonDef;
   import engine.stat.def.StatRange;
   import engine.stat.def.StatRangeVars;
   import engine.stat.def.StatRanges;
   import engine.stat.model.Stats;
   import engine.tile.def.TileRect;
   import engine.tile.def.TileRectRange;
   
   public class AbilityExecutionEntityConditions
   {
      
      public static const schema:Object = {
         "name":"AbilityExecutionEntityConditions",
         "properties":{
            "tag":{
               "type":EffectTagReqsVars.schema,
               "optional":true
            },
            "race":{
               "type":StringValueReqs.schema,
               "optional":true
            },
            "entityClass":{
               "type":StringValueReqs.schema,
               "optional":true
            },
            "entityDefId":{
               "type":StringValueReqs.schema,
               "optional":true
            },
            "team":{
               "type":StringValueReqs.schema,
               "optional":true
            },
            "requireInvisible":{
               "type":"boolean",
               "optional":true
            },
            "requireVisible":{
               "type":"boolean",
               "optional":true
            },
            "mobile":{
               "type":BooleanValueReqs.schema,
               "optional":true
            },
            "visualAlignment":{
               "type":"string",
               "optional":true
            },
            "requireAdjacentAlliesMin":{
               "type":"number",
               "optional":true
            },
            "statRanges":{
               "type":"array",
               "items":StatRangeVars.schema,
               "optional":true
            },
            "warped":{
               "type":BooleanValueReqs.schema,
               "optional":true
            },
            "visible":{
               "type":BooleanValueReqs.schema,
               "optional":true
            },
            "incorporeal":{
               "type":BooleanValueReqs.schema,
               "optional":true
            },
            "tileUnoccupied":{
               "type":BooleanValueReqs.schema,
               "optional":true
            }
         }
      };
      
      public static const empty:AbilityExecutionEntityConditions = new AbilityExecutionEntityConditions();
      
      public static const emptyJsonEverything:Object = empty.save(true);
       
      
      public var tag:EffectTagReqs;
      
      public var race:StringValueReqs;
      
      public var team:StringValueReqs;
      
      public var entityClass:StringValueReqs;
      
      public var entityDefId:StringValueReqs;
      
      public var requireInvisible:Boolean;
      
      public var requireVisible:Boolean;
      
      public var visualAlignment:String;
      
      public var requireAdjacentAlliesMin:int;
      
      public var statRanges:StatRanges;
      
      public var mobile:BooleanValueReqs;
      
      public var warped:BooleanValueReqs;
      
      public var incorporeal:BooleanValueReqs;
      
      public var visible:BooleanValueReqs;
      
      public var tileUnoccupied:BooleanValueReqs;
      
      public var _reason:BoxString;
      
      public var abilityReason:AbilityReason;
      
      public function AbilityExecutionEntityConditions()
      {
         this._reason = new BoxString();
         this.abilityReason = new AbilityReason();
         super();
      }
      
      public function checkExecutionConditions(param1:IBattleEntity, param2:ILogger, param3:Boolean, param4:BoxString = null) : Boolean
      {
         var _loc5_:IPersistedEffects = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:String = null;
         if(!param4)
         {
            param4 = this._reason;
         }
         param4.value = null;
         if(!param1)
         {
            return true;
         }
         if(this.tag)
         {
            _loc5_ = param1.effects;
            if(!this.tag.checkTags(_loc5_,param2,this.abilityReason))
            {
               param4.value = "tags_" + this.abilityReason.msg;
               return false;
            }
         }
         if(this.race)
         {
            _loc6_ = String(param1.def.entityClass.race);
            if(!this.race.checkValue(_loc6_,param2))
            {
               param4.value = "race";
               return false;
            }
         }
         if(this.team)
         {
            _loc7_ = param1.team;
            if(!this.team.checkValue(_loc7_,param2))
            {
               param4.value = "team";
               return false;
            }
         }
         if(!this.checkStatRanges(param1.stats))
         {
            param4.value = "statranges";
            return false;
         }
         if(this.entityClass)
         {
            _loc8_ = String(param1.def.entityClass.id);
            if(!this.entityClass.checkValue(_loc8_,param2))
            {
               param4.value = "entityClass";
               return false;
            }
         }
         if(this.entityDefId)
         {
            _loc9_ = String(param1.def.id);
            if(!this.entityDefId.checkValue(_loc9_,param2))
            {
               param4.value = "entityDefId";
               return false;
            }
         }
         if(param3)
         {
            if(this.requireInvisible && Boolean(param1.visible))
            {
               param4.value = "visibility";
               return false;
            }
            if(this.requireVisible && !param1.visible)
            {
               param4.value = "visibility";
               return false;
            }
            if(!BooleanValueReqs.check(this.mobile,param1.mobile))
            {
               param4.value = "mobility";
               return false;
            }
            if(!BooleanValueReqs.check(this.visible,param1.visible))
            {
               param4.value = "visibility";
               return false;
            }
            if(!BooleanValueReqs.check(this.warped,param1.def.isWarped))
            {
               param4.value = "warpity";
               return false;
            }
            if(!BooleanValueReqs.check(this.incorporeal,param1.incorporeal))
            {
               param4.value = "incorporeal";
               return false;
            }
         }
         if(this.tileUnoccupied)
         {
            if(!BooleanValueReqs.check(this.tileUnoccupied,!this._isCurrentTileBlockedForEntity(param1)))
            {
               param4.value = "tileBlocked";
               return false;
            }
         }
         if(!this.checkAdjacentAlliesMin(param1))
         {
            param4.value = "adjacency";
            return false;
         }
         return true;
      }
      
      public function checkStatRanges(param1:Stats) : Boolean
      {
         var _loc3_:StatRange = null;
         var _loc4_:int = 0;
         if(!this.statRanges)
         {
            return true;
         }
         var _loc2_:int = 0;
         while(_loc2_ < this.statRanges.numStatRanges)
         {
            _loc3_ = this.statRanges.getStatRangeByIndex(_loc2_);
            _loc4_ = !!param1 ? param1.getValue(_loc3_.type) : 0;
            if(_loc3_.min > _loc4_ || _loc3_.max < _loc4_)
            {
               return false;
            }
            _loc2_++;
         }
         return true;
      }
      
      public function checkAdjacentAlliesMin(param1:IBattleEntity) : Boolean
      {
         var _loc2_:TileRect = null;
         if(this.requireAdjacentAlliesMin)
         {
            _loc2_ = param1.rect;
            return this.checkAdjacentAlliesMinFromRect(param1,_loc2_);
         }
         return true;
      }
      
      private function _isCurrentTileBlockedForEntity(param1:IBattleEntity) : Boolean
      {
         if(Boolean(param1) && Boolean(param1.tiles))
         {
            return param1.tiles.isTileBlockedForEntity(param1,param1.tile,false,false,false);
         }
         return false;
      }
      
      public function checkAdjacentAlliesMinFromRect(param1:IBattleEntity, param2:TileRect) : Boolean
      {
         var _loc3_:IBattleParty = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:IBattleEntity = null;
         var _loc7_:int = 0;
         if(this.requireAdjacentAlliesMin)
         {
            _loc3_ = param1.party;
            if(_loc3_)
            {
               _loc5_ = 0;
               while(_loc5_ < _loc3_.numMembers)
               {
                  _loc6_ = _loc3_.getMember(_loc5_);
                  if(_loc6_ && _loc6_ != param1 && _loc6_.alive && _loc6_.active && Boolean(_loc6_.enabled))
                  {
                     _loc7_ = TileRectRange.computeRange(param2,_loc6_.rect);
                     if(_loc7_ <= 1)
                     {
                        _loc4_++;
                        if(_loc4_ >= this.requireAdjacentAlliesMin)
                        {
                           return true;
                        }
                     }
                  }
                  _loc5_++;
               }
            }
            return false;
         }
         return true;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : AbilityExecutionEntityConditions
      {
         var _loc3_:Object = null;
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.visualAlignment = param1.visualAlignment;
         this.requireAdjacentAlliesMin = param1.requireAdjacentAlliesMin;
         if(param1.tag)
         {
            this.tag = new EffectTagReqsVars(param1.tag,param2);
         }
         if(param1.race)
         {
            this.race = new StringValueReqs().fromJson(param1.race,param2);
         }
         if(param1.team)
         {
            this.team = new StringValueReqs().fromJson(param1.team,param2);
         }
         if(param1.entityClass)
         {
            this.entityClass = new StringValueReqs().fromJson(param1.entityClass,param2);
         }
         if(param1.entityDefId)
         {
            this.entityDefId = new StringValueReqs().fromJson(param1.entityDefId,param2);
         }
         if(param1.warped)
         {
            this.warped = new BooleanValueReqs().fromJson(param1.warped,param2);
         }
         if(param1.incorporeal)
         {
            this.incorporeal = new BooleanValueReqs().fromJson(param1.incorporeal,param2);
         }
         if(param1.tileUnoccupied)
         {
            this.tileUnoccupied = new BooleanValueReqs().fromJson(param1.tileUnoccupied,param2);
         }
         if(param1.mobile)
         {
            this.mobile = new BooleanValueReqs().fromJson(param1.mobile,param2);
         }
         this.requireInvisible = BooleanVars.parse(param1.requireInvisible,this.requireInvisible);
         this.requireVisible = BooleanVars.parse(param1.requireVisible,this.requireVisible);
         if(param1.statRanges != undefined)
         {
            this.statRanges = new StatRanges();
            for each(_loc3_ in param1.statRanges)
            {
               StatRangeVars.parseInto(this.statRanges,_loc3_,param2);
            }
         }
         return this;
      }
      
      public function save(param1:Boolean = false) : Object
      {
         var _loc2_:Object = {};
         if(param1 || Boolean(this.visualAlignment))
         {
            _loc2_.visualAlignment = !!this.visualAlignment ? this.visualAlignment : "";
         }
         if(param1 || Boolean(this.requireAdjacentAlliesMin))
         {
            _loc2_.requireAdjacentAlliesMin = this.requireAdjacentAlliesMin;
         }
         if(this.tag && !this.tag.isEmpty || param1)
         {
            _loc2_.tag = EffectTagReqsVars.save(this.tag,param1);
         }
         if(Boolean(this.race) && !this.race.isEmpty)
         {
            _loc2_.race = this.race.save(param1);
         }
         else if(param1)
         {
            _loc2_.race = StringValueReqs.emptyJsonEverything;
         }
         if(Boolean(this.team) && !this.team.isEmpty)
         {
            _loc2_.team = this.team.save(param1);
         }
         else if(param1)
         {
            _loc2_.team = StringValueReqs.emptyJsonEverything;
         }
         if(Boolean(this.entityClass) && !this.entityClass.isEmpty)
         {
            _loc2_.entityClass = this.entityClass.save(param1);
         }
         else if(param1)
         {
            _loc2_.entityClass = StringValueReqs.emptyJsonEverything;
         }
         if(Boolean(this.entityDefId) && !this.entityDefId.isEmpty)
         {
            _loc2_.entityDefId = this.entityDefId.save(param1);
         }
         else if(param1)
         {
            _loc2_.entityDefId = StringValueReqs.emptyJsonEverything;
         }
         if(this.requireInvisible || param1)
         {
            _loc2_.requireInvisible = this.requireInvisible;
         }
         if(this.requireVisible || param1)
         {
            _loc2_.requireVisible = this.requireVisible;
         }
         if(Boolean(this.mobile) && !this.mobile.isEmpty)
         {
            _loc2_.mobile = this.mobile.save(param1);
         }
         else if(param1)
         {
            _loc2_.warped = BooleanValueReqs.emptyJsonEverything;
         }
         if(Boolean(this.warped) && !this.warped.isEmpty)
         {
            _loc2_.warped = this.warped.save(param1);
         }
         else if(param1)
         {
            _loc2_.warped = BooleanValueReqs.emptyJsonEverything;
         }
         if(Boolean(this.incorporeal) && !this.incorporeal.isEmpty)
         {
            _loc2_.incorporeal = this.incorporeal.save(param1);
         }
         else if(param1)
         {
            _loc2_.incorporeal = BooleanValueReqs.emptyJsonEverything;
         }
         if(Boolean(this.tileUnoccupied) && !this.tileUnoccupied.isEmpty)
         {
            _loc2_.tileUnoccupied = this.tileUnoccupied.save(param1);
         }
         else if(param1)
         {
            _loc2_.tileUnoccupied = BooleanValueReqs.emptyJsonEverything;
         }
         return _loc2_;
      }
   }
}

package engine.saga
{
   import engine.battle.ability.effect.def.StringValueReqs;
   import engine.core.analytic.Ga;
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.IEntityListDef;
   import engine.saga.save.CaravanSave;
   import engine.saga.save.SagaSave;
   import engine.saga.vars.IVariable;
   import engine.saga.vars.IVariableBag;
   import engine.stat.def.StatRange;
   import engine.stat.def.StatType;
   import engine.stat.model.Stats;
   import flash.errors.IllegalOperationError;
   import flash.utils.Dictionary;
   
   public class SagaImportDef
   {
      
      public static const schema_RequiredVar:Object = {
         "name":"RequiredVars",
         "type":"object",
         "properties":{
            "name":{"type":"string"},
            "value":{"type":"number"}
         }
      };
      
      public static const schema_RequiredVars:Object = {
         "name":"RequiredVars",
         "type":"object",
         "properties":{
            "token":{"type":"string"},
            "vars":{
               "type":"array",
               "items":schema_RequiredVar
            },
            "operator":{"type":"string"}
         }
      };
      
      public static const schema:Object = {
         "name":"SagaImportDef",
         "type":"object",
         "properties":{
            "minRank":{"type":"number"},
            "importSagaId":{"type":"string"},
            "importSaveId":{"type":"string"},
            "caravans":{
               "type":"array",
               "items":{"properties":{
                  "src":{"type":"string"},
                  "dst":{"type":"string"},
                  "vars":{
                     "type":"array",
                     "items":"string"
                  }
               }}
            },
            "castVars":{
               "type":"array",
               "items":"string",
               "optional":true
            },
            "globalVars":{
               "type":"array",
               "items":{"properties":{
                  "src":{"type":"string"},
                  "dst":{"type":"string"},
                  "negate":{
                     "type":"boolean",
                     "optional":true
                  }
               }}
            },
            "marker_var":{"type":"string"},
            "achievement":{"type":"string"},
            "requiredVars":{
               "type":"array",
               "items":schema_RequiredVars,
               "optional":true
            },
            "last_checkpoint_save_id":{
               "type":StringValueReqs.schema,
               "optional":true
            },
            "saga_id":{
               "type":StringValueReqs.schema,
               "optional":true
            }
         }
      };
       
      
      public var importSaveId:String;
      
      public var importSagaId:String;
      
      public var globalVars:Array;
      
      public var caravans:Array;
      
      public var castVars:Array;
      
      public var castVarsDict:Dictionary;
      
      public var minRank:int;
      
      public var minVersion:int = 2;
      
      public var maxVersion:int = 2;
      
      private var requiredVars:RequiredVarsList;
      
      public var marker_var:String;
      
      public var achievement:String;
      
      public var last_checkpoint_save_id:StringValueReqs;
      
      public var saga_id:StringValueReqs;
      
      public function SagaImportDef()
      {
         this.requiredVars = new RequiredVarsList();
         super();
      }
      
      public static function doApplyMinimumRank(param1:Saga, param2:int) : void
      {
         var _loc3_:IEntityListDef = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:IEntityDef = null;
         var _loc7_:Stats = null;
         var _loc8_:StatRange = null;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         param2++;
         if(param2)
         {
            _loc3_ = param1.def.cast;
            _loc4_ = _loc3_.numEntityDefs;
            _loc5_ = 0;
            while(_loc5_ < _loc4_)
            {
               _loc6_ = _loc3_.getEntityDef(_loc5_);
               if(_loc6_.saves)
               {
                  _loc7_ = _loc6_.stats;
                  if(_loc7_.rank < param2)
                  {
                     _loc8_ = _loc6_.statRanges.getStatRange(StatType.RANK);
                     if(_loc8_)
                     {
                        _loc9_ = Math.min(param2,_loc8_.max);
                        if(_loc9_ > _loc7_.rank)
                        {
                           if(param1.logger)
                           {
                              param1.logger.info("Force-ranking [" + _loc6_.id + "] from " + _loc7_.rank + " to " + _loc9_);
                           }
                           _loc7_.rank = _loc9_;
                           if(_loc9_ > 1)
                           {
                              _loc10_ = _loc7_.getBase(StatType.KILLS);
                              _loc11_ = param1.def.unitStatCosts.getKillsRequiredToPromote(_loc9_ - 1);
                              if(_loc10_ < _loc11_)
                              {
                                 _loc7_.setBase(StatType.KILLS,_loc11_);
                              }
                           }
                        }
                     }
                  }
               }
               _loc5_++;
            }
         }
      }
      
      public function fromJson(param1:Object, param2:ILogger) : SagaImportDef
      {
         var _loc3_:String = null;
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.importSaveId = param1.importSaveId;
         if(!this.importSaveId)
         {
            throw new ArgumentError("need an importSaveId if you want to import a save.  perhaps saga1=sav_finale, saga2=sav_saga2_finale");
         }
         this.importSagaId = param1.importSagaId;
         if(!this.importSagaId)
         {
            throw new ArgumentError("need an importSagaId if you want to import a save.  perhaps saga1,saga2");
         }
         this.globalVars = param1.globalVars;
         this.caravans = param1.caravans;
         this.minRank = param1.minRank;
         this.marker_var = param1.marker_var;
         this.achievement = param1.achievement;
         if(param1.last_checkpoint_save_id)
         {
            this.last_checkpoint_save_id = new StringValueReqs().fromJson(param1.last_checkpoint_save_id,param2);
         }
         if(param1.saga_id)
         {
            this.saga_id = new StringValueReqs().fromJson(param1.saga_id,param2);
         }
         if(param1.castVars)
         {
            this.castVars = param1.castVars;
            this.castVarsDict = new Dictionary();
            for each(_loc3_ in this.castVars)
            {
               this.castVarsDict[_loc3_] = true;
            }
         }
         if(param1.requiredVars)
         {
            this.requiredVars.fromJson(param1.requiredVars,param2);
         }
         return this;
      }
      
      public function toJson() : Object
      {
         var _loc1_:Object = {
            "globalVars":this.globalVars,
            "importSagaId":this.importSagaId,
            "importSaveId":this.importSaveId,
            "caravans":this.caravans,
            "minRank":this.minRank
         };
         if(this.castVars)
         {
            _loc1_.castVars = this.castVars;
         }
         _loc1_.marker_var = !!this.marker_var ? this.marker_var : "";
         _loc1_.achievement = !!this.achievement ? this.achievement : "";
         _loc1_.requiredVars = this.requiredVars.toJson();
         if(this.last_checkpoint_save_id)
         {
            _loc1_.last_checkpoint_save_id = this.last_checkpoint_save_id.save(false);
         }
         if(this.saga_id)
         {
            _loc1_.saga_id = this.saga_id.save(false);
         }
         return _loc1_;
      }
      
      public function doImport(param1:SagaSave, param2:Saga) : void
      {
         var _loc3_:Object = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc8_:IVariableBag = null;
         var _loc9_:Boolean = false;
         var _loc10_:* = undefined;
         var _loc11_:IVariable = null;
         var _loc12_:CaravanSave = null;
         var _loc13_:String = null;
         var _loc14_:Caravan = null;
         var _loc15_:Array = null;
         var _loc16_:String = null;
         var _loc17_:IEntityDef = null;
         if(!param1 || !param2)
         {
            return;
         }
         var _loc6_:ILogger = param2.logger;
         _loc6_.info("SAGA IMPORT ... " + param1.toString() + " @ " + param1.date + " build " + param1.build + " version " + param1.version);
         if(param1.version < this.minVersion)
         {
            _loc6_.error("SAGA IMPORT version too old");
            return;
         }
         if(param1.version > this.minVersion)
         {
            _loc6_.error("SAGA IMPORT version too new");
            return;
         }
         if(this.globalVars)
         {
            _loc8_ = param2.global;
            for each(_loc3_ in this.globalVars)
            {
               _loc4_ = _loc3_.src;
               _loc5_ = _loc3_.dst;
               _loc9_ = Boolean(_loc3_.negate);
               _loc10_ = param1.globalVars[_loc4_];
               _loc11_ = _loc8_.fromDictionaryKey(_loc4_,_loc5_,param1.globalVars,_loc6_,_loc9_);
               if(!_loc11_)
               {
                  _loc6_.error("SAGA IMPORT failed for var [" + _loc4_ + "] = " + _loc10_ + " -> [" + _loc5_ + "]");
               }
               else
               {
                  _loc6_.info("SAGA IMPORT var [" + _loc4_ + "] = " + _loc10_ + " -> [" + _loc5_ + "] = " + _loc11_.asString);
                  Ga.normal("import","var_global",_loc11_.def.name,_loc11_.asInteger);
               }
            }
         }
         if(this.caravans)
         {
            for each(_loc3_ in this.caravans)
            {
               _loc4_ = _loc3_.src;
               _loc5_ = _loc3_.dst;
               _loc12_ = param1.caravansByName[_loc4_];
               if(!_loc12_)
               {
                  _loc13_ = !!param1.caravans ? param1.caravans.join(",") : null;
                  throw new IllegalOperationError("impossible to copy from caravan " + _loc4_ + " to " + _loc5_ + ": source caravan does not exist.  valids=" + _loc13_);
               }
               _loc14_ = param2.getCaravan(_loc5_) as Caravan;
               if(!_loc14_)
               {
                  _loc13_ = !!param2.def.caravans ? param2.def.caravans.join(",") : null;
                  throw new IllegalOperationError("impossible to copy from caravan " + _loc4_ + " to " + _loc5_ + ": target caravan does not exist. valids=" + _loc13_);
               }
               _loc14_._legend.loadFromSave(_loc12_.legend,false);
               Ga.normal("import","renown",_loc14_.def.name + "._renown",_loc14_._legend.renown);
               _loc15_ = _loc3_.vars;
               if(_loc15_)
               {
                  if(_loc12_.vars)
                  {
                     for each(_loc16_ in _loc15_)
                     {
                        _loc11_ = _loc14_.vars.fromDictionaryKey(_loc16_,_loc16_,_loc12_.vars,_loc6_,false);
                        if(_loc11_)
                        {
                           Ga.normal("import","var_caravan",_loc14_.def.name + "." + _loc11_.def.name,_loc11_.asInteger);
                           _loc6_.info("SAGA IMPORT var [" + _loc14_.def.name + "." + _loc11_.def.name + "=" + _loc11_.asString + "]");
                        }
                     }
                  }
               }
            }
         }
         param1.applyCastInfo(param2,this.castVarsDict);
         var _loc7_:int = 0;
         while(_loc7_ < param2.def.cast.numEntityDefs)
         {
            _loc17_ = param2.def.cast.getEntityDef(_loc7_);
            if(_loc17_ && _loc17_.saves && _loc17_.combatant && param1.cast_info && Boolean(param1.cast_info[_loc17_.id]))
            {
               Ga.normal("import","cast_rank",_loc17_.id,_loc17_.stats.rank);
            }
            _loc7_++;
         }
         doApplyMinimumRank(param2,this.minRank);
         if(this.marker_var)
         {
            param2.setVar(this.marker_var,true);
         }
         else
         {
            _loc6_.error("No marker var for SagaImportDef");
         }
         if(this.achievement)
         {
            SagaAchievements.unlockAchievementById(this.achievement,param2.minutesPlayed,true);
         }
      }
      
      public function checkRequirements(param1:SagaSave) : String
      {
         if(this.saga_id)
         {
            if(!this.saga_id.checkValue(param1.saga_id,null))
            {
               return "saga_id";
            }
         }
         if(this.last_checkpoint_save_id)
         {
            if(!this.last_checkpoint_save_id.checkValue(param1.last_checkpoint_save_id,null))
            {
               return "last_checkpoint_save_id";
            }
         }
         return this.requiredVars.checkRequirements(param1);
      }
      
      private function checkGlobal(param1:Object, param2:SagaSave) : Boolean
      {
         if(param2.globalVars[param1.src])
         {
            if(!param1.negate)
            {
               return true;
            }
         }
         else if(param1.src == "7 alettedoomed" && Boolean(param2.globalVars["7_alettedoomed"]))
         {
            if(!param1.negate)
            {
               return true;
            }
         }
         else if(param1.negate)
         {
            return true;
         }
         return false;
      }
      
      public function determineWho(param1:SagaSave) : String
      {
         var _loc2_:Object = null;
         for each(_loc2_ in this.globalVars)
         {
            if(_loc2_.dst == "hero_rook" && this.checkGlobal(_loc2_,param1))
            {
               return "rook";
            }
            if(_loc2_.dst == "hero_alette" && this.checkGlobal(_loc2_,param1))
            {
               return "alette";
            }
         }
         return null;
      }
   }
}

import engine.core.logging.ILogger;
import engine.saga.save.SagaSave;

class RequiredVar
{
    
   
   public var name:String;
   
   public var value:Number = 0;
   
   public function RequiredVar()
   {
      super();
   }
   
   public function fromJson(param1:Object, param2:ILogger) : RequiredVar
   {
      this.name = param1.name;
      this.value = param1.value;
      return this;
   }
   
   public function toJson() : Object
   {
      return {
         "name":this.name,
         "value":this.value
      };
   }
   
   public function checkRequirements(param1:SagaSave) : Boolean
   {
      var _loc2_:* = param1.globalVars[this.name];
      if(!_loc2_ == this.value)
      {
         _loc2_ = param1.globalVars[this.name.replace(/ /g,"_")];
         return _loc2_ == this.value;
      }
      return true;
   }
}

import engine.core.logging.ILogger;
import engine.saga.save.SagaSave;

class RequiredVars
{
    
   
   public var vars:Vector.<RequiredVar>;
   
   public var op:String;
   
   public var token:String = "unknown";
   
   public function RequiredVars()
   {
      this.vars = new Vector.<RequiredVar>();
      super();
   }
   
   public function fromJson(param1:Object, param2:ILogger) : RequiredVars
   {
      var _loc3_:Object = null;
      var _loc4_:RequiredVar = null;
      for each(_loc3_ in param1.vars)
      {
         _loc4_ = new RequiredVar().fromJson(_loc3_,param2);
         this.vars.push(_loc4_);
      }
      this.op = param1.operator;
      if(param1.token)
      {
         this.token = param1.token;
      }
      return this;
   }
   
   public function checkRequirements(param1:SagaSave) : Boolean
   {
      var _loc3_:RequiredVar = null;
      var _loc2_:Boolean = false;
      for each(_loc3_ in this.vars)
      {
         _loc2_ = _loc3_.checkRequirements(param1);
         if(_loc2_)
         {
            if(this.op == "or")
            {
               return true;
            }
         }
         else if(this.op == "and")
         {
            return false;
         }
      }
      return _loc2_;
   }
   
   public function toJson() : Object
   {
      var _loc2_:RequiredVar = null;
      var _loc1_:Object = {
         "operator":this.op,
         "token":this.token,
         "vars":[]
      };
      for each(_loc2_ in this.vars)
      {
         _loc1_.vars.push(_loc2_.toJson());
      }
      return _loc1_;
   }
}

import engine.core.logging.ILogger;
import engine.saga.save.SagaSave;

class RequiredVarsList
{
    
   
   public var requiredVars:Vector.<RequiredVars>;
   
   public function RequiredVarsList()
   {
      this.requiredVars = new Vector.<RequiredVars>();
      super();
   }
   
   public function fromJson(param1:Array, param2:ILogger) : RequiredVarsList
   {
      var _loc3_:Object = null;
      var _loc4_:RequiredVars = null;
      for each(_loc3_ in param1)
      {
         _loc4_ = new RequiredVars().fromJson(_loc3_,param2);
         this.requiredVars.push(_loc4_);
      }
      return this;
   }
   
   public function checkRequirements(param1:SagaSave) : String
   {
      var _loc2_:RequiredVars = null;
      for each(_loc2_ in this.requiredVars)
      {
         if(!_loc2_.checkRequirements(param1))
         {
            return _loc2_.token;
         }
      }
      return null;
   }
   
   public function toJson() : Object
   {
      var _loc2_:RequiredVars = null;
      var _loc1_:Array = [];
      for each(_loc2_ in this.requiredVars)
      {
         _loc1_.push(_loc2_.toJson());
      }
      return _loc1_;
   }
}

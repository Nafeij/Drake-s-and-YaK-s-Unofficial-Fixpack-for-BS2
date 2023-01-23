package engine.saga
{
   import engine.core.logging.ILogger;
   import engine.entity.def.IEntityDef;
   import engine.saga.vars.IBattleEntityProvider;
   import engine.saga.vars.IVariable;
   import engine.saga.vars.IVariableBag;
   import engine.saga.vars.IVariableProvider;
   import engine.saga.vars.Variable;
   import engine.saga.vars.VariableBag;
   import engine.saga.vars.VariableDef;
   import engine.saga.vars.VariableEvent;
   import engine.saga.vars.VariableFactory;
   import engine.saga.vars.VariableType;
   import flash.utils.Dictionary;
   
   public class SagaVariableProvider implements IVariableProvider
   {
       
      
      public var _global:VariableBag;
      
      public var _cnv:VariableBag;
      
      public var _scene:VariableBag;
      
      public var _cnvn:VariableBag;
      
      public var logger:ILogger;
      
      public var vardefs:IVariableDefProvider;
      
      public var cleanedup:Boolean;
      
      public var castProvider:ISagaCastProvider;
      
      public var caravanProvider:ISagaCaravanProvider;
      
      public var sagaLog:ISagaLog;
      
      private var _fglobal:Function;
      
      private var _fother:Function;
      
      public function SagaVariableProvider(param1:String, param2:IVariableDefProvider, param3:ISagaCastProvider, param4:ISagaCaravanProvider, param5:IBattleEntityProvider, param6:ISagaLog, param7:ILogger)
      {
         var _loc8_:Vector.<VariableDef> = null;
         var _loc9_:VariableDef = null;
         var _loc10_:Variable = null;
         super();
         this.logger = param7;
         this.castProvider = param3;
         this.caravanProvider = param4;
         this._global = new VariableBag("global",param2,param5,param7);
         this._cnv = new VariableBag("cnv",null,param5,param7);
         this._scene = new VariableBag("scene",null,param5,param7);
         this._cnvn = new VariableBag("cnvn",null,param5,param7);
         this.sagaLog = param6;
         this.vardefs = param2;
         if(param2)
         {
            _loc8_ = param2.getVariables();
            for each(_loc9_ in _loc8_)
            {
               _loc10_ = VariableFactory.factory(param5,_loc9_,param7);
               if(!_loc10_.def.perCaravan && !_loc10_.def.perUnit)
               {
                  this._global.add(_loc10_);
               }
            }
         }
      }
      
      public function enumerateVarsNames(param1:Vector.<String>) : Vector.<String>
      {
         this._global.enumerateVarsNames(param1);
         this._cnv.enumerateVarsNames(param1);
         this._cnvn.enumerateVarsNames(param1);
         this._scene.enumerateVarsNames(param1);
         return param1;
      }
      
      public function fromDictionary(param1:Dictionary, param2:ILogger) : void
      {
         this._global.fromDictionary(param1,param2);
      }
      
      public function resetAll() : void
      {
         this._global.resetAll();
         this._cnv.resetAll();
         this._cnvn.resetAll();
         this._scene.resetAll();
      }
      
      public function forEachVar(param1:Function) : void
      {
         var _loc2_:Variable = null;
         for each(_loc2_ in this._global.vars)
         {
            param1(_loc2_);
         }
      }
      
      public function listenToVars(param1:Function, param2:ISagaMetrics, param3:Function) : void
      {
         this._fglobal = param1;
         this._fother = param3;
         this._global.addEventListener(VariableEvent.TYPE,this._fglobal);
         this._cnv.addEventListener(VariableEvent.TYPE,this._fother);
         this._cnv.addEventListener(VariableEvent.TYPE,this._fother);
         this._scene.addEventListener(VariableEvent.TYPE,this._fother);
         this._global.initMetricsVariables(param2);
      }
      
      public function unlistenToVars() : void
      {
         this._global.removeEventListener(VariableEvent.TYPE,this._fglobal);
         this._cnv.removeEventListener(VariableEvent.TYPE,this._fother);
         this._scene.removeEventListener(VariableEvent.TYPE,this._fother);
      }
      
      public function notifyVarGaCustoms(param1:Function) : void
      {
         var _loc2_:VariableDef = null;
         var _loc3_:IVariable = null;
         if(!this.vardefs || this.cleanedup)
         {
            return;
         }
         for each(_loc2_ in this.vardefs.getVariables())
         {
            if(Boolean(_loc2_.ga_custom_metric) || Boolean(_loc2_.ga_custom_dimension))
            {
               _loc3_ = this._global.fetch(_loc2_.name,null);
               if(_loc3_)
               {
                  param1(_loc3_);
               }
            }
         }
      }
      
      public function incrementGlobalVar(param1:String, param2:Boolean, param3:int = 1) : int
      {
         var _loc4_:IVariable = this._global.fetch(param1,null);
         if(_loc4_)
         {
            if(_loc4_.def.achievement_stat)
            {
               if(param2)
               {
                  this.logger.info("Suppressed Achievements blocks increment of " + param1);
                  return _loc4_.asInteger;
               }
            }
            _loc4_.asInteger += param3;
            return _loc4_.asInteger;
         }
         return 0;
      }
      
      public function modifyGlobalVar(param1:String, param2:Boolean, param3:Number) : Number
      {
         var _loc4_:IVariable = this._global.fetch(param1,null);
         if(_loc4_)
         {
            if(Boolean(_loc4_.def.achievement_stat) && param2)
            {
               this.logger.info("Suppressed Achievements blocks modifications of " + param1 + " by " + param3);
               return _loc4_.asNumber;
            }
            _loc4_.asNumber += param3;
            return _loc4_.asNumber;
         }
         return 0;
      }
      
      public function setMaxGlobalVar(param1:String, param2:Boolean, param3:Number) : Number
      {
         var _loc4_:IVariable = this._global.fetch(param1,null);
         if(_loc4_)
         {
            if(Boolean(_loc4_.def.achievement_stat) && param2)
            {
               this.logger.info("Suppressed Achievements blocks setting of " + param1 + " to " + param3);
               return _loc4_.asNumber;
            }
            _loc4_.asNumber = Math.max(_loc4_.asNumber,param3);
            return _loc4_.asNumber;
         }
         return 0;
      }
      
      public function checkMinGlobal(param1:String, param2:String) : void
      {
         var _loc4_:IVariable = null;
         var _loc3_:IVariable = this._global.fetch(param1,null);
         if(_loc3_)
         {
            _loc4_ = this.getVar(param2,null);
            if(_loc4_)
            {
               _loc3_.asInteger = Math.min(_loc4_.asInteger,_loc3_.asInteger);
            }
         }
      }
      
      public function cleanup() : void
      {
         this.cleanedup = true;
      }
      
      public function getVar(param1:String, param2:VariableType) : IVariable
      {
         var _loc7_:VariableDef = null;
         if(!param1)
         {
            return null;
         }
         var _loc3_:String = null;
         var _loc4_:String = param1;
         var _loc5_:int = param1.indexOf(".");
         if(_loc5_ > 0)
         {
            _loc3_ = param1.substr(0,_loc5_);
            _loc4_ = param1.substr(_loc5_ + 1);
         }
         else if(this.vardefs)
         {
            _loc7_ = this.vardefs.getVariableDefByName(param1);
            if(_loc7_)
            {
               if(_loc7_.perCaravan)
               {
                  _loc3_ = "caravan";
               }
            }
         }
         var _loc6_:IVariableBag = this.getBag(_loc3_);
         return !!_loc6_ ? _loc6_.fetch(_loc4_,param2) : null;
      }
      
      public function getBag(param1:String) : IVariableBag
      {
         var _loc2_:IEntityDef = null;
         var _loc3_:IVariableBag = null;
         var _loc4_:ICaravan = null;
         if(!param1 || param1 == this._global.name)
         {
            return this._global;
         }
         if(param1 == this._cnv.name)
         {
            return this._cnv;
         }
         if(param1 == this._cnvn.name)
         {
            return this._cnvn;
         }
         if(param1 == this._scene.name)
         {
            return this._scene;
         }
         if(this.castProvider)
         {
            _loc2_ = this.castProvider.getCastMember(param1);
            _loc3_ = !!_loc2_ ? _loc2_.vars : null;
            if(_loc3_)
            {
               return _loc3_;
            }
         }
         if(this.caravanProvider)
         {
            _loc4_ = this.caravanProvider.getCaravan(param1);
            if(_loc4_)
            {
               return _loc4_.vars;
            }
         }
         return null;
      }
      
      public function setVar(param1:String, param2:*) : IVariable
      {
         var _loc9_:VariableDef = null;
         var _loc10_:String = null;
         if(this.cleanedup)
         {
            return null;
         }
         var _loc3_:String = null;
         var _loc4_:String = param1;
         var _loc5_:int = param1.indexOf(".");
         if(_loc5_ > 0)
         {
            _loc3_ = param1.substr(0,_loc5_);
            _loc4_ = param1.substr(_loc5_ + 1);
         }
         else if(this.vardefs)
         {
            _loc9_ = this.vardefs.getVariableDefByName(param1);
            if(_loc9_)
            {
               if(_loc9_.perCaravan)
               {
                  _loc3_ = "caravan";
               }
            }
         }
         var _loc6_:IVariableBag = this.getBag(_loc3_);
         if(!_loc6_)
         {
            this.logger.error("   VAR bag not found " + _loc3_);
            return null;
         }
         var _loc7_:VariableType = VariableType.findType(param2);
         var _loc8_:IVariable = _loc6_.fetch(_loc4_,_loc7_);
         if(param2 == "NaN" || isNaN(param2))
         {
            param2 = param2;
         }
         if(_loc3_ != "cnvn")
         {
            if(_loc8_.value != param2)
            {
               _loc10_ = "VAR " + _loc8_.fullname + "=" + param2;
               this.sagaLog && this.sagaLog.appendItemInstant(_loc10_,null);
               this.logger.i("SAGA","   " + _loc10_);
            }
         }
         _loc8_.asAny = param2;
         return _loc8_;
      }
      
      public function removeVar(param1:String) : void
      {
         var _loc2_:IVariable = this.getVar(param1,null);
         if(_loc2_)
         {
            _loc2_.bag.removeVar(_loc2_);
         }
      }
      
      public function getVarBool(param1:String) : Boolean
      {
         var _loc2_:IVariable = this.getVar(param1,null);
         return Boolean(_loc2_) && _loc2_.asBoolean;
      }
      
      public function getVarInt(param1:String) : int
      {
         var _loc2_:IVariable = this.getVar(param1,null);
         return !!_loc2_ ? _loc2_.asInteger : 0;
      }
      
      public function getVarString(param1:String) : String
      {
         var _loc2_:IVariable = this.getVar(param1,null);
         return !!_loc2_ ? _loc2_.asString : null;
      }
      
      public function getVarNumber(param1:String) : Number
      {
         var _loc2_:IVariable = this.getVar(param1,null);
         return !!_loc2_ ? _loc2_.asNumber : 0;
      }
      
      public function getSymbolValue(param1:String, param2:Boolean) : Number
      {
         var _loc4_:* = null;
         var _loc3_:IVariable = this.getVar(param1,null);
         if(_loc3_)
         {
            return _loc3_.asNumber;
         }
         param2 = false;
         if(!param2)
         {
            if(this.logger.isDebugEnabled)
            {
               _loc4_ = "Symbolic request for unknown variable [" + param1 + "] returns zero";
               if(Boolean(param1) && param1.charAt(0) == "_")
               {
                  this.logger.debug(_loc4_);
               }
               else
               {
                  this.logger.debug(_loc4_);
               }
            }
            return 0;
         }
         throw new ArgumentError("Symbolic request for unknown variable [" + param1 + "]");
      }
   }
}

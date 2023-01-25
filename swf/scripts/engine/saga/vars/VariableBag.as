package engine.saga.vars
{
   import engine.core.logging.ILogger;
   import engine.core.logging.Logger;
   import engine.core.util.StringUtil;
   import engine.saga.ISagaMetrics;
   import engine.saga.IVariableDefProvider;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class VariableBag extends EventDispatcher implements IVariableBag
   {
       
      
      public var _name:String;
      
      public var _vars:Dictionary;
      
      public var binds:Dictionary;
      
      public var _owner:IVariableDefProvider;
      
      public var disable_metrics:Boolean = false;
      
      public var logger:ILogger;
      
      public var bbp:IBattleEntityProvider;
      
      public function VariableBag(param1:String, param2:IVariableDefProvider, param3:IBattleEntityProvider, param4:ILogger)
      {
         this._vars = new Dictionary();
         this.binds = new Dictionary();
         super();
         this._name = param1;
         this._owner = param2;
         this.logger = param4;
         this.bbp = param3;
      }
      
      public static function fromJsonToDictionary(param1:Object) : Dictionary
      {
         var _loc2_:Dictionary = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         if(param1)
         {
            for(_loc3_ in param1)
            {
               _loc4_ = String(param1[_loc3_]);
               if(_loc4_)
               {
                  if(_loc4_ == "NaN")
                  {
                     _loc4_ = "";
                  }
                  if(!_loc2_)
                  {
                     _loc2_ = new Dictionary();
                  }
                  _loc3_ = _loc3_.replace(/ /g,"_");
                  _loc2_[_loc3_] = _loc4_;
               }
            }
         }
         return _loc2_;
      }
      
      public static function toJsonFromDictionary(param1:Dictionary) : Object
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         if(!param1)
         {
            return null;
         }
         var _loc2_:Object = {};
         for(_loc3_ in param1)
         {
            _loc4_ = String(param1[_loc3_]);
            _loc2_[_loc3_] = _loc4_;
         }
         return _loc2_;
      }
      
      public function get owner() : IVariableDefProvider
      {
         return this._owner;
      }
      
      public function get vars() : Dictionary
      {
         return this._vars;
      }
      
      public function cleanup() : void
      {
         this._vars = null;
         this.binds = null;
         this._owner = null;
      }
      
      public function enumerateVarsNames(param1:Vector.<String>) : Vector.<String>
      {
         var _loc2_:String = null;
         for(_loc2_ in this.vars)
         {
            if(!param1)
            {
               param1 = new Vector.<String>();
            }
            if(this._name)
            {
               param1.push(this._name + "." + _loc2_);
            }
            else
            {
               param1.push(_loc2_);
            }
         }
         return param1;
      }
      
      public function toDictionary(param1:ILogger) : Dictionary
      {
         var _loc2_:Dictionary = null;
         var _loc3_:Variable = null;
         for each(_loc3_ in this.vars)
         {
            if(!(_loc3_.def.transient || _loc3_.def.scripted || Boolean(_loc3_.def.bind)))
            {
               if(!_loc3_.isDefault(param1))
               {
                  if(!_loc2_)
                  {
                     _loc2_ = new Dictionary();
                  }
                  _loc2_[_loc3_.def.name] = _loc3_._value;
               }
            }
         }
         return _loc2_;
      }
      
      public function fromDictionary(param1:Dictionary, param2:ILogger) : void
      {
         var _loc3_:String = null;
         if(!param1)
         {
            return;
         }
         for(_loc3_ in param1)
         {
            this.fromDictionaryKey(_loc3_,_loc3_,param1,param2,false);
         }
      }
      
      private function _determineImportSourceValue(param1:String, param2:Dictionary) : *
      {
         var _loc4_:VariableDef = null;
         var _loc3_:* = param2[param1];
         if(_loc3_ == undefined)
         {
            param1 = StringUtil.stripSurroundingSpace(param1).replace(/ /g,"_");
            _loc3_ = param2[param1];
            if(_loc3_ == undefined)
            {
               _loc4_ = this._owner.getVariableDefByName(param1);
               if(_loc4_)
               {
                  _loc3_ = _loc4_.start;
               }
            }
         }
         return _loc3_;
      }
      
      private function _discoverImportTargetVariable(param1:String) : IVariable
      {
         var _loc2_:IVariable = this.fetch(param1,null);
         if(!_loc2_)
         {
            _loc2_ = this.fetch(param1,VariableType.INTEGER);
            _loc2_.def.lowerBound = 0;
         }
         else if(_loc2_.def.bind || _loc2_.def.scripted || _loc2_.def.transient)
         {
            return null;
         }
         return _loc2_;
      }
      
      public function fromDictionaryKey(param1:String, param2:String, param3:Dictionary, param4:ILogger, param5:Boolean) : IVariable
      {
         var _loc8_:String = null;
         if(!param3 || !param1 || !param2)
         {
            return null;
         }
         var _loc6_:* = this._determineImportSourceValue(param1,param3);
         var _loc7_:IVariable = this._discoverImportTargetVariable(param2);
         if(!_loc7_)
         {
            return null;
         }
         if(_loc6_ != undefined)
         {
            _loc8_ = _loc6_;
            _loc7_.asAny = _loc8_;
         }
         if(param5)
         {
            _loc7_.asBoolean = !_loc6_;
         }
         return _loc7_;
      }
      
      public function resetAll() : void
      {
         var _loc1_:Variable = null;
         for each(_loc1_ in this.vars)
         {
            if(!_loc1_.def.bind && !_loc1_.def.scripted)
            {
               if(_loc1_.def.type == VariableType.STRING)
               {
                  _loc1_.asAny = _loc1_.def.start_str;
               }
               else
               {
                  _loc1_.asAny = _loc1_.def.start;
                  if(Boolean(_loc1_.def.start) && _loc1_.asNumber != _loc1_.def.start)
                  {
                     if(Logger.instance)
                     {
                        Logger.instance.error("VariableBag.resetAll failed to start " + _loc1_.def.name + " expected " + _loc1_.def.start + " actual " + _loc1_.asNumber);
                     }
                  }
               }
            }
         }
      }
      
      public function removeVar(param1:IVariable) : void
      {
         var _loc2_:String = param1.def.name;
         delete this._vars[_loc2_];
         delete this.binds[_loc2_];
      }
      
      public function fetch(param1:String, param2:VariableType) : IVariable
      {
         var _loc5_:VariableDef = null;
         var _loc6_:VariableDef = null;
         if(!this.vars || !param1)
         {
            return null;
         }
         var _loc3_:* = this.vars[param1];
         var _loc4_:Variable = _loc3_ as Variable;
         if(!_loc4_)
         {
            _loc5_ = !!this.owner ? this.owner.getVariableDefByName(param1) : null;
            if(_loc5_)
            {
               _loc4_ = new Variable(_loc5_,this.logger);
               _loc4_.bag = this;
               this.add(_loc4_);
               return _loc4_;
            }
         }
         if(!_loc4_ && Boolean(param2))
         {
            _loc6_ = new VariableDef();
            if(param2 == VariableType.BOOLEAN)
            {
               _loc6_.lowerBound = 0;
               _loc6_.upperBound = 1;
            }
            else if(param2 == VariableType.INTEGER || param2 == VariableType.DECIMAL)
            {
               _loc6_.lowerBound = 0;
               _loc6_.start = 0;
            }
            _loc6_.name = param1;
            _loc6_.type = param2;
            _loc6_.transient = true;
            _loc4_ = VariableFactory.factory(this.bbp,_loc6_,this.logger);
            _loc4_.bag = this;
            this.add(_loc4_);
         }
         return _loc4_;
      }
      
      public function getVarInt(param1:String) : int
      {
         var _loc2_:IVariable = this.fetch(param1,null);
         return !!_loc2_ ? _loc2_.asInteger : 0;
      }
      
      public function getVarBool(param1:String) : Boolean
      {
         var _loc2_:IVariable = this.fetch(param1,null);
         return Boolean(_loc2_) && _loc2_.asBoolean;
      }
      
      public function setVar(param1:String, param2:*) : IVariable
      {
         var _loc3_:IVariable = this.fetch(param1,null);
         if(_loc3_)
         {
            _loc3_.asAny = param2;
         }
         return _loc3_;
      }
      
      public function incrementVar(param1:String, param2:int) : void
      {
         var _loc3_:int = this.getVarInt(param1);
         this.setVar(param1,_loc3_ + param2);
      }
      
      public function add(param1:IVariable) : void
      {
         var _loc2_:Variable = this.vars[param1.def.name];
         if(_loc2_)
         {
            this.removeBinding(param1);
         }
         this.vars[param1.def.name] = param1;
         param1.bag = this;
         if(param1.def.bind)
         {
            this.addBinding(param1);
         }
         this.updateBindingFromSrc(param1.def.name);
      }
      
      public function handleVariableChange(param1:IVariable, param2:String) : void
      {
         var _loc3_:Variable = param1 as Variable;
         this.updateBindingFromSrc(_loc3_.def.name);
         dispatchEvent(new VariableEvent(_loc3_,param2));
      }
      
      private function updateBindingFromSrc(param1:String) : void
      {
         var _loc4_:Object = null;
         var _loc5_:Variable = null;
         var _loc6_:IVariable = null;
         var _loc2_:IVariable = this.fetch(param1,null);
         if(!_loc2_)
         {
            return;
         }
         var _loc3_:String = _loc2_.def.name;
         for each(_loc4_ in this.binds)
         {
            _loc5_ = this.binds[_loc4_] as Variable;
            if(_loc5_.def.bind.isBound(_loc3_))
            {
               _loc6_ = this.fetch(_loc5_.def.bind.dst.name,null);
               _loc6_.asNumber = _loc6_.def.bind.compute(this);
            }
         }
      }
      
      public function addBinding(param1:IVariable) : void
      {
         var _loc2_:IVariable = null;
         if(param1.def.bind)
         {
            this.binds[param1] = param1;
            _loc2_ = this.fetch(param1.def.bind.src,null);
            if(_loc2_)
            {
               param1.asNumber = param1.def.bind.compute(this);
            }
         }
      }
      
      public function removeBinding(param1:IVariable) : void
      {
         if(param1.def.bind)
         {
            delete this.binds[param1];
         }
      }
      
      public function debugPrintLog(param1:ILogger, param2:String) : void
      {
         var _loc4_:Variable = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc10_:* = null;
         var _loc11_:String = null;
         var _loc12_:int = 0;
         var _loc3_:Array = [];
         for each(_loc4_ in this.vars)
         {
            _loc3_.push(_loc4_.def.name);
         }
         _loc3_.sort(Array.CASEINSENSITIVE);
         _loc5_ = StringUtil.padRight(this._name," ",25);
         for each(_loc6_ in _loc3_)
         {
            if(param2)
            {
               if(_loc6_.indexOf(param2) < 0)
               {
                  continue;
               }
            }
            _loc4_ = this.vars[_loc6_];
            if(_loc4_.def.name == "cur_units_05")
            {
               _loc4_ = _loc4_;
            }
            _loc7_ = StringUtil.padRight(_loc4_.def.type.name," ",15);
            _loc8_ = StringUtil.padRight(_loc4_.def.name," ",35);
            _loc9_ = StringUtil.padRight(_loc4_.asString," ",10);
            _loc10_ = "";
            if(_loc4_.def.type == VariableType.DECIMAL || _loc4_.def.type == VariableType.INTEGER)
            {
               _loc12_ = _loc4_.def.type == VariableType.DECIMAL ? 2 : 0;
               _loc10_ = "[" + StringUtil.padLeft(_loc4_.def.lowerBound.toFixed(_loc12_)," ",5) + ", " + StringUtil.padLeft(_loc4_.def.upperBound.toFixed(_loc12_)," ",6) + "] ";
            }
            else
            {
               _loc10_ = "                ";
            }
            _loc11_ = !!_loc4_.def.bind ? _loc4_.def.bind.toString() : "";
            if(_loc4_.def.scripted)
            {
               _loc11_ = "SCRIPT";
            }
            param1.info(_loc7_ + " " + _loc5_ + " " + _loc8_ + " " + _loc9_ + " " + _loc10_ + " " + _loc11_);
         }
      }
      
      public function initMetricsVariables(param1:ISagaMetrics) : void
      {
         var _loc2_:Variable = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         for each(_loc2_ in this.vars)
         {
            if(!(!_loc2_.def.metrics_var && !_loc2_.def.metrics_dim))
            {
               _loc3_ = this._name + "." + _loc2_.def.name;
               if(_loc2_.def.metrics_var)
               {
                  _loc4_ = this._name + "." + _loc2_.def.name;
                  param1.snapshotVariable(_loc4_,_loc2_.asInteger);
               }
            }
         }
      }
      
      public function get name() : String
      {
         return this._name;
      }
   }
}

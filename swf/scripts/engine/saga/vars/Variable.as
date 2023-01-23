package engine.saga.vars
{
   import com.stoicstudio.platform.Platform;
   import engine.core.logging.ILogger;
   import engine.core.logging.Logger;
   import engine.entity.def.IEntityDef;
   import engine.expression.Symbols;
   import engine.saga.ICaravan;
   import engine.saga.ISaga;
   import engine.saga.SagaConfig;
   import engine.saga.SagaInstance;
   import flash.errors.IllegalOperationError;
   import flash.utils.Dictionary;
   
   public class Variable implements IVariable
   {
      
      public static var ALLOW_PLATFORM_OVERRIDE:Boolean;
      
      private static var _errored:Dictionary = new Dictionary();
       
      
      private var _readonly:Boolean;
      
      public var _bag:IVariableBag;
      
      public var _def:VariableDef;
      
      public var _value:String = "";
      
      public var cumulative:int;
      
      public var logger:ILogger;
      
      protected var _isScripted:Boolean;
      
      public function Variable(param1:VariableDef, param2:ILogger)
      {
         var _loc3_:* = undefined;
         super();
         if(!this._isScripted && param1.scripted)
         {
            throw new IllegalOperationError("Bogus scripted variable: " + param1);
         }
         this._def = param1;
         this.logger = param2;
         if(!ALLOW_PLATFORM_OVERRIDE)
         {
            if(param1.platformsDict)
            {
               if(!param1.platformsDict[Platform.id])
               {
                  this._readonly = true;
               }
            }
         }
         if(param1.type != VariableType.STRING)
         {
            _loc3_ = !!SagaConfig.FORCE_VARS ? SagaConfig.FORCE_VARS[param1.name] : undefined;
            if(_loc3_ != undefined)
            {
               this.asAny = _loc3_;
            }
            else
            {
               this.asAny = param1.start;
               if(Boolean(this.def.start) && this.asNumber != this.def.start)
               {
                  if(!_errored[param1])
                  {
                     if(Logger.instance)
                     {
                        _errored[param1] = true;
                        Logger.instance.error("Variable ctor failed to start " + this.def.name + " expected " + this.def.start + " actual " + this.asNumber);
                     }
                  }
               }
            }
         }
         else if(this._value != param1.start_str)
         {
            this.asAny = param1.start_str;
         }
      }
      
      public function get bag() : IVariableBag
      {
         return this._bag;
      }
      
      public function set bag(param1:IVariableBag) : void
      {
         this._bag = param1;
      }
      
      public function get def() : VariableDef
      {
         return this._def;
      }
      
      public function getOwnerEntityDef() : IEntityDef
      {
         if(this.bag)
         {
            return this._bag.owner as IEntityDef;
         }
         return null;
      }
      
      public function getOwnerCaravan() : ICaravan
      {
         var _loc2_:ISaga = null;
         var _loc1_:ICaravan = null;
         if(Boolean(this._bag) && this._bag is VariableBag)
         {
            _loc1_ = (this._bag as VariableBag).owner as ICaravan;
         }
         if(!_loc1_)
         {
            _loc2_ = SagaInstance.instance;
            _loc1_ = !!_loc2_ ? _loc2_.icaravan : null;
         }
         return _loc1_;
      }
      
      public function isDefault(param1:ILogger) : Boolean
      {
         if(this.def.type != VariableType.STRING)
         {
            return this.def.clamp(this.def.start,param1) == this.asNumber;
         }
         return this.def.start_str == this.asString;
      }
      
      public function get fullname() : String
      {
         if(this.bag)
         {
            return this._bag.name + "." + this.def.name;
         }
         return this.def.name;
      }
      
      public function toString() : String
      {
         this.handleAccessGet();
         return this.fullname + "=" + this._value;
      }
      
      public function get asInteger() : int
      {
         this.handleAccessGet();
         return int(this._value);
      }
      
      public function get asUnsigned() : uint
      {
         this.handleAccessGet();
         return uint(this._value);
      }
      
      public function get asNumber() : Number
      {
         this.handleAccessGet();
         if(Boolean(this._def) && this._def.type == VariableType.STRING)
         {
            return Symbols.process(this._value);
         }
         return Number(this._value);
      }
      
      public function get asBoolean() : Boolean
      {
         return this.asInteger == 1;
      }
      
      public function get asString() : String
      {
         this.handleAccessGet();
         return this._value;
      }
      
      protected function convertToString(param1:*) : String
      {
         if(param1 is Number)
         {
            return this.clamp(param1).toString();
         }
         if(param1 is Boolean)
         {
            return (!!param1 ? 1 : 0).toString();
         }
         if(param1 is String)
         {
            return param1;
         }
         if(param1 == undefined || param1 == null)
         {
            return null;
         }
         throw new ArgumentError("Invalid type");
      }
      
      public function set asAny(param1:*) : void
      {
         this.asString = this.convertToString(param1);
      }
      
      public function set asInteger(param1:int) : void
      {
         var _loc2_:String = this.clamp(param1).toString();
         this.asString = _loc2_;
      }
      
      public function set asNumber(param1:Number) : void
      {
         var _loc2_:String = this.clamp(param1).toString();
         this.asString = _loc2_;
      }
      
      public function set asBoolean(param1:Boolean) : void
      {
         var _loc2_:String = this.clamp(param1 ? 1 : 0).toString();
         this.asString = _loc2_;
      }
      
      public function set asString(param1:String) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         this.handleAccessGet();
         if(this._value == param1)
         {
            return;
         }
         var _loc2_:String = this._value;
         if(this.def.type == VariableType.DECIMAL || this.def.type == VariableType.INTEGER)
         {
            if(this.def.accumulate)
            {
               _loc3_ = Number(_loc2_);
               _loc4_ = Number(param1);
               if(!isNaN(_loc3_) && !isNaN(_loc4_))
               {
                  if(_loc4_ > _loc3_)
                  {
                     this.cumulative += _loc4_ - _loc3_;
                  }
               }
            }
         }
         if(this._value == param1)
         {
            return;
         }
         if(this._readonly)
         {
            if(this.def.type == VariableType.STRING && this.def.start_str != param1 || this.def.type != VariableType.STRING && this.def.start.toString() != param1)
            {
               throw new IllegalOperationError("Cannot set readonly var " + this);
            }
         }
         this._value = param1;
         this.handleAccessSet();
         if(this.bag)
         {
            this._bag.handleVariableChange(this,_loc2_);
         }
      }
      
      protected function clamp(param1:Number) : Number
      {
         return this.def.clamp(param1,this.logger);
      }
      
      protected function handleAccessGet() : void
      {
      }
      
      protected function handleAccessSet() : void
      {
      }
      
      public function get value() : String
      {
         return this._value;
      }
   }
}

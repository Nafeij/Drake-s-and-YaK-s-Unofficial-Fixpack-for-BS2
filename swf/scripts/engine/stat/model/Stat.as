package engine.stat.model
{
   import engine.core.logging.ILogger;
   import engine.core.logging.Logger;
   import engine.stat.def.StatType;
   import flash.errors.IllegalOperationError;
   import flash.events.EventDispatcher;
   
   public class Stat extends EventDispatcher
   {
       
      
      private var _type:StatType;
      
      private var _value:int;
      
      private var _base:int;
      
      private var _original:int;
      
      public var provider:IStatsProvider;
      
      private var _mods:Vector.<StatMod>;
      
      private var consuming:Boolean;
      
      private var locked:Boolean = true;
      
      public function Stat(param1:StatType, param2:int, param3:Boolean)
      {
         super();
         if(param1 == StatType.INJURY)
         {
            param3 = false;
         }
         this._base = param2;
         this._value = param2;
         this._type = param1;
         this._original = param2;
         this.locked = param3;
      }
      
      public function clone() : Stat
      {
         var _loc2_:StatMod = null;
         var _loc1_:Stat = new Stat(this.type,this.base,this.locked);
         _loc1_._original = this._original;
         if(this._mods)
         {
            for each(_loc2_ in this._mods)
            {
               _loc1_.addMod(_loc2_.provider,_loc2_.amount,_loc2_.charges);
            }
         }
         _loc1_._value = this._value;
         _loc1_.internalSetOriginal(this._original);
         return _loc1_;
      }
      
      public function testEquals(param1:Stat, param2:ILogger) : Boolean
      {
         if(this._type != param1._type)
         {
            param2.info("Stat.equals types mismatched");
            return false;
         }
         if(this._value != param1._value)
         {
            param2.info("Stat.equals values mismatched");
            return false;
         }
         if(this._base != param1._base)
         {
            param2.info("Stat.equals bases mismatched");
            return false;
         }
         if(this._original != param1._original)
         {
            param2.info("Stat.equals originals mismatched");
            return false;
         }
         return true;
      }
      
      public function synchronizeFrom(param1:Stat) : void
      {
         var _loc2_:int = 0;
         var _loc3_:StatMod = null;
         if(this._type != param1._type)
         {
            throw new IllegalOperationError("Cannot synchronize stats of different types.");
         }
         this._base = param1._base;
         this._value = param1._base;
         this._original = param1._original;
         this.locked = param1.locked;
         if(param1._mods)
         {
            if(this._mods == null)
            {
               this._mods = new Vector.<StatMod>();
            }
            _loc2_ = 0;
            while(_loc2_ < param1._mods.length)
            {
               _loc3_ = param1._mods[_loc2_];
               if(this._mods.length < _loc2_)
               {
                  this._mods[_loc2_].synchronizeTo(this,_loc3_);
               }
               else
               {
                  this.addMod(_loc3_.provider,_loc3_.amount,_loc3_.charges);
               }
               _loc2_++;
            }
            if(this._mods.length > param1._mods.length)
            {
               this._mods.splice(param1._mods.length,this._mods.length - param1._mods.length);
            }
         }
         else if(this._mods != null)
         {
            this._mods.splice(0,this._mods.length);
         }
         this._value = param1._value;
      }
      
      public function internalSetOriginal(param1:int) : void
      {
         this._original = param1;
      }
      
      public function get type() : StatType
      {
         return this._type;
      }
      
      internal function statModModifyValue(param1:int) : void
      {
         this._value += param1;
         dispatchEvent(new StatEvent(StatEvent.CHANGE,param1));
      }
      
      public function get value() : int
      {
         if(!this.type.allowNegative)
         {
            return Math.max(0,this._value);
         }
         return this._value;
      }
      
      public function modifyBase(param1:int) : void
      {
         this.base = this._base + param1;
      }
      
      override public function toString() : String
      {
         return "[" + this.provider + " " + this._type + " " + this._value + " (base " + this._base + ", mod " + this.modDelta + ")]";
      }
      
      public function addMod(param1:IStatModProvider, param2:int, param3:int) : StatMod
      {
         var _loc4_:StatMod = new StatMod(this,param1,param2,param3);
         if(!this._mods)
         {
            this._mods = new Vector.<StatMod>();
         }
         this._mods.push(_loc4_);
         return _loc4_;
      }
      
      public function removeMods(param1:IStatModProvider) : void
      {
         var _loc2_:int = 0;
         var _loc3_:StatMod = null;
         if(this._mods)
         {
            _loc2_ = 0;
            while(_loc2_ < this._mods.length)
            {
               _loc3_ = this._mods[_loc2_];
               if(_loc3_.provider == param1)
               {
                  _loc3_.internalConsume();
               }
               _loc2_++;
            }
         }
         if(this.consuming)
         {
            return;
         }
         this.purgeMods();
      }
      
      public function get modDelta() : int
      {
         return this.value - this.base;
      }
      
      public function doConsume() : int
      {
         var _loc2_:int = 0;
         var _loc3_:StatMod = null;
         var _loc1_:int = this.value;
         this.consuming = true;
         if(this._mods)
         {
            _loc2_ = 0;
            while(_loc2_ < this._mods.length)
            {
               _loc3_ = this._mods[_loc2_];
               _loc3_.consume();
               _loc2_++;
            }
         }
         this.consuming = false;
         this.purgeMods();
         return _loc1_;
      }
      
      public function purgeMods() : void
      {
         var _loc1_:int = 0;
         var _loc2_:StatMod = null;
         if(this._mods)
         {
            _loc1_ = 0;
            while(_loc1_ < this._mods.length)
            {
               _loc2_ = this._mods[_loc1_];
               if(_loc2_.consumed || _loc2_.provider && _loc2_.provider.isStatModProviderRemoved)
               {
                  this._mods.splice(_loc1_,1);
               }
               else
               {
                  _loc1_++;
               }
            }
         }
      }
      
      public function get original() : int
      {
         return this._original;
      }
      
      public function get base() : int
      {
         return this._base;
      }
      
      public function set base(param1:int) : void
      {
         var _loc3_:ILogger = null;
         if(param1 == this._base)
         {
            return;
         }
         var _loc2_:int = param1 - this._base;
         if(StatType.DEBUG_INJURY)
         {
            if(this._base != param1)
            {
               if(this.type == StatType.INJURY)
               {
                  _loc3_ = Logger.instance;
                  _loc3_.debug("DEBUG_INJURY: set to " + param1 + " from " + this._base + " on " + this.provider);
               }
            }
         }
         this._base = param1;
         this._value += _loc2_;
         if(this.locked)
         {
            this._original = this.base;
         }
         dispatchEvent(new StatEvent(StatEvent.CHANGE,_loc2_));
         dispatchEvent(new StatEvent(StatEvent.BASE_CHANGE,_loc2_));
      }
      
      public function getDebugStringMods(param1:String) : String
      {
         var _loc3_:StatMod = null;
         if(!this._mods || !this._mods.length)
         {
            return null;
         }
         var _loc2_:String = "";
         for each(_loc3_ in this._mods)
         {
            _loc2_ += param1 + _loc3_.getDebugString() + "\n";
         }
         return _loc2_;
      }
   }
}

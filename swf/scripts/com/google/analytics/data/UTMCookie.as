package com.google.analytics.data
{
   import com.google.analytics.core.Buffer;
   
   public class UTMCookie implements Cookie
   {
       
      
      private var _creation:Date;
      
      private var _expiration:Date;
      
      private var _timespan:Number;
      
      protected var name:String;
      
      protected var inURL:String;
      
      protected var fields:Array;
      
      public var proxy:Buffer;
      
      public function UTMCookie(param1:String, param2:String, param3:Array, param4:Number = 0)
      {
         super();
         this.name = param1;
         this.inURL = param2;
         this.fields = param3;
         this._timestamp(param4);
      }
      
      private function _timestamp(param1:Number) : void
      {
         this.creation = new Date();
         this._timespan = param1;
         if(param1 > 0)
         {
            this.expiration = new Date(this.creation.valueOf() + param1);
         }
      }
      
      protected function update() : void
      {
         this.resetTimestamp();
         if(this.proxy)
         {
            this.proxy.update(this.name,this.toSharedObject());
         }
      }
      
      public function get creation() : Date
      {
         return this._creation;
      }
      
      public function set creation(param1:Date) : void
      {
         this._creation = param1;
      }
      
      public function get expiration() : Date
      {
         if(this._expiration)
         {
            return this._expiration;
         }
         return new Date(new Date().valueOf() + 1000);
      }
      
      public function set expiration(param1:Date) : void
      {
         this._expiration = param1;
      }
      
      public function fromSharedObject(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:int = int(this.fields.length);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc2_ = String(this.fields[_loc4_]);
            if(param1[_loc2_])
            {
               this[_loc2_] = param1[_loc2_];
            }
            _loc4_++;
         }
         if(param1.creation)
         {
            this.creation = param1.creation;
         }
         if(param1.expiration)
         {
            this.expiration = param1.expiration;
         }
      }
      
      public function isEmpty() : Boolean
      {
         var _loc2_:String = null;
         var _loc1_:int = 0;
         var _loc3_:int = 0;
         while(_loc3_ < this.fields.length)
         {
            _loc2_ = String(this.fields[_loc3_]);
            if(this[_loc2_] is Number && isNaN(this[_loc2_]))
            {
               _loc1_++;
            }
            else if(this[_loc2_] is String && this[_loc2_] == "")
            {
               _loc1_++;
            }
            _loc3_++;
         }
         if(_loc1_ == this.fields.length)
         {
            return true;
         }
         return false;
      }
      
      public function isExpired() : Boolean
      {
         var _loc1_:Date = new Date();
         var _loc2_:Number = this.expiration.valueOf() - _loc1_.valueOf();
         if(_loc2_ <= 0)
         {
            return true;
         }
         return false;
      }
      
      public function reset() : void
      {
         var _loc1_:String = null;
         var _loc2_:int = 0;
         while(_loc2_ < this.fields.length)
         {
            _loc1_ = String(this.fields[_loc2_]);
            if(this[_loc1_] is Number)
            {
               this[_loc1_] = NaN;
            }
            else if(this[_loc1_] is String)
            {
               this[_loc1_] = "";
            }
            _loc2_++;
         }
         this.resetTimestamp();
         this.update();
      }
      
      public function resetTimestamp(param1:Number = NaN) : void
      {
         if(!isNaN(param1))
         {
            this._timespan = param1;
         }
         this._creation = null;
         this._expiration = null;
         this._timestamp(this._timespan);
      }
      
      public function toURLString() : String
      {
         return this.inURL + "=" + this.valueOf();
      }
      
      public function toSharedObject() : Object
      {
         var _loc2_:String = null;
         var _loc3_:* = undefined;
         var _loc1_:Object = {};
         var _loc4_:int = 0;
         while(_loc4_ < this.fields.length)
         {
            _loc2_ = String(this.fields[_loc4_]);
            _loc3_ = this[_loc2_];
            if(_loc3_ is String)
            {
               _loc1_[_loc2_] = _loc3_;
            }
            else if(_loc3_ == 0)
            {
               _loc1_[_loc2_] = _loc3_;
            }
            else if(!isNaN(_loc3_))
            {
               _loc1_[_loc2_] = _loc3_;
            }
            _loc4_++;
         }
         _loc1_.creation = this.creation;
         _loc1_.expiration = this.expiration;
         return _loc1_;
      }
      
      public function toString(param1:Boolean = false) : String
      {
         var _loc3_:String = null;
         var _loc4_:* = undefined;
         var _loc2_:Array = [];
         var _loc5_:int = int(this.fields.length);
         var _loc6_:int = 0;
         while(_loc6_ < _loc5_)
         {
            _loc3_ = String(this.fields[_loc6_]);
            _loc4_ = this[_loc3_];
            if(_loc4_ is String)
            {
               _loc2_.push(_loc3_ + ": \"" + _loc4_ + "\"");
            }
            else if(_loc4_ == 0)
            {
               _loc2_.push(_loc3_ + ": " + _loc4_);
            }
            else if(!isNaN(_loc4_))
            {
               _loc2_.push(_loc3_ + ": " + _loc4_);
            }
            _loc6_++;
         }
         var _loc7_:* = this.name.toUpperCase() + " {" + _loc2_.join(", ") + "}";
         if(param1)
         {
            _loc7_ += " creation:" + this.creation + ", expiration:" + this.expiration;
         }
         return _loc7_;
      }
      
      public function valueOf() : String
      {
         var _loc2_:String = null;
         var _loc3_:* = undefined;
         var _loc4_:Array = null;
         var _loc1_:Array = [];
         var _loc5_:String = "";
         var _loc6_:int = 0;
         while(_loc6_ < this.fields.length)
         {
            _loc2_ = String(this.fields[_loc6_]);
            _loc3_ = this[_loc2_];
            if(_loc3_ is String)
            {
               if(_loc3_ == "")
               {
                  _loc3_ = "-";
                  _loc1_.push(_loc3_);
               }
               else
               {
                  _loc1_.push(_loc3_);
               }
            }
            else if(_loc3_ is Number)
            {
               if(_loc3_ == 0)
               {
                  _loc1_.push(_loc3_);
               }
               else if(isNaN(_loc3_))
               {
                  _loc3_ = "-";
                  _loc1_.push(_loc3_);
               }
               else
               {
                  _loc1_.push(_loc3_);
               }
            }
            _loc6_++;
         }
         if(this.isEmpty())
         {
            return "-";
         }
         return "" + _loc1_.join(".");
      }
   }
}

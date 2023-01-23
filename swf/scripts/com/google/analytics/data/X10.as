package com.google.analytics.data
{
   public class X10
   {
       
      
      private var _projectData:Object;
      
      private var _key:String = "k";
      
      private var _value:String = "v";
      
      private var _set:Array;
      
      private var _delimBegin:String = "(";
      
      private var _delimEnd:String = ")";
      
      private var _delimSet:String = "*";
      
      private var _delimNumValue:String = "!";
      
      private var _escapeChar:String = "\'";
      
      private var _escapeCharMap:Object;
      
      private var _minimum:int;
      
      private var _hasData:int;
      
      public function X10()
      {
         this._set = [this._key,this._value];
         super();
         this._projectData = {};
         this._escapeCharMap = {};
         this._escapeCharMap[this._escapeChar] = "\'0";
         this._escapeCharMap[this._delimEnd] = "\'1";
         this._escapeCharMap[this._delimSet] = "\'2";
         this._escapeCharMap[this._delimNumValue] = "\'3";
         this._minimum = 1;
      }
      
      private function _setInternal(param1:Number, param2:String, param3:Number, param4:String) : void
      {
         if(!this.hasProject(param1))
         {
            this._projectData[param1] = {};
         }
         if(this._projectData[param1][param2] == undefined)
         {
            this._projectData[param1][param2] = [];
         }
         this._projectData[param1][param2][param3] = param4;
         this._hasData += 1;
      }
      
      private function _getInternal(param1:Number, param2:String, param3:Number) : Object
      {
         if(this.hasProject(param1) && this._projectData[param1][param2] != undefined)
         {
            return this._projectData[param1][param2][param3];
         }
         return undefined;
      }
      
      private function _clearInternal(param1:Number, param2:String) : void
      {
         var _loc3_:Boolean = false;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         if(this.hasProject(param1) && this._projectData[param1][param2] != undefined)
         {
            this._projectData[param1][param2] = undefined;
            _loc3_ = true;
            _loc5_ = this._set.length;
            _loc4_ = 0;
            while(_loc4_ < _loc5_)
            {
               if(this._projectData[param1][this._set[_loc4_]] != undefined)
               {
                  _loc3_ = false;
                  break;
               }
               _loc4_++;
            }
            if(_loc3_)
            {
               this._projectData[param1] = undefined;
               this._hasData = this._hasData - 1;
            }
         }
      }
      
      private function _escapeExtensibleValue(param1:String) : String
      {
         var _loc3_:int = 0;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc2_:String = "";
         _loc3_ = 0;
         while(_loc3_ < param1.length)
         {
            _loc4_ = param1.charAt(_loc3_);
            _loc5_ = this._escapeCharMap[_loc4_];
            if(_loc5_)
            {
               _loc2_ += _loc5_;
            }
            else
            {
               _loc2_ += _loc4_;
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      private function _renderDataType(param1:Array) : String
      {
         var _loc3_:String = null;
         var _loc4_:int = 0;
         var _loc2_:Array = [];
         _loc4_ = 0;
         while(_loc4_ < param1.length)
         {
            if(param1[_loc4_] != undefined)
            {
               _loc3_ = "";
               if(_loc4_ != this._minimum && param1[_loc4_ - 1] == undefined)
               {
                  _loc3_ += _loc4_.toString();
                  _loc3_ += this._delimNumValue;
               }
               _loc3_ += this._escapeExtensibleValue(param1[_loc4_]);
               _loc2_.push(_loc3_);
            }
            _loc4_++;
         }
         return this._delimBegin + _loc2_.join(this._delimSet) + this._delimEnd;
      }
      
      private function _renderProject(param1:Object) : String
      {
         var _loc4_:int = 0;
         var _loc5_:Array = null;
         var _loc2_:String = "";
         var _loc3_:Boolean = false;
         var _loc6_:int = this._set.length;
         _loc4_ = 0;
         while(_loc4_ < _loc6_)
         {
            _loc5_ = param1[this._set[_loc4_]];
            if(_loc5_)
            {
               if(_loc3_)
               {
                  _loc2_ += this._set[_loc4_];
               }
               _loc2_ += this._renderDataType(_loc5_);
               _loc3_ = false;
            }
            else
            {
               _loc3_ = true;
            }
            _loc4_++;
         }
         return _loc2_;
      }
      
      public function hasProject(param1:Number) : Boolean
      {
         return this._projectData[param1];
      }
      
      public function hasData() : Boolean
      {
         return this._hasData > 0;
      }
      
      public function setKey(param1:Number, param2:Number, param3:String) : Boolean
      {
         this._setInternal(param1,this._key,param2,param3);
         return true;
      }
      
      public function getKey(param1:Number, param2:Number) : String
      {
         return this._getInternal(param1,this._key,param2) as String;
      }
      
      public function clearKey(param1:Number) : void
      {
         this._clearInternal(param1,this._key);
      }
      
      public function setValue(param1:Number, param2:Number, param3:Number) : Boolean
      {
         if(Math.round(param3) != param3 || isNaN(param3) || param3 == Infinity)
         {
            return false;
         }
         this._setInternal(param1,this._value,param2,param3.toString());
         return true;
      }
      
      public function getValue(param1:Number, param2:Number) : *
      {
         var _loc3_:* = this._getInternal(param1,this._value,param2);
         if(_loc3_ == null)
         {
            return null;
         }
         return Number(_loc3_);
      }
      
      public function clearValue(param1:Number) : void
      {
         this._clearInternal(param1,this._value);
      }
      
      public function renderUrlString() : String
      {
         var _loc2_:* = null;
         var _loc1_:Array = [];
         for(_loc2_ in this._projectData)
         {
            if(this.hasProject(Number(_loc2_)))
            {
               _loc1_.push(_loc2_ + this._renderProject(this._projectData[_loc2_]));
            }
         }
         return _loc1_.join("");
      }
      
      public function renderMergedUrlString(param1:X10 = null) : String
      {
         var _loc3_:* = null;
         if(!param1)
         {
            return this.renderUrlString();
         }
         var _loc2_:Array = [param1.renderUrlString()];
         for(_loc3_ in this._projectData)
         {
            if(this.hasProject(Number(_loc3_)) && !param1.hasProject(Number(_loc3_)))
            {
               _loc2_.push(_loc3_ + this._renderProject(this._projectData[_loc3_]));
            }
         }
         return _loc2_.join("");
      }
   }
}

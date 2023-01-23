package com.google.analytics.utils
{
   import flash.net.URLVariables;
   
   public dynamic class Variables
   {
       
      
      public var URIencode:Boolean;
      
      public var pre:Array;
      
      public var post:Array;
      
      public var sort:Boolean = true;
      
      public function Variables(param1:String = null, param2:Array = null, param3:Array = null)
      {
         this.pre = [];
         this.post = [];
         super();
         if(param1)
         {
            this.decode(param1);
         }
         if(param2)
         {
            this.pre = param2;
         }
         if(param3)
         {
            this.post = param3;
         }
      }
      
      private function _join(param1:Variables) : void
      {
         var _loc2_:* = null;
         if(!param1)
         {
            return;
         }
         for(_loc2_ in param1)
         {
            this[_loc2_] = param1[_loc2_];
         }
      }
      
      public function decode(param1:String) : void
      {
         var _loc2_:Array = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:Array = null;
         if(param1 == "")
         {
            return;
         }
         if(param1.charAt(0) == "?")
         {
            param1 = param1.substr(1,param1.length);
         }
         if(param1.indexOf("&") > -1)
         {
            _loc2_ = param1.split("&");
         }
         else
         {
            _loc2_ = [param1];
         }
         var _loc7_:int = 0;
         while(_loc7_ < _loc2_.length)
         {
            _loc3_ = _loc2_[_loc7_];
            if(_loc3_.indexOf("=") > -1)
            {
               _loc6_ = _loc3_.split("=");
               _loc4_ = _loc6_[0];
               _loc5_ = decodeURI(_loc6_[1]);
               this[_loc4_] = _loc5_;
            }
            _loc7_++;
         }
      }
      
      public function join(... rest) : void
      {
         var _loc2_:int = int(rest.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            if(rest[_loc3_] is Variables)
            {
               this._join(rest[_loc3_]);
            }
            _loc3_++;
         }
      }
      
      public function toString() : String
      {
         var _loc2_:String = null;
         var _loc3_:* = null;
         var _loc4_:String = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc1_:Array = [];
         for(_loc3_ in this)
         {
            _loc2_ = this[_loc3_];
            if(this.URIencode)
            {
               _loc2_ = encodeURI(_loc2_);
            }
            _loc1_.push(_loc3_ + "=" + _loc2_);
         }
         if(this.sort)
         {
            _loc1_.sort();
         }
         if(this.pre.length > 0)
         {
            this.pre.reverse();
            _loc5_ = 0;
            while(_loc5_ < this.pre.length)
            {
               _loc7_ = this.pre[_loc5_];
               _loc6_ = 0;
               while(_loc6_ < _loc1_.length)
               {
                  _loc4_ = _loc1_[_loc6_];
                  if(_loc4_.indexOf(_loc7_) == 0)
                  {
                     _loc1_.unshift(_loc1_.splice(_loc6_,1)[0]);
                  }
                  _loc6_++;
               }
               _loc5_++;
            }
            this.pre.reverse();
         }
         if(this.post.length > 0)
         {
            _loc5_ = 0;
            while(_loc5_ < this.post.length)
            {
               _loc8_ = this.post[_loc5_];
               _loc6_ = 0;
               while(_loc6_ < _loc1_.length)
               {
                  _loc4_ = _loc1_[_loc6_];
                  if(_loc4_.indexOf(_loc8_) == 0)
                  {
                     _loc1_.push(_loc1_.splice(_loc6_,1)[0]);
                  }
                  _loc6_++;
               }
               _loc5_++;
            }
         }
         return _loc1_.join("&");
      }
      
      public function toURLVariables() : URLVariables
      {
         var _loc2_:* = null;
         var _loc1_:URLVariables = new URLVariables();
         for(_loc2_ in this)
         {
            _loc1_[_loc2_] = this[_loc2_];
         }
         return _loc1_;
      }
   }
}

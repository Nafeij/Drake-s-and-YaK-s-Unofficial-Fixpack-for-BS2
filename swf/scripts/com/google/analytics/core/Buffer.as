package com.google.analytics.core
{
   import com.google.analytics.data.UTMA;
   import com.google.analytics.data.UTMB;
   import com.google.analytics.data.UTMC;
   import com.google.analytics.data.UTMK;
   import com.google.analytics.data.UTMV;
   import com.google.analytics.data.UTMX;
   import com.google.analytics.data.UTMZ;
   import com.google.analytics.debug.DebugConfiguration;
   import com.google.analytics.debug.VisualDebugMode;
   import com.google.analytics.v4.Configuration;
   import flash.events.NetStatusEvent;
   import flash.net.SharedObject;
   import flash.net.SharedObjectFlushStatus;
   
   public dynamic class Buffer
   {
       
      
      private var _config:Configuration;
      
      private var _debug:DebugConfiguration;
      
      private var _SO:SharedObject;
      
      private var _OBJ:Object;
      
      private var _data:Object;
      
      private var _volatile:Boolean;
      
      private var _utma:UTMA;
      
      private var _utmb:UTMB;
      
      private var _utmc:UTMC;
      
      private var _utmk:UTMK;
      
      private var _utmx:UTMX;
      
      private var _utmv:UTMV;
      
      private var _utmz:UTMZ;
      
      public function Buffer(param1:Configuration, param2:DebugConfiguration, param3:Boolean = false, param4:Object = null)
      {
         var _loc5_:String = null;
         super();
         this._config = param1;
         this._debug = param2;
         this._data = param4;
         this._volatile = param3;
         if(this._volatile)
         {
            this._OBJ = new Object();
            if(this._data)
            {
               for(_loc5_ in this._data)
               {
                  this._OBJ[_loc5_] = this._data[_loc5_];
               }
            }
         }
      }
      
      private function _onFlushStatus(param1:NetStatusEvent) : void
      {
         this._debug.info("User closed permission dialog...");
         switch(param1.info.code)
         {
            case "SharedObject.Flush.Success":
               this._debug.info("User granted permission -- value saved.");
               break;
            case "SharedObject.Flush.Failed":
               this._debug.info("User denied permission -- value not saved.");
         }
         this._SO.removeEventListener(NetStatusEvent.NET_STATUS,this._onFlushStatus);
      }
      
      private function _clearUTMA() : void
      {
         this._utma = null;
         if(!this.isVolatile())
         {
            this._SO.data.utma = null;
            delete this._SO.data.utma;
         }
      }
      
      private function _clearUTMB() : void
      {
         this._utmb = null;
         if(!this.isVolatile())
         {
            if(this._SO != null && this._SO.data != null)
            {
               this._SO.data.utmb = null;
            }
            delete this._SO.data.utmb;
         }
      }
      
      private function _clearUTMC() : void
      {
         this._utmc = null;
      }
      
      private function _clearUTMV() : void
      {
         this._utmv = null;
         if(!this.isVolatile())
         {
            this._SO.data.utmv = null;
            delete this._SO.data.utmv;
         }
      }
      
      private function _clearUTMZ() : void
      {
         this._utmz = null;
         if(!this.isVolatile())
         {
            this._SO.data.utmz = null;
            delete this._SO.data.utmz;
         }
      }
      
      private function _createUMTA() : void
      {
         this._utma = new UTMA();
         this._utma.proxy = this;
      }
      
      private function _createUMTB() : void
      {
         this._utmb = new UTMB();
         this._utmb.proxy = this;
      }
      
      private function _createUMTC() : void
      {
         this._utmc = new UTMC();
      }
      
      private function _createUMTK() : void
      {
         this._utmk = new UTMK();
         this._utmk.proxy = this;
      }
      
      private function _createUMTX() : void
      {
         this._utmx = new UTMX();
         this._utmx.proxy = this;
      }
      
      private function _createUMTV() : void
      {
         this._utmv = new UTMV();
         this._utmv.proxy = this;
      }
      
      private function _createUMTZ() : void
      {
         this._utmz = new UTMZ();
         this._utmz.proxy = this;
      }
      
      public function createSO() : void
      {
         var saveSO:Boolean = false;
         UTMZ.defaultTimespan = this._config.conversionTimeout;
         UTMB.defaultTimespan = this._config.sessionTimeout;
         if(!this._volatile)
         {
            try
            {
               this._SO = SharedObject.getLocal(this._config.cookieName,this._config.cookiePath);
            }
            catch(e:Error)
            {
               if(_debug.active)
               {
                  _debug.warning("Shared Object " + _config.cookieName + " failed to be set\nreason: " + e.message);
               }
            }
            saveSO = false;
            if(this._SO.data.utma)
            {
               if(!this.hasUTMA())
               {
                  this._createUMTA();
               }
               this._utma.fromSharedObject(this._SO.data.utma);
               if(this._debug.verbose)
               {
                  this._debug.info("found: " + this._utma.toString(true),VisualDebugMode.geek);
               }
               if(this._utma.isExpired())
               {
                  if(this._debug.verbose)
                  {
                     this._debug.warning("UTMA has expired",VisualDebugMode.advanced);
                  }
                  this._clearUTMA();
                  saveSO = true;
               }
            }
            if(this._SO.data.utmb)
            {
               if(!this.hasUTMB())
               {
                  this._createUMTB();
               }
               this._utmb.fromSharedObject(this._SO.data.utmb);
               if(this._debug.verbose)
               {
                  this._debug.info("found: " + this._utmb.toString(true),VisualDebugMode.geek);
               }
               if(this._utmb.isExpired())
               {
                  if(this._debug.verbose)
                  {
                     this._debug.warning("UTMB has expired",VisualDebugMode.advanced);
                  }
                  this._clearUTMB();
                  saveSO = true;
               }
            }
            if(this._SO.data.utmc)
            {
               delete this._SO.data.utmc;
               saveSO = true;
            }
            if(this._SO.data.utmk)
            {
               if(!this.hasUTMK())
               {
                  this._createUMTK();
               }
               this._utmk.fromSharedObject(this._SO.data.utmk);
               if(this._debug.verbose)
               {
                  this._debug.info("found: " + this._utmk.toString(),VisualDebugMode.geek);
               }
            }
            if(!this.hasUTMX())
            {
               this._createUMTX();
            }
            if(this._SO.data.utmv)
            {
               if(!this.hasUTMV())
               {
                  this._createUMTV();
               }
               this._utmv.fromSharedObject(this._SO.data.utmv);
               if(this._debug.verbose)
               {
                  this._debug.info("found: " + this._utmv.toString(true),VisualDebugMode.geek);
               }
               if(this._utmv.isExpired())
               {
                  if(this._debug.verbose)
                  {
                     this._debug.warning("UTMV has expired",VisualDebugMode.advanced);
                  }
                  this._clearUTMV();
                  saveSO = true;
               }
            }
            if(this._SO.data.utmz)
            {
               if(!this.hasUTMZ())
               {
                  this._createUMTZ();
               }
               this._utmz.fromSharedObject(this._SO.data.utmz);
               if(this._debug.verbose)
               {
                  this._debug.info("found: " + this._utmz.toString(true),VisualDebugMode.geek);
               }
               if(this._utmz.isExpired())
               {
                  if(this._debug.verbose)
                  {
                     this._debug.warning("UTMZ has expired",VisualDebugMode.advanced);
                  }
                  this._clearUTMZ();
                  saveSO = true;
               }
            }
            if(saveSO)
            {
               this.save();
            }
         }
      }
      
      public function get utma() : UTMA
      {
         if(!this.hasUTMA())
         {
            this._createUMTA();
         }
         return this._utma;
      }
      
      public function get utmb() : UTMB
      {
         if(!this.hasUTMB())
         {
            this._createUMTB();
         }
         return this._utmb;
      }
      
      public function get utmc() : UTMC
      {
         if(!this.hasUTMC())
         {
            this._createUMTC();
         }
         return this._utmc;
      }
      
      public function get utmk() : UTMK
      {
         if(!this.hasUTMK())
         {
            this._createUMTK();
         }
         return this._utmk;
      }
      
      public function get utmx() : UTMX
      {
         if(!this.hasUTMX())
         {
            this._createUMTX();
         }
         return this._utmx;
      }
      
      public function get utmv() : UTMV
      {
         if(!this.hasUTMV())
         {
            this._createUMTV();
         }
         return this._utmv;
      }
      
      public function get utmz() : UTMZ
      {
         if(!this.hasUTMZ())
         {
            this._createUMTZ();
         }
         return this._utmz;
      }
      
      public function hasUTMA() : Boolean
      {
         if(this._utma)
         {
            return true;
         }
         return false;
      }
      
      public function hasUTMB() : Boolean
      {
         if(this._utmb)
         {
            return true;
         }
         return false;
      }
      
      public function hasUTMC() : Boolean
      {
         if(this._utmc)
         {
            return true;
         }
         return false;
      }
      
      public function hasUTMK() : Boolean
      {
         if(this._utmk)
         {
            return true;
         }
         return false;
      }
      
      public function hasUTMV() : Boolean
      {
         if(this._utmv)
         {
            return true;
         }
         return false;
      }
      
      public function hasUTMX() : Boolean
      {
         if(this._utmx)
         {
            return true;
         }
         return false;
      }
      
      public function hasUTMZ() : Boolean
      {
         if(this._utmz)
         {
            return true;
         }
         return false;
      }
      
      public function update(param1:String, param2:*) : void
      {
         if(this.isVolatile())
         {
            this._OBJ[param1] = param2;
         }
         else
         {
            this._SO.data[param1] = param2;
         }
      }
      
      public function clearCookies() : void
      {
         this.utma.reset();
         this.utmb.reset();
         this.utmc.reset();
         this.utmz.reset();
         this.utmv.reset();
         this.utmk.reset();
      }
      
      public function generateCookiesHash() : Number
      {
         var _loc1_:String = "";
         _loc1_ += this.utma.valueOf();
         _loc1_ += this.utmb.valueOf();
         _loc1_ += this.utmc.valueOf();
         _loc1_ += this.utmx.valueOf();
         _loc1_ += this.utmz.valueOf();
         _loc1_ += this.utmv.valueOf();
         return Utils.generateHash(_loc1_);
      }
      
      public function toLinkerParams() : String
      {
         var _loc1_:String = "";
         _loc1_ += this.utma.toURLString();
         _loc1_ += "&" + this.utmb.toURLString();
         _loc1_ += "&" + this.utmc.toURLString();
         _loc1_ += "&" + this.utmx.toURLString();
         _loc1_ += "&" + this.utmz.toURLString();
         _loc1_ += "&" + this.utmv.toURLString();
         return _loc1_ + ("&__utmk=" + this.generateCookiesHash());
      }
      
      public function getLinkerUrl(param1:String = "", param2:Boolean = false) : String
      {
         var _loc3_:String = this.toLinkerParams();
         var _loc4_:* = param1;
         var _loc5_:Array = param1.split("#");
         if(_loc3_)
         {
            if(param2)
            {
               if(1 >= _loc5_.length)
               {
                  _loc4_ += "#" + _loc3_;
               }
               else
               {
                  _loc4_ += "&" + _loc3_;
               }
            }
            else if(1 >= _loc5_.length)
            {
               if(param1.indexOf("?") > -1)
               {
                  _loc4_ += "&";
               }
               else
               {
                  _loc4_ += "?";
               }
               _loc4_ += _loc3_;
            }
            else
            {
               _loc4_ = String(_loc5_[0]);
               if(param1.indexOf("?") > -1)
               {
                  _loc4_ += "&";
               }
               else
               {
                  _loc4_ += "?";
               }
               _loc4_ += _loc3_ + "#" + _loc5_[1];
            }
         }
         return _loc4_;
      }
      
      public function isVolatile() : Boolean
      {
         return this._volatile;
      }
      
      public function isGenuine() : Boolean
      {
         if(!this.hasUTMK())
         {
            return true;
         }
         return this.utmk.hash == this.generateCookiesHash();
      }
      
      public function updateUTMA(param1:Number) : void
      {
         if(this._debug.verbose)
         {
            this._debug.info("updateUTMA( " + param1 + " )",VisualDebugMode.advanced);
         }
         if(!this.utma.isEmpty())
         {
            if(isNaN(this.utma.sessionCount))
            {
               this.utma.sessionCount = 1;
            }
            else
            {
               this.utma.sessionCount += 1;
            }
            this.utma.lastTime = this.utma.currentTime;
            this.utma.currentTime = param1;
         }
      }
      
      public function resetCurrentSession() : void
      {
         this._clearUTMB();
         this._clearUTMC();
         this.save();
      }
      
      public function save() : void
      {
         var flushStatus:String = null;
         if(!this.isVolatile())
         {
            flushStatus = null;
            try
            {
               flushStatus = this._SO.flush();
            }
            catch(e:Error)
            {
               _debug.warning("Error...Could not write SharedObject to disk");
            }
            switch(flushStatus)
            {
               case SharedObjectFlushStatus.PENDING:
                  this._debug.info("Requesting permission to save object...");
                  this._SO.addEventListener(NetStatusEvent.NET_STATUS,this._onFlushStatus);
                  break;
               case SharedObjectFlushStatus.FLUSHED:
                  this._debug.info("Value flushed to disk.");
            }
         }
      }
   }
}

package com.google.analytics.debug
{
   import com.google.analytics.core.GIFRequest;
   import flash.net.URLRequest;
   import flash.utils.getTimer;
   
   public class DebugConfiguration
   {
       
      
      private var _active:Boolean = false;
      
      private var _verbose:Boolean = false;
      
      private var _visualInitialized:Boolean = false;
      
      private var _mode:VisualDebugMode;
      
      public var layout:ILayout;
      
      public var traceOutput:Boolean = false;
      
      public var javascript:Boolean = false;
      
      public var GIFRequests:Boolean = false;
      
      public var showInfos:Boolean = true;
      
      public var infoTimeout:Number = 1000;
      
      public var showWarnings:Boolean = true;
      
      public var warningTimeout:Number = 1500;
      
      public var minimizedOnStart:Boolean = false;
      
      public var showHideKey:Number = 32;
      
      public var destroyKey:Number = 8;
      
      public function DebugConfiguration()
      {
         this._mode = VisualDebugMode.basic;
         super();
      }
      
      private function _initializeVisual() : void
      {
         if(this.layout)
         {
            this.layout.init();
            this._visualInitialized = true;
         }
      }
      
      private function _destroyVisual() : void
      {
         if(Boolean(this.layout) && this._visualInitialized)
         {
            this.layout.destroy();
         }
      }
      
      [Inspectable(defaultValue="basic",enumeration="basic,advanced,geek",type="String")]
      public function get mode() : *
      {
         return this._mode;
      }
      
      public function set mode(param1:*) : void
      {
         if(param1 is String)
         {
            switch(param1)
            {
               case "geek":
                  param1 = VisualDebugMode.geek;
                  break;
               case "advanced":
                  param1 = VisualDebugMode.advanced;
                  break;
               case "basic":
               default:
                  param1 = VisualDebugMode.basic;
            }
         }
         this._mode = param1;
      }
      
      protected function trace(param1:String) : void
      {
         var _loc7_:Array = null;
         var _loc8_:int = 0;
         var _loc2_:Array = [];
         var _loc3_:* = "";
         var _loc4_:* = "";
         if(this.mode == VisualDebugMode.geek)
         {
            _loc3_ = getTimer() + " - ";
            _loc4_ = new Array(_loc3_.length).join(" ") + " ";
         }
         if(param1.indexOf("\n") > -1)
         {
            _loc7_ = param1.split("\n");
            _loc8_ = 0;
            while(_loc8_ < _loc7_.length)
            {
               if(_loc7_[_loc8_] != "")
               {
                  if(_loc8_ == 0)
                  {
                     _loc2_.push(_loc3_ + _loc7_[_loc8_]);
                  }
                  else
                  {
                     _loc2_.push(_loc4_ + _loc7_[_loc8_]);
                  }
               }
               _loc8_++;
            }
         }
         else
         {
            _loc2_.push(_loc3_ + param1);
         }
         var _loc5_:int = int(_loc2_.length);
         var _loc6_:int = 0;
         while(_loc6_ < _loc5_)
         {
            _loc6_++;
         }
      }
      
      public function get active() : Boolean
      {
         return this._active;
      }
      
      public function set active(param1:Boolean) : void
      {
         this._active = param1;
         if(this._active)
         {
            this._initializeVisual();
         }
         else
         {
            this._destroyVisual();
         }
      }
      
      public function get verbose() : Boolean
      {
         return this._verbose;
      }
      
      public function set verbose(param1:Boolean) : void
      {
         this._verbose = param1;
      }
      
      private function _filter(param1:VisualDebugMode = null) : Boolean
      {
         return Boolean(param1) && int(param1) >= int(this.mode);
      }
      
      public function info(param1:String, param2:VisualDebugMode = null) : void
      {
         if(this._filter(param2))
         {
            return;
         }
         if(Boolean(this.layout) && this.showInfos)
         {
            this.layout.createInfo(param1);
         }
         if(this.traceOutput)
         {
         }
      }
      
      public function warning(param1:String, param2:VisualDebugMode = null) : void
      {
         if(this._filter(param2))
         {
            return;
         }
         if(Boolean(this.layout) && this.showWarnings)
         {
            this.layout.createWarning(param1);
         }
         if(this.traceOutput)
         {
            this.trace("## " + param1 + " ##");
         }
      }
      
      public function alert(param1:String) : void
      {
         if(this.layout)
         {
            this.layout.createAlert(param1);
         }
         if(this.traceOutput)
         {
            this.trace("!! " + param1 + " !!");
         }
      }
      
      public function failure(param1:String) : void
      {
         if(this.layout)
         {
            this.layout.createFailureAlert(param1);
         }
         if(this.traceOutput)
         {
            this.trace("[-] " + param1 + " !!");
         }
      }
      
      public function success(param1:String) : void
      {
         if(this.layout)
         {
            this.layout.createSuccessAlert(param1);
         }
         if(this.traceOutput)
         {
            this.trace("[+] " + param1 + " !!");
         }
      }
      
      public function alertGifRequest(param1:String, param2:URLRequest, param3:GIFRequest) : void
      {
         if(this.layout)
         {
            this.layout.createGIFRequestAlert(param1,param2,param3);
         }
         if(this.traceOutput)
         {
            this.trace(">> " + param1 + " <<");
         }
      }
   }
}

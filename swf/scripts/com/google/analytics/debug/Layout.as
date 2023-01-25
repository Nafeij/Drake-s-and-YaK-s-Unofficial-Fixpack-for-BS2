package com.google.analytics.debug
{
   import com.google.analytics.GATracker;
   import com.google.analytics.core.GIFRequest;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.net.URLRequest;
   
   public class Layout implements ILayout
   {
       
      
      private var _display:DisplayObject;
      
      private var _debug:DebugConfiguration;
      
      private var _mainPanel:Panel;
      
      private var _hasWarning:Boolean;
      
      private var _hasInfo:Boolean;
      
      private var _hasDebug:Boolean;
      
      private var _hasGRAlert:Boolean;
      
      private var _infoQueue:Array;
      
      private var _maxCharPerLine:int = 85;
      
      private var _warningQueue:Array;
      
      private var _GRAlertQueue:Array;
      
      public var visualDebug:Debug;
      
      public function Layout(param1:DebugConfiguration, param2:DisplayObject)
      {
         super();
         this._display = param2;
         this._debug = param1;
         this._hasWarning = false;
         this._hasInfo = false;
         this._hasDebug = false;
         this._hasGRAlert = false;
         this._warningQueue = [];
         this._infoQueue = [];
         this._GRAlertQueue = [];
      }
      
      public function init() : void
      {
         var _loc1_:int = 10;
         var _loc2_:uint = uint(this._display.stage.stageWidth - _loc1_ * 2);
         var _loc3_:uint = uint(this._display.stage.stageHeight - _loc1_ * 2);
         var _loc4_:Panel = new Panel("analytics",_loc2_,_loc3_);
         _loc4_.alignement = Align.top;
         _loc4_.stickToEdge = false;
         _loc4_.title = "Google Analytics v" + GATracker.version;
         this._mainPanel = _loc4_;
         this.addToStage(_loc4_);
         this.bringToFront(_loc4_);
         if(this._debug.minimizedOnStart)
         {
            this._mainPanel.onToggle();
         }
         this.createVisualDebug();
         this._display.stage.addEventListener(KeyboardEvent.KEY_DOWN,this.onKey,false,0,true);
      }
      
      public function destroy() : void
      {
         this._mainPanel.close();
         this._debug.layout = null;
      }
      
      private function onKey(param1:KeyboardEvent = null) : void
      {
         switch(param1.keyCode)
         {
            case this._debug.showHideKey:
               this._mainPanel.visible = !this._mainPanel.visible;
               break;
            case this._debug.destroyKey:
               this.destroy();
         }
      }
      
      private function _clearInfo(param1:Event) : void
      {
         this._hasInfo = false;
         if(this._infoQueue.length > 0)
         {
            this.createInfo(this._infoQueue.shift());
         }
      }
      
      private function _clearWarning(param1:Event) : void
      {
         this._hasWarning = false;
         if(this._warningQueue.length > 0)
         {
            this.createWarning(this._warningQueue.shift());
         }
      }
      
      private function _clearGRAlert(param1:Event) : void
      {
         this._hasGRAlert = false;
         if(this._GRAlertQueue.length > 0)
         {
            this.createGIFRequestAlert.apply(this,this._GRAlertQueue.shift());
         }
      }
      
      private function _filterMaxChars(param1:String, param2:int = 0) : String
      {
         var _loc6_:String = null;
         var _loc3_:String = "\n";
         var _loc4_:Array = [];
         var _loc5_:Array = param1.split(_loc3_);
         if(param2 == 0)
         {
            param2 = this._maxCharPerLine;
         }
         var _loc7_:int = 0;
         while(_loc7_ < _loc5_.length)
         {
            _loc6_ = String(_loc5_[_loc7_]);
            while(_loc6_.length > param2)
            {
               _loc4_.push(_loc6_.substr(0,param2));
               _loc6_ = _loc6_.substring(param2);
            }
            _loc4_.push(_loc6_);
            _loc7_++;
         }
         return _loc4_.join(_loc3_);
      }
      
      public function addToStage(param1:DisplayObject) : void
      {
         this._display.stage.addChild(param1);
      }
      
      public function addToPanel(param1:String, param2:DisplayObject) : void
      {
         var _loc4_:Panel = null;
         var _loc3_:DisplayObject = this._display.stage.getChildByName(param1);
         if(_loc3_)
         {
            _loc4_ = _loc3_ as Panel;
            _loc4_.addData(param2);
         }
         else
         {
            trace("panel \"" + param1 + "\" not found");
         }
      }
      
      public function bringToFront(param1:DisplayObject) : void
      {
         this._display.stage.setChildIndex(param1,this._display.stage.numChildren - 1);
      }
      
      public function isAvailable() : Boolean
      {
         return this._display.stage != null;
      }
      
      public function createVisualDebug() : void
      {
         if(!this.visualDebug)
         {
            this.visualDebug = new Debug();
            this.visualDebug.alignement = Align.bottom;
            this.visualDebug.stickToEdge = true;
            this.addToPanel("analytics",this.visualDebug);
            this._hasDebug = true;
         }
      }
      
      public function createPanel(param1:String, param2:uint, param3:uint) : void
      {
         var _loc4_:Panel = new Panel(param1,param2,param3);
         _loc4_.alignement = Align.center;
         _loc4_.stickToEdge = false;
         this.addToStage(_loc4_);
         this.bringToFront(_loc4_);
      }
      
      public function createInfo(param1:String) : void
      {
         if(this._hasInfo || !this.isAvailable())
         {
            this._infoQueue.push(param1);
            return;
         }
         param1 = this._filterMaxChars(param1);
         this._hasInfo = true;
         var _loc2_:Info = new Info(param1,this._debug.infoTimeout);
         this.addToPanel("analytics",_loc2_);
         _loc2_.addEventListener(Event.REMOVED_FROM_STAGE,this._clearInfo,false,0,true);
         if(this._hasDebug)
         {
            this.visualDebug.write(param1);
         }
      }
      
      public function createWarning(param1:String) : void
      {
         if(this._hasWarning || !this.isAvailable())
         {
            this._warningQueue.push(param1);
            return;
         }
         param1 = this._filterMaxChars(param1);
         this._hasWarning = true;
         var _loc2_:Warning = new Warning(param1,this._debug.warningTimeout);
         this.addToPanel("analytics",_loc2_);
         _loc2_.addEventListener(Event.REMOVED_FROM_STAGE,this._clearWarning,false,0,true);
         if(this._hasDebug)
         {
            this.visualDebug.writeBold(param1);
         }
      }
      
      public function createAlert(param1:String) : void
      {
         param1 = this._filterMaxChars(param1);
         var _loc2_:Alert = new Alert(param1,[new AlertAction("Close","close","close")]);
         this.addToPanel("analytics",_loc2_);
         if(this._hasDebug)
         {
            this.visualDebug.writeBold(param1);
         }
      }
      
      public function createFailureAlert(param1:String) : void
      {
         var _loc2_:AlertAction = null;
         if(this._debug.verbose)
         {
            param1 = this._filterMaxChars(param1);
            _loc2_ = new AlertAction("Close","close","close");
         }
         else
         {
            _loc2_ = new AlertAction("X","close","close");
         }
         var _loc3_:Alert = new FailureAlert(this._debug,param1,[_loc2_]);
         this.addToPanel("analytics",_loc3_);
         if(this._hasDebug)
         {
            if(this._debug.verbose)
            {
               param1 = param1.split("\n").join("");
               param1 = this._filterMaxChars(param1,66);
            }
            this.visualDebug.writeBold(param1);
         }
      }
      
      public function createSuccessAlert(param1:String) : void
      {
         var _loc2_:AlertAction = null;
         if(this._debug.verbose)
         {
            param1 = this._filterMaxChars(param1);
            _loc2_ = new AlertAction("Close","close","close");
         }
         else
         {
            _loc2_ = new AlertAction("X","close","close");
         }
         var _loc3_:Alert = new SuccessAlert(this._debug,param1,[_loc2_]);
         this.addToPanel("analytics",_loc3_);
         if(this._hasDebug)
         {
            if(this._debug.verbose)
            {
               param1 = param1.split("\n").join("");
               param1 = this._filterMaxChars(param1,66);
            }
            this.visualDebug.writeBold(param1);
         }
      }
      
      public function createGIFRequestAlert(param1:String, param2:URLRequest, param3:GIFRequest) : void
      {
         var f:Function;
         var gra:GIFRequestAlert;
         var message:String = param1;
         var request:URLRequest = param2;
         var ref:GIFRequest = param3;
         if(this._hasGRAlert)
         {
            this._GRAlertQueue.push([message,request,ref]);
            return;
         }
         this._hasGRAlert = true;
         f = function():void
         {
            ref.sendRequest(request);
         };
         message = this._filterMaxChars(message);
         gra = new GIFRequestAlert(message,[new AlertAction("OK","ok",f),new AlertAction("Cancel","cancel","close")]);
         this.addToPanel("analytics",gra);
         gra.addEventListener(Event.REMOVED_FROM_STAGE,this._clearGRAlert,false,0,true);
         if(this._hasDebug)
         {
            if(this._debug.verbose)
            {
               message = message.split("\n").join("");
               message = this._filterMaxChars(message,66);
            }
            this.visualDebug.write(message);
         }
      }
   }
}

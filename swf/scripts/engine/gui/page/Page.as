package engine.gui.page
{
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.ShellCmdManager;
   import engine.core.fsm.State;
   import engine.core.logging.ILogger;
   import engine.gui.core.GuiSprite;
   import flash.geom.Point;
   import flash.utils.getQualifiedClassName;
   
   public class Page extends GuiSprite
   {
       
      
      public var sortingPriority:int = 0;
      
      private var _state:PageState;
      
      public var pageCallback:Function;
      
      private var _manager:IPageManager;
      
      private var _showing:Boolean;
      
      private var _percentLoaded:Number = 0;
      
      public var logger:ILogger;
      
      public var shell:ShellCmdManager;
      
      public var fullscreen:Boolean = true;
      
      public function Page(param1:String, param2:ILogger)
      {
         this._state = PageState.INIT;
         super();
         this.shell = new ShellCmdManager(param2);
         this.logger = param2;
         this.name = param1;
         this.anchor.percentHeight = 100;
         this.anchor.percentWidth = 100;
         this.shell.add("loading",this.shellCmdFuncLoading);
         this.shell.add("visible",this.shellCmdFuncVisible);
         this.shell.add("rect",this.shellCmdFuncRect);
      }
      
      override public function toString() : String
      {
         return this.clazzName();
      }
      
      private function clazzName() : String
      {
         var _loc1_:String = getQualifiedClassName(this);
         var _loc2_:int = _loc1_.indexOf("::");
         if(_loc2_ > 0)
         {
            _loc1_ = _loc1_.substr(_loc2_ + 2);
         }
         return _loc1_;
      }
      
      public function start() : void
      {
         visible = true;
      }
      
      public function terminate() : void
      {
         visible = false;
         this.state = PageState.TERMINATED;
         try
         {
            this.cleanup();
         }
         catch(err:Error)
         {
            logger.error("Failed to cleanup " + this + "\n" + err.getStackTrace());
         }
      }
      
      override public function cleanup() : void
      {
         if(this.shell)
         {
            this.shell.cleanup();
            this.shell = null;
         }
         super.cleanup();
      }
      
      public function get state() : PageState
      {
         return this._state;
      }
      
      public function set state(param1:PageState) : void
      {
         if(this._state == param1)
         {
            return;
         }
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("Page.state [" + this + "] " + param1);
         }
         this._state = param1;
         if(this._manager)
         {
            this._manager.onPageStateChanged(this);
         }
         this.handleStateChanged();
      }
      
      protected function handleStateChanged() : void
      {
      }
      
      public function get showing() : Boolean
      {
         return this._showing;
      }
      
      public function set showing(param1:Boolean) : void
      {
         this._showing = param1;
      }
      
      public function get percentLoaded() : Number
      {
         return this._percentLoaded;
      }
      
      public function set percentLoaded(param1:Number) : void
      {
         this._percentLoaded = param1;
         if(this._manager)
         {
            this._manager.onPagePercentLoadedChanged(this);
         }
      }
      
      public function get manager() : IPageManager
      {
         return this._manager;
      }
      
      public function set manager(param1:IPageManager) : void
      {
         this._manager = param1;
      }
      
      public function shellCmdFuncLoading(param1:CmdExec) : void
      {
         var _loc3_:Number = NaN;
         var _loc2_:Array = param1.param;
         if(_loc2_.length > 1)
         {
            _loc3_ = int(_loc2_[1]) / 100;
            if(_loc3_ < 1)
            {
               this.state = PageState.LOADING;
            }
            this.percentLoaded = _loc3_;
            if(_loc3_ >= 1)
            {
               this.state = PageState.READY;
            }
         }
         this.logger.info("Page " + this + " percentLoaded=" + this.percentLoaded + " state=" + this.state + " loading=" + this.manager.loading);
      }
      
      public function shellCmdFuncVisible(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         if(_loc2_.length > 1)
         {
            visible = _loc2_[1] == "true";
         }
         this.logger.info("Page " + this + " visible=" + visible);
      }
      
      public function shellCmdFuncRect(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         var _loc3_:Point = null;
         var _loc4_:Point = null;
         if(_loc2_.length > 2)
         {
            setPosition(_loc2_[1],_loc2_[2]);
            if(_loc2_.length > 4)
            {
               setSize(_loc2_[3],_loc2_[4]);
            }
         }
         this.logger.info("Page " + this + " rect=" + getRect(null));
      }
      
      public function canReusePageForState(param1:State) : Boolean
      {
         return true;
      }
      
      public function update(param1:int) : void
      {
      }
   }
}

package engine.gui.page
{
   import com.stoicstudio.platform.PlatformStarling;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.ShellCmdManager;
   import engine.core.fsm.Fsm;
   import engine.core.fsm.FsmEvent;
   import engine.core.fsm.State;
   import engine.core.logging.ILogger;
   import engine.core.util.EngineCoreContext;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.errors.IllegalOperationError;
   import flash.events.EventDispatcher;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   import flash.utils.getTimer;
   
   public class PageManagerAdapter extends EventDispatcher implements IPageManager
   {
      
      public static var OVERLAY_VISIBLE:Boolean;
      
      public static var IS_LOADING:Boolean;
       
      
      protected var _currentPage:Page;
      
      public var loadingPage:Page;
      
      public var loadingPageInterface:ILoadingPage;
      
      private var _layerLoading:int;
      
      private var _loading:Boolean;
      
      public var context:EngineCoreContext;
      
      private var fsmStatePageClasses:Dictionary;
      
      public var pageCtor:Function;
      
      private var fsm:Fsm;
      
      public var holder:DisplayObjectContainer;
      
      protected var rect:Rectangle;
      
      private var holderIndex:int;
      
      private var _shell:ShellCmdManager;
      
      public var logger:ILogger;
      
      private var cleanedup:Boolean;
      
      private var _checkLoadingNextFrame:Boolean;
      
      private var _loadStartTime:int;
      
      public function PageManagerAdapter(param1:EngineCoreContext, param2:Fsm, param3:Page, param4:DisplayObjectContainer, param5:int, param6:int)
      {
         this.fsmStatePageClasses = new Dictionary();
         this.rect = new Rectangle(0,0,200,100);
         super();
         if(!param1)
         {
            throw ArgumentError("bad context");
         }
         this._layerLoading = param6;
         this.context = param1;
         this.logger = param1.logger;
         this.fsm = param2;
         this.holder = param4;
         this.holderIndex = param5;
         this._shell = new ShellCmdManager(param1.logger);
         this.loadingPage = param3;
         if(param3)
         {
            param3.visible = false;
            param3.manager = this;
            this.loadingPageInterface = param3 as ILoadingPage;
            if(!this.loadingPageInterface)
            {
               throw new ArgumentError("Invalid loading page");
            }
         }
         this._shell.add("current",this.shellCmdFuncCurrent);
         this._shell.add("info",this.shellCmdFuncInfo);
      }
      
      public function handleFsmReady(param1:Fsm) : void
      {
         this.fsm = param1;
         param1.addEventListener(FsmEvent.CURRENT,this.fsmCurrentHandler);
         param1.addEventListener(FsmEvent.LOADING,this.fsmLoadingHandler);
      }
      
      public function onPageStateChanged(param1:Page) : void
      {
         if(param1.state == PageState.TERMINATED)
         {
            param1.manager = null;
            this.holder.removeChild(param1);
         }
         this.checkLoading(false);
      }
      
      public function onPagePercentLoadedChanged(param1:Page) : void
      {
         this.checkLoading(false);
         if(this.loadingPageInterface)
         {
            this.loadingPageInterface.onTargetChanged();
         }
      }
      
      public function setRect(param1:Number, param2:Number, param3:Number, param4:Number) : void
      {
         this.rect.setTo(param1,param2,param3,param4);
         if(this._currentPage)
         {
            this._currentPage.setSize(param3,param4);
            this._currentPage.setPosition(param1,param2);
         }
         if(this.loadingPage)
         {
            this.loadingPage.setSize(param3,param4);
            this.loadingPage.setPosition(param1,param2);
         }
      }
      
      public function cleanup() : void
      {
         if(this.cleanedup)
         {
            throw new IllegalOperationError("Why cleanedup twice?");
         }
         this.cleanedup = true;
         if(this.fsm)
         {
            this.fsm.removeEventListener(FsmEvent.CURRENT,this.fsmCurrentHandler);
            this.fsm.removeEventListener(FsmEvent.LOADING,this.fsmLoadingHandler);
         }
         this.currentPage = null;
      }
      
      public function registerFsmStatePageClass(param1:Class, param2:Class) : void
      {
         this.fsmStatePageClasses[param1] = param2;
      }
      
      private function fsmLoadingHandler(param1:FsmEvent) : void
      {
         this.checkLoading(false);
      }
      
      private function fsmCurrentHandler(param1:FsmEvent) : void
      {
         var _loc3_:String = null;
         var _loc4_:Class = null;
         var _loc2_:Class = this.fsmStatePageClasses[this.fsm.currentClass];
         if(_loc2_ != null)
         {
            if(this._currentPage)
            {
               _loc3_ = getQualifiedClassName(this.currentPage);
               _loc4_ = getDefinitionByName(_loc3_) as Class;
               if(_loc4_ == _loc2_)
               {
                  if(this._currentPage.canReusePageForState(this.fsm.current))
                  {
                     if(this.logger.isDebugEnabled)
                     {
                        this.logger.debug("PageManagerAdapter re-using page for state " + this.fsm.current);
                     }
                     return;
                  }
               }
            }
            this.currentPage = this.pageCtor(_loc2_);
         }
         this.updateLoadingPage();
      }
      
      public function addHolderChild(param1:DisplayObject, param2:int) : void
      {
         var _loc5_:Page = null;
         var _loc3_:Page = param1 as Page;
         if(!_loc3_)
         {
            throw new IllegalOperationError("Pages only, please");
         }
         if(_loc3_.manager != this)
         {
            throw new IllegalOperationError("use addPage(), please");
         }
         _loc3_.sortingPriority = this.holderIndex + param2;
         var _loc4_:int = 0;
         while(_loc4_ < this.holder.numChildren)
         {
            _loc5_ = this.holder.getChildAt(_loc4_) as Page;
            if(_loc5_)
            {
               if(_loc5_.sortingPriority > _loc3_.sortingPriority)
               {
                  this.holder.addChildAt(_loc3_,_loc4_);
                  _loc3_.makeAllDirty();
                  return;
               }
            }
            _loc4_++;
         }
         this.holder.addChildAt(param1,_loc4_);
         _loc3_.makeAllDirty();
      }
      
      protected function get canRenderNullCurrentPage() : Boolean
      {
         return false;
      }
      
      private function checkLoading(param1:Boolean) : void
      {
         var _loc3_:Boolean = false;
         this._checkLoadingNextFrame = false;
         if(this.currentPage)
         {
            _loc3_ = this.currentPage.state == PageState.LOADING || Boolean(this.fsm.current) && this.fsm.current.loading;
            if(!param1)
            {
               if(this._loading && !_loc3_)
               {
                  this._checkLoadingNextFrame = true;
                  return;
               }
            }
            this.loading = _loc3_;
         }
         else if(this.canRenderNullCurrentPage)
         {
            this.loading = false;
         }
         else
         {
            this.loading = true;
         }
         var _loc2_:String = "";
         if(this.logger.isDebugEnabled)
         {
            _loc2_ = "PageManagerAdapter.checkLoading loading=" + this.loading + " _currentPage=" + this._currentPage;
         }
         PlatformStarling.setFullscreenGui(this.loading || Boolean(this._currentPage) && this._currentPage.fullscreen,_loc2_,this.logger);
      }
      
      public function get loading() : Boolean
      {
         return this._loading;
      }
      
      public function set loading(param1:Boolean) : void
      {
         if(this._loading == param1)
         {
            return;
         }
         this._loading = param1;
         IS_LOADING = this._loading;
         if(this._loading)
         {
            this._loadStartTime = getTimer();
         }
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("PageManager loading=" + this._loading);
         }
         this.updateLoadingPage();
         this.handleLoadingChanged();
         if(!this._loading)
         {
            this.logger.i("LOAD","completed in " + (getTimer() - this._loadStartTime) + " ms");
         }
      }
      
      protected function handleLoadingChanged() : void
      {
      }
      
      private function updateLoadingPage() : void
      {
         if(this._loading)
         {
            if(!this.loadingPage.parent)
            {
               this.addHolderChild(this.loadingPage,this._layerLoading);
            }
         }
         else if(this.loadingPage.parent)
         {
            this.holder.removeChild(this.loadingPage);
         }
         if(this.loadingPage)
         {
            this.loadingPage.showing = this._loading;
            this.loadingPageInterface.setTarget(this.currentPage,!!this.fsm ? this.fsm.current : null);
         }
         if(this.currentPage)
         {
            this.currentPage.showing = !this._loading;
         }
      }
      
      public function get currentPage() : Page
      {
         return this._currentPage;
      }
      
      public function set currentPage(param1:Page) : void
      {
         var _loc2_:String = null;
         if(this._currentPage != param1)
         {
            if(this._currentPage)
            {
               this._currentPage.visible = false;
               this._currentPage.terminate();
            }
            this._currentPage = param1;
            if(this.logger.isDebugEnabled)
            {
               this.logger.debug("PageManagerAdapter.currentPage " + param1);
            }
            if(this._currentPage)
            {
               this._currentPage.visible = true;
               this._currentPage.manager = this;
               this.addHolderChild(this._currentPage,0);
               this._currentPage.start();
            }
            _loc2_ = "";
            if(this.logger.isDebugEnabled)
            {
               _loc2_ = "PageManagerAdapter.checkLoading loading=" + this.loading + " _currentPage=" + this._currentPage;
            }
            PlatformStarling.setFullscreenGui(this.loading || Boolean(this._currentPage) && this._currentPage.fullscreen,_loc2_,this.logger);
         }
      }
      
      public function get shell() : ShellCmdManager
      {
         return this._shell;
      }
      
      public function shellCmdFuncCurrent(param1:CmdExec) : void
      {
         if(this.currentPage)
         {
            this.currentPage.shell.execSubShell(param1);
         }
      }
      
      public function shellCmdFuncInfo(param1:CmdExec) : void
      {
         var _loc3_:DisplayObject = null;
         this.context.logger.info("CurrentPage        : " + this.currentPage);
         if(this.currentPage)
         {
            this.context.logger.info("CurrentPage.state  : " + this.currentPage.state);
            this.context.logger.info("CurrentPage.showing: " + this.currentPage.showing);
            this.context.logger.info("CurrentPage.visible: " + this.currentPage.visible);
            this.context.logger.info("CurrentPage.percent: " + this.currentPage.percentLoaded);
            this.context.logger.info("CurrentPage.pos    : " + this.currentPage.x + ", " + this.currentPage.y);
            this.context.logger.info("CurrentPage.size   : " + this.currentPage.width + ", " + this.currentPage.height);
         }
         this.context.logger.info("Loading: " + this.loading);
         this.context.logger.info("LoadingPage.visible: " + this.loadingPage.visible);
         this.context.logger.info("LoadingPage.parent : " + this.loadingPage.parent);
         this.context.logger.info("LoadingPage.state  : " + this.loadingPage.state);
         this.context.logger.info("LoadingPage.pos    : " + this.loadingPage.x + ", " + this.loadingPage.y);
         this.context.logger.info("LoadingPage.size   : " + this.loadingPage.width + ", " + this.loadingPage.height);
         this.context.logger.info("Holder: " + this.holder);
         var _loc2_:int = 0;
         while(_loc2_ < this.holder.numChildren)
         {
            _loc3_ = this.holder.getChildAt(_loc2_);
            this.context.logger.info("       " + _loc2_.toString() + " " + _loc3_);
            _loc2_++;
         }
      }
      
      public function update(param1:int) : void
      {
         if(this._checkLoadingNextFrame)
         {
            this.checkLoading(true);
         }
         if(this._currentPage)
         {
            this._currentPage.update(param1);
         }
         if(this.loadingPage && this.loadingPage.visible && Boolean(this.loadingPage.parent))
         {
            this.loadingPage.update(param1);
         }
      }
   }
}

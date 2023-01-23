package game.gui
{
   import com.greensock.TweenMax;
   import engine.core.cmd.CmdExec;
   import engine.core.locale.LocaleCategory;
   import engine.core.render.BoundedCamera;
   import engine.core.render.FitConstraints;
   import engine.core.render.MatteHelper;
   import engine.core.render.ScreenAspectHelper;
   import engine.core.util.MovieClipUtil;
   import engine.gui.GuiUtil;
   import engine.gui.IGuiButton;
   import engine.gui.core.GuiSprite;
   import engine.gui.page.Page;
   import engine.gui.page.PageState;
   import engine.resource.Resource;
   import engine.resource.ResourceGroup;
   import engine.resource.ResourceMonitor;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   import game.cfg.GameConfig;
   
   public class GamePage extends Page
   {
      
      public static var mcButtonCloseNwClazz:Class;
       
      
      private var ui_author_width:int = 2731;
      
      private var ui_author_height:int = 1536;
      
      public var config:GameConfig;
      
      protected var monitor:ResourceMonitor;
      
      private var startDelayTicks:int = 2;
      
      protected var container:GuiSprite;
      
      protected var fullScreenMc:MovieClip;
      
      protected var fitConstraints:FitConstraints;
      
      private var resourceGroup:ResourceGroup;
      
      protected var boundedCamera:BoundedCamera;
      
      protected var matteHelper:MatteHelper;
      
      protected var allowPageScaling:Boolean = true;
      
      private var _overlay:DisplayObject;
      
      private var buttonClose:IGuiButton;
      
      private var bmpholderHelper:GuiBitmapHolderHelper;
      
      protected var blockTranslate:Boolean;
      
      public var cleanedup:Boolean;
      
      public function GamePage(param1:GameConfig, param2:int = 2731, param3:int = 1536, param4:Boolean = true)
      {
         this.container = new GuiSprite();
         this.resourceGroup = new ResourceGroup(this,param1.logger);
         this.bmpholderHelper = new GuiBitmapHolderHelper(param1.resman,null);
         this.ui_author_width = param2;
         this.ui_author_height = param3;
         name = getQualifiedClassName(this);
         var _loc5_:int = name.indexOf("::");
         if(_loc5_ > 0)
         {
            name = name.substr(_loc5_ + 2);
         }
         super(name,param1.logger);
         this.config = param1;
         this.anchor.percentHeight = 100;
         this.anchor.percentWidth = 100;
         this.mouseChildren = true;
         this.mouseEnabled = true;
         this.container.name = "container";
         addChild(this.container);
         this.container.anchor.verticalCenter = 0;
         this.container.anchor.horizontalCenter = 0;
         this.monitor = new ResourceMonitor("GP " + this,param1.logger,this.resourceMonitorChangedHandler);
         this.fitConstraints = new FitConstraints();
         this.fitConstraints.cinemascope = false;
         this.fitConstraints.minHeight = ScreenAspectHelper.HEIGHT_NATIVE;
         this.fitConstraints.maxHeight = ScreenAspectHelper.HEIGHT_NATIVE;
         this.fitConstraints.minWidth = ScreenAspectHelper.WIDTH_STANDARD;
         this.fitConstraints.maxWidth = ScreenAspectHelper.WIDTH_NATIVE;
         this.boundedCamera = new BoundedCamera("page:" + name,this.config.logger,new Rectangle(x,y,width,height),true);
         this.boundedCamera.guiPage = true;
         this.boundedCamera.minHeight = ScreenAspectHelper.HEIGHT_NATIVE;
         this.boundedCamera.maxHeight = ScreenAspectHelper.HEIGHT_NATIVE;
         this.boundedCamera.cinemascope = false;
         if(param4)
         {
            this.matteHelper = new MatteHelper(this,this.boundedCamera);
         }
         this.boundedCamera.fitCamera(this.width,this.height);
         addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler);
      }
      
      final protected function setupButtonClose() : void
      {
         if(!this.buttonClose)
         {
            this.buttonClose = new mcButtonCloseNwClazz() as IGuiButton;
            GuiUtil.attemptStopAllMovieClips(this.buttonClose.movieClip);
            this.buttonClose.guiButtonContext = this.config.gameGuiContext;
            this.buttonClose.setDownFunction(this.buttonCloseHandler);
            this.buttonClose.movieClip.visible = false;
         }
      }
      
      protected function handleButtonClosePress() : void
      {
      }
      
      final private function buttonCloseHandler(param1:*) : void
      {
         this.handleButtonClosePress();
      }
      
      final protected function showButtonClose(param1:Number) : void
      {
         this.setupButtonClose();
         if(!this.buttonClose.movieClip.parent)
         {
            addChild(this.buttonClose.movieClip);
         }
         this.buttonClose.movieClip.visible = true;
         TweenMax.killDelayedCallsTo(this.delayedHideButtonClose);
         TweenMax.delayedCall(param1,this.delayedHideButtonClose);
      }
      
      final protected function isCloseButtonShowing() : Boolean
      {
         return this.buttonClose != null && this.buttonClose.movieClip != null && this.buttonClose.movieClip.visible;
      }
      
      private function delayedHideButtonClose() : void
      {
         if(!this.buttonClose.movieClip.parent)
         {
            this.buttonClose.movieClip.parent.removeChild(this.buttonClose.movieClip);
         }
         this.buttonClose.movieClip.visible = false;
      }
      
      override public function cleanup() : void
      {
         if(this.cleanedup)
         {
            return;
         }
         GuiIconSlot.cancelAllDrags();
         this.cleanedup = true;
         TweenMax.killDelayedCallsTo(this.delayedHideButtonClose);
         if(this.buttonClose)
         {
            this.buttonClose.cleanup();
            this.buttonClose = null;
         }
         this.bmpholderHelper.cleanup();
         removeEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler);
         this.config.resman.removeMonitor(this.monitor);
         this.monitor.cleanup();
         this.monitor = null;
         this.fitConstraints = null;
         this.config = null;
         this.fitConstraints = null;
         this.boundedCamera.cleanup();
         this.boundedCamera = null;
         if(this.matteHelper)
         {
            this.matteHelper.cleanup();
            this.matteHelper = null;
         }
         this.resourceGroup.release();
         this.resourceGroup = null;
         if(this.fullScreenMc)
         {
            MovieClipUtil.stopRecursive(this.fullScreenMc);
            if(this.fullScreenMc.parent)
            {
               this.fullScreenMc.parent.removeChild(this.fullScreenMc);
            }
            this.fullScreenMc = null;
         }
         if(this.container)
         {
            this.container.cleanup();
         }
         if(this.bmpholderHelper)
         {
            this.bmpholderHelper.cleanup();
            this.bmpholderHelper = null;
         }
         super.cleanup();
      }
      
      public function getPageResource(param1:String, param2:Class) : Resource
      {
         return this.config.resman.getResource(param1,param2,this.resourceGroup) as Resource;
      }
      
      public function releasePageResource(param1:String) : void
      {
         if(this.resourceGroup)
         {
            this.resourceGroup.releaseResource(param1);
         }
      }
      
      override protected function resizeHandler() : void
      {
         super.resizeHandler();
         if(!this.allowPageScaling)
         {
            return;
         }
         var _loc1_:Number = this.width;
         var _loc2_:Number = this.height;
         this.boundedCamera.fitCamera(_loc1_,_loc2_);
         this.container.scaleX = this.container.scaleY = this.boundedCamera.scale;
      }
      
      private function resourceMonitorChangedHandler(param1:ResourceMonitor) : void
      {
         if(state == PageState.LOADING)
         {
            percentLoaded = this.monitor.percent;
            this.checkReady();
         }
      }
      
      override public function start() : void
      {
         super.start();
         this.config.resman.addMonitor(this.monitor);
         try
         {
            this.handleStart();
         }
         catch(err:Error)
         {
            logger.error("GamePage.start failed for " + this);
            logger.error(err.getStackTrace());
         }
         if(!this.cleanedup)
         {
            this.checkReady();
         }
         if(!this.cleanedup)
         {
            if(Boolean(this.config) && Boolean(this.config.saga))
            {
               this.config.saga.triggerPageStarted(name);
            }
         }
      }
      
      protected function handleStart() : void
      {
      }
      
      protected function handleDelayStart() : void
      {
      }
      
      protected function handleLoaded() : void
      {
      }
      
      protected function setFullPageMovieClipClass(param1:Class, param2:Dictionary = null) : void
      {
         if(this.fullScreenMc)
         {
            return;
         }
         if(!param1)
         {
            logger.error("Game.setFullPageMovieClipClass null for " + this);
            return;
         }
         var _loc3_:MovieClip = new param1() as MovieClip;
         this.setFullPageMovieClip(_loc3_,param2);
      }
      
      protected function setFullPageMovieClip(param1:MovieClip, param2:Dictionary = null) : void
      {
         if(this.fullScreenMc)
         {
            return;
         }
         if(param1)
         {
            GuiUtil.attemptStopAllMovieClips(param1);
         }
         this.fullScreenMc = param1;
         if(!this.fullScreenMc)
         {
            this.config.logger.error("GamePage.handleFullPageMovieClip invalid movieclip for " + this);
            return;
         }
         this.addChildToContainer(this.fullScreenMc);
         this.fullScreenMc.x = -this.ui_author_width / 2;
         this.fullScreenMc.y = -this.ui_author_height / 2;
         this.resizeHandler();
         this.config.context.locale.translateDisplayObjects(LocaleCategory.GUI,this.fullScreenMc,logger);
         this.bmpholderHelper.loadGuiBitmaps(this.fullScreenMc,param2);
      }
      
      final protected function loadGuiBitmaps(param1:MovieClip, param2:Dictionary = null) : void
      {
         this.bmpholderHelper.loadGuiBitmaps(param1,param2);
      }
      
      protected function checkReady() : void
      {
         if(this.cleanedup)
         {
            return;
         }
         if(this.monitor.empty)
         {
            if(this.fullScreenMc)
            {
               MovieClipUtil.stopRecursive(this.fullScreenMc);
            }
            if(this.monitor.empty)
            {
               try
               {
                  this.handleLoaded();
                  if(Boolean(this.fullScreenMc) && !this.blockTranslate)
                  {
                     this.config.context.locale.translateDisplayObjects(LocaleCategory.GUI,this.fullScreenMc,logger);
                  }
               }
               catch(e:Error)
               {
                  config.logger.error("GamePage.checkReady Failed to load " + name + ": " + e.getStackTrace());
               }
               if(this.monitor.empty)
               {
                  this.config.resman.removeMonitor(this.monitor);
                  if(this.canBeReady())
                  {
                     state = PageState.READY;
                     try
                     {
                        this.handleDelayStart();
                     }
                     catch(e:Error)
                     {
                        config.logger.error("GamePage.checkReady Failed to handleDelayStart " + name + ": " + e.getStackTrace());
                     }
                     if(this.cleanedup)
                     {
                        return;
                     }
                     if(Boolean(this.config.fsm) && Boolean(this.config.fsm.currentGameState))
                     {
                        try
                        {
                           this.config.fsm.currentGameState.handlePageReady();
                        }
                        catch(e:Error)
                        {
                           config.logger.error("GamePage.checkReady Failed to handlePageReady " + name + ": " + e.getStackTrace());
                        }
                     }
                  }
                  return;
               }
            }
         }
         state = PageState.LOADING;
      }
      
      protected function canBeReady() : Boolean
      {
         return true;
      }
      
      protected function getFullScreenChild(param1:String, param2:Boolean = true) : DisplayObject
      {
         if(!this.fullScreenMc)
         {
            throw new ArgumentError("no fullScreenMc available");
         }
         var _loc3_:DisplayObject = this.fullScreenMc.getChildByName(param1);
         if(!_loc3_ && param2)
         {
            throw new ArgumentError("no such child " + param1 + " in " + this.fullScreenMc);
         }
         return _loc3_;
      }
      
      public function get overlay() : DisplayObject
      {
         return this._overlay;
      }
      
      public function set overlay(param1:DisplayObject) : void
      {
         if(this._overlay == param1)
         {
            return;
         }
         if(this._overlay)
         {
            if(this._overlay.parent == this.container)
            {
               this.removeChildFromContainer(this._overlay);
            }
         }
         this._overlay = param1;
         if(this._overlay)
         {
            this.addChildToContainer(this._overlay);
            this._overlay.x = -this.ui_author_width / 2;
            this._overlay.y = -this.ui_author_height / 2;
         }
      }
      
      protected function bringContainerToFront() : void
      {
         this.container.bringToFront();
         if(this.matteHelper)
         {
            this.matteHelper.bringToFront();
         }
      }
      
      protected function addChildToContainer(param1:DisplayObject) : void
      {
         this.container.addChild(param1);
         if(this.matteHelper)
         {
            this.matteHelper.visible = this.container.numChildren > 0;
         }
         this.bringContainerToFront();
      }
      
      protected function removeChildFromContainer(param1:DisplayObject) : void
      {
         if(param1.parent == this.container)
         {
            this.container.removeChild(param1);
            if(this.matteHelper)
            {
               this.matteHelper.visible = this.container.numChildren > 0;
            }
         }
      }
      
      protected function onEscapeHit(param1:CmdExec) : void
      {
      }
      
      override public function update(param1:int) : void
      {
         super.update(param1);
         if(this.boundedCamera)
         {
            this.boundedCamera.update(param1);
         }
      }
      
      private function mouseDownHandler(param1:MouseEvent) : void
      {
         this.handleTap();
      }
      
      protected function handleTap() : void
      {
      }
      
      public function handleOptionsButton() : void
      {
      }
      
      public function handleOptionsShowing(param1:Boolean) : void
      {
      }
   }
}

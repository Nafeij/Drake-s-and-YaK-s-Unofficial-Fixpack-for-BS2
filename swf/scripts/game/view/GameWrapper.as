package game.view
{
   import com.greensock.TweenMax;
   import com.stoicstudio.platform.Platform;
   import com.stoicstudio.platform.PlatformStarling;
   import engine.convo.view.ConvoView;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.KeyBindGroup;
   import engine.core.fsm.FsmEvent;
   import engine.core.gp.GpControlButton;
   import engine.core.gp.GpDevBinder;
   import engine.core.logging.ILogger;
   import engine.core.logging.Log;
   import engine.core.logging.targets.DebugLogTarget;
   import engine.core.logging.targets.TraceLogTarget;
   import engine.core.pref.PrefBag;
   import engine.core.util.AppInfo;
   import engine.core.util.EngineCoreContext;
   import engine.gui.ConsoleGui;
   import engine.gui.GuiMouse;
   import engine.gui.GuiSoundDebug;
   import engine.gui.MonoFont;
   import engine.gui.core.GuiSprite;
   import engine.gui.page.Page;
   import engine.resource.BitmapResource;
   import engine.saga.save.GameSaveSynchronizer;
   import engine.saga.save.SaveManager;
   import engine.scene.model.Scene;
   import flash.display.Bitmap;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.filters.GlowFilter;
   import flash.system.Capabilities;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.ui.Keyboard;
   import game.cfg.GameConfig;
   import game.gui.IGuiDialog;
   import game.gui.page.ScenePageAnimDebug;
   import game.gui.page.ScenePagePathDebug;
   import game.session.GameFsm;
   import game.session.states.SceneState;
   import starling.core.Starling;
   
   public class GameWrapper extends GuiSprite
   {
      
      public static var DEVELOPER_DEV_PANEL_HIDDEN:Boolean = true;
       
      
      public var config:GameConfig;
      
      public var logger:ILogger;
      
      public var dialogLayer:DialogLayer;
      
      public var cmdFullscreen:Boolean;
      
      public var cmdFullscreenSet:Boolean;
      
      private var context:EngineCoreContext;
      
      private var console:ConsoleGui;
      
      public var appInfo:AppInfo;
      
      private var pageManager:GamePageManagerAdapter;
      
      private var flyManager:GameScreenFlyTextManagerAdapter;
      
      private var perf:PerfSprite;
      
      private var guiMouse:GuiMouse;
      
      private var systemMessageText:TextField;
      
      private var soundDebug:GuiSoundDebug;
      
      private var networkProblemDisplay:NetworkProblemDisplay;
      
      public var screenFlash:Sprite;
      
      public var screenFlashText:TextField;
      
      private var saveSpinnerMC:MovieClip;
      
      private var spinnerBMPResource:BitmapResource;
      
      public var devPanel:GameDevPanel;
      
      private var devPanelGestureAdapter:GameDevPanelGestureAdapter;
      
      private var socket:IGameDevSocket;
      
      private var gameDevSocketClazz:Class;
      
      public var programText:String;
      
      private var _configLoaded:Boolean;
      
      private var frameNumber:int = 0;
      
      private var wasLoading:Boolean;
      
      private var wasConsoleOut:Boolean = false;
      
      private var _desktopResolutionChangeDirty:Boolean;
      
      private var cleanedup:Boolean;
      
      public function GameWrapper(param1:int, param2:AppInfo, param3:Class, param4:Boolean, param5:Class, param6:Class, param7:SaveManager)
      {
         var _loc8_:DebugLogTarget = null;
         this.screenFlash = new Sprite();
         this.screenFlashText = new TextField();
         super();
         name = "wrapper_" + param2.ordinal;
         this.gameDevSocketClazz = param6;
         this.logger = Log.getLogger(null);
         this.logger.addTarget(new TraceLogTarget());
         _loc8_ = new DebugLogTarget();
         this.logger.addTarget(_loc8_);
         if(param4)
         {
            this.logger.isDebugEnabled = param4;
         }
         this.mouseChildren = true;
         this.mouseEnabled = false;
         this.dialogLayer = new DialogLayer();
         addChild(this.dialogLayer);
         GpDevBinder.instance.bind(GpControlButton.D_U,GpControlButton.Y,1,this.func_toggleConsole);
         this.console = new ConsoleGui(this.logger,_loc8_,param5);
         this.logger.info("GAME START " + new Date());
         this.screenFlashText.defaultTextFormat = new TextFormat(MonoFont.FONT,80,0,true);
         this.screenFlashText.width = 1000;
         this.screenFlashText.text = "Console Error!";
         this.screenFlashText.width = this.screenFlashText.textWidth;
         this.screenFlash.mouseChildren = this.screenFlash.mouseEnabled = false;
         this.screenFlash.addChild(this.screenFlashText);
         _loc8_.errorCallback = this.debugLogErrorHandler;
         param2.init(this.logger);
         this.appInfo = param2;
         this.appInfo.addEventListener(AppInfo.EVENT_WINDOW_MOVE,this.windowMoveHandler);
         addChild(this.console);
         layoutGuiSprite();
         this.context = new EngineCoreContext(null,param2,this.logger);
         this.config = new GameConfig(this.context,GameFsm,param3,this.configLoadedHandler,this.dialogLayer,param7,param1);
         this.config.addEventListener(GameConfig.EVENT_TOGGLE_PERF,this.configTogglePerfHandler);
         this.config.addEventListener(GameConfig.EVENT_TOGGLE_CONSOLE,this.configToggleConsoleHandler);
         this.config.addEventListener(GameConfig.EVENT_BOOTSTRAPPED,this.configBootstrappedHandler);
         this.config.addEventListener(GameConfig.EVENT_TOGGLE_DEV_PANEL,this.configToggleDevPanel);
         addEventListener(Event.ADDED_TO_STAGE,this.addedToStageHandler);
         this.addedToStageHandler(null);
         this.perf = new PerfSprite(this,this.config.memReport);
         addChild(this.perf);
         this.perf.width = 150;
         this.perf.height = 40;
         this.perf.perfEnabled = this.config.globalPrefs.getPref(GameConfig.PREF_SHOW_PERF);
         this.checkPerfEnabled();
         this.devPanelGestureAdapter = new GameDevPanelGestureAdapter(this);
      }
      
      private function func_toggleConsole() : void
      {
         if(this.console)
         {
            this.console.out = !this.console.out;
         }
      }
      
      private function sizeSystemMessageText() : void
      {
         if(!this.systemMessageText)
         {
            return;
         }
         this.systemMessageText.width = this.width;
         this.systemMessageText.height = 300;
         this.systemMessageText.x = 0;
         this.systemMessageText.y = this.height - this.systemMessageText.height;
      }
      
      private function updateSystemMessage() : void
      {
         if(this.config.systemMessage.msg)
         {
            if(!this.systemMessageText)
            {
               this.systemMessageText = new TextField();
               this.systemMessageText.defaultTextFormat = new TextFormat("Vinque",32,16711680,true,null,null,null,null,"center");
               this.systemMessageText.filters = [new GlowFilter(0,1,16,16,3)];
               this.systemMessageText.selectable = false;
               this.systemMessageText.mouseEnabled = false;
               this.systemMessageText.wordWrap = true;
               addChild(this.systemMessageText);
               this.sizeSystemMessageText();
            }
            if(this.systemMessageText.text != this.config.systemMessage.msg)
            {
               this.systemMessageText.text = this.config.systemMessage.msg;
            }
         }
         else if(this.systemMessageText)
         {
            removeChild(this.systemMessageText);
            this.systemMessageText = null;
         }
      }
      
      private function addedToStageHandler(param1:Event) : void
      {
         if(this.config.keybinder)
         {
            this.config.keybinder.stage = stage;
         }
      }
      
      private function configLoadedHandler() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:IGuiDialog = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         if(!this.config)
         {
            return;
         }
         this.pageManager.handleConfigReady(this.config);
         this.flyManager = new GameScreenFlyTextManagerAdapter(this.config,this);
         this.config.flyManager = this.flyManager;
         addChild(this.config.guiAlerts);
         this.config.guiAlerts.anchor.percentHeight = 100;
         this.config.guiAlerts.anchor.percentWidth = 100;
         this.dialogLayer.bringToFront();
         this.console.bringToFront();
         if(this.soundDebug)
         {
            this.soundDebug.bringToFront();
            this.soundDebug.soundConfig = this.config.soundSystem;
            this.soundDebug.animDispatcher = this.config.animDispatcher;
         }
         this.perf.bringToFront();
         this.guiMouse = new GuiMouse();
         this.guiMouse.init(this.config.resman,this.appInfo,stage,this.config.options.softwareMouse);
         PlatformStarling.toucher = this.guiMouse;
         Platform.toucher = this.guiMouse;
         this.updateSystemMessage();
         this.config.systemMessage.addEventListener(Event.CHANGE,this.systemMessageChangeHandler);
         this.networkProblemDisplay = new NetworkProblemDisplay(this,this.config,this.config.fsm.communicator,null,this.config.context.locale);
         if(this.cmdFullscreen)
         {
            this.appInfo.fullscreen = this.cmdFullscreenSet;
         }
         else
         {
            this.appInfo.fullscreen = this.config.globalPrefs.getPref(GameConfig.PREF_OPTION_FULLSCREEN);
         }
         this.config.fsm.addEventListener(FsmEvent.CURRENT,this.fsmCurrentHandler);
         this.config.fsm.startFsm(null);
         _loc1_ = Capabilities.screenResolutionX;
         _loc2_ = Capabilities.screenResolutionY;
         this.loadWindowSizeFromPrefs();
         _loc3_ = _loc1_ > _loc2_ ? _loc1_ : _loc2_;
         _loc4_ = _loc1_ > _loc2_ ? _loc2_ : _loc1_;
         if(_loc3_ < this.appInfo.minSize.x || _loc4_ < this.appInfo.minSize.y)
         {
            _loc5_ = this.config.gameGuiContext.createDialog();
            _loc6_ = this.config.gameGuiContext.translate("screen_too_small_title");
            _loc7_ = this.config.gameGuiContext.translate("screen_too_small_body");
            _loc7_ = _loc7_.replace("$SCREEN_W",_loc3_);
            _loc7_ = _loc7_.replace("$SCREEN_H",_loc4_);
            _loc7_ = _loc7_.replace("$MINSCREEN_W",this.appInfo.minSize.x);
            _loc7_ = _loc7_.replace("$MINSCREEN_H",this.appInfo.minSize.y);
            _loc5_.openDialog(_loc6_,_loc7_,"OK",null);
         }
         if(this.devPanel)
         {
            this.devPanel.bringToFront();
         }
         this._configLoaded = true;
         if(Platform.showSaveSpinner)
         {
            this.saveSpinnerMC = new MovieClip();
            this.saveSpinnerMC.name = "save_spinner_container";
            this.spinnerBMPResource = this.config.resman.getResource("common/gui/notification/save_spinner.png",BitmapResource) as BitmapResource;
            this.spinnerBMPResource.addResourceListener(this.finishLoadingSpinnerBitmap);
         }
      }
      
      private function finishLoadingSpinnerBitmap(param1:Event) : void
      {
         var _loc2_:Bitmap = this.spinnerBMPResource.bmp;
         if(_loc2_ != null)
         {
            _loc2_.x = -_loc2_.width * 0.5;
            _loc2_.y = -_loc2_.height * 0.5;
            this.saveSpinnerMC.addChild(_loc2_);
         }
         else
         {
            this.logger.error("finishLoadingSpinnerBitmap - failed to find spinner!");
         }
      }
      
      private function loadWindowSizeFromPrefs() : void
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         if(this.appInfo.fullscreen)
         {
            return;
         }
         var _loc1_:PrefBag = this.config.globalPrefs;
         var _loc2_:int = Capabilities.screenResolutionX;
         var _loc3_:int = Capabilities.screenResolutionY;
         var _loc4_:int = _loc1_.getPref(GameConfig.PREF_WINDOW_WIDTH);
         var _loc5_:int = _loc1_.getPref(GameConfig.PREF_WINDOW_HEIGHT);
         _loc4_ = Math.min(_loc4_,_loc2_);
         _loc5_ = Math.min(_loc5_,_loc3_);
         if(Boolean(_loc4_) && Boolean(_loc5_))
         {
            this.appInfo.windowWidth = _loc4_;
            this.appInfo.windowHeight = _loc5_;
         }
         if(_loc1_.getPref(GameConfig.PREF_WINDOW_X) != undefined && _loc1_.getPref(GameConfig.PREF_WINDOW_Y) != undefined)
         {
            _loc6_ = _loc1_.getPref(GameConfig.PREF_WINDOW_X);
            _loc7_ = _loc1_.getPref(GameConfig.PREF_WINDOW_Y);
            _loc6_ = Math.max(0,Math.min(_loc6_,_loc2_ - _loc4_));
            _loc7_ = Math.max(0,Math.min(_loc7_,_loc3_ - _loc5_));
         }
      }
      
      private function storeWindowPrefs() : void
      {
         if(this._configLoaded && Boolean(this.appInfo))
         {
            this.config.globalPrefs.setPref(GameConfig.PREF_WINDOW_WIDTH,this.appInfo.windowWidth);
            this.config.globalPrefs.setPref(GameConfig.PREF_WINDOW_HEIGHT,this.appInfo.windowHeight);
            this.config.globalPrefs.setPref(GameConfig.PREF_WINDOW_X,this.appInfo.windowX);
            this.config.globalPrefs.setPref(GameConfig.PREF_WINDOW_Y,this.appInfo.windowY);
         }
      }
      
      private function windowMoveHandler(param1:Event) : void
      {
      }
      
      private function fsmCurrentHandler(param1:FsmEvent) : void
      {
         if(!this.config)
         {
            return;
         }
         var _loc2_:SceneState = this.config.fsm.current as SceneState;
         if(this.soundDebug)
         {
            this.soundDebug.scene = !!_loc2_ ? _loc2_.scene : null;
         }
      }
      
      private function systemMessageChangeHandler(param1:Event) : void
      {
         this.updateSystemMessage();
      }
      
      private function _checkDesktopResolutionChange() : void
      {
         this._desktopResolutionChangeDirty = this.appInfo.checkDesktopResolutionChange();
      }
      
      public function update(param1:int) : void
      {
         var _loc3_:int = 0;
         if(this.cleanedup)
         {
            return;
         }
         if(this._desktopResolutionChangeDirty)
         {
            this._checkDesktopResolutionChange();
         }
         this.config.updateGameConfig(param1);
         var _loc2_:Boolean = Boolean(this.pageManager) && this.pageManager.loading;
         if(_loc2_ != this.wasLoading)
         {
            if(this.devPanel)
            {
               this.devPanel.bringToFront();
            }
            if(this.perf && this.perf.parent && this.perf.visible)
            {
               this.perf.bringToFront();
            }
            this.wasLoading = _loc2_;
         }
         if(this.console.out != this.wasConsoleOut)
         {
            if(this.devPanel)
            {
               this.devPanel.bringToFront();
            }
            this.wasConsoleOut = this.console.out;
         }
         if(this.perf)
         {
            this.perf.update(param1);
         }
         if(Boolean(this.screenFlash) && Boolean(this.screenFlash.parent))
         {
            _loc3_ = this.screenFlash.parent.getChildIndex(this.screenFlash);
            if(_loc3_ < this.screenFlash.parent.numChildren - 1)
            {
               this.screenFlash.parent.setChildIndex(this.screenFlash,this.screenFlash.parent.numChildren - 1);
            }
         }
         if(this.soundDebug && this.soundDebug.visible && Boolean(this.soundDebug.parent))
         {
            this.soundDebug.update(param1);
         }
         ++this.frameNumber;
         this.logger.frameNumber = this.frameNumber;
         this.checkSaveSpinner(param1);
      }
      
      private function checkSaveSpinner(param1:int) : void
      {
         var _loc2_:Number = NaN;
         if(this.saveSpinnerMC)
         {
            if(GameSaveSynchronizer.instance.isBusy)
            {
               if(!this.saveSpinnerMC.parent)
               {
                  addChild(this.saveSpinnerMC);
                  this.positionSaveSpinner();
               }
               _loc2_ = param1 / 1000 * 45;
               this.saveSpinnerMC.rotation += _loc2_;
               if(getChildIndex(this.saveSpinnerMC) != numChildren - 1)
               {
                  setChildIndex(this.saveSpinnerMC,numChildren - 1);
               }
            }
            else if(this.saveSpinnerMC.parent)
            {
               removeChild(this.saveSpinnerMC);
            }
         }
      }
      
      private function positionSaveSpinner() : void
      {
         var _loc1_:int = 0;
         if(this.saveSpinnerMC.parent)
         {
            _loc1_ = 80;
            this.saveSpinnerMC.y = _loc1_ + this.saveSpinnerMC.height * 0.5;
            this.saveSpinnerMC.x = width - this.saveSpinnerMC.width * 0.5 - _loc1_;
         }
      }
      
      private function pageCtor(param1:Class) : Page
      {
         return new param1(this.config) as Page;
      }
      
      public function toggleDevPanel() : void
      {
         if(this.devPanel)
         {
            this.devPanel.toggle();
         }
         else
         {
            this.devPanel = new GameDevPanel(this.config,this);
            this.devPanel.resizeHandler(width,height);
         }
      }
      
      private function configBootstrappedHandler(param1:Event) : void
      {
         if(!this.config)
         {
            return;
         }
         this.pageManager = new GamePageManagerAdapter(this.config,this,0);
         this.pageManager.setRect(0,0,width,height);
         this.config.pageManager = this.pageManager;
         this.console.bringToFront();
         this.perf.bringToFront();
         this.pageManager.loading = true;
      }
      
      public function startLoading() : void
      {
         if(this.config.options.developer)
         {
            if(this.gameDevSocketClazz != null)
            {
               this.socket = new this.gameDevSocketClazz(this.logger,this);
            }
            if(!DEVELOPER_DEV_PANEL_HIDDEN)
            {
               this.toggleDevPanel();
            }
         }
         this.console.runMode = this.config.runMode;
         this.config.startLoading();
         this.console.keybinder = this.config.keybinder;
         this.console.shell = this.config.shell;
         this.console.prefs = this.config.globalPrefs;
         this.config.keybinder.bind(true,false,true,Keyboard.P,new Cmd("toggle_perfsprite",this.cmdFuncTogglePerfSprite),KeyBindGroup.COMBAT);
         if(this.config.options.developer)
         {
            this.soundDebug = new GuiSoundDebug(this,this.logger);
            this.config.keybinder.bind(true,false,true,Keyboard.F1,new Cmd("toggle_sound_debug",this.cmdFuncToggleSoundDebug),KeyBindGroup.COMBAT);
            this.config.keybinder.bind(true,false,true,Keyboard.F2,new Cmd("toggle_anim_debug",this.cmdFuncToggleAnimDebug),KeyBindGroup.COMBAT);
            this.config.keybinder.bind(true,false,true,Keyboard.F3,new Cmd("toggle_path_debug",this.cmdFuncTogglePathDebug),KeyBindGroup.COMBAT);
            this.config.keybinder.bind(true,false,true,Keyboard.F4,new Cmd("toggle_convo_debug",this.cmdFuncToggleConvoDebug),KeyBindGroup.COMBAT);
            this.config.keybinder.bind(true,false,true,Keyboard.F5,new Cmd("toggle_bounds_clamp",this.cmdFuncToggleBoundsClamp),KeyBindGroup.COMBAT);
            this.config.shell.add("page",this.cmdFuncPage);
         }
         this.config.shell.add("debug",this.shellFuncDebug);
         this.dialogLayer.keybinder = this.config.keybinder;
         this.dialogLayer.gpbinder = this.config.gpbinder;
         this.addedToStageHandler(null);
      }
      
      override protected function resizeHandler() : void
      {
         this._desktopResolutionChangeDirty = true;
         super.resizeHandler();
         if(this.pageManager)
         {
            this.pageManager.setRect(0,0,width,height);
         }
         PlatformStarling.handleResize(width,height);
         this.sizeSystemMessageText();
         if(this.devPanel)
         {
            this.devPanel.resizeHandler(width,height);
         }
         if(this.devPanelGestureAdapter)
         {
            this.devPanelGestureAdapter.resizeHandler(width,height);
         }
         this.storeWindowPrefs();
      }
      
      private function doScreenFlash() : void
      {
         if(this.screenFlash.parent == null)
         {
            addChild(this.screenFlash);
            this.screenFlash.graphics.clear();
            this.screenFlash.graphics.beginFill(16711680,1);
            this.screenFlash.graphics.drawRect(0,0,this.width,this.height);
            this.screenFlash.graphics.endFill();
            this.screenFlashText.x = (this.width - this.screenFlashText.width) / 2;
            this.screenFlashText.y = (this.height - this.screenFlashText.height) / 2;
         }
         this.screenFlash.mouseChildren = this.screenFlash.mouseEnabled = false;
         TweenMax.killTweensOf(this.screenFlash);
         this.screenFlash.alpha = 1;
         TweenMax.to(this.screenFlash,1,{
            "delay":0.15,
            "alpha":0,
            "onComplete":this.screenFlashCompleteHandler
         });
      }
      
      private function screenFlashCompleteHandler() : void
      {
         if(this.screenFlash.parent)
         {
            this.screenFlash.parent.removeChild(this.screenFlash);
         }
      }
      
      protected function debugLogErrorHandler() : void
      {
         if(Boolean(this.config) && Boolean(this.config.options))
         {
            if(this.config.options.screenFlashErrors)
            {
               if(!this.console || !this.console.out)
               {
                  this.doScreenFlash();
               }
            }
         }
      }
      
      override public function cleanup() : void
      {
         if(this.cleanedup)
         {
            throw new IllegalOperationError("Why cleanedup twice?");
         }
         this.cleanedup = true;
         if(this.socket)
         {
            this.socket.cleanup();
            this.socket = null;
         }
         if(this.flyManager)
         {
            this.flyManager.cleanup();
            this.flyManager = null;
         }
         if(this.pageManager)
         {
            this.pageManager.cleanup();
            this.pageManager = null;
         }
         if(this.config)
         {
            this.config.cleanup();
            this.config = null;
         }
         super.cleanup();
      }
      
      private function configTogglePerfHandler(param1:Event) : void
      {
         this.cmdFuncTogglePerfSprite(null);
      }
      
      private function configToggleConsoleHandler(param1:Event) : void
      {
         this.console.out = !this.console.out;
      }
      
      private function configToggleDevPanel(param1:Event) : void
      {
         this.toggleDevPanel();
      }
      
      private function checkPerfEnabled() : void
      {
         if(this.perf.enabled)
         {
            this.config.enableMemReport = true;
         }
         else
         {
            this.config.enableMemReport = false;
         }
      }
      
      public function cmdFuncTogglePerfSprite(param1:CmdExec) : void
      {
         this.perf.toggle();
         this.checkPerfEnabled();
         if(Starling.current)
         {
            if(this.perf.visible)
            {
               Starling.current.showStatsAt("left","middle");
               Starling.current.showStats = true;
            }
            else
            {
               Starling.current.showStats = false;
            }
         }
         this.config.globalPrefs.setPref(GameConfig.PREF_SHOW_PERF,this.perf.perfEnabled);
      }
      
      public function cmdFuncToggleSoundDebug(param1:CmdExec) : void
      {
         if(visible && this.config.options.developer)
         {
            if(this.soundDebug)
            {
               this.soundDebug.toggle();
            }
         }
      }
      
      public function cmdFuncToggleAnimDebug(param1:CmdExec) : void
      {
         if(visible && this.config.options.developer)
         {
            ScenePageAnimDebug.ENABLED = !ScenePageAnimDebug.ENABLED;
            this.logger.info("ScenePageAnimDebug.ENABLED " + ScenePageAnimDebug.ENABLED);
         }
      }
      
      public function cmdFuncTogglePathDebug(param1:CmdExec) : void
      {
         if(visible && this.config.options.developer)
         {
            ScenePagePathDebug.ENABLED = !ScenePagePathDebug.ENABLED;
            this.logger.info("ScenePagePathDebug.ENABLED " + ScenePagePathDebug.ENABLED);
         }
      }
      
      public function cmdFuncToggleConvoDebug(param1:CmdExec) : void
      {
         if(!visible || !this.config.options.developer)
         {
            return;
         }
         ConvoView.DEBUG_MARKS = !ConvoView.DEBUG_MARKS;
         this.logger.info("ConvoView.DEBUG_MARKS " + ConvoView.DEBUG_MARKS);
      }
      
      public function cmdFuncToggleBoundsClamp(param1:CmdExec) : void
      {
         if(!visible || !this.config.options.developer)
         {
            return;
         }
         var _loc2_:Scene = this.config.saga.getScene();
         if(Boolean(_loc2_) && Boolean(_loc2_.landscape))
         {
            _loc2_.landscape.clampParallax = !_loc2_.landscape.clampParallax;
            ConvoView.refreshInstanceCamera();
            this.logger.info("Scene.landscape.clampParallax= " + _loc2_.landscape.clampParallax);
         }
      }
      
      public function cmdFuncPage(param1:CmdExec) : void
      {
         if(this.pageManager)
         {
            this.pageManager.shell.execSubShell(param1);
         }
      }
      
      public function shellFuncDebug(param1:CmdExec) : void
      {
         this.logger.isDebugEnabled = !this.logger.isDebugEnabled;
         this.logger.info("debug " + this.logger.isDebugEnabled);
      }
   }
}

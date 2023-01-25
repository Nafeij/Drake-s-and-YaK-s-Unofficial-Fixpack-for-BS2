package game.gui.page
{
   import com.greensock.TweenMax;
   import com.stoicstudio.platform.Platform;
   import engine.automator.EngineAutomator;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.fsm.StateData;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.core.locale.Locale;
   import engine.core.locale.LocaleCategory;
   import engine.core.render.BoundedCamera;
   import engine.core.util.AppInfo;
   import engine.gui.SagaNews;
   import engine.gui.page.PageState;
   import engine.resource.BitmapResource;
   import engine.resource.IResource;
   import engine.saga.Saga;
   import engine.saga.SagaCreditsDef;
   import engine.saga.SagaDef;
   import engine.saga.SagaDlcEntry;
   import engine.saga.SagaDlcEvent;
   import engine.saga.SagaIap;
   import engine.saga.SagaIapEvent;
   import engine.saga.SagaIapProduct;
   import engine.saga.SagaRecapDef;
   import engine.saga.SagaVar;
   import engine.saga.VideoParams;
   import engine.saga.happening.HappeningDef;
   import engine.saga.save.GameSaveSynchronizer;
   import engine.saga.save.SagaSave;
   import engine.saga.save.SaveManager;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.ui.Keyboard;
   import game.cfg.GameConfig;
   import game.gui.GamePage;
   import game.gui.GuiSagaStartConfig;
   import game.gui.IGuiDialog;
   import game.gui.IGuiSagaNews;
   import game.gui.IGuiSagaNewsToggle;
   import game.gui.IGuiSurvivalPitchPopup;
   import game.session.states.GameStateDataEnum;
   import game.session.states.SagaNewGameState;
   import game.view.GamePageManagerAdapterSagaHeraldry;
   
   public class SagaStartPage extends GamePage implements IGuiSagaStartListener
   {
      
      public static var CLOUD_SAVE_DISABLED_MESSAGE_BODY_TOKEN:String = "";
      
      public static var CLOUD_SAVE_DISABLED_MESSAGE_TITLE_TOKEN:String = "";
      
      public static var mcClazz:Class;
      
      public static var mcClazz_e3:Class;
      
      public static var mcClazz_SurvivalPitchPopup:Class;
      
      public static var mcClazz_SagaNews:Class;
      
      public static var mcClazz_SagaNewsToggle:Class;
      
      public static var NEWS_URL_OVERRIDE:String;
      
      public static var ENABLE_GUI:Boolean = true;
       
      
      private var gui_survival_pitch_popup:IGuiSurvivalPitchPopup;
      
      private var gui:IGuiSagaStart;
      
      private var gui_news:IGuiSagaNews;
      
      private var gui_news_toggle:IGuiSagaNewsToggle;
      
      private var _showingSaveLoad:Boolean;
      
      private var cmd_esc:Cmd;
      
      private var cmd_news:Cmd;
      
      private var cmd_back:Cmd;
      
      private var _saveResume:SagaSave;
      
      private var _hasCheckpoints:Boolean;
      
      private var _scenePage:ScenePage;
      
      private var _saveResumeProfileIndex:int = -1;
      
      private var _firstEmptyProfile:int = -1;
      
      private var _resumeCount:int = 0;
      
      private var _survivalProduct:SagaIapProduct;
      
      private var _platformStoreDialog:IGuiDialog;
      
      private var userName:String;
      
      public var _enableRecap:Boolean;
      
      private var _delayedReadyToShow:Boolean = false;
      
      private var _readyToShow:Boolean;
      
      private var popup_bg:IResource;
      
      private var starting:Boolean;
      
      private var _lastSceneScale:Number = 0;
      
      private var _needToSetupSaves:Boolean = false;
      
      private var newsWrangler:SagaNewsWrangler;
      
      private var news:SagaNews;
      
      private var loadNews_count:int = 0;
      
      public function SagaStartPage(param1:GameConfig, param2:ScenePage, param3:String = null)
      {
         this.cmd_esc = new Cmd("cmd_esc_start",this.cmdfunc_esc);
         this.cmd_news = new Cmd("cmd_news",this.cmdfunc_news);
         this.cmd_back = new Cmd("back",this.cmdGpBack);
         super(param1);
         this._scenePage = param2;
         this.userName = param3;
         allowPageScaling = false;
         var _loc4_:String = String(param1.context.appInfo.ini["recap"]);
         this._enableRecap = _loc4_ == "1" || _loc4_ == "true";
         if(GameSaveSynchronizer.instance.pull_complete)
         {
            this.onSaveSyncComplete(null);
         }
         else
         {
            GameSaveSynchronizer.instance.addEventListener(GameSaveSynchronizer.EVENT_PULL_COMPLETE,this.onSaveSyncComplete);
            if(!GameSaveSynchronizer.instance.hasPulled)
            {
               param1.context.appInfo.setSystemIdleKeepAwake(true);
               GameSaveSynchronizer.instance.pull();
            }
         }
         param1.saveManager.addEventListener(SaveManager.EVENT_SAVE_DELETED,this.handleSaveDeleted);
         this.setupSaves();
         if(ENABLE_GUI)
         {
            setFullPageMovieClipClass(mcClazz);
         }
      }
      
      private function setupControls() : void
      {
         config.keybinder.bind(false,false,false,Keyboard.BACK,this.cmd_esc,"SagaStartPage");
         config.keybinder.bind(true,false,false,Keyboard.N,this.cmd_news,"SagaStartPage");
         GpBinder.gpbinder.bindPress(GpControlButton.B,this.cmd_back,"start");
      }
      
      private function teardownControls() : void
      {
         config.keybinder.unbind(this.cmd_esc);
         config.keybinder.unbind(this.cmd_news);
         GpBinder.gpbinder.unbind(this.cmd_back);
      }
      
      private function cmdGpBack(param1:CmdExec) : void
      {
         if(manager.loading)
         {
            return;
         }
         if(!GuiSagaStartConfig.ENABLE_QUIT)
         {
            if(!config.saga || !config.saga.parentSagaUrl)
            {
               config.context.appInfo.logger.info("SagaStartPage::cmdGpBack - Disabled by config");
               return;
            }
         }
         if(param1.param == 1)
         {
            this.guiSagaStartQuit();
         }
      }
      
      private function setupSaves() : void
      {
         var _loc5_:SagaSave = null;
         var _loc9_:SagaSave = null;
         logger.info("SagaStartPage.setupSaves START");
         if(!config || !config.saga || !config.saveManager.initialized)
         {
            return;
         }
         var _loc1_:AppInfo = config.context.appInfo;
         var _loc2_:String = config.saga.def.id;
         var _loc3_:String = null;
         var _loc4_:Array = config.saveManager.getResumeSaves(_loc2_,false);
         var _loc6_:Array = [];
         var _loc7_:Number = 0;
         this._saveResume = null;
         this._hasCheckpoints = false;
         this._saveResumeProfileIndex = -1;
         this._firstEmptyProfile = -1;
         this._resumeCount = 0;
         logger.d("STRT","SagaStartPage.setupSaves resumes.length={0}",_loc4_.length);
         var _loc8_:int = 0;
         while(_loc8_ < _loc4_.length)
         {
            _loc9_ = _loc4_[_loc8_];
            logger.d("STRT","SagaStartPage.setupSaves ss {0} [{1}]",_loc8_,_loc9_);
            if(!_loc9_)
            {
               if(this._firstEmptyProfile < 0)
               {
                  this._firstEmptyProfile = _loc8_;
               }
            }
            else
            {
               if(!this._saveResume || _loc9_.date.time > _loc7_)
               {
                  _loc7_ = _loc9_.date.time;
                  this._saveResume = _loc9_;
                  ++this._resumeCount;
                  this._saveResumeProfileIndex = _loc8_;
               }
               this._hasCheckpoints = true;
            }
            _loc8_++;
         }
         if(this.gui)
         {
            this.gui.updateState(this._resumeCount > 0,this._hasCheckpoints);
         }
      }
      
      public function doReadyToShow() : void
      {
         if(config.readyToStart)
         {
            this.internalReadyToShow();
         }
         else
         {
            config.addEventListener(GameConfig.EVENT_READY_TO_START,function():void
            {
               config.removeEventListener(GameConfig.EVENT_READY_TO_START,arguments.callee);
               internalReadyToShow();
            });
         }
      }
      
      private function internalReadyToShow() : void
      {
         this.delayedInternalReadyToShow();
      }
      
      private function delayedInternalReadyToShow() : void
      {
         var app_info:AppInfo;
         var loc:Locale;
         var dialog:IGuiDialog = null;
         var ok:String = null;
         var text:String = null;
         var title:String = null;
         var saga:Saga = config.saga;
         if(Boolean(saga) && saga.isOptionsShowing)
         {
            this._delayedReadyToShow = true;
            return;
         }
         app_info = config.context.appInfo;
         loc = config.context.locale;
         this.setupControls();
         this._readyToShow = true;
         if(this.gui)
         {
            (this.gui as MovieClip).visible = true;
         }
         if(CLOUD_SAVE_DISABLED_MESSAGE_BODY_TOKEN != "")
         {
            dialog = config.gameGuiContext.createDialog();
            ok = config.gameGuiContext.translate("ok");
            text = app_info.getLocalizedString(CLOUD_SAVE_DISABLED_MESSAGE_BODY_TOKEN,loc.id.id);
            title = app_info.getLocalizedString(CLOUD_SAVE_DISABLED_MESSAGE_TITLE_TOKEN,loc.id.id);
            dialog.openDialog(title,text,ok,function(param1:String):void
            {
               if(param1 == ok)
               {
               }
            });
            CLOUD_SAVE_DISABLED_MESSAGE_BODY_TOKEN = "";
            CLOUD_SAVE_DISABLED_MESSAGE_TITLE_TOKEN = "";
         }
         this.constructSagaNews();
         TweenMax.delayedCall(1,this.doShowNews);
      }
      
      private function doShowNews() : void
      {
         if(!this._readyToShow)
         {
            logger.d("NEWS","doShowNews() skipping due to !_readyToShow");
            return;
         }
         if(this.gui_news)
         {
            this.gui_news.movieClip.visible = this._readyToShow && this.gui_news.numVisibleNews > 0;
            this.gui_news.isShowing = this.gui_news.movieClip.visible;
         }
         if(this.gui_news_toggle)
         {
            this.gui_news_toggle.movieClip.visible = this.gui_news.movieClip.visible;
            this.gui_news_toggle.handleNewsUpdated();
         }
         logger.d("NEWS","doShowNews() all done");
         EngineAutomator.notify("saga_start_page_ready");
      }
      
      final private function onSaveSyncComplete(param1:Event) : void
      {
         logger.info("SagaStartPage.onSaveSyncComplete");
         if(GameSaveSynchronizer.instance)
         {
            GameSaveSynchronizer.instance.removeEventListener(GameSaveSynchronizer.EVENT_PULL_COMPLETE,this.onSaveSyncComplete);
         }
         if(config && config.context && Boolean(config.context.appInfo))
         {
            config.context.appInfo.setSystemIdleKeepAwake(false);
         }
         this.setupSaves();
      }
      
      override public function cleanup() : void
      {
         var _loc1_:GamePageManagerAdapterSagaHeraldry = Boolean(config) && Boolean(config.pageManager) ? config.pageManager.sagaHeraldry : null;
         if(_loc1_)
         {
            _loc1_.removeEventListener(GamePageManagerAdapterSagaHeraldry.EVENT_SHOWING,this.heraldryShowingHandler);
         }
         config.saveManager.removeEventListener(SaveManager.EVENT_SAVE_DELETED,this.handleSaveDeleted);
         this.teardownControls();
         TweenMax.killDelayedCallsTo(this.doShowNews);
         if(this.gui)
         {
            this.gui.cleanup();
         }
         this.gui = null;
         if(this.gui_news)
         {
            this.gui_news.cleanup();
            this.gui_news = null;
         }
         if(this.gui_news_toggle)
         {
            this.gui_news_toggle.cleanup();
            this.gui_news_toggle = null;
         }
         if(this.gui_survival_pitch_popup)
         {
            this.gui_survival_pitch_popup.cleanup();
            this.gui_survival_pitch_popup = null;
         }
         this.hideGuiSurvivalPitchPopup();
         if(this.cmd_esc)
         {
            this.cmd_esc.cleanup();
            this.cmd_esc = null;
         }
         if(this.cmd_news)
         {
            this.cmd_news.cleanup();
            this.cmd_news = null;
         }
         if(this.cmd_back)
         {
            this.cmd_back.cleanup();
            this.cmd_back = null;
         }
         if(this.popup_bg)
         {
            this.popup_bg.release();
         }
         this._delayedReadyToShow = false;
         super.cleanup();
      }
      
      override protected function handleLoaded() : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:Saga = null;
         var _loc4_:Locale = null;
         var _loc1_:GamePageManagerAdapterSagaHeraldry = Boolean(config) && Boolean(config.pageManager) ? config.pageManager.sagaHeraldry : null;
         if(_loc1_)
         {
            _loc1_.addEventListener(GamePageManagerAdapterSagaHeraldry.EVENT_SHOWING,this.heraldryShowingHandler);
         }
         if(Boolean(fullScreenMc) && !this.gui)
         {
            fullScreenMc.visible = this._readyToShow;
            this.gui = fullScreenMc as IGuiSagaStart;
            _loc3_ = config.saga;
            _loc2_ = SagaDef.SURVIVAL_ENABLED && !_loc3_.def.survival;
            fullScreenMc.visible = false;
            this.gui.init(config.gameGuiContext,this,this._resumeCount > 0,this._hasCheckpoints,_loc2_,this._enableRecap,this.userName);
            this.gui.updateUsernameText();
            _loc4_ = config.context.locale;
            _loc4_.translateDisplayObjects(LocaleCategory.GUI,this.gui as MovieClip,logger);
            this.gui.setupButtonSizes();
            this.resizeHandler();
         }
         if(!this.popup_bg)
         {
            this.popup_bg = config.resman.getResource("common/gui/survival_battle_popup/poppening_art.png",BitmapResource);
         }
      }
      
      private function constructSagaNews() : void
      {
         if(!ENABLE_GUI)
         {
            return;
         }
         if(config.saga.getVarBool(SagaVar.START_NEWS_DISABLED))
         {
            return;
         }
         if(!this.gui_news && mcClazz_SagaNews != null)
         {
            this.gui_news = new mcClazz_SagaNews() as IGuiSagaNews;
            this.gui_news.init(config.gameGuiContext);
            this.gui_news.setNews(this.news);
            this.gui_news.movieClip.visible = false;
            this.gui_news.isShowing = false;
            addChild(this.gui_news.movieClip);
            this.gui_news.movieClip.x = width / 2;
         }
         if(!this.gui_news_toggle && mcClazz_SagaNewsToggle != null)
         {
            this.gui_news_toggle = new mcClazz_SagaNewsToggle() as IGuiSagaNewsToggle;
            this.gui_news_toggle.init(config.gameGuiContext,this.gui_news);
            this.gui_news_toggle.movieClip.visible = false;
            addChild(this.gui_news_toggle.movieClip);
            this.gui_news_toggle.movieClip.x = width / 2;
            this.gui_news.guiToggle = this.gui_news_toggle;
         }
         if(this.loadNews_count == 0)
         {
            this.loadNews();
         }
         this.doShowNews();
         this.resizeHandler();
      }
      
      private function showGuiSurvivalPitchPopup() : void
      {
         var _loc1_:MovieClip = null;
         if(!ENABLE_GUI)
         {
            return;
         }
         if(!this.gui_survival_pitch_popup)
         {
            _loc1_ = new mcClazz_SurvivalPitchPopup() as MovieClip;
            this.gui_survival_pitch_popup = _loc1_ as IGuiSurvivalPitchPopup;
            this.gui_survival_pitch_popup.init(config.gameGuiContext);
            loadGuiBitmaps(_loc1_,null);
            addChild(_loc1_);
            _loc1_.visible = true;
            this.checkGuiVisibility();
            this.gui_survival_pitch_popup.addEventListener(Event.COMPLETE,this.guiSurvivalPitchPopupHandler);
            this.gui_survival_pitch_popup.priceString = this._survivalProduct.price;
            this.resizeHandler();
         }
      }
      
      private function hideGuiSurvivalPitchPopup() : void
      {
         if(this.gui_survival_pitch_popup)
         {
            removeChild(this.gui_survival_pitch_popup.movieClip);
            this.gui_survival_pitch_popup.cleanup();
            this.gui_survival_pitch_popup = null;
            this.checkGuiVisibility();
         }
      }
      
      private function checkGuiVisibility() : void
      {
         var _loc1_:Boolean = false;
         var _loc2_:GamePageManagerAdapterSagaHeraldry = null;
         if(this.gui)
         {
            _loc1_ = true;
            if(this.gui_survival_pitch_popup)
            {
               _loc1_ = false;
            }
            if(_loc1_)
            {
               _loc2_ = Boolean(config) && Boolean(config.pageManager) ? config.pageManager.sagaHeraldry : null;
               if(Boolean(_loc2_) && _loc2_.visible)
               {
                  _loc1_ = false;
               }
            }
            this.gui.visible = _loc1_;
         }
      }
      
      private function guiSurvivalPitchPopupHandler(param1:Event) : void
      {
         var _loc2_:Boolean = this.gui_survival_pitch_popup.isAccepted;
         var _loc3_:Boolean = this.gui_survival_pitch_popup.isRestore;
         this.hideGuiSurvivalPitchPopup();
         if(_loc2_)
         {
            SagaIap.impl.addEventListener(SagaIapEvent.PURCHASE_COMPLETE,this.onPurchaseComplete);
            SagaIap.impl.addEventListener(SagaIapEvent.PURCHASE_DEFERRED,this.onPurchaseDeferred);
            SagaIap.impl.addEventListener(SagaIapEvent.PURCHASE_FAILED,this.onPurchaseFailed);
            SagaIap.impl.purchaseProduct(this._survivalProduct.dlc);
         }
         else if(_loc3_)
         {
            SagaIap.impl.addEventListener(SagaIapEvent.RESTORE_SUCCESS,this.onRestorePurchaseSuccess);
            SagaIap.impl.addEventListener(SagaIapEvent.RESTORE_FAILED,this.onRestorePurchaseFailed);
            SagaIap.impl.restorePurchase(this._survivalProduct.dlc);
         }
      }
      
      private function onProductList(param1:SagaIapEvent) : void
      {
         logger.d("IAP","Received product information - showing purchase display");
         SagaIap.impl.removeEventListener(SagaIapEvent.PRODUCT_LIST,this.onProductList);
         if(param1.product)
         {
            this._survivalProduct = param1.product;
            this.showGuiSurvivalPitchPopup();
         }
         else
         {
            logger.e("IAP","No product information in response");
            this.showSurvivalUnavailableDialog();
         }
      }
      
      private function onStoreOpened(param1:SagaIapEvent) : void
      {
         logger.d("IAP","Received onStoreOpened event, closing platformStoreDialog");
         SagaIap.impl.removeEventListener(SagaIapEvent.STORE_OPENED,this.onStoreOpened);
         SagaIap.impl.removeEventListener(SagaIapEvent.STORE_FAILED,this.onStoreFailed);
         if(this._platformStoreDialog)
         {
            this._platformStoreDialog.closeDialog("");
         }
      }
      
      private function onStoreFailed(param1:SagaIapEvent) : void
      {
         logger.d("IAP","Received onStoreFailed event, showing the error dialog");
         SagaIap.impl.removeEventListener(SagaIapEvent.STORE_OPENED,this.onStoreOpened);
         SagaIap.impl.removeEventListener(SagaIapEvent.STORE_FAILED,this.onStoreFailed);
         if(this._platformStoreDialog)
         {
            this._platformStoreDialog.closeDialog("");
         }
         this.showSurvivalUnavailableDialog();
      }
      
      private function onPurchaseComplete(param1:SagaIapEvent) : void
      {
         SagaIap.impl.removeEventListener(SagaIapEvent.PURCHASE_COMPLETE,this.onPurchaseComplete);
         SagaIap.impl.removeEventListener(SagaIapEvent.PURCHASE_DEFERRED,this.onPurchaseDeferred);
         SagaIap.impl.removeEventListener(SagaIapEvent.PURCHASE_FAILED,this.onPurchaseFailed);
         logger.i("IAP","Purchase of " + param1.dlc + " complete");
         var _loc2_:Saga = config.saga;
         var _loc3_:Boolean = _loc2_.getVarBool("dlc_survival");
         if(!_loc3_)
         {
            this.startSurvival();
         }
      }
      
      private function onPurchaseDeferred(param1:SagaIapEvent) : void
      {
         SagaIap.impl.removeEventListener(SagaIapEvent.PURCHASE_COMPLETE,this.onPurchaseComplete);
         SagaIap.impl.removeEventListener(SagaIapEvent.PURCHASE_DEFERRED,this.onPurchaseDeferred);
         SagaIap.impl.removeEventListener(SagaIapEvent.PURCHASE_FAILED,this.onPurchaseFailed);
         logger.i("IAP","Purchase of " + param1.dlc + " deferred...");
      }
      
      private function onPurchaseFailed(param1:SagaIapEvent) : void
      {
         SagaIap.impl.removeEventListener(SagaIapEvent.PURCHASE_COMPLETE,this.onPurchaseComplete);
         SagaIap.impl.removeEventListener(SagaIapEvent.PURCHASE_DEFERRED,this.onPurchaseDeferred);
         SagaIap.impl.removeEventListener(SagaIapEvent.PURCHASE_FAILED,this.onPurchaseFailed);
         logger.i("IAP","Purchase of " + param1.dlc + " failed");
      }
      
      private function onRestorePurchaseSuccess(param1:SagaIapEvent) : void
      {
         SagaIap.impl.removeEventListener(SagaIapEvent.RESTORE_FAILED,this.onRestorePurchaseFailed);
         SagaIap.impl.removeEventListener(SagaIapEvent.RESTORE_SUCCESS,this.onRestorePurchaseSuccess);
         this.guiSagaTbs2Survival();
      }
      
      private function onRestorePurchaseFailed(param1:SagaIapEvent) : void
      {
         SagaIap.impl.removeEventListener(SagaIapEvent.RESTORE_FAILED,this.onRestorePurchaseFailed);
         SagaIap.impl.removeEventListener(SagaIapEvent.RESTORE_SUCCESS,this.onRestorePurchaseSuccess);
         logger.e("IAP","Failed to restore purchases");
      }
      
      public function cmdfunc_esc(param1:CmdExec) : void
      {
         this.guiSagaStartQuit();
      }
      
      public function cmdfunc_news(param1:CmdExec) : void
      {
         this.loadNews();
      }
      
      override protected function resizeHandler() : void
      {
         var _loc1_:MovieClip = null;
         super.resizeHandler();
         var _loc2_:Number = 1;
         var _loc3_:Number = 1;
         if(Boolean(this._scenePage) && Boolean(this._scenePage.camera))
         {
            _loc2_ = this._scenePage.camera.scale;
            _loc3_ = this._scenePage.camera.zoom;
         }
         if(this.gui_news)
         {
            _loc1_ = this.gui_news.movieClip;
            _loc1_.x = width / 2;
            _loc1_.scaleX = _loc1_.scaleY = _loc2_ / _loc3_;
            this.gui_news.handleResize();
         }
         if(this.gui_news_toggle)
         {
            _loc1_ = this.gui_news_toggle.movieClip;
            _loc1_.x = width / 2;
            _loc1_.scaleX = _loc1_.scaleY = _loc2_ / _loc3_;
         }
         var _loc4_:Number = this.width;
         var _loc5_:Number = this.height;
         if(this.gui)
         {
            _loc1_ = this.gui as MovieClip;
            this._zenterMovieClip(_loc1_,_loc1_.height / _loc1_.scaleY);
            this.gui.handleStartPageResized();
         }
         if(this.gui_survival_pitch_popup)
         {
            this._zenterMovieClip(this.gui_survival_pitch_popup.movieClip,this.gui_survival_pitch_popup.movieClip.height / this.gui_survival_pitch_popup.movieClip.scaleY);
         }
      }
      
      private function _zenterMovieClip(param1:MovieClip, param2:int) : void
      {
         var _loc3_:Number = this.width;
         var _loc4_:Number = this.height;
         param1.x = _loc3_ / 2;
         param1.y = _loc4_ / 2;
         if(Platform.requiresUiSafeZoneBuffer)
         {
            param1.x -= 50;
         }
         if(Platform._showBuyTbs2Func != null)
         {
            param1.y -= 60;
         }
         var _loc5_:Number = _loc4_ * _loc4_ / param2;
         var _loc6_:Number = Number(Platform.startPageScale || BoundedCamera.computeDpiScaling(_loc3_,_loc5_));
         param1.scaleX = param1.scaleY = _loc6_;
      }
      
      public function guiSagaStartUser() : void
      {
         config.context.appInfo.emitPlatformEvent("pick_new_user");
      }
      
      public function guiSagaStartResume() : void
      {
         if(this._saveResume)
         {
            config.loadSaga(config.saga.def.url,null,this._saveResume,0,this._saveResumeProfileIndex,null,null,config.saga.parentSagaUrl);
         }
         else
         {
            config.pageManager.showSaveProfileLoad(true);
         }
      }
      
      public function guiSagaStartRecap(param1:String) : void
      {
         var _loc4_:SagaRecapDef = null;
         var _loc5_:String = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:VideoParams = null;
         var _loc2_:Saga = config.saga;
         _loc2_.videoReturnsToStartScene = true;
         _loc2_.sound.stopAllSounds();
         var _loc3_:HappeningDef = _loc2_.getHappeningDefById("recap",null,false);
         if(Boolean(_loc3_) && _loc3_.enabled)
         {
            logger.info("Found recap happening, using " + _loc4_);
            _loc2_.executeHappeningDef(_loc3_,null);
            return;
         }
         _loc4_ = _loc2_.def.recap;
         if(_loc4_)
         {
            logger.info("Found recap def, using " + _loc4_);
            _loc2_.performVideo(_loc4_.videoParams);
            return;
         }
         var _loc6_:String = config.skuSaga;
         switch(_loc6_)
         {
            case "saga2":
               _loc7_ = "saga2/video/saga1_recap.720.flv";
               _loc8_ = "saga2/locale/en/saga1_recap.sbv.z";
               _loc9_ = new VideoParams().setUrl(_loc7_).setSubtitle(_loc8_);
               _loc2_.performVideo(_loc9_);
               break;
            default:
               logger.error("Invalid recap sku [" + _loc6_ + "]");
         }
      }
      
      public function guiSagaStartTutorial() : void
      {
         config.saga.sound.stopAllSounds();
         var _loc1_:String = SagaDef.START_TUTORIAL_HAPPENING;
         var _loc2_:HappeningDef = config.saga.def.happenings.getHappeningDef(_loc1_);
         if(_loc2_)
         {
            if(!config.saga.isHappeningHappening(_loc2_))
            {
               if(_loc2_.automatic)
               {
                  logger.error("Don\'t start global happening: " + _loc2_);
               }
               else
               {
                  config.saga.executeHappeningDef(_loc2_,this);
               }
            }
            else
            {
               logger.info("Saga.startTutorial happening [" + _loc2_ + "] is already in the process of happening");
            }
         }
         else
         {
            logger.error("Saga.startTutorial No such happening: " + _loc1_);
         }
      }
      
      public function guiSagaStartStart(param1:String) : void
      {
         this.handleStartNewGame(param1);
      }
      
      private function handleStartNewGame(param1:String) : void
      {
         if(this.starting)
         {
            return;
         }
         this.doStart(param1);
      }
      
      private function doStart(param1:String) : void
      {
         var saga:Saga;
         var demoMode:Boolean;
         var sd:StateData = null;
         var happening:String = param1;
         if(!happening)
         {
            happening = SagaDef.START_HAPPENING;
         }
         saga = config.saga;
         demoMode = saga.getVarBool("demomode_skip_newgame");
         if(this._firstEmptyProfile < 0)
         {
            if(!demoMode)
            {
               config.pageManager.showSaveProfileStart(happening);
               return;
            }
            this._firstEmptyProfile = 0;
         }
         this._scenePage.percentLoaded = 0;
         this._scenePage.state = PageState.LOADING;
         this.starting = true;
         if(!demoMode && saga && Boolean(saga.def.importDef))
         {
            sd = new StateData();
            sd.setValue(GameStateDataEnum.NEW_GAME_PROFILE,this._firstEmptyProfile);
            sd.setValue(GameStateDataEnum.HAPPENING_ID,happening);
            config.fsm.transitionTo(SagaNewGameState,sd);
            return;
         }
         TweenMax.delayedCall(0.1,function():void
         {
            var _loc1_:int = config.saga.difficulty;
            var _loc2_:Saga = config.saga;
            config.loadSaga(_loc2_.def.url,happening,null,_loc1_,_firstEmptyProfile,null,null,_loc2_.parentSagaUrl);
         });
      }
      
      public function guiSagaStartLoad() : void
      {
         config.pageManager.showSaveLoad(true,-1,true);
      }
      
      public function guiSagaStartOptions() : void
      {
         config.pageManager.showOptions();
      }
      
      public function guiSagaStartCredits() : void
      {
         var _loc1_:SagaCreditsDef = config.saga.def.getCreditsDef(0);
         config.pageManager.showCreditsPage(_loc1_,false,true);
      }
      
      public function guiSagaStartHeraldry() : void
      {
         config.pageManager.sagaHeraldry.showSagaHeraldry(true);
      }
      
      private function heraldryShowingHandler(param1:Event) : void
      {
         this.checkGuiVisibility();
      }
      
      public function guiSagaStartCartPicker() : void
      {
         config.pageManager.sagaCartPicker.showCartPicker(true);
      }
      
      public function guiSagaStartQuit() : void
      {
         var dialog:IGuiDialog;
         var yes:String = null;
         if(config.saga.quitToParentSaga())
         {
            return;
         }
         dialog = config.gameGuiContext.createDialog();
         yes = config.gameGuiContext.translate("yes");
         dialog.openTwoBtnDialog(config.gameGuiContext.translate("start_quit_confirm_title"),config.gameGuiContext.locale.translateAppTitleToken("start_quit_confirm_text"),yes,config.gameGuiContext.translate("no"),function(param1:String):void
         {
            if(param1 == yes)
            {
               config.context.appInfo.exitGame("Quit from Start Menu");
            }
         });
      }
      
      public function guiSagaTbs2BuyNow() : void
      {
         Platform.showBuyTbs2();
      }
      
      private function showSurvivalPurchaseDialog() : void
      {
         var _loc2_:SagaDlcEntry = null;
         var _loc1_:SagaDlcEntry = null;
         for each(_loc2_ in config.saga.def.dlcs.entries)
         {
            if(_loc2_.id == "dlc_survival")
            {
               _loc1_ = _loc2_;
               break;
            }
         }
         if(_loc1_ != null && Boolean(SagaIap.impl))
         {
            if(SagaIap.impl.skipIngamePitch)
            {
               SagaIap.impl.addEventListener(SagaIapEvent.STORE_OPENED,this.onStoreOpened);
               SagaIap.impl.addEventListener(SagaIapEvent.STORE_FAILED,this.onStoreFailed);
               this.showPlatformStoreDialog();
               SagaIap.impl.purchaseProduct(_loc1_.id);
            }
            else
            {
               logger.i("IAP","SagaStartPage requesting product information");
               SagaIap.impl.addEventListener(SagaIapEvent.PRODUCT_LIST,this.onProductList);
               SagaIap.impl.requestProductInfo(_loc1_);
            }
         }
         else
         {
            this.showSurvivalUnavailableDialog();
         }
      }
      
      private function showPlatformStoreDialog(param1:Function = null) : void
      {
         var _loc2_:String = "";
         if(param1 != null)
         {
            config.gameGuiContext.translateCategory("platform_continue",LocaleCategory.PLATFORM);
         }
         var _loc3_:String = config.gameGuiContext.translate("ss_welcome_title");
         var _loc4_:String = config.gameGuiContext.translateCategory("platform_contacting_store",LocaleCategory.PLATFORM);
         if(this._platformStoreDialog)
         {
            this._platformStoreDialog.closeDialog("");
         }
         this._platformStoreDialog = config.gameGuiContext.createDialog();
         this._platformStoreDialog.openDialog(_loc3_,_loc4_,_loc2_,param1);
      }
      
      private function showSurvivalUnavailableDialog() : void
      {
         var _loc1_:String = config.gameGuiContext.translate("ok");
         var _loc2_:String = config.gameGuiContext.translate("ss_welcome_title");
         var _loc3_:String = config.gameGuiContext.translate("start_survival_unavailable_body");
         config.gameGuiContext.createDialog().openDialog(_loc2_,_loc3_,_loc1_);
      }
      
      public function guiSagaTbs2Survival() : void
      {
         this.checkForSurvivalDlc(this.startSurvival,this.showSurvivalPurchaseDialog,this.showSurvivalPurchaseDialog);
      }
      
      private function checkForSurvivalDlc(param1:Function, param2:Function = null, param3:Function = null) : void
      {
         var title:String;
         var body:String;
         var saga:Saga = null;
         var entry:SagaDlcEntry = null;
         var dialog:IGuiDialog = null;
         var ownedCallback:Function = param1;
         var notOwnedCallback:Function = param2;
         var needsInstallCallback:Function = param3;
         saga = config.saga;
         var dlc_survival:Boolean = saga.getVarBool("dlc_survival");
         if(dlc_survival)
         {
            if(ownedCallback != null)
            {
               ownedCallback();
            }
            return;
         }
         entry = saga.def.dlcs.getDlc("dlc_survival");
         if(!entry)
         {
            this.showSurvivalUnavailableDialog();
            return;
         }
         title = config.gameGuiContext.translate("ss_welcome_title");
         body = config.gameGuiContext.translateCategory("platform_checking_dlc",LocaleCategory.PLATFORM);
         dialog = config.gameGuiContext.createDialog();
         dialog.openNoButtonDialog(title,body);
         entry.addEventListener(SagaDlcEvent.DLC_CHECK_COMPLETE,function(param1:SagaDlcEvent):void
         {
            entry.removeEventListener(SagaDlcEvent.DLC_CHECK_COMPLETE,arguments.callee);
            dialog.closeDialog("");
            if(needsInstallCallback != null && param1.dlc_status == SagaDlcEntry.DLC_NEEDS_INSTALL)
            {
               needsInstallCallback();
               return;
            }
            if(saga.getVarBool("dlc_survival"))
            {
               if(ownedCallback != null)
               {
                  ownedCallback();
               }
            }
            else if(notOwnedCallback != null)
            {
               notOwnedCallback();
            }
         });
         entry.conditionallyApplyDlc(saga,saga.appinfo);
      }
      
      public function startSurvival() : void
      {
         var saga:Saga = null;
         var survivalUrl:String = null;
         var dialog:IGuiDialog = null;
         var yes:String = null;
         saga = config.saga;
         survivalUrl = "saga2s/saga2s.json.z";
         var hasPlayedSurvival:Boolean = saga.masterSaveChildren["saga2s"] != null;
         if(!hasPlayedSurvival)
         {
            dialog = config.gameGuiContext.createDialog();
            yes = config.gameGuiContext.translate("yes");
            dialog.openTwoBtnDialog(config.gameGuiContext.translate("start_survival_confirm_title"),config.gameGuiContext.translate("start_survival_confirm_body"),yes,config.gameGuiContext.translate("no"),function(param1:String):void
            {
               if(param1 == yes)
               {
                  saga.launchSagaByUrl(survivalUrl,null,saga.difficulty,saga.def.url);
               }
            });
            return;
         }
         saga.launchSagaByUrl(survivalUrl,null,saga.difficulty,saga.def.url);
      }
      
      public function guiSagaCartPicker() : void
      {
         config.pageManager.sagaHeraldry.showSagaHeraldry(true);
      }
      
      override public function update(param1:int) : void
      {
         var _loc3_:Saga = null;
         super.update(param1);
         if(this._delayedReadyToShow)
         {
            _loc3_ = config.saga;
            if(Boolean(_loc3_) && !_loc3_.isOptionsShowing)
            {
               this._delayedReadyToShow = false;
               this.delayedInternalReadyToShow();
            }
         }
         var _loc2_:Number = Boolean(this._scenePage) && Boolean(this._scenePage.camera) ? this._scenePage.camera.scale : 0;
         if(_loc2_ != this._lastSceneScale)
         {
            this._lastSceneScale = _loc2_;
            this.resizeHandler();
         }
         if(this._needToSetupSaves)
         {
            this.setupSaves();
            this._needToSetupSaves = false;
         }
         if(config.pageManager.sagaCartPicker.visible)
         {
            config.pageManager.sagaCartPicker.update(param1);
         }
      }
      
      private function handleSaveDeleted(param1:Event) : void
      {
         this._needToSetupSaves = true;
      }
      
      public function loadNews() : void
      {
         var _loc1_:String = String(config.context.appInfo.ini["news"]);
         if(NEWS_URL_OVERRIDE)
         {
            _loc1_ = NEWS_URL_OVERRIDE;
         }
         logger.i("NEWS","SagaStartPage.loadNews [" + _loc1_ + "]");
         if(!_loc1_)
         {
            logger.i("NEWS","SagaStartPage. No news is good news?");
            return;
         }
         ++this.loadNews_count;
         if(this.newsWrangler)
         {
            this.newsWrangler.cleanup();
            this.newsWrangler = null;
         }
         if(_loc1_)
         {
            this.newsWrangler = new SagaNewsWrangler(_loc1_,logger,config.resman,this.newsHandler,config.globalPrefs);
            this.newsWrangler.load(true);
         }
         else
         {
            this.news = null;
         }
      }
      
      private function newsHandler(param1:SagaNewsWrangler) : void
      {
         if(param1 != this.newsWrangler)
         {
            param1.cleanup();
            return;
         }
         if(this.news)
         {
            this.news.cleanup();
            this.news = null;
         }
         this.news = param1.news;
         logger.i("NEWS","newsHandler [{0}]",this.news);
         param1.cleanup();
         this.newsWrangler = null;
         if(this.gui_news)
         {
            this.gui_news.setNews(this.news);
            logger.d("NEWS","newsHandler: {0} load count",this.loadNews_count);
            this.doShowNews();
         }
         if(this.gui_news_toggle)
         {
            this.gui_news_toggle.handleNewsUpdated();
         }
      }
   }
}

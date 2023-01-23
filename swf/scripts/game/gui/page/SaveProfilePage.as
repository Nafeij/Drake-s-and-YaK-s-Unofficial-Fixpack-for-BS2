package game.gui.page
{
   import com.greensock.TweenMax;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.fsm.StateData;
   import engine.core.gp.GpControlButton;
   import engine.core.locale.LocaleCategory;
   import engine.core.util.AppInfo;
   import engine.gui.GuiMouse;
   import engine.gui.page.PageState;
   import engine.saga.Saga;
   import engine.saga.save.GameSaveSynchronizer;
   import engine.saga.save.SagaSave;
   import engine.saga.save.SagaSaveCollection;
   import engine.saga.save.SaveManager;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.ui.Keyboard;
   import flash.utils.ByteArray;
   import game.cfg.GameConfig;
   import game.gui.GameGuiContext;
   import game.gui.GamePage;
   import game.gui.IGuiDialog;
   import game.session.states.GameStateDataEnum;
   import game.session.states.SagaNewGameState;
   
   public class SaveProfilePage extends GamePage implements IGuiSaveProfileListener
   {
      
      public static var mcClazz:Class;
      
      public static var LOAD_PREVIOUS_SAGA_FINALE_SAVES_FROM_APPINFO:Boolean;
       
      
      private var gui:IGuiSaveProfile;
      
      private var _showingSaveProfile:Boolean;
      
      private var cmd_esc:Cmd;
      
      private var saga:Saga;
      
      private var gplayer:int = 0;
      
      private var happening:String;
      
      private var _mode:SaveProfilePageMode;
      
      private var _closeCallback:Function;
      
      private var _startCallback:Function;
      
      private var loaders:Array;
      
      private var resumes:Vector.<SagaSaveCollection>;
      
      private var starting:Boolean;
      
      public function SaveProfilePage(param1:GameConfig)
      {
         this.cmd_esc = new Cmd("cmd_esc_saveprofile",this.cmdfunc_esc);
         this._mode = SaveProfilePageMode.PROFILE_MODE_LOAD;
         this.loaders = [];
         super(param1);
         visible = false;
         setFullPageMovieClipClass(mcClazz);
      }
      
      override public function cleanup() : void
      {
         this.clearLoaders();
         if(this.gui)
         {
            this.gui.cleanup();
         }
         this.gui = null;
         this._closeCallback = null;
         this._startCallback = null;
         super.cleanup();
      }
      
      override protected function handleLoaded() : void
      {
         if(Boolean(fullScreenMc) && !this.gui)
         {
            this.gui = fullScreenMc as IGuiSaveProfile;
            this.gui.init(config.gameGuiContext,this);
         }
         resizeHandler();
         if(this._showingSaveProfile)
         {
            this.showSaveProfile(this._mode,this.happening,null,null);
         }
      }
      
      private function clearLoaders() : void
      {
         var _loc1_:Loader = null;
         for each(_loc1_ in this.loaders)
         {
            _loc1_.unload();
         }
         this.loaders = [];
      }
      
      public function doBind() : void
      {
         this.gplayer = config.gpbinder.createLayer("SaveProfilePage");
         config.keybinder.bind(false,false,false,Keyboard.ESCAPE,this.cmd_esc,"");
         config.keybinder.bind(false,false,false,Keyboard.BACK,this.cmd_esc,"");
         config.gpbinder.bindPress(GpControlButton.B,this.cmd_esc,"");
      }
      
      public function doUnbind() : void
      {
         config.gpbinder.removeLayer(this.gplayer);
         config.keybinder.unbind(this.cmd_esc);
         config.gpbinder.unbind(this.cmd_esc);
      }
      
      public function hideSaveProfile(param1:Boolean) : void
      {
         this.doUnbind();
         if(this.saga)
         {
            this.saga.unpause(this);
            this.saga = null;
         }
         if(visible && param1)
         {
            config.gameGuiContext.playSound("ui_generic");
         }
         this.clearLoaders();
         visible = false;
         if(this.gui)
         {
            (this.gui as MovieClip).visible = false;
         }
         this._showingSaveProfile = false;
         config.saveManager.removeEventListener(SaveManager.EVENT_SAVE_DELETED,this.handleSaveDeleted);
      }
      
      public function isImportOldSagaMode() : Boolean
      {
         return this._mode == SaveProfilePageMode.PROFILE_MODE_IMPORT_OLD_SAGA;
      }
      
      public function showSaveProfile(param1:SaveProfilePageMode, param2:String, param3:Function, param4:Function) : void
      {
         config.gameGuiContext.translateDisplayObjects(LocaleCategory.GUI,this);
         this._mode = param1;
         this._closeCallback = param3;
         this._startCallback = param4;
         this.happening = param2;
         this.starting = false;
         config.dialogLayer.clearDialogs();
         this.doBind();
         this.clearLoaders();
         config.gameGuiContext.playSound("ui_generic");
         this._showingSaveProfile = true;
         visible = true;
         if(!this.gui)
         {
            return;
         }
         (this.gui as MovieClip).visible = true;
         this.saga = config.saga;
         if(this.saga)
         {
            this.saga.pause(this);
         }
         logger.info("SaveProfilePage: re-synchronizing saved games.");
         config.context.appInfo.setSystemIdleKeepAwake(true);
         logger.info("SaveProfilePage: pull cloud saves");
         GameSaveSynchronizer.instance.addEventListener(GameSaveSynchronizer.EVENT_PULL_COMPLETE,this.onSaveSyncComplete);
         GameSaveSynchronizer.instance.addEventListener(GameSaveSynchronizer.EVENT_PULL_UPDATE,this.onSaveSyncUpdate);
         GameSaveSynchronizer.instance.pull();
         config.saveManager.addEventListener(SaveManager.EVENT_SAVE_DELETED,this.handleSaveDeleted);
      }
      
      final private function onSaveSyncUpdate(param1:Event) : void
      {
         logger.info("SaveProfilePage.onSaveSyncUpdate");
         this.setupProfiles();
      }
      
      final private function onSaveSyncComplete(param1:Event) : void
      {
         logger.info("SaveProfilePage.onSaveSyncComplete");
         GameSaveSynchronizer.instance.removeEventListener(GameSaveSynchronizer.EVENT_PULL_UPDATE,this.onSaveSyncUpdate);
         GameSaveSynchronizer.instance.removeEventListener(GameSaveSynchronizer.EVENT_PULL_COMPLETE,this.onSaveSyncComplete);
         config.context.appInfo.setSystemIdleKeepAwake(false);
         this.setupProfiles();
      }
      
      override public function update(param1:int) : void
      {
         super.update(param1);
      }
      
      private function setupProfiles() : void
      {
         var _loc1_:String = null;
         var _loc2_:AppInfo = null;
         var _loc3_:Array = null;
         var _loc4_:Vector.<SagaSaveCollection> = null;
         var _loc5_:SagaSaveCollection = null;
         var _loc6_:int = 0;
         if(!config || !config.context || !this.saga || !this.saga.def)
         {
            logger.info("Attempting to setup profiles on SaveProfilePage with no config or no saga.");
            return;
         }
         if(this._mode != SaveProfilePageMode.PROFILE_MODE_IMPORT_OLD_SAGA)
         {
            _loc1_ = this.saga.def.id;
            _loc2_ = config.context.appInfo;
            _loc3_ = config.saveManager.getResumeSaves(_loc1_,this.saga.isSurvival);
            _loc4_ = new Vector.<SagaSaveCollection>();
            if(_loc3_)
            {
               _loc5_ = new SagaSaveCollection(_loc1_,Saga.PROFILE_COUNT,false);
               _loc4_.push(_loc5_);
               _loc6_ = 0;
               while(_loc6_ < _loc3_.length)
               {
                  _loc5_.setSaveAtProfile(_loc6_,_loc3_[_loc6_]);
                  _loc6_++;
               }
            }
            this.resumes = _loc4_;
            if(this.gui != null)
            {
               this.gui.setupProfiles(this.resumes);
            }
         }
         else
         {
            this.loadPreviousSagaFinaleSavesAsync();
         }
      }
      
      private function loadPreviousSagaFinaleSavesHandler(param1:Vector.<SagaSaveCollection>) : void
      {
         this.gui.hideImportWaitDialog();
         if(param1 == null || param1.length == 0)
         {
            this.gui.showImportFailedDialog(this._hackImportSagaId(this.saga.def.id),this.onFinishedDisplayingImportFailureError);
            return;
         }
         logger.d("SAVE","Setting up profile list with {0} base ids",param1.length);
         this.resumes = param1;
         this.gui.setupProfiles(this.resumes);
      }
      
      private function onFinishedDisplayingImportFailureError(param1:String) : void
      {
         if(this._closeCallback != null)
         {
            this._closeCallback(null);
         }
         config.pageManager.hideSaveProfile();
      }
      
      public function loadPreviousSagaFinaleSavesAsync() : void
      {
         var _loc3_:AppInfo = null;
         if(!this.saga || !this.saga.def || !this.saga.def.importDef)
         {
            throw new IllegalOperationError("Saga is not setup for importing");
         }
         var _loc1_:String = this.saga.def.importDef.importSagaId;
         var _loc2_:String = this.saga.def.importDef.importSaveId;
         if(LOAD_PREVIOUS_SAGA_FINALE_SAVES_FROM_APPINFO)
         {
            this.gui.showImportWaitDialog();
            _loc3_ = config.context.appInfo;
            _loc3_.loadPreviousSagaFinaleSavesAsync(this.loadPreviousSagaFinaleSavesHandler,_loc1_,_loc2_);
            return;
         }
         this.loadPreviousSagaFinaleSavesAsync_pc(_loc1_,_loc2_);
      }
      
      private function _hackImportSagaId(param1:String) : String
      {
         switch(param1)
         {
            case "saga2":
               return "saga1";
            case "saga3":
               return "saga2";
            default:
               return null;
         }
      }
      
      private function _hackImportSaveId(param1:String) : String
      {
         switch(param1)
         {
            case "saga2":
               return "sav_finale";
            case "saga3":
               return "sav_finale";
            default:
               return null;
         }
      }
      
      private function loadSagaSaveFromAbsolutePath(param1:String) : SagaSave
      {
         var _loc2_:SagaSave = null;
         var _loc5_:String = null;
         var _loc6_:Object = null;
         var _loc3_:AppInfo = config.context.appInfo;
         var _loc4_:ByteArray = _loc3_.loadFile(AppInfo.DIR_ABSOLUTE,param1);
         if(Boolean(_loc4_) && Boolean(_loc4_.length))
         {
            _loc5_ = _loc4_.readUTFBytes(_loc4_.length);
            _loc4_.clear();
            _loc6_ = JSON.parse(_loc5_);
            _loc2_ = new SagaSave(null).fromJson(_loc6_,logger);
         }
         return _loc2_;
      }
      
      private function loadPreviousSagaFinaleSavesAsync_pc(param1:String, param2:String) : void
      {
         var appInfo:AppInfo;
         var sscs:Vector.<SagaSaveCollection>;
         var ssc:SagaSaveCollection = null;
         var i:int = 0;
         var url:String = null;
         var ss:SagaSave = null;
         var importSagaId:String = param1;
         var importSaveId:String = param2;
         if(!importSaveId)
         {
            throw new ArgumentError("need an importId, did you mean [sav_finale]?");
         }
         appInfo = config.context.appInfo;
         sscs = this.getImportSaveUrls(importSagaId,importSaveId);
         for each(ssc in sscs)
         {
            i = 0;
            while(i < ssc.profile_urls.length)
            {
               url = ssc.profile_urls[i];
               try
               {
                  logger.d("SAVE","Attempting to read finale save at {0}",url);
                  ss = this.loadSagaSaveFromAbsolutePath(url);
                  ssc.setSaveAtProfile(i,ss);
               }
               catch(e:Error)
               {
                  logger.error("Failed to load saga finale save: " + url + ": " + e.getStackTrace());
               }
               i++;
            }
         }
         this.loadPreviousSagaFinaleSavesHandler(sscs);
      }
      
      private function confirmStart(param1:int, param2:String) : void
      {
         var yes:String = null;
         var profile_index:int = param1;
         var token_prefix:String = param2;
         var dialog:IGuiDialog = config.gameGuiContext.createDialog();
         yes = config.gameGuiContext.translate("yes");
         var text:String = config.gameGuiContext.locale.translateAppTitleToken(token_prefix + "_text");
         text = text.replace("{profile_slot}",(profile_index + 1).toString());
         dialog.openTwoBtnDialog(config.gameGuiContext.translate(token_prefix + "_title"),text,yes,config.gameGuiContext.translate("no"),function(param1:String):void
         {
            if(param1 == yes)
            {
               doStart(profile_index);
            }
         });
      }
      
      public function guiSaveProfileImportFile() : void
      {
         this.doImportSave();
      }
      
      public function guiSaveProfileDelete(param1:int) : void
      {
         var yes:String = null;
         var profile_index:int = param1;
         var ggc:GameGuiContext = config.gameGuiContext;
         var dialog:IGuiDialog = ggc.createDialog();
         var title:String = ggc.translate("save_delete_profile_title");
         var body:String = ggc.translate("save_delete_profile_body");
         body = body.replace("$PROFILEID",(profile_index + 1).toString());
         yes = ggc.translate("yes");
         var no:String = ggc.translate("no");
         dialog.openTwoBtnDialog(title,body,yes,no,function(param1:String):void
         {
            if(param1 == yes)
            {
               config.saveManager.deleteProfile(config.saga.def.id,profile_index);
            }
         });
      }
      
      private function handleSaveDeleted(param1:Event) : void
      {
         this.setupProfiles();
      }
      
      private function performImportSave(param1:SagaSave) : void
      {
         config.pageManager.hideSaveProfile();
         if(this._closeCallback != null)
         {
            this._closeCallback(param1);
         }
      }
      
      public function guiSaveProfileSelect(param1:int, param2:int) : void
      {
         var ss:SagaSave = null;
         var p:GamePage = null;
         var resume:SagaSave = null;
         var collection_index:int = param1;
         var profile_index:int = param2;
         ss = null;
         var ssc:SagaSaveCollection = !!this.resumes ? this.resumes[collection_index] : null;
         if(this._mode == SaveProfilePageMode.PROFILE_MODE_IMPORT_OLD_SAGA)
         {
            ss = !!ssc ? ssc.profile_saves[profile_index] : null;
            this.performImportSave(ss);
            return;
         }
         if(this._mode == SaveProfilePageMode.PROFILE_MODE_RESUME)
         {
            if(profile_index < 0 || !ssc || !ssc.profile_saves || ssc.profile_saves.length <= profile_index)
            {
               return;
            }
            ss = !!ssc ? ssc.profile_saves[profile_index] : null;
            if(ss)
            {
               if(!this.saga.checkSurvivalReloadable(ss))
               {
                  return;
               }
               p = config.pageManager.currentPage as GamePage;
               if(p)
               {
                  p.percentLoaded = 0;
                  p.state = PageState.LOADING;
               }
               config.pageManager.hideSaveProfile();
               this.starting = true;
               TweenMax.delayedCall(0.1,function():void
               {
                  config.loadSaga(config.saga.def.url,null,ss,0,profile_index,null,null,config.saga.parentSagaUrl);
               });
               if(this._closeCallback != null)
               {
                  this._closeCallback(ss);
               }
               return;
            }
         }
         if(ssc && profile_index >= 0 && profile_index < ssc.profile_saves.length)
         {
            resume = ssc.profile_saves[profile_index];
            if(!resume)
            {
               this.confirmStart(profile_index,"start_confirm");
               return;
            }
         }
         if(this._mode == SaveProfilePageMode.PROFILE_MODE_LOAD)
         {
            config.pageManager.showSaveLoad(true,profile_index,true);
         }
         else if(this.saga.isSurvival)
         {
            this.confirmStart(profile_index,"ss_restart_confirm");
         }
         else
         {
            this.confirmStart(profile_index,"restart_confirm");
         }
      }
      
      private function doStart(param1:int) : void
      {
         var p:GamePage;
         var willImport:Boolean;
         var sd:StateData = null;
         var profile_index:int = param1;
         if(this.starting)
         {
            return;
         }
         p = config.pageManager.currentPage as GamePage;
         if(p)
         {
            p.percentLoaded = 0;
            p.state = PageState.LOADING;
         }
         willImport = Boolean(this.saga) && Boolean(this.saga.def.importDef);
         config.pageManager.hideSaveProfile();
         config.pageManager.hideOptions();
         this.starting = true;
         if(this._startCallback != null)
         {
            this._startCallback();
            this._startCallback = null;
         }
         if(willImport)
         {
            sd = new StateData();
            sd.setValue(GameStateDataEnum.NEW_GAME_PROFILE,profile_index);
            sd.setValue(GameStateDataEnum.HAPPENING_ID,this.happening);
            config.fsm.transitionTo(SagaNewGameState,sd);
            return;
         }
         TweenMax.delayedCall(0.1,function():void
         {
            var _loc1_:int = config.saga.difficulty;
            config.loadSaga(config.saga.def.url,happening,null,_loc1_,profile_index,null,null,config.saga.parentSagaUrl);
         });
      }
      
      public function guiSaveProfileClose() : void
      {
         config.pageManager.hideSaveProfile();
         if(this._closeCallback != null)
         {
            this._closeCallback(null);
         }
      }
      
      public function cmdfunc_esc(param1:CmdExec) : void
      {
         this.guiSaveProfileClose();
      }
      
      private function doImportSave() : void
      {
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:Array = null;
         if(!this.saga || !this.saga.def || !this.saga.def.importDef)
         {
            throw new IllegalOperationError("saga has no importDef");
         }
         var _loc1_:String = this.saga.def.importDef.importSagaId;
         var _loc2_:String = this.saga.def.importDef.importSaveId;
         if(!_loc1_ || !_loc2_)
         {
            throw new IllegalOperationError("saga importdef importSagaId=" + _loc1_ + " importSaveId=" + _loc2_);
         }
         GuiMouse.gamePaused = true;
         var _loc3_:Vector.<String> = this.getImportSaveFolderUrls(_loc1_);
         var _loc4_:* = _loc2_ + ".save.json";
         for each(_loc5_ in _loc3_)
         {
            _loc7_ = config.context.appInfo.findFilesUnderUrl(AppInfo.DIR_ABSOLUTE,_loc5_,_loc4_);
            if(Boolean(_loc7_) && Boolean(_loc7_.length))
            {
               _loc5_ = _loc7_[0];
               break;
            }
         }
         _loc6_ = "Find ${importSagaId} Save File (${importSaveId}.save.json)";
         _loc6_ = _loc6_.replace("${importSaveId}",_loc2_);
         _loc6_ = _loc6_.replace("${importSagaId}",_loc1_);
         config.context.appInfo.browseForFile(AppInfo.DIR_ABSOLUTE,_loc5_,_loc6_,"*.json",this.browseFileSelectHandler);
      }
      
      private function getImportSaveFolderUrls(param1:String) : Vector.<String>
      {
         var _loc4_:String = null;
         var _loc2_:AppInfo = config.context.appInfo;
         var _loc3_:Vector.<String> = new Vector.<String>();
         var _loc5_:String = SaveManager.IMPORT_SAVE_DIR != null ? SaveManager.IMPORT_SAVE_DIR : SaveManager.SAVE_DIR;
         var _loc6_:String = _loc2_.getUrlFromAbstractFolder(_loc5_);
         if(_loc6_)
         {
            switch(param1)
            {
               case "saga1":
                  _loc4_ = _loc6_;
                  _loc4_ = _loc4_.replace("TheBannerSaga2","TheBannerSaga");
                  _loc4_ = _loc4_.replace("TheBannerSaga0","TheBannerSaga");
                  break;
               case "saga2":
                  _loc4_ = _loc6_;
                  _loc4_ = _loc4_.replace("TheBannerSaga3","TheBannerSaga2");
                  _loc4_ = _loc4_.replace("TheBannerSaga0","TheBannerSaga2");
            }
            if(_loc4_)
            {
               _loc4_ = _loc4_.replace("Locally","");
               _loc4_ += "/save/" + param1;
               _loc3_.push(_loc4_);
            }
         }
         var _loc7_:String = _loc2_.getUrlFromAbstractFolder(SaveManager.SAVE_DIR);
         if(_loc7_)
         {
            if(_loc7_ != _loc6_ || _loc7_.indexOf("TheBannerSaga0") >= 0)
            {
               _loc4_ = _loc7_.replace("Locally","");
               _loc4_ += "/save/" + param1;
               _loc3_.push(_loc4_);
            }
         }
         return _loc3_;
      }
      
      private function getImportSaveUrls(param1:String, param2:String) : Vector.<SagaSaveCollection>
      {
         var _loc4_:Vector.<SagaSaveCollection> = null;
         var _loc6_:String = null;
         var _loc7_:SagaSaveCollection = null;
         var _loc8_:int = 0;
         var _loc9_:* = null;
         var _loc3_:Vector.<String> = this.getImportSaveFolderUrls(param1);
         if(_loc3_.length == 0)
         {
            logger.d("IMPORT","Failed to find any save folder URLs");
            return _loc4_;
         }
         _loc4_ = new Vector.<SagaSaveCollection>(_loc3_.length);
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_.length)
         {
            _loc6_ = _loc3_[_loc5_];
            _loc7_ = new SagaSaveCollection(_loc6_,Saga.PROFILE_COUNT,true);
            _loc4_[_loc5_] = _loc7_;
            _loc8_ = 0;
            while(_loc8_ < Saga.PROFILE_COUNT)
            {
               _loc9_ = _loc6_ + "/" + _loc8_ + "/" + param2 + ".save.json";
               _loc7_.setUrlAtProfile(_loc8_,_loc9_);
               logger.d("IMPORT","Checking save URL {0}",_loc9_);
               _loc8_++;
            }
            _loc5_++;
         }
         return _loc4_;
      }
      
      private function browseFileSelectHandler(param1:String) : void
      {
         GuiMouse.gamePaused = false;
         if(!param1)
         {
            return;
         }
         var _loc2_:SagaSave = this.loadSagaSaveFromAbsolutePath(param1);
         if(_loc2_)
         {
            this.performImportSave(_loc2_);
         }
         else
         {
            logger.error("Failed to load save from absolute path [" + param1 + "]");
         }
      }
      
      public function ensureTopGp() : void
      {
         if(!visible)
         {
            return;
         }
         this.doUnbind();
         this.doBind();
         if(Boolean(this.gui) && this.gui.visible)
         {
            this.gui.ensureTopGp();
         }
      }
   }
}

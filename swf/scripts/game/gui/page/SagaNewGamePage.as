package game.gui.page
{
   import com.greensock.TweenMax;
   import engine.automator.EngineAutomator;
   import engine.core.fsm.State;
   import engine.gui.page.PageState;
   import engine.saga.Saga;
   import engine.saga.SagaDef;
   import engine.saga.SagaImportDef;
   import engine.saga.save.SagaSave;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import game.cfg.GameConfig;
   import game.gui.GamePage;
   import game.session.states.SagaNewGameState;
   
   public class SagaNewGamePage extends GamePage implements IGuiSagaNewGameListener
   {
      
      public static var mcClazz_newGame_saga2:Class;
      
      public static var mcClazz_newGame_saga3:Class;
      
      public static var IMPORT_SAVE_TOKEN_PREFIX:String = "save_import_tbs1";
       
      
      private var _newGame:IGuiSagaNewGame;
      
      public var _imported:SagaSave;
      
      private var starting:Boolean;
      
      public function SagaNewGamePage(param1:GameConfig, param2:int = 2731, param3:int = 1536)
      {
         super(param1,param2,param3);
      }
      
      private function _selectMcClazz() : Class
      {
         var _loc1_:Saga = config.saga;
         var _loc2_:SagaDef = !!_loc1_ ? _loc1_.def : null;
         if(!_loc2_)
         {
            throw new IllegalOperationError("SagaNewGamePage._selectMcClazz() picked a bad time to stop selecting a class");
         }
         switch(_loc2_.id)
         {
            case "saga2":
               return mcClazz_newGame_saga2;
            case "saga3":
               return mcClazz_newGame_saga3;
            default:
               throw new IllegalOperationError("SagaNewGamePage._selectMcClazz() no class for saga id [" + _loc2_.id + "]");
         }
      }
      
      override protected function handleStart() : void
      {
         var _loc1_:Class = this._selectMcClazz();
         setFullPageMovieClipClass(_loc1_);
      }
      
      override public function cleanup() : void
      {
         if(this._newGame)
         {
            this._newGame.removeEventListener(Event.COMPLETE,this.newGameCompleteHandler);
            this._newGame.cleanup();
         }
         this._newGame = null;
         super.cleanup();
      }
      
      override protected function handleLoaded() : void
      {
         if(Boolean(fullScreenMc) && !this._newGame)
         {
            fullScreenMc.visible = true;
            this._newGame = fullScreenMc as IGuiSagaNewGame;
            this._newGame.init(config.gameGuiContext,this,config.saga,config.context.appInfo);
            this._newGame.resizeHandler(width,height);
            this._newGame.addEventListener(Event.COMPLETE,this.newGameCompleteHandler);
            EngineAutomator.notify("gui_saga_new_game_ready");
            this.resizeHandler();
         }
      }
      
      public function guiOpenSaveImportDialog() : void
      {
         this.doCheckImportSave();
      }
      
      private function doCheckImportSave() : void
      {
         this._imported = null;
         if(fullScreenMc)
         {
            fullScreenMc.visible = false;
         }
         var _loc1_:SagaImportDef = config.saga.def.importDef;
         if(!_loc1_)
         {
            throw new IllegalOperationError("Should not have gotten here");
         }
         config.pageManager.showSaveProfileImport(this.saveProfileImportHandler);
      }
      
      private function saveProfileImportHandler(param1:SagaSave) : void
      {
         if(param1 != null)
         {
            if(this.handleImportSaveLoaded("",param1))
            {
               return;
            }
         }
         if(fullScreenMc)
         {
            fullScreenMc.visible = true;
         }
      }
      
      private function handleImportSaveLoaded(param1:String, param2:SagaSave) : Boolean
      {
         this._newGame.hideWaitPopup();
         if(!param2)
         {
            logger.error("Import Failed: Deserialize");
            this._newGame.showImportFailedPopup("import_err_deserialize");
            return false;
         }
         var _loc3_:SagaImportDef = config.saga.def.importDef;
         if(param2.version < _loc3_.minVersion)
         {
            logger.error("Import Failed: Version " + param2.version + " < " + _loc3_.minVersion);
            this._newGame.showImportFailedPopup("import_err_too_old");
            return false;
         }
         if(param2.version > _loc3_.maxVersion)
         {
            logger.error("Import Failed: Version " + param2.version + " > " + _loc3_.maxVersion);
            this._newGame.showImportFailedPopup("import_err_too_new");
            return false;
         }
         var _loc4_:String = _loc3_.checkRequirements(param2);
         if(_loc4_)
         {
            logger.error("Import Failed: Requirement " + _loc4_);
            _loc4_ = "import_err_" + _loc4_;
            this._newGame.showImportFailedPopup(_loc4_);
            return false;
         }
         param2.stripForImport();
         this._imported = param2;
         this.newGameCompleteHandler(null);
         return true;
      }
      
      private function newGameCompleteHandler(param1:Event) : void
      {
         if(!this._newGame)
         {
            return;
         }
         var _loc2_:String = this._newGame.selection;
         var _loc3_:SagaSave = this._imported;
         if(!_loc2_ && !_loc3_)
         {
            if(config.saga)
            {
               config.saga.showStartPage(true);
            }
            return;
         }
         this.doStart(_loc2_,_loc3_);
      }
      
      private function doStart(param1:String, param2:SagaSave) : void
      {
         var profile_index:int = 0;
         var happening_id:String = null;
         var selectedVariable:String = param1;
         var imported:SagaSave = param2;
         var sngs:SagaNewGameState = config.fsm.currentGameState as SagaNewGameState;
         profile_index = sngs.profile_index;
         happening_id = sngs.happening_id;
         this.percentLoaded = 0;
         this.state = PageState.LOADING;
         this.starting = true;
         TweenMax.delayedCall(0.1,function():void
         {
            if(!config || !config.saga || !config.saga.def)
            {
               return;
            }
            var _loc1_:int = config.saga.difficulty;
            config.loadSaga(config.saga.def.url,happening_id,null,_loc1_,profile_index,imported,selectedVariable,config.saga.parentSagaUrl);
         });
      }
      
      override protected function resizeHandler() : void
      {
         super.resizeHandler();
      }
      
      override public function canReusePageForState(param1:State) : Boolean
      {
         return false;
      }
   }
}

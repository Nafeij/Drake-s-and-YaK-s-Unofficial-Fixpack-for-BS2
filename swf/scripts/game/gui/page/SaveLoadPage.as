package game.gui.page
{
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.gp.GpControlButton;
   import engine.core.locale.LocaleCategory;
   import engine.core.render.Screenshot;
   import engine.core.util.MemoryReporter;
   import engine.resource.BitmapResource;
   import engine.resource.ResourceGroup;
   import engine.resource.event.ResourceLoadedEvent;
   import engine.saga.Saga;
   import engine.saga.SagaDef;
   import engine.saga.save.SagaSave;
   import engine.saga.save.SaveManager;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.ui.Keyboard;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import game.cfg.GameConfig;
   import game.gui.GamePage;
   import game.gui.IGuiDialog;
   
   public class SaveLoadPage extends GamePage implements IGuiSaveLoadListener
   {
      
      public static var mcClazz:Class;
      
      public static var RESTART_BITMAP_URL:String = "saga1/restart1.png";
       
      
      private var gui:IGuiSaveLoad;
      
      private var _showingSaveLoad:Boolean;
      
      private var cmd_esc:Cmd;
      
      private var profile_index:int = -1;
      
      private var restartBmpr:BitmapResource;
      
      private var resourceGroup:ResourceGroup;
      
      public var bitmapResourceToSaves:Dictionary;
      
      private var loaders:Array;
      
      private var bmpds:Vector.<BitmapData>;
      
      private var _allowClose:Boolean;
      
      private var saga:Saga;
      
      private var _closeToProfile:Boolean;
      
      private var gplayer:int = 0;
      
      public function SaveLoadPage(param1:GameConfig)
      {
         this.cmd_esc = new Cmd("cmd_esc_saveload",this.cmdfunc_esc);
         this.bitmapResourceToSaves = new Dictionary();
         this.loaders = [];
         this.bmpds = new Vector.<BitmapData>();
         super(param1);
         this.visible = false;
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
         this.cmd_esc.cleanup();
         super.cleanup();
         config.saveManager.removeEventListener(SaveManager.EVENT_SAVE_DELETED,this.setupSaves);
      }
      
      override protected function handleStart() : void
      {
         this.restartBmpr = getPageResource(RESTART_BITMAP_URL,BitmapResource) as BitmapResource;
      }
      
      override protected function handleLoaded() : void
      {
         if(Boolean(fullScreenMc) && !this.gui)
         {
            this.gui = fullScreenMc as IGuiSaveLoad;
            this.gui.init(config.gameGuiContext,this);
            resizeHandler();
            if(this._showingSaveLoad)
            {
               this.showSaveLoad(this._allowClose,this.profile_index,this._closeToProfile);
            }
         }
      }
      
      private function registerBitmapResourceToSave(param1:BitmapResource, param2:SagaSave) : void
      {
         var _loc3_:Vector.<SagaSave> = this.bitmapResourceToSaves[param1];
         if(!_loc3_)
         {
            _loc3_ = new Vector.<SagaSave>();
            this.bitmapResourceToSaves[param1] = _loc3_;
         }
         _loc3_.push(param2);
      }
      
      private function loadBitmap(param1:SagaSave) : void
      {
         var _loc2_:String = null;
         var _loc3_:* = null;
         var _loc4_:BitmapResource = null;
         if(SaveManager.SAVE_SCREENSHOT_PREGENERATED)
         {
            _loc2_ = param1.id;
            if(param1.isSaveQuick)
            {
               _loc2_ = "quicksave";
            }
            if(!param1.isSaveCheckpoint)
            {
               if(param1.last_chapter_save_id)
               {
                  _loc2_ = param1.last_chapter_save_id;
               }
            }
            _loc2_ = SaveManager.fixupMigrateSaveId(_loc2_);
            _loc3_ = param1.saga_id + "/save/" + _loc2_ + ".png";
            _loc4_ = config.resman.getResource(_loc3_,BitmapResource,this.resourceGroup) as BitmapResource;
            this.registerBitmapResourceToSave(_loc4_,param1);
            _loc4_.addResourceListener(this.bitmapResourceHandler);
            return;
         }
         config.saveManager.getSaveBitmapAsync(param1.saga_id,param1.id,this.profile_index,param1,SaveManager.SAVE_SCREENSHOT_PNG ? this.saveBitmapPngHandler : this.saveBitmapZippedHandler);
      }
      
      private function bitmapResourceHandler(param1:ResourceLoadedEvent) : void
      {
         var _loc4_:SagaSave = null;
         param1.resource.removeResourceListener(this.bitmapResourceHandler);
         var _loc2_:BitmapResource = param1.resource as BitmapResource;
         if(!_loc2_)
         {
            return;
         }
         if(!this.bitmapResourceToSaves)
         {
            return;
         }
         var _loc3_:Vector.<SagaSave> = this.bitmapResourceToSaves[_loc2_];
         if(_loc3_)
         {
            for each(_loc4_ in _loc3_)
            {
               if(Boolean(_loc4_) && !_loc4_.thumbnailBmp)
               {
                  _loc4_.thumbnailBmp = _loc2_.bmp;
               }
            }
         }
      }
      
      private function saveBitmapZippedHandler(param1:String, param2:SagaSave, param3:ByteArray) : void
      {
         if(!param2 || !param3)
         {
            return;
         }
         var _loc4_:BitmapData = Screenshot.unzipScreenshot(param3);
         param3.clear();
         this.bmpds.push(_loc4_);
         param2.thumbnailBmp = new Bitmap(_loc4_);
      }
      
      private function saveBitmapPngHandler(param1:String, param2:SagaSave, param3:ByteArray) : void
      {
         var loader:Loader = null;
         var bitmapCompleteHandler:Function = null;
         var url:String = param1;
         var ss:SagaSave = param2;
         var data:ByteArray = param3;
         bitmapCompleteHandler = function(param1:Event):void
         {
            data.clear();
            MemoryReporter.notifyModified();
            loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,bitmapCompleteHandler);
            var _loc2_:Bitmap = loader.content as Bitmap;
            ss.thumbnailBmp = _loc2_;
         };
         if(!ss || !data)
         {
            return;
         }
         loader = new Loader();
         this.loaders.push(loader);
         loader.contentLoaderInfo.addEventListener(Event.COMPLETE,bitmapCompleteHandler);
         loader.loadBytes(data);
      }
      
      private function clearLoaders() : void
      {
         var _loc1_:Loader = null;
         var _loc2_:BitmapData = null;
         for each(_loc1_ in this.loaders)
         {
            _loc1_.unload();
         }
         this.loaders = [];
         if(this.bmpds.length)
         {
            for each(_loc2_ in this.bmpds)
            {
               _loc2_.dispose();
            }
            this.bmpds.splice(0,this.bmpds.length - 1);
         }
      }
      
      public function hideSaveLoad(param1:Boolean) : void
      {
         var _loc2_:Object = null;
         var _loc3_:BitmapResource = null;
         for each(_loc2_ in this.bitmapResourceToSaves)
         {
            _loc3_ = _loc2_ as BitmapResource;
            if(_loc3_)
            {
               _loc3_.removeResourceListener(this.bitmapResourceHandler);
            }
         }
         this.bitmapResourceToSaves = null;
         if(this.resourceGroup)
         {
            this.resourceGroup.release();
            this.resourceGroup = null;
         }
         this.doUnbind();
         if(this.saga)
         {
            this.saga.unpause(this);
            this.saga = null;
         }
         if(param1 && visible)
         {
            config.gameGuiContext.playSound("ui_generic");
         }
         if(this.gui)
         {
            this.gui.clearSaves();
         }
         this.clearLoaders();
         this.visible = false;
         if(this.gui)
         {
            (this.gui as MovieClip).visible = false;
         }
         this._showingSaveLoad = false;
         config.saveManager.removeEventListener(SaveManager.EVENT_SAVE_DELETED,this.handleSaveDeleted);
      }
      
      public function get allowClose() : Boolean
      {
         return this._allowClose;
      }
      
      public function showSaveLoad(param1:Boolean, param2:int, param3:Boolean) : void
      {
         this.resourceGroup = new ResourceGroup(this,logger);
         this.bitmapResourceToSaves = new Dictionary();
         config.gameGuiContext.translateDisplayObjects(LocaleCategory.GUI,this);
         this.profile_index = param2;
         this._closeToProfile = param3;
         config.dialogLayer.clearDialogs();
         this.doBind();
         this.clearLoaders();
         config.gameGuiContext.playSound("ui_generic");
         this._showingSaveLoad = true;
         this._allowClose = param1;
         this.visible = true;
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
         config.saveManager.addEventListener(SaveManager.EVENT_SAVE_DELETED,this.handleSaveDeleted);
         this.setupSaves();
      }
      
      override public function set visible(param1:Boolean) : void
      {
         if(param1 != super.visible)
         {
            super.visible = param1;
         }
      }
      
      private function setupSaves() : void
      {
         var _loc3_:SagaSave = null;
         var _loc4_:SagaSave = null;
         var _loc1_:String = config.skuSaga;
         var _loc2_:Array = config.saveManager.getSavesInProfile(_loc1_,this.profile_index,this.saga.isSurvival);
         for each(_loc4_ in _loc2_)
         {
            this.loadBitmap(_loc4_);
            if(_loc4_.id == Saga.SAVE_ID_RESUME)
            {
               _loc3_ = _loc4_;
            }
         }
         _loc2_.sortOn("dateTime",Array.DESCENDING);
         this.gui.setupSaves(this._allowClose,_loc3_,_loc2_,this.restartBmpr.bitmapData);
      }
      
      public function guiSaveLoadFromSave(param1:SagaSave) : void
      {
         if(!param1)
         {
            return;
         }
         var _loc2_:Saga = config.saga;
         config.loadSaga(_loc2_.def.url,null,param1,0,this.profile_index,null,null,_loc2_.parentSagaUrl);
         config.pageManager.HideAllLayers();
      }
      
      public function guiSaveLoadFromBookmark(param1:String) : void
      {
         var _loc2_:Saga = config.saga;
         if(!param1)
         {
            param1 = _loc2_.startHappening;
            if(!param1)
            {
               param1 = SagaDef.START_HAPPENING;
            }
         }
         if(!param1)
         {
            _loc2_.showStartPage(true);
         }
         else
         {
            _loc2_.ensureSelectedVariable();
            config.loadSaga(_loc2_.def.url,param1,null,config.saga.difficulty,this.profile_index,_loc2_.imported,_loc2_.selectedVariable,_loc2_.parentSagaUrl);
         }
         config.pageManager.HideAllLayers();
      }
      
      public function guiSaveLoadClose() : void
      {
         if(this._closeToProfile)
         {
            config.pageManager.showSaveProfileLoad(false);
         }
         else if(this._allowClose)
         {
            config.pageManager.hideSaveLoad();
         }
      }
      
      public function guiSaveLoadDelete(param1:SagaSave, param2:String) : void
      {
         var yes:String = null;
         var ss:SagaSave = param1;
         var description:String = param2;
         var dialog:IGuiDialog = config.gameGuiContext.createDialog();
         var title:String = config.gameGuiContext.translate("save_delete_title");
         var body:String = config.gameGuiContext.translate("save_delete_body");
         body = body.replace("$SAVEID",description);
         yes = config.gameGuiContext.translate("yes");
         var no:String = config.gameGuiContext.translate("no");
         dialog.openTwoBtnDialog(title,body,yes,no,function(param1:String):void
         {
            if(param1 == yes)
            {
               config.saveManager.deleteSave(config.saga.def.id,ss.id,profile_index);
            }
         });
      }
      
      private function handleSaveDeleted(param1:Event) : void
      {
         this.setupSaves();
      }
      
      public function cmdfunc_esc(param1:CmdExec) : void
      {
         this.guiSaveLoadClose();
      }
      
      public function doBind() : void
      {
         this.gplayer = config.gpbinder.createLayer("SaveLoadPage");
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

package game.gui.pages
{
   import com.greensock.TweenMax;
   import com.stoicstudio.platform.PlatformInput;
   import engine.core.locale.LocaleCategory;
   import engine.core.util.AppInfo;
   import engine.gui.GuiGpNav;
   import engine.saga.Saga;
   import engine.saga.SagaImportDef;
   import flash.events.Event;
   import flash.text.TextField;
   import game.gui.ButtonWithIndex;
   import game.gui.GuiBase;
   import game.gui.IGuiContext;
   import game.gui.IGuiDialog;
   import game.gui.page.IGuiSagaNewGame;
   import game.gui.page.IGuiSagaNewGameListener;
   
   public class GuiSagaNewGame extends GuiBase implements IGuiSagaNewGame
   {
       
      
      public var listener:IGuiSagaNewGameListener;
      
      public var _button$newgame_choose_rook:ButtonWithIndex;
      
      public var _button$newgame_choose_alette:ButtonWithIndex;
      
      public var _button$newgame_import_save:ButtonWithIndex;
      
      public var _buttonClose:ButtonWithIndex;
      
      public var _button$confirm:ButtonWithIndex;
      
      public var _description$newgame_desc_rook:TextField;
      
      public var _description$newgame_desc_alette:TextField;
      
      public var _selection:String;
      
      private var appInfo:AppInfo;
      
      public var nav:GuiGpNav;
      
      private var dialogImportSaveWait:IGuiDialog;
      
      public function GuiSagaNewGame()
      {
         super();
         stop();
      }
      
      public function get selection() : String
      {
         return this._selection;
      }
      
      public function init(param1:IGuiContext, param2:IGuiSagaNewGameListener, param3:Saga, param4:AppInfo) : void
      {
         super.initGuiBase(param1);
         this.appInfo = param4;
         this.listener = param2;
         var _loc5_:String = "";
         if(param3 && param3.def && Boolean(param3.def.id))
         {
            _loc5_ = param3.def.id;
         }
         var _loc6_:String = _loc5_ == "saga3" ? "description$newgame3_desc_rook" : "description$newgame_desc_rook";
         var _loc7_:String = _loc5_ == "saga3" ? "description$newgame3_desc_alette" : "description$newgame_desc_alette";
         this._button$newgame_import_save = requireGuiChild("button$newgame_import_save") as ButtonWithIndex;
         this._button$newgame_choose_rook = requireGuiChild("button$newgame_choose_rook") as ButtonWithIndex;
         this._button$newgame_choose_alette = requireGuiChild("button$newgame_choose_alette") as ButtonWithIndex;
         this._button$confirm = requireGuiChild("button$confirm") as ButtonWithIndex;
         this._buttonClose = requireGuiChild("buttonClose") as ButtonWithIndex;
         this._description$newgame_desc_rook = requireGuiChild(_loc6_) as TextField;
         this._description$newgame_desc_alette = requireGuiChild(_loc7_) as TextField;
         this._button$newgame_import_save.guiButtonContext = param1;
         this._button$newgame_choose_rook.guiButtonContext = param1;
         this._button$newgame_choose_alette.guiButtonContext = param1;
         this._buttonClose.guiButtonContext = param1;
         this._button$confirm.guiButtonContext = param1;
         this._button$newgame_choose_rook.disableAutoAlpha = true;
         this._button$newgame_choose_alette.disableAutoAlpha = true;
         this._button$confirm.setDownFunction(this.buttonConfirmHandler);
         this._buttonClose.setDownFunction(this.buttonCloseHandler);
         this._button$newgame_choose_rook.setDownFunction(this.buttonSelectHandler);
         this._button$newgame_choose_alette.setDownFunction(this.buttonSelectHandler);
         this._button$newgame_import_save.setDownFunction(this.buttonImportHandler);
         this._description$newgame_desc_alette.visible = false;
         this._description$newgame_desc_rook.visible = false;
         this._button$confirm.visible = false;
         var _loc8_:SagaImportDef = param3.def.importDef;
         this._button$newgame_import_save.visible = _loc8_ != null;
         this.nav = new GuiGpNav(param1,"newgame",this);
         this.nav.add(this._button$newgame_import_save);
         this.nav.add(this._button$newgame_choose_rook);
         this.nav.add(this._button$newgame_choose_alette);
         this.nav.add(this._button$confirm);
         this.nav.autoSelect();
         this.nav.activate();
         this._buttonClose.visible = PlatformInput.hasClicker;
         param1.locale.translateDisplayObjects(LocaleCategory.GUI,this,logger);
      }
      
      public function resizeHandler(param1:Number, param2:Number) : void
      {
      }
      
      public function cleanup() : void
      {
         super.cleanupGuiBase();
         this.nav.cleanup();
         this.nav = null;
      }
      
      public function showImportFailedPopup(param1:String) : void
      {
         var _loc2_:IGuiDialog = _context.createDialog();
         var _loc3_:String = _context.translate("ok");
         var _loc4_:String = _context.translate(param1);
         var _loc5_:String = _context.translate("import_err_title");
         _loc2_.openDialog(_loc5_,_loc4_,_loc3_,null);
      }
      
      public function showWaitPopup() : void
      {
         var yes:String;
         var text:String;
         var title:String;
         this.hideWaitPopup();
         this.dialogImportSaveWait = _context.createDialog();
         yes = _context.translate("yes");
         text = "Waiting for import...";
         title = "Waiting for import...";
         this.dialogImportSaveWait.openDialog(title,text,null,function(param1:String):void
         {
            if(!param1)
            {
            }
         });
      }
      
      public function hideWaitPopup() : void
      {
         if(this.dialogImportSaveWait)
         {
            this.dialogImportSaveWait.closeDialog(null);
            this.dialogImportSaveWait = null;
         }
      }
      
      private function buttonConfirmHandler(param1:*) : void
      {
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      private function buttonCloseHandler(param1:*) : void
      {
         this._selection = null;
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      private function showSelection(param1:TextField, param2:ButtonWithIndex, param3:ButtonWithIndex) : void
      {
         this._description$newgame_desc_rook.visible = param1 == this._description$newgame_desc_rook;
         this._description$newgame_desc_alette.visible = param1 == this._description$newgame_desc_alette;
         param2.alpha = 1;
         TweenMax.killTweensOf(param2);
         TweenMax.to(param3,0.5,{"alpha":0.6});
      }
      
      private function buttonSelectHandler(param1:*) : void
      {
         if(param1 == this._button$newgame_choose_rook)
         {
            this._selection = "hero_rook";
            this.showSelection(this._description$newgame_desc_rook,param1,this._button$newgame_choose_alette);
         }
         else
         {
            this._selection = "hero_alette";
            this.showSelection(this._description$newgame_desc_alette,param1,this._button$newgame_choose_rook);
         }
         this._button$confirm.visible = true;
         this._selection = param1 == this._button$newgame_choose_rook ? "hero_rook" : "hero_alette";
         if(this.nav)
         {
            this.nav.remap();
         }
      }
      
      private function buttonImportHandler(param1:*) : void
      {
         this.showWaitPopup();
         this.listener.guiOpenSaveImportDialog();
      }
   }
}

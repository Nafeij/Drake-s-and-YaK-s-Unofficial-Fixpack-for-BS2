package game.gui
{
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.entity.def.IEntityDef;
   import engine.gui.GuiContextEvent;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpAlignH;
   import engine.gui.GuiGpAlignV;
   import engine.gui.GuiGpBitmap;
   import engine.stat.def.StatType;
   import flash.display.MovieClip;
   import flash.text.TextField;
   import game.gui.page.GuiBioConfig;
   import game.gui.page.IGuiBioListener;
   
   public class GuiBio extends GuiBase
   {
       
      
      private var bioPage:MovieClip;
      
      private var dismissPage:MovieClip;
      
      private var classDesc:TextField;
      
      private var className:TextField;
      
      private var killCount:TextField;
      
      public var text$days_in_service_pfx:TextField;
      
      public var text$battles_pfx:TextField;
      
      private var dayCount:TextField;
      
      private var battlesCount:TextField;
      
      private var dismissCancel:ButtonWithIndex;
      
      private var dismissConfirm:ButtonWithIndex;
      
      public var button$dismiss:ButtonWithIndex;
      
      public var button$rename:ButtonWithIndex;
      
      public var button$variations:ButtonWithIndex;
      
      private var _entity:IEntityDef;
      
      private var listener:IGuiBioListener;
      
      private var buttonToggle:ButtonWithIndex;
      
      private var gp_b:GuiGpBitmap;
      
      private var cmd_close:Cmd;
      
      private var gplayer:int;
      
      public function GuiBio()
      {
         this.gp_b = GuiGp.ctorPrimaryBitmap(GpControlButton.B);
         this.cmd_close = new Cmd("pg_bio_close",this.cmdfunc_close);
         super();
      }
      
      public function init(param1:IGuiContext, param2:GuiBioConfig, param3:IGuiBioListener, param4:ButtonWithIndex) : void
      {
         this.visible = false;
         this.buttonToggle = param4;
         initGuiBase(param1);
         this.listener = param3;
         this.dismissPage = getChildByName("dismissPage") as MovieClip;
         this.bioPage = getChildByName("bioPage") as MovieClip;
         this.classDesc = this.bioPage.getChildByName("classDesc") as TextField;
         this.className = this.bioPage.getChildByName("className") as TextField;
         this.killCount = this.bioPage.getChildByName("killCount") as TextField;
         this.dayCount = this.bioPage.getChildByName("dayCount") as TextField;
         this.battlesCount = this.bioPage.getChildByName("battlesCount") as TextField;
         this.button$variations = this.bioPage.button$variations;
         this.button$variations.setDownFunction(this.onVariationClick);
         this.button$rename = this.bioPage.button$rename;
         this.button$rename.setDownFunction(this.onRenameClick);
         this.button$dismiss = this.bioPage.button$dismiss;
         this.button$dismiss.setDownFunction(this.onDismissButtonClick);
         this.button$variations.visible = param2.showColor;
         this.button$rename.visible = param2.showRename;
         this.button$dismiss.visible = param2.showDismiss;
         this.dismissPage.visible = false;
         this.dismissConfirm = this.dismissPage.getChildByName("confirm") as ButtonWithIndex;
         this.dismissConfirm.setDownFunction(this.onDismissConfirmClick);
         this.dismissCancel = this.dismissPage.getChildByName("cancel") as ButtonWithIndex;
         this.dismissCancel.setDownFunction(this.onDismissCancelClick);
         this.text$days_in_service_pfx = this.bioPage.getChildByName("text$days_in_service_pfx") as TextField;
         this.text$battles_pfx = this.bioPage.getChildByName("text$battles_pfx") as TextField;
         this.text$days_in_service_pfx.visible = this.dayCount.visible = param2.showServiceDays;
         this.text$battles_pfx.visible = this.battlesCount.visible = param2.showBattles;
         param1.addEventListener(GuiContextEvent.LOCALE,this.localeHandler);
         param4.parent.addChild(this.gp_b);
         this.gp_b.scale = 1.5;
         GuiGp.placeIcon(param4,null,this.gp_b,GuiGpAlignH.C,GuiGpAlignV.N_DOWN);
      }
      
      public function cleanup() : void
      {
         context.removeEventListener(GuiContextEvent.LOCALE,this.localeHandler);
         GpBinder.gpbinder.unbind(this.cmd_close);
         this.cmd_close.cleanup();
         GuiGp.releasePrimaryBitmap(this.gp_b);
         if(this.dismissCancel)
         {
            this.dismissCancel.cleanup();
         }
         if(this.dismissConfirm)
         {
            this.dismissConfirm.cleanup();
         }
         if(this.button$dismiss)
         {
            this.button$dismiss.cleanup();
         }
         if(this.button$rename)
         {
            this.button$rename.cleanup();
         }
         if(this.button$variations)
         {
            this.button$variations.cleanup();
         }
         while(numChildren > 0)
         {
            removeChildAt(numChildren - 1);
         }
         super.cleanupGuiBase();
      }
      
      private function localeHandler(param1:GuiContextEvent) : void
      {
         this.setupBio();
      }
      
      public function get entity() : IEntityDef
      {
         return this._entity;
      }
      
      public function set entity(param1:IEntityDef) : void
      {
         if(param1 == this._entity)
         {
            return;
         }
         this._entity = param1;
         if(this._entity == null)
         {
            this.visible = false;
         }
         else
         {
            this.setupBio();
            this.visible = true;
         }
      }
      
      private function setupBio() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(!this._entity)
         {
            return;
         }
         this.bioPage.visible = true;
         this.dismissPage.visible = false;
         if(this._entity.description)
         {
            this.classDesc.text = this._entity.description;
            this.className.text = this._entity.name;
         }
         else
         {
            this.classDesc.text = this._entity.entityClass.description;
            this.className.text = this._entity.entityClass.name;
         }
         context.currentLocale.fixTextFieldFormat(this.classDesc);
         context.currentLocale.fixTextFieldFormat(this.className);
         this.killCount.text = this._entity.stats.getValue(StatType.KILLS).toString();
         _loc1_ = new Date().time;
         _loc2_ = _loc1_ - this._entity.startDate;
         _loc3_ = _loc2_ / (1000 * 60);
         _loc4_ = _loc3_ / 60;
         var _loc5_:int = _loc4_ / 24;
         this.dayCount.text = _loc5_.toString();
         this.battlesCount.text = this._entity.stats.getValue(StatType.BATTLES).toString();
         this.button$rename.enabled = this._entity.stats.getValue(StatType.RANK) > 1;
         this.button$variations.enabled = this._entity.stats.getValue(StatType.RANK) > 1;
      }
      
      private function onDismissButtonClick(param1:ButtonWithIndex) : void
      {
         var _loc2_:IGuiDialog = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         if(context.legend.roster.numCombatants <= 6)
         {
            _loc2_ = context.createDialog();
            _loc3_ = String(context.translate("pg_cannot_dismiss_limit_title"));
            _loc4_ = String(context.translate("pg_cannot_dismiss_limit_body"));
            _loc5_ = String(context.translate("ok"));
            _loc2_.openDialog(_loc3_,_loc4_,_loc5_,null);
            return;
         }
         this.bioPage.visible = false;
         this.dismissPage.visible = true;
      }
      
      private function onDismissCancelClick(param1:ButtonWithIndex) : void
      {
         this.bioPage.visible = true;
         this.dismissPage.visible = false;
      }
      
      private function onDismissConfirmClick(param1:ButtonWithIndex) : void
      {
         context.legend.dismissEntity(this._entity);
         this.listener.onDismiss();
      }
      
      private function onRenameClick(param1:ButtonWithIndex) : void
      {
         this.listener.onBioRenameCharacter();
      }
      
      private function onVariationClick(param1:ButtonWithIndex) : void
      {
         this.listener.onBioVariation();
      }
      
      override public function set visible(param1:Boolean) : void
      {
         if(param1 && !super.visible)
         {
            this.gplayer = GpBinder.gpbinder.createLayer("GuiBio");
            GpBinder.gpbinder.bindPress(GpControlButton.B,this.cmd_close);
            GpBinder.gpbinder.bindPress(GpControlButton.A,this.cmd_close);
            this.gp_b.gplayer = this.gplayer;
         }
         else if(!param1 && super.visible)
         {
            GpBinder.gpbinder.removeLayer(this.gplayer);
            GpBinder.gpbinder.unbind(this.cmd_close);
            GpBinder.gpbinder.unbind(this.cmd_close);
            this.gplayer = 0;
         }
         this.gp_b.visible = param1;
         super.visible = param1;
      }
      
      private function cmdfunc_close(param1:CmdExec) : void
      {
         this.listener.onGuiBioCloseRequest();
      }
   }
}

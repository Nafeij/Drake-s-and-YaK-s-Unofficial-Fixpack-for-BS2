package game.gui.pages
{
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpAlignH;
   import engine.gui.GuiGpAlignV;
   import engine.gui.GuiGpBitmap;
   import engine.gui.GuiGpNav;
   import engine.saga.Saga;
   import flash.display.DisplayObject;
   import game.gui.GuiCharacterStats;
   import game.gui.GuiPgStatDisplay;
   import game.gui.IGuiContext;
   
   public class GuiPgDetails_Gp
   {
       
      
      private var details:GuiPgDetails;
      
      private var context:IGuiContext;
      
      public var _details_item:GuiPgDetailsItem;
      
      private var gp_left:GuiGpBitmap;
      
      private var gp_right:GuiGpBitmap;
      
      private var gp_y:GuiGpBitmap;
      
      private var gp_x:GuiGpBitmap;
      
      private var cmd_x:Cmd;
      
      private var cmd_left:Cmd;
      
      private var cmd_right:Cmd;
      
      private var cmd_pg_items:Cmd;
      
      private var nav:GuiGpNav;
      
      private var gplayer:int;
      
      public var _statsVisibilityChangeOrdinal:int;
      
      private var _prevHeroicVisibility:Boolean = false;
      
      public function GuiPgDetails_Gp()
      {
         this.gp_left = GuiGp.ctorPrimaryBitmap(GpControlButton.L1,true);
         this.gp_right = GuiGp.ctorPrimaryBitmap(GpControlButton.R1,true);
         this.gp_y = GuiGp.ctorPrimaryBitmap(GpControlButton.Y,true);
         this.gp_x = GuiGp.ctorPrimaryBitmap(GpControlButton.X,true);
         this.cmd_x = new Cmd("pg_details_x",this.cmdfunc_x);
         this.cmd_left = new Cmd("pg_details_left",this.cmdfunc_left);
         this.cmd_right = new Cmd("pg_details_left",this.cmdfunc_right);
         this.cmd_pg_items = new Cmd("cmd_pg_details_items",this.cmdfunc_items);
         super();
         this.cmd_pg_items.global = true;
         this.gp_y.global = true;
         this.gp_y.visible = false;
         this.gp_y.scale = 1.5;
         this.gp_x.global = true;
         this.gp_x.visible = false;
         this.gp_x.scale = 1.5;
      }
      
      public function refreshGui() : void
      {
         this.gp_x.visible = false;
         if(this.details._button$survival_funeral_hero.visible)
         {
            GuiGp.placeIcon(this.details._button$survival_funeral_hero,null,this.gp_x,GuiGpAlignH.C,GuiGpAlignV.N);
            this.gp_x.visible = true;
         }
         else if(this.details._button_survival_recruit_hero.visible)
         {
            GuiGp.placeIcon(this.details._button_survival_recruit_hero,null,this.gp_x,GuiGpAlignH.C,GuiGpAlignV.N);
            this.gp_x.visible = true;
         }
      }
      
      public function update() : void
      {
         var _loc2_:int = 0;
         var _loc1_:GuiCharacterStats = !!this.details ? this.details._characterStats : null;
         if(_loc1_)
         {
            _loc2_ = _loc1_.visibilityChangeOrdinal;
            if(_loc2_ != this._statsVisibilityChangeOrdinal)
            {
               this._statsVisibilityChangeOrdinal = _loc2_;
               if(this.nav)
               {
                  this.nav.remap();
               }
            }
         }
      }
      
      public function init(param1:GuiPgDetails) : void
      {
         var _loc2_:GuiPgStatDisplay = null;
         this.details = param1;
         this.context = param1.context;
         this._details_item = param1._details_item;
         param1.addChild(this.gp_y);
         param1.addChild(this.gp_x);
         GuiGp.placeIcon(this._details_item._item,null,this.gp_y,GuiGpAlignH.W,GuiGpAlignV.C);
         this.gp_left.scale = 1.5;
         this.gp_right.scale = 1.5;
         param1.addChild(this.gp_left);
         param1.addChild(this.gp_right);
         this.handleDetailsItemVisible();
         this.nav = new GuiGpNav(this.context,"pgdet",param1);
         this.nav.setCallbackPress(this.navControlPressHandler);
         this.nav.scale = 1.5;
         this.nav.setAlignNavDefault(GuiGpAlignH.C,GuiGpAlignV.S);
         this.nav.setAlignControlDefault(GuiGpAlignH.C,GuiGpAlignV.N);
         this.nav.add(param1._button$bio);
         this.nav.add(param1._button$heroic_titles);
         this.nav.add(param1._characterStats._abilityButton);
         for each(_loc2_ in param1._characterStats._statDisplays)
         {
            this.nav.add(_loc2_._buttonStat);
            this.nav.add(_loc2_._buttonMinus);
            this.nav.add(_loc2_._buttonPlus);
         }
         this.nav.add(param1._characterStats.confirm_button);
         this.nav.add(param1._characterStats.cancel_button);
         this.nav.autoSelect();
      }
      
      public function cleanup() : void
      {
         this.handleDeactivateDetails();
         GuiGp.releasePrimaryBitmap(this.gp_y);
         this.gp_y = null;
         GuiGp.releasePrimaryBitmap(this.gp_left);
         this.gp_left = null;
         GuiGp.releasePrimaryBitmap(this.gp_right);
         this.gp_right = null;
         this.cmd_x.cleanup();
         this.cmd_x = null;
         this.cmd_left.cleanup();
         this.cmd_left = null;
         this.cmd_right.cleanup();
         this.cmd_right = null;
         this.cmd_pg_items.cleanup();
         this.cmd_pg_items = null;
         if(this.nav)
         {
            this.nav.cleanup();
            this.nav = null;
         }
         this.details = null;
         this.context = null;
         this._details_item = null;
      }
      
      private function navControlPressHandler(param1:DisplayObject, param2:Boolean) : Boolean
      {
         if(param1 == this.details._button$bio)
         {
            this.details._button$bio.press();
         }
         else if(param1 == this.details._characterStats._abilityButton)
         {
            this.details._characterStats._abilityButton.press();
         }
         else
         {
            if(param1 != this.details._button$heroic_titles)
            {
               return false;
            }
            this.details._button$heroic_titles.press();
            if(this.details.guiHeroicTitleTutorial.shouldDisplayTutorial())
            {
               this.nav.selected = null;
            }
            else
            {
               this.nav.autoSelect();
            }
         }
         return true;
      }
      
      public function cmdfunc_x(param1:CmdExec) : void
      {
         if(this.details._button$survival_funeral_hero.visible)
         {
            this.gp_x.pulse();
            this.details._button$survival_funeral_hero.press();
         }
         else if(this.details._button_survival_recruit_hero.visible)
         {
            this.gp_x.pulse();
            this.details._button_survival_recruit_hero.press();
         }
         else if(this.details._promoteBanner.visible)
         {
            this.details._promoteBanner.doPress(false);
         }
      }
      
      public function cmdfunc_left(param1:CmdExec) : void
      {
         this.details.buttonLeft.press();
         this.gp_left.pulse();
         this.handleHeroicButtonRemap();
      }
      
      public function cmdfunc_right(param1:CmdExec) : void
      {
         this.details.buttonRight.press();
         this.gp_right.pulse();
         this.handleHeroicButtonRemap();
      }
      
      public function handleDeactivateDetails() : void
      {
         GpBinder.gpbinder.removeLayer(this.gplayer);
         this.gplayer = 0;
         GpBinder.gpbinder.unbind(this.cmd_pg_items);
         GpBinder.gpbinder.unbind(this.cmd_left);
         GpBinder.gpbinder.unbind(this.cmd_right);
         GpBinder.gpbinder.unbind(this.cmd_x);
         this.gp_left.visible = false;
         this.gp_right.visible = false;
         this.nav.deactivate();
         this._prevHeroicVisibility = false;
         GpBinder.gpbinder.unbind(this.cmd_pg_items);
      }
      
      public function handleActivateDetails() : void
      {
         if(this.gplayer)
         {
            GpBinder.gpbinder.removeLayer(this.gplayer);
         }
         this.gplayer = GpBinder.gpbinder.createLayer("GuiPgDetails_Gp");
         if(this.context.saga.isSurvival)
         {
            GpBinder.gpbinder.bindPress(GpControlButton.X,this.cmd_x);
         }
         GpBinder.gpbinder.bindPress(GpControlButton.Y,this.cmd_pg_items);
         GpBinder.gpbinder.bindPress(GpControlButton.L1,this.cmd_left);
         GpBinder.gpbinder.bindPress(GpControlButton.R1,this.cmd_right);
         this.gp_left.gplayer = this.gp_right.gplayer = this.gp_y.gplayer = this.gp_x.gplayer = this.gplayer;
         this.gp_left.visible = true;
         this.gp_right.visible = true;
         GuiGp.placeIconBottom(this.details.buttonLeft,this.gp_left);
         GuiGp.placeIconBottom(this.details.buttonRight,this.gp_right);
         this.nav.activate();
         this.handleHeroicButtonRemap();
         this.nav.autoSelect();
      }
      
      private function handleHeroicButtonRemap() : void
      {
         if(this._prevHeroicVisibility != this.details._button$heroic_titles.visible)
         {
            this._prevHeroicVisibility = this.details._button$heroic_titles.visible;
            if(this.nav)
            {
               this.nav.remap();
            }
         }
      }
      
      private function cmdfunc_items(param1:CmdExec) : void
      {
         if(!this._details_item._items.items || this._details_item._items.items.length == 0 || this._details_item.isDialogOpen)
         {
            return;
         }
         if(this.details.guiHeroicTitles.visible || this.details.guiHeroicTitleTutorial.visible)
         {
            this._details_item.deactivateGp();
            return;
         }
         if(Boolean(Saga.instance) && Saga.instance.isSurvival)
         {
            if(this.details.selectedCharacter.isSurvivalDead || !this.details.selectedCharacter.isSurvivalRecruited)
            {
               return;
            }
         }
         if(this.details._promoteBanner.bannerVisible)
         {
            this.details._promoteBanner.extended = false;
         }
         if(this._details_item.isActivatedGp)
         {
            this._details_item.deactivateGp();
         }
         else
         {
            this._details_item.activateGp();
         }
      }
      
      public function itemsActivationGpHandler() : void
      {
         if(!this._details_item.isActivatedGp)
         {
            if(this.details._promoteBanner.bannerVisible)
            {
               this.details._promoteBanner.extended = true;
            }
         }
      }
      
      public function handleDetailsItemVisible() : void
      {
         if(this.gp_y)
         {
            this.gp_y.visible = Boolean(this._details_item) && this._details_item.visible;
         }
      }
      
      public function heroicTitleToggleGpHandler() : void
      {
         if(!this.details || !this.details.guiHeroicTitles || !this.details.guiHeroicTitleTutorial)
         {
            return;
         }
         if(this.details.guiHeroicTitles.visible || this.details.guiHeroicTitleTutorial.visible)
         {
            if(this.nav)
            {
               this.nav.deactivate();
            }
            this._details_item.visible = false;
         }
         else
         {
            if(this.nav)
            {
               this.nav.activate();
            }
            this._details_item.visible = !(this.details._promoteBanner.bannerVisible && this.details._promoteBanner.extended);
         }
      }
      
      public function statsDeactivatedGpHandler() : void
      {
         if(!this.details || !this.details._characterStats)
         {
            return;
         }
         if(this.details._characterStats.isActivatedGp())
         {
            if(this.nav)
            {
               this.nav.deactivate();
            }
            this.details.buttonRight.visible = this.details.buttonLeft.visible = false;
            this.details._button$bio.visible = false;
            this._details_item.visible = false;
            this.details._kc.visible = false;
         }
         else
         {
            if(this.nav)
            {
               this.nav.activate();
            }
            this.details.buttonRight.visible = this.details.buttonLeft.visible = true;
            this.details._button$bio.visible = true;
            this.details._kc.visible = true;
            this._details_item.visible = !(this.details._promoteBanner.bannerVisible && this.details._promoteBanner.extended);
         }
      }
      
      public function handleGpCancel() : Boolean
      {
         if(this._details_item.isActivatedGp)
         {
            this._details_item.deactivateGp();
            return true;
         }
         if(this.details._characterStats.handleGpCancel())
         {
            return true;
         }
         return false;
      }
   }
}

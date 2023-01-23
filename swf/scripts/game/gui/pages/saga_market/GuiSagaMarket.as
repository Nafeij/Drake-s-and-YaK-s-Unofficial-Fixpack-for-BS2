package game.gui.pages.saga_market
{
   import com.stoicstudio.platform.PlatformInput;
   import engine.core.TutorialTooltipAlign;
   import engine.core.TutorialTooltipAnchor;
   import engine.core.analytic.Ga;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.core.locale.LocaleCategory;
   import engine.entity.def.ItemDef;
   import engine.gui.GuiContextEvent;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpAlignH;
   import engine.gui.GuiGpAlignV;
   import engine.gui.GuiGpBitmap;
   import engine.gui.GuiGpNav;
   import engine.math.MathUtil;
   import engine.saga.Saga;
   import engine.saga.SagaVar;
   import engine.saga.vars.IVariable;
   import engine.saga.vars.VariableType;
   import flash.events.Event;
   import flash.text.TextField;
   import game.gui.ButtonWithIndex;
   import game.gui.GuiBase;
   import game.gui.IGuiContext;
   import game.gui.page.IGuiSagaMarket;
   
   public class GuiSagaMarket extends GuiBase implements IGuiSagaMarket
   {
       
      
      public var _textSuppliesAvailable:TextField;
      
      public var _textSuppliesPerRenown:TextField;
      
      public var _textTotalRenown:TextField;
      
      public var _textTotalSupplies:TextField;
      
      public var _textTotalDays:TextField;
      
      public var _textSuppliesAdd:TextField;
      
      public var _button_confirm:ButtonWithIndex;
      
      public var _button_plus:ButtonWithIndex;
      
      public var _button_minus:ButtonWithIndex;
      
      public var _button_close:ButtonWithIndex;
      
      public var _item_tabs:GuiSagaMarketTabItems;
      
      public var _$items:TextField;
      
      private var spendRenown:int = 0;
      
      private var gainSupplies:int = 0;
      
      public var _saga:Saga;
      
      private var perRenown:int;
      
      private var cmd_b:Cmd;
      
      private var cmd_r1:Cmd;
      
      private var cmd_l1:Cmd;
      
      private var cmd_y:Cmd;
      
      private var cmd_a:Cmd;
      
      private var gp_b:GuiGpBitmap;
      
      private var gp_r1:GuiGpBitmap;
      
      private var gp_l1:GuiGpBitmap;
      
      private var gp_a:GuiGpBitmap;
      
      private var gp_y:GuiGpBitmap;
      
      private var nav:GuiGpNav;
      
      private var nav_gplayer:int;
      
      private var gplayer:int;
      
      private var _button_close_can_show:Boolean = true;
      
      private var tutorial_market_purchase_supplies_enabled:Boolean;
      
      private var tutorial_2_wait:Boolean;
      
      private var tutorial_3_wait:Boolean;
      
      private var tutorial_4_wait:Boolean;
      
      private var ignoreVarChange:Boolean;
      
      private var _availableSupplies:int = 0;
      
      private var _pressedCount:int;
      
      private var _pressedElapsed:int;
      
      private var _pressed_l1:Boolean;
      
      private var _pressed_r1:Boolean;
      
      public function GuiSagaMarket()
      {
         this.cmd_b = new Cmd("cmd_market_b",this.cmdfunc_b);
         this.cmd_r1 = new Cmd("cmd_market_r1",this.cmdfunc_r1);
         this.cmd_l1 = new Cmd("cmd_market_l1",this.cmdfunc_l1);
         this.cmd_y = new Cmd("cmd_market_y",this.cmdfunc_y);
         this.cmd_a = new Cmd("cmd_market_a",this.cmdfunc_a);
         this.gp_b = GuiGp.ctorPrimaryBitmap(GpControlButton.B);
         this.gp_r1 = GuiGp.ctorPrimaryBitmap(GpControlButton.R1,true);
         this.gp_l1 = GuiGp.ctorPrimaryBitmap(GpControlButton.L1,true);
         this.gp_a = GuiGp.ctorPrimaryBitmap(GpControlButton.A,true);
         this.gp_y = GuiGp.ctorPrimaryBitmap(GpControlButton.Y,true);
         super();
         addChild(this.gp_b);
         addChild(this.gp_r1);
         addChild(this.gp_l1);
         addChild(this.gp_a);
         addChild(this.gp_y);
         this.cmd_y.global = true;
         this.gp_y.global = true;
         this.gp_b.global = true;
         this.cmd_b.global = true;
         this.gp_a.scale = 1.5;
         this.gp_b.scale = 1.5;
         this.gp_r1.scale = 1.5;
         this.gp_l1.scale = 1.5;
         this.gp_y.scale = 1.5;
      }
      
      public function init(param1:IGuiContext) : void
      {
         super.initGuiBase(param1);
         registerScalableTextfield(getChildByName("$mkt_renown_pfx") as TextField);
         registerScalableTextfield(getChildByName("$mkt_supplies_pfx") as TextField);
         registerScalableTextfield(getChildByName("$mkt_days_worth_pfx") as TextField);
         registerScalableTextfield(getChildByName("$mkt_total_available_pfx") as TextField);
         registerScalableTextfield(getChildByName("$mkt_1_renown_gets_pfx") as TextField);
         this._textSuppliesAvailable = getChildByName("textSuppliesAvailable") as TextField;
         this._textSuppliesPerRenown = getChildByName("textSuppliesPerRenown") as TextField;
         this._textTotalRenown = getChildByName("textTotalRenown") as TextField;
         this._textTotalSupplies = getChildByName("textTotalSupplies") as TextField;
         this._textTotalDays = getChildByName("textTotalDays") as TextField;
         this._textSuppliesAdd = getChildByName("textSuppliesAdd") as TextField;
         this._button_confirm = getChildByName("button_confirm") as ButtonWithIndex;
         this._button_plus = getChildByName("button_plus") as ButtonWithIndex;
         this._button_minus = getChildByName("button_minus") as ButtonWithIndex;
         this._button_close = getChildByName("button_close") as ButtonWithIndex;
         this._item_tabs = getChildByName("item_tabs") as GuiSagaMarketTabItems;
         this._$items = getChildByName("$items") as TextField;
         this.onOperationModeChange(null);
         this._item_tabs.init(param1,this);
         this._button_confirm.guiButtonContext = param1;
         this._button_plus.guiButtonContext = param1;
         this._button_minus.guiButtonContext = param1;
         this._button_confirm.setDownFunction(this.buttonConfirmHandler);
         this._button_plus.setDownFunction(this.buttonPlusHandler);
         this._button_minus.setDownFunction(this.buttonMinusHandler);
         this._button_close.setDownFunction(this.buttonCloseHandler);
         this._button_close_can_show = PlatformInput.hasClicker;
         this._button_close.visible = this._button_close_can_show;
      }
      
      public function cleanup() : void
      {
         this.visible = false;
         GuiGp.releasePrimaryBitmap(this.gp_a);
         GuiGp.releasePrimaryBitmap(this.gp_b);
         GuiGp.releasePrimaryBitmap(this.gp_l1);
         GuiGp.releasePrimaryBitmap(this.gp_r1);
         GuiGp.releasePrimaryBitmap(this.gp_y);
         GpBinder.gpbinder.unbind(this.cmd_a);
         GpBinder.gpbinder.unbind(this.cmd_b);
         GpBinder.gpbinder.unbind(this.cmd_l1);
         GpBinder.gpbinder.unbind(this.cmd_r1);
         GpBinder.gpbinder.unbind(this.cmd_y);
         this.cmd_a.cleanup();
         this.cmd_b.cleanup();
         this.cmd_l1.cleanup();
         this.cmd_r1.cleanup();
         this.cmd_y.cleanup();
         this._item_tabs.cleanup();
         this._button_close.cleanup();
         this._button_confirm.cleanup();
         this._button_plus.cleanup();
         this._button_minus.cleanup();
         this._saga = null;
         super.cleanupGuiBase();
      }
      
      public function showMarket() : void
      {
         if(!this._saga || !this._saga.market)
         {
            return;
         }
         _context.removeAllTooltips();
         this.tutorial_market_purchase_supplies_enabled = this.saga.getVarBool("tutorial_market_purchase_supplies_enabled");
         if(this.tutorial_market_purchase_supplies_enabled)
         {
            this._button_close.enabled = this._button_close.visible = false;
            this._item_tabs.mouseChildren = this._item_tabs.mouseEnabled = false;
         }
         else
         {
            this._item_tabs.mouseChildren = this._item_tabs.mouseEnabled = true;
         }
         this.spendRenown = 0;
         this.perRenown = this._saga.market.suppliesPerRenown;
         this._item_tabs.update();
         this.updateGui();
         this.gplayer = GpBinder.gpbinder.createLayer("GuiSagaMarket");
         GpBinder.gpbinder.bindPress(GpControlButton.B,this.cmd_b);
         GpBinder.gpbinder.bindPress(GpControlButton.A,this.cmd_a);
         GpBinder.gpbinder.bindPress(GpControlButton.Y,this.cmd_y);
         GpBinder.gpbinder.bind(GpControlButton.L1,this.cmd_l1);
         GpBinder.gpbinder.bind(GpControlButton.R1,this.cmd_r1);
         this.gp_a.gplayer = this.gplayer;
         this.gp_b.gplayer = this.gplayer;
         this.gp_l1.gplayer = this.gplayer;
         this.gp_r1.gplayer = this.gplayer;
         this.gp_y.gplayer = this.gplayer;
         if(Boolean(this._button_close) && this._button_close.visible)
         {
            GuiGp.placeIconRight(this._button_close,this.gp_b);
         }
         GuiGp.placeIconTop(this._button_plus,this.gp_r1);
         GuiGp.placeIconTop(this._button_minus,this.gp_l1);
         GuiGp.placeIconTop(this._$items,this.gp_y);
         GuiGp.placeIconTop(this._button_confirm,this.gp_a);
         this.gp_y.visible = this._item_tabs.tabs.length != 0;
         _context.addEventListener(GuiContextEvent.LOCALE,this.localeHandler);
         this.localeHandler(null);
         if(this.tutorial_market_purchase_supplies_enabled)
         {
            this._button_plus.enabled = false;
            this._button_minus.enabled = false;
            this.gp_r1.visible = false;
            this.gp_l1.visible = false;
            this.gp_y.visible = false;
            this.showTutorial_0();
         }
      }
      
      private function showTutorial_0() : void
      {
         var _loc1_:String = _context.translateCategory("tut_s2_market_0",LocaleCategory.TUTORIAL);
         _loc1_ = _context.saga.performStringReplacement_SagaVar(_loc1_);
         _context.createTutorialPopup(this._textSuppliesPerRenown,_loc1_,TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.BOTTOM,true,true,this.showTutorial_1);
      }
      
      private function showTutorial_1(param1:int) : void
      {
         var _loc2_:String = _context.translateCategory("tut_s2_market_1",LocaleCategory.TUTORIAL);
         _loc2_ = _context.saga.performStringReplacement_SagaVar(_loc2_);
         _context.createTutorialPopup(this._textTotalDays,_loc2_,TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.BOTTOM,true,true,this.showTutorial_2);
      }
      
      private function showTutorial_2(param1:int) : void
      {
         this.tutorial_3_wait = false;
         this.tutorial_2_wait = true;
         this._button_confirm.enabled = this._button_confirm.visible = false;
         _context.removeAllTooltips();
         this._button_plus.enabled = true;
         this._button_minus.enabled = true;
         this.gp_r1.visible = true;
         this.gp_l1.visible = true;
         var _loc2_:String = _context.translateCategory("tut_s2_market_2",LocaleCategory.TUTORIAL);
         _context.createTutorialPopup(this._button_plus,_loc2_,TutorialTooltipAlign.TOP,TutorialTooltipAnchor.TOP,true,false,null);
      }
      
      private function showTutorial_3(param1:int) : void
      {
         this.tutorial_2_wait = false;
         this.tutorial_3_wait = true;
         this._button_confirm.enabled = this._button_confirm.visible = true;
         _context.removeAllTooltips();
         var _loc2_:String = _context.translateCategory("tut_s2_market_3",LocaleCategory.TUTORIAL);
         _context.createTutorialPopup(this._button_confirm,_loc2_,TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.BOTTOM,true,false,null);
      }
      
      private function showTutorial_4(param1:int) : void
      {
         this.tutorial_2_wait = false;
         this.tutorial_3_wait = false;
         this.tutorial_4_wait = true;
         this.gp_y.visible = false;
         this._item_tabs.mouseChildren = this._item_tabs.mouseEnabled = true;
         var _loc2_:String = _context.translateCategory("tut_s2_market_4",LocaleCategory.TUTORIAL);
         _context.createTutorialPopup(this._item_tabs,_loc2_,TutorialTooltipAlign.TOP,TutorialTooltipAnchor.TOP,true,true,this.showTutorial_5);
      }
      
      private function showTutorial_5(param1:int) : void
      {
         this.tutorial_4_wait = false;
         this.saga.setVar("tutorial_market_purchase_supplies_enabled",0);
         this._button_close.enabled = true;
         this._button_close.visible = this._button_close_can_show;
         var _loc2_:String = _context.translateCategory("tut_s2_market_5",LocaleCategory.TUTORIAL);
         _context.createTutorialPopup(this._button_close,_loc2_,TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.BOTTOM,true,true,null);
      }
      
      override public function set visible(param1:Boolean) : void
      {
         super.visible = param1;
         if(param1)
         {
            PlatformInput.dispatcher.addEventListener(PlatformInput.EVENT_LAST_INPUT,this.onOperationModeChange);
            this.onOperationModeChange(null);
         }
         else
         {
            PlatformInput.dispatcher.removeEventListener(PlatformInput.EVENT_LAST_INPUT,this.onOperationModeChange);
            this.deactivateNav();
            if(this.gplayer)
            {
               GpBinder.gpbinder.removeLayer(this.gplayer);
               this.gplayer = 0;
            }
            _context.removeEventListener(GuiContextEvent.LOCALE,this.localeHandler);
            GpBinder.gpbinder.unbind(this.cmd_a);
            GpBinder.gpbinder.unbind(this.cmd_b);
            GpBinder.gpbinder.unbind(this.cmd_l1);
            GpBinder.gpbinder.unbind(this.cmd_r1);
            GpBinder.gpbinder.unbind(this.cmd_y);
         }
      }
      
      private function localeHandler(param1:GuiContextEvent) : void
      {
         _context.translateDisplayObjects(LocaleCategory.GUI,this);
         scaleTextfields();
         this._item_tabs.updateDisplayText();
      }
      
      private function buttonCloseHandler(param1:ButtonWithIndex) : void
      {
         dispatchEvent(new Event(Event.CLOSE));
      }
      
      private function buttonConfirmHandler(param1:ButtonWithIndex) : void
      {
         if(this.spendRenown <= 0)
         {
            return;
         }
         this.sagaRenown -= this.spendRenown;
         this.sagaSupplies += this.gainSupplies;
         this._saga.market.availableSupplies -= this.gainSupplies;
         this.setupAvailableSupplies();
         if(this._saga.caravan)
         {
            this._saga.caravan.vars.incrementVar("tot_renown_supplies",this.spendRenown);
         }
         this.spendRenown = 0;
         context.playSound("ui_stats_glisten");
         Ga.normal("market","supplies","",this.gainSupplies);
         if(this.tutorial_market_purchase_supplies_enabled)
         {
            if(this.tutorial_3_wait)
            {
               this.showTutorial_4(0);
            }
         }
         this.updateGui();
      }
      
      public function handleItemPurchase(param1:ItemDef) : void
      {
         Ga.normal("market","item",param1.id,param1.rank);
         if(this._saga.caravan)
         {
            this._saga.caravan.vars.incrementVar("tot_renown_items",param1.price);
            this._saga.caravan.vars.incrementVar("tot_items_purchased",1);
         }
         this.sagaRenown -= param1.price;
         this._saga.gainItemDef(param1);
         this._saga.market.removeItemDef(param1);
         this.recheckRenown();
         this.updateGui();
         this._item_tabs.update();
         if(this.nav)
         {
            if(this._item_tabs.tabs.length)
            {
               this.nav.autoSelect();
            }
            else
            {
               this.deactivateNav();
            }
         }
      }
      
      public function recheckRenown() : void
      {
         if(this.spendRenown > this.sagaRenown)
         {
            this.spendRenown = this.sagaRenown;
            this.updateGui();
         }
      }
      
      private function buttonPlusHandler(param1:ButtonWithIndex) : void
      {
         if(this.spendRenown >= this.sagaRenown)
         {
            context.playSound("ui_error");
            return;
         }
         if(this.gainSupplies >= this._availableSupplies)
         {
            context.playSound("ui_error");
            return;
         }
         ++this.spendRenown;
         this.updateGui();
      }
      
      private function buttonMinusHandler(param1:ButtonWithIndex) : void
      {
         if(this.spendRenown <= 0)
         {
            context.playSound("ui_error");
            return;
         }
         --this.spendRenown;
         this.updateGui();
      }
      
      public function get sagaRenown() : int
      {
         var _loc1_:IVariable = this._saga.getVar(SagaVar.VAR_RENOWN,VariableType.INTEGER);
         return !!_loc1_ ? _loc1_.asInteger : 0;
      }
      
      public function set sagaRenown(param1:int) : void
      {
         this.ignoreVarChange = true;
         this._saga.suppressVariableFlytext = true;
         this._saga.setVar(SagaVar.VAR_RENOWN,param1);
         this._saga.suppressVariableFlytext = false;
         this.ignoreVarChange = false;
      }
      
      private function get sagaSupplies() : int
      {
         var _loc1_:IVariable = this._saga.getVar(SagaVar.VAR_SUPPLIES,VariableType.INTEGER);
         return !!_loc1_ ? _loc1_.asInteger : 0;
      }
      
      private function get sagaSupplyBurn() : int
      {
         var _loc1_:IVariable = this._saga.getVar(SagaVar.VAR_SUPPLY_BURN,VariableType.INTEGER);
         return !!_loc1_ ? _loc1_.asInteger : 0;
      }
      
      private function set sagaSupplies(param1:int) : void
      {
         this.ignoreVarChange = true;
         this._saga.suppressVariableFlytext = true;
         this._saga.setVar(SagaVar.VAR_SUPPLIES,param1);
         this._saga.suppressVariableFlytext = false;
         this.ignoreVarChange = false;
      }
      
      private function setupAvailableSupplies() : void
      {
         this._availableSupplies = this._saga.market.availableSupplies;
         var _loc1_:int = this._availableSupplies / this.perRenown;
         this._availableSupplies = this.perRenown * _loc1_;
      }
      
      public function update(param1:int) : void
      {
         var _loc3_:Number = NaN;
         if(!visible)
         {
            return;
         }
         if(this._pressed_l1 == this._pressed_r1)
         {
            return;
         }
         this._pressedElapsed += param1;
         var _loc2_:int = 0;
         if(this._pressedCount == 0)
         {
            _loc2_ = 500;
         }
         else
         {
            _loc3_ = Math.min(1,this._pressedCount / 20);
            _loc2_ = MathUtil.lerp(500,50,_loc3_);
         }
         if(this._pressedElapsed < _loc2_)
         {
            return;
         }
         this._pressedElapsed = 0;
         ++this._pressedCount;
         if(this._pressed_l1)
         {
            this._button_minus.press();
            this.gp_l1.pulse();
         }
         else if(this._pressed_r1)
         {
            this._button_plus.press();
            this.gp_r1.pulse();
         }
      }
      
      private function updateGui() : void
      {
         var _loc5_:int = 0;
         this.gainSupplies = this.spendRenown * this.perRenown;
         this._button_confirm.enabled = this._button_confirm.visible = this.spendRenown > 0;
         this.setupAvailableSupplies();
         this._button_plus.enabled = this.gainSupplies < this._availableSupplies;
         this._button_minus.enabled = this.gainSupplies > 0;
         this._textSuppliesAvailable.text = this._availableSupplies.toString();
         this._textSuppliesPerRenown.text = this.perRenown.toString();
         this._textSuppliesAdd.text = this.gainSupplies.toString();
         var _loc1_:int = this.sagaRenown;
         _loc1_ -= this.spendRenown;
         this._textTotalRenown.text = _loc1_.toString();
         var _loc2_:int = this.sagaSupplies;
         _loc2_ += this.gainSupplies;
         this._textTotalSupplies.text = _loc2_.toString();
         var _loc3_:int = this.sagaSupplyBurn;
         var _loc4_:int = 0;
         if(_loc3_)
         {
            _loc4_ = Math.round(_loc2_ / -_loc3_);
         }
         this._textTotalDays.text = _loc4_.toString();
         if(this.tutorial_market_purchase_supplies_enabled)
         {
            _loc5_ = 15;
            if(this.tutorial_2_wait)
            {
               if(this.gainSupplies >= _loc5_)
               {
                  this._button_confirm.enabled = this._button_confirm.visible = true;
                  this.showTutorial_3(0);
               }
               else
               {
                  this._button_confirm.enabled = this._button_confirm.visible = false;
               }
            }
            else if(this.tutorial_3_wait)
            {
               if(this.gainSupplies < _loc5_)
               {
                  this._button_confirm.enabled = this._button_confirm.visible = false;
                  this.showTutorial_2(0);
               }
               else
               {
                  this._button_confirm.enabled = this._button_confirm.visible = true;
               }
            }
         }
         this.gp_a.visible = this._button_confirm.visible;
      }
      
      public function set saga(param1:Saga) : void
      {
         this._saga = param1;
      }
      
      public function get saga() : Saga
      {
         return this._saga;
      }
      
      private function cmdfunc_b(param1:CmdExec) : void
      {
         if(this.nav)
         {
            this.deactivateNav();
         }
         else if(this._button_close)
         {
            this._button_close.press();
         }
      }
      
      private function cmdfunc_a(param1:CmdExec) : void
      {
         if(this._button_confirm)
         {
            this._button_confirm.press();
         }
         else
         {
            context.playSound("ui_error");
         }
      }
      
      private function cmdfunc_l1(param1:CmdExec) : void
      {
         var _loc2_:Number = param1.param;
         if(_loc2_ == 1)
         {
            this._button_minus.press();
            this.gp_l1.pulse();
            this._pressed_l1 = true;
            this._pressedElapsed = 0;
            this._pressedCount = 0;
         }
         else if(_loc2_ == 0)
         {
            this._pressed_l1 = false;
         }
      }
      
      private function cmdfunc_r1(param1:CmdExec) : void
      {
         var _loc2_:Number = param1.param;
         if(_loc2_ == 1)
         {
            this._button_plus.press();
            this.gp_r1.pulse();
            this._pressed_r1 = true;
            this._pressedElapsed = 0;
            this._pressedCount = 0;
         }
         else if(_loc2_ == 0)
         {
            this._pressed_r1 = false;
         }
      }
      
      private function cmdfunc_y(param1:CmdExec) : void
      {
         if(!this._item_tabs.mouseEnabled)
         {
            return;
         }
         if(!this.nav)
         {
            if(this._item_tabs.tabs.length)
            {
               this.activateNav();
            }
            else
            {
               context.playSound("ui_error");
            }
         }
         else
         {
            this.deactivateNav();
         }
      }
      
      private function activateNav() : void
      {
         var _loc1_:GuiSagaMarketTabItem = null;
         if(this.nav)
         {
            return;
         }
         context.playSound("ui_travel_press");
         this.nav_gplayer = GpBinder.gpbinder.createLayer("GuiSagaMarket nav");
         this.nav = new GuiGpNav(context,"market",this);
         this.nav.setAlignNavDefault(GuiGpAlignH.W,GuiGpAlignV.S_UP);
         this.nav.setAlignControlDefault(GuiGpAlignH.E,GuiGpAlignV.S_UP);
         this.nav.scale = 1.5;
         for each(_loc1_ in this._item_tabs.tabs)
         {
            if(_loc1_.visible)
            {
               this.nav.add(_loc1_);
            }
         }
         this.nav.autoSelect();
         this.nav.activate();
      }
      
      private function deactivateNav() : void
      {
         context.playSound("ui_generic");
         if(this.nav)
         {
            this.nav.deactivate();
            this.nav.cleanup();
            this.nav = null;
         }
         if(this.nav_gplayer)
         {
            GpBinder.gpbinder.removeLayer(this.nav_gplayer);
            this.nav_gplayer = 0;
         }
         this.gp_y.visible = this._item_tabs.tabs.length != 0;
      }
      
      public function onClickedItem(param1:ItemDef) : void
      {
      }
      
      private function onOperationModeChange(param1:Event) : void
      {
         this._button_close.visible = PlatformInput.hasClicker || !PlatformInput.lastInputGp;
      }
   }
}

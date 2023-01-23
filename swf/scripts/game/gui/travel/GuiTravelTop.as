package game.gui.travel
{
   import com.stoicstudio.platform.PlatformInput;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.core.locale.Locale;
   import engine.gui.GuiContextEvent;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpBitmap;
   import engine.gui.IGuiButton;
   import engine.gui.core.ResizableTextField;
   import engine.saga.SagaEvent;
   import engine.saga.SagaVar;
   import engine.saga.vars.IVariable;
   import engine.saga.vars.IVariableBag;
   import engine.saga.vars.Variable;
   import engine.saga.vars.VariableEvent;
   import engine.saga.vars.VariableType;
   import flash.events.Event;
   import flash.text.TextField;
   import game.gui.ButtonWithIndex;
   
   public class GuiTravelTop extends GuiBaseTravelTop
   {
       
      
      public var _button$camp:ButtonWithIndex;
      
      public var _button_travel:ButtonWithIndex;
      
      public var _textNumPeasants:TextField;
      
      public var _textNumFighters:TextField;
      
      public var _textNumVarl:TextField;
      
      public var _banner_supplies:GuiTravelBanner;
      
      public var _button$map:ButtonWithIndex;
      
      public var _$clansmen_label:ResizableTextField;
      
      public var _$fighters_label:ResizableTextField;
      
      public var _$varl_label:ResizableTextField;
      
      private var gp_y:GuiGpBitmap;
      
      private var gp_x:GuiGpBitmap;
      
      private var gp_a:GuiGpBitmap;
      
      private var cmd_a:Cmd;
      
      private var cmd_x:Cmd;
      
      public function GuiTravelTop()
      {
         this.gp_y = GuiGp.ctorPrimaryBitmap(GpControlButton.Y,true);
         this.gp_x = GuiGp.ctorPrimaryBitmap(GpControlButton.X,true);
         this.gp_a = GuiGp.ctorPrimaryBitmap(GpControlButton.A,true);
         this.cmd_a = new Cmd("cmd_travel_top_a",this.func_cmd_travel_top_a);
         this.cmd_x = new Cmd("cmd_travel_top_x",this.func_cmd_travel_top_x);
         super();
         name = "GuiTravelTop";
         this.stop();
         this._$clansmen_label = ResizableTextField.ctor(getChildByName("$clansmen_label") as TextField);
         this._$fighters_label = ResizableTextField.ctor(getChildByName("$fighters_label") as TextField);
         this._$varl_label = ResizableTextField.ctor(getChildByName("$varl_label") as TextField);
         addChild(this.gp_y);
         addChild(this.gp_a);
         addChild(this.gp_x);
         this.gp_a.scale = this.gp_x.scale = this.gp_y.scale = gp_start.scale = 0.75;
         this.checkButtonsVisible();
         this._button$camp = requireGuiChild("button$camp") as ButtonWithIndex;
         this._button_travel = requireGuiChild("button_travel") as ButtonWithIndex;
         this._textNumPeasants = getChildByName("textNumPeasants") as TextField;
         this._textNumFighters = getChildByName("textNumFighters") as TextField;
         this._textNumVarl = getChildByName("textNumVarl") as TextField;
         this._banner_supplies = getChildByName("banner_supplies") as GuiTravelBanner;
         this._button$map = requireGuiChild("button$map") as ButtonWithIndex;
      }
      
      override protected function handleInit() : void
      {
         if(this._banner_supplies)
         {
            this._banner_supplies.init(this,_caravanVars,SagaVar.VAR_SUPPLY_DAYS);
         }
         this._button$camp.guiButtonContext = context;
         this._button_travel.guiButtonContext = context;
         this._button_travel.visible = false;
         this._button$camp.clickSound = "ui_map_open";
         this._button_travel.clickSound = "ui_travel_press";
         this._button$camp.setDownFunction(this.campButtonHandler);
         this._button_travel.setDownFunction(this.travelButtonHandler);
         this._button$map.setDownFunction(this.buttonMapHandler);
         this._button$map.guiButtonContext = context;
         this._button$map.clickSound = "ui_stats_lo";
         this.gp_y.gplayer = GpBinder.gpbinder.lastCmdId;
         this.gp_a.createCaption(context,GuiGpBitmap.CAPTION_RIGHT).setToken("travel_top_camp");
         this.gp_x.createCaption(context,GuiGpBitmap.CAPTION_RIGHT).setToken("travel_top_map");
         this.resizeLabels();
         update();
      }
      
      override protected function addSagaDispatcherListeners() : void
      {
         if(_sagaDispatcher)
         {
            _sagaDispatcher.addEventListener(SagaEvent.EVENT_CLEANUP,this.sagaCleanupHandler);
            _sagaDispatcher.addEventListener(SagaEvent.EVENT_HALT,this.haltHandler);
            _sagaDispatcher.addEventListener(SagaEvent.EVENT_HALTING,this.haltHandler);
            _sagaDispatcher.addEventListener(SagaEvent.EVENT_CAMP,this.campHandler);
            _sagaDispatcher.addEventListener(SagaEvent.EVENT_RESTING,this.restingHandler);
         }
      }
      
      override protected function removeSagaDispatcherListeners() : void
      {
         if(_sagaDispatcher)
         {
            _sagaDispatcher.removeEventListener(SagaEvent.EVENT_CLEANUP,this.sagaCleanupHandler);
            _sagaDispatcher.removeEventListener(SagaEvent.EVENT_HALT,this.haltHandler);
            _sagaDispatcher.removeEventListener(SagaEvent.EVENT_HALTING,this.haltHandler);
            _sagaDispatcher.removeEventListener(SagaEvent.EVENT_CAMP,this.campHandler);
            _sagaDispatcher.removeEventListener(SagaEvent.EVENT_RESTING,this.restingHandler);
         }
      }
      
      override protected function handleLocaleHandler(param1:GuiContextEvent) : void
      {
         this.resizeLabels();
         if(_banner_renown)
         {
            _banner_renown.handleLocaleChange();
         }
         if(this._banner_supplies)
         {
            this._banner_supplies.handleLocaleChange();
         }
      }
      
      protected function resizeLabels() : void
      {
         var _loc1_:Locale = _context.locale;
         if(this._$clansmen_label)
         {
            this._$clansmen_label.scaleToFit(_loc1_);
         }
         if(this._$fighters_label)
         {
            this._$fighters_label.scaleToFit(_loc1_);
         }
         if(this._$varl_label)
         {
            this._$varl_label.scaleToFit(_loc1_);
         }
         _context.locale.fixTextFieldFormat(_tooltip$days);
         super.scaleTextfields();
      }
      
      private function buttonMapHandler(param1:Object) : void
      {
         listener.guiTravelMap();
      }
      
      private function updateNumberText(param1:TextField, param2:IVariableBag, param3:String) : void
      {
         if(!param1)
         {
            return;
         }
         var _loc4_:IVariable = param2.fetch(param3,null);
         if(_loc4_)
         {
            if(_loc4_.def.type == VariableType.DECIMAL)
            {
               param1.text = _loc4_.asNumber.toFixed(2);
            }
            else
            {
               param1.text = !!_loc4_.value ? _loc4_.value : "";
            }
         }
         else
         {
            param1.text = "";
         }
      }
      
      private function updateNumberTextEvent(param1:TextField, param2:IVariableBag, param3:String, param4:VariableEvent) : void
      {
         if(!param1)
         {
            return;
         }
         var _loc5_:Variable = !!param4 ? param4.value : null;
         if(!_loc5_ || param4.value.def.name == param3)
         {
            this.updateNumberText(param1,param2,param3);
         }
      }
      
      override protected function caravanVarHandler(param1:VariableEvent) : void
      {
         if(!_sagaDispatcher || !_caravanVars)
         {
            return;
         }
         if(this._textNumFighters)
         {
            this.updateNumberTextEvent(this._textNumFighters,_caravanVars,SagaVar.VAR_NUM_FIGHTERS,param1);
         }
         if(this._textNumPeasants)
         {
            this.updateNumberTextEvent(this._textNumPeasants,_caravanVars,SagaVar.VAR_NUM_PEASANTS,param1);
         }
         if(this._textNumVarl)
         {
            this.updateNumberTextEvent(this._textNumVarl,_caravanVars,SagaVar.VAR_NUM_VARL,param1);
         }
      }
      
      private function sagaCleanupHandler(param1:Event) : void
      {
         sagaDispatcher = null;
         globalVars = null;
      }
      
      override protected function handleCleanup() : void
      {
         GuiGp.releasePrimaryBitmap(this.gp_y);
         GuiGp.releasePrimaryBitmap(this.gp_x);
         GuiGp.releasePrimaryBitmap(this.gp_a);
         this.gp_y = null;
         this.gp_x = null;
         this.gp_a = null;
         GpBinder.gpbinder.unbind(this.cmd_a);
         GpBinder.gpbinder.unbind(this.cmd_x);
         this.cmd_a.cleanup();
         this.cmd_a = null;
         this.cmd_x.cleanup();
         this.cmd_x = null;
         this._button$camp.cleanup();
         this._button$camp = null;
         this._button_travel.cleanup();
         this._button_travel = null;
         this._button$map.cleanup();
         this._button$map = null;
         if(this._banner_supplies)
         {
            this._banner_supplies.cleanup();
            this._banner_supplies = null;
         }
      }
      
      private function campButtonHandler(param1:IGuiButton) : void
      {
         listener.guiTravelCamp();
      }
      
      private function travelButtonHandler(param1:IGuiButton) : void
      {
         listener.guiTravelDecamp();
      }
      
      private function campHandler(param1:Event) : void
      {
         update();
      }
      
      private function haltHandler(param1:Event) : void
      {
         update();
      }
      
      private function restingHandler(param1:Event) : void
      {
         update();
      }
      
      override protected function handleUpdate() : void
      {
         this._button_travel.visible = false;
         this._button$camp.visible = _campEnabled && !_saga.camped && !_saga.haltToCamp && !_saga.resting;
         this._button$map.visible = _mapEnabled;
      }
      
      override protected function handleActivatedGp() : void
      {
         if(this._banner_supplies)
         {
            this._banner_supplies.setHovering(true);
         }
         GpBinder.gpbinder.bindPress(GpControlButton.A,this.cmd_a);
         GpBinder.gpbinder.bindPress(GpControlButton.X,this.cmd_x);
      }
      
      override public function handleDeactivateGp() : void
      {
         this.gp_y.pulse();
         this.gp_a.visible = this.gp_x.visible = gp_start.visible = false;
         if(this._banner_supplies)
         {
            this._banner_supplies.setHovering(false);
         }
         GpBinder.gpbinder.unbind(this.cmd_a);
         GpBinder.gpbinder.unbind(this.cmd_x);
      }
      
      override protected function checkButtonsVisible() : void
      {
         this.gp_a.gplayer = this.gp_x.gplayer = gp_start.gplayer = this.gp_y.gplayer = GpBinder.gpbinder.lastCmdId;
         this.gp_y.visible = true;
         var _loc1_:Boolean = _activatedGp && (_extended || _animating);
         this.gp_a.visible = _loc1_ && this._button$camp.visible;
         this.gp_x.visible = _loc1_ && this._button$map.visible;
         gp_start.visible = _loc1_ && PlatformInput.hasClicker;
      }
      
      override protected function handleResizeHandler() : void
      {
         if(_extended || _animating)
         {
            if(this._$fighters_label)
            {
               this.gp_y.x = this._$fighters_label.x - this.gp_y.width;
               this.gp_y.y = this._$fighters_label.y;
            }
            else if(_button_morale)
            {
               this.gp_y.x = _button_morale.x - this.gp_y.width / 1.25;
               this.gp_y.y = _button_morale.y + _button_morale.height / 3.5;
            }
         }
         else
         {
            this.gp_y.y = -this.y + 10;
            this.gp_y.x = -this.gp_y.width * 2;
         }
         if(!_activatedGp)
         {
            return;
         }
         this.gp_x.x = this._button$map.x + 60;
         this.gp_x.y = this._button$map.y + 20;
         this.gp_a.x = this._button$camp.x + 60;
         this.gp_a.y = this._button$camp.y + 20;
         this.gp_a.updateCaptionPlacement();
         this.gp_x.updateCaptionPlacement();
      }
      
      private function func_cmd_travel_top_a(param1:CmdExec) : void
      {
         if(this._button$camp.visible)
         {
            this.gp_a.pulse();
            this._button$camp.press();
         }
      }
      
      private function func_cmd_travel_top_x(param1:CmdExec) : void
      {
         if(this._button$map.visible)
         {
            this.gp_x.pulse();
            this._button$map.press();
         }
      }
   }
}

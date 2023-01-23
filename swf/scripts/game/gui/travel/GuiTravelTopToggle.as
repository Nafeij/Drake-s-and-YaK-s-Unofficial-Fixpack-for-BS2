package game.gui.travel
{
   import com.greensock.TweenMax;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpBitmap;
   import engine.saga.ISaga;
   import engine.saga.SagaEvent;
   import flash.events.Event;
   import game.gui.ButtonWithIndex;
   import game.gui.GuiBase;
   import game.gui.IGuiContext;
   
   public class GuiTravelTopToggle extends GuiBase implements IGuiTravelTopToggle
   {
       
      
      public var _button:ButtonWithIndex;
      
      public var travel:IGuiTravelTop;
      
      private var saga:ISaga;
      
      private var gp_d_up:GuiGpBitmap;
      
      private var cmd_d_up:Cmd;
      
      private var _guiEnabled:Boolean;
      
      public function GuiTravelTopToggle()
      {
         this.gp_d_up = GuiGp.ctorPrimaryBitmap(GpControlButton.D_U,true);
         this.cmd_d_up = new Cmd("cmd_travel_d_up",this.func_cmd_d_up);
         super();
         name = "GuiTravelTopToggle";
         this.gp_d_up.scale = 0.75;
         addChild(this.gp_d_up);
         this.gp_d_up.visible = false;
      }
      
      public function init(param1:IGuiContext, param2:IGuiTravelTop, param3:ISaga) : void
      {
         super.initGuiBase(param1);
         this.travel = param2;
         if(!param2)
         {
            throw new ArgumentError("no travel");
         }
         this._button = requireGuiChild("button") as ButtonWithIndex;
         this._button.guiButtonContext = param1;
         this._button.setDownFunction(this.buttonHandler);
         this.saga = param3;
         if(!param3)
         {
            throw new ArgumentError("no saga");
         }
         param3.addEventListener(SagaEvent.EVENT_HALT,this.sagaHandler);
         param3.addEventListener(SagaEvent.EVENT_HALTING,this.sagaHandler);
         param3.addEventListener(SagaEvent.EVENT_CAMP,this.sagaHandler);
         this.gp_d_up.createCaption(param1,GuiGpBitmap.CAPTION_RIGHT).setToken("travel_top_toggle");
         this.update();
      }
      
      override public function set visible(param1:Boolean) : void
      {
         if(super.visible != param1)
         {
            param1 = param1;
         }
         super.visible = param1;
      }
      
      public function cleanup() : void
      {
         GpBinder.gpbinder.unbind(this.cmd_d_up);
         GuiGp.releasePrimaryBitmap(this.gp_d_up);
         if(this.saga)
         {
            this.saga.removeEventListener(SagaEvent.EVENT_HALT,this.sagaHandler);
            this.saga.removeEventListener(SagaEvent.EVENT_HALTING,this.sagaHandler);
            this.saga.removeEventListener(SagaEvent.EVENT_CAMP,this.sagaHandler);
            this.saga = null;
         }
         this.travel = null;
         cleanupGuiBase();
      }
      
      private function sagaHandler(param1:Event) : void
      {
         this.update();
      }
      
      private function buttonHandler(param1:ButtonWithIndex) : void
      {
         if(this.travel.animating)
         {
            return;
         }
         this.travel.extended = !this.travel.extended;
         TweenMax.killTweensOf(this._button);
         if(this.travel.extended)
         {
            TweenMax.to(this._button,GuiBaseTravelTop.ANIMATE_TIME,{"rotation":0});
         }
         else
         {
            TweenMax.to(this._button,GuiBaseTravelTop.ANIMATE_TIME,{"rotation":180});
         }
      }
      
      private function update() : void
      {
         if(!this.saga)
         {
            return;
         }
         this.visible = this._guiEnabled && !this.saga.hudTravelHidden && (this.saga.camped || !this.saga.halting);
         this.mouseEnabled = this.visible;
         this.mouseChildren = this.visible;
      }
      
      public function set guiEnabled(param1:Boolean) : void
      {
         this._guiEnabled = param1;
         this.update();
      }
      
      private function func_cmd_d_up(param1:CmdExec) : void
      {
         this._button.press();
         this.gp_d_up.pulse();
      }
      
      public function resizeHandler() : void
      {
         this.gp_d_up.x = this._button.x - this.gp_d_up.width / 2;
         this.gp_d_up.y = this._button.y - this.gp_d_up.height / 2;
         this.gp_d_up.updateCaptionPlacement();
      }
      
      public function activateGp() : void
      {
         this.deactivateGp();
         GpBinder.gpbinder.bindPress(GpControlButton.D_U,this.cmd_d_up);
         this.gp_d_up.gplayer = GpBinder.gpbinder.lastCmdId;
         this.gp_d_up.visible = true;
         this.resizeHandler();
      }
      
      public function deactivateGp() : void
      {
         GpBinder.gpbinder.unbind(this.cmd_d_up);
         this.gp_d_up.visible = false;
      }
   }
}

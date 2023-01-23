package game.gui.battle.redeployment
{
   import com.greensock.TweenMax;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpAlignH;
   import engine.gui.GuiGpAlignV;
   import engine.gui.GuiGpBitmap;
   import flash.display.MovieClip;
   import flash.events.Event;
   import game.gui.ButtonWithIndex;
   import game.gui.GuiBase;
   import game.gui.IGuiContext;
   import game.gui.travel.GuiBaseTravelTop;
   
   public class GuiRedeploymentRosterToggle extends GuiBase
   {
       
      
      public var _button:ButtonWithIndex;
      
      private var gp_L1:GuiGpBitmap;
      
      private var cmd_L1:Cmd;
      
      private var _rosterTitle:MovieClip;
      
      private var _rosterGui:GuiRedeploymentRoster;
      
      public function GuiRedeploymentRosterToggle()
      {
         this.gp_L1 = GuiGp.ctorPrimaryBitmap(GpControlButton.L1,true);
         this.cmd_L1 = new Cmd("cmd_reinforce_L1",this.func_cmd_L1);
         super();
      }
      
      public function init(param1:IGuiContext, param2:GuiRedeploymentRoster, param3:MovieClip) : void
      {
         super.initGuiBase(param1);
         this._button = requireGuiChild("button") as ButtonWithIndex;
         this._button.guiButtonContext = param1;
         this._button.setDownFunction(this.buttonHandler);
         this._rosterGui = param2;
         this._rosterGui.addEventListener(GuiRedeploymentRoster.ROSTER_DISPLAY_CHANGED,this.onRosterDisplayChanged);
         this._rosterTitle = param3;
         this.gp_L1.scale = 0.75;
         this._rosterTitle.addChild(this.gp_L1);
         this.gp_L1.visible = false;
      }
      
      override public function set visible(param1:Boolean) : void
      {
         if(param1 == super.visible)
         {
            return;
         }
         super.visible = param1;
         this.mouseEnabled = this.visible;
         this.mouseChildren = this.visible;
      }
      
      override public function get visible() : Boolean
      {
         return super.visible;
      }
      
      public function cleanup() : void
      {
         if(this._rosterGui)
         {
            this._rosterGui.removeEventListener(GuiRedeploymentRoster.ROSTER_DISPLAY_CHANGED,this.onRosterDisplayChanged);
         }
         GpBinder.gpbinder.unbind(this.cmd_L1);
         GuiGp.releasePrimaryBitmap(this.gp_L1);
         cleanupGuiBase();
      }
      
      private function buttonHandler(param1:ButtonWithIndex) : void
      {
         if(this._rosterGui)
         {
            this._rosterGui.toggleRoster();
         }
      }
      
      private function onRosterDisplayChanged(param1:Event) : void
      {
         TweenMax.killTweensOf(this._button);
         if(this._rosterGui.rosterDisplayed)
         {
            TweenMax.to(this._button,GuiBaseTravelTop.ANIMATE_TIME,{"rotation":0});
         }
         else
         {
            TweenMax.to(this._button,GuiBaseTravelTop.ANIMATE_TIME,{"rotation":180});
         }
      }
      
      private function func_cmd_L1(param1:CmdExec) : void
      {
         this._button.press();
         this.gp_L1.pulse();
      }
      
      public function activateGp() : void
      {
         GpBinder.gpbinder.bindPress(GpControlButton.L1,this.cmd_L1);
         this.gp_L1.visible = true;
         GuiGp.placeIcon(this._rosterTitle,null,this.gp_L1,GuiGpAlignH.E,GuiGpAlignV.C_UP);
      }
      
      public function deactivateGp() : void
      {
         GpBinder.gpbinder.unbind(this.cmd_L1);
         this.gp_L1.visible = false;
      }
   }
}

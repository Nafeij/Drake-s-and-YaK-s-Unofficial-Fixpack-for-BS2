package game.gui.battle
{
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpAlignH;
   import engine.gui.GuiGpAlignV;
   import engine.gui.GuiGpBitmap;
   import engine.resource.loader.SoundControllerManager;
   import engine.sound.ISoundDriver;
   import engine.sound.SoundBundleWrapper;
   import flash.text.TextField;
   import game.gui.ButtonWithIndex;
   import game.gui.GuiBase;
   import game.gui.IGuiContext;
   
   public class GuiWaveRedeploymentTop extends GuiBase implements IGuiWaveRedeploymentTop
   {
       
      
      public var _button$wave_fight:ButtonWithIndex;
      
      public var _button$wave_flee:ButtonWithIndex;
      
      private var _text$wave_fight:TextField;
      
      private var _text$wave_flee:TextField;
      
      private var cmd_a:Cmd;
      
      private var cmd_b:Cmd;
      
      private var gp_a:GuiGpBitmap;
      
      private var gp_b:GuiGpBitmap;
      
      public var listener:IGuiBattleHudListener;
      
      private var _soundControllerManager:SoundControllerManager;
      
      private var sbw_appear:SoundBundleWrapper;
      
      public function GuiWaveRedeploymentTop()
      {
         this.cmd_a = new Cmd("cmd_wave_redeployment_top_fight",this.func_cmd_wave_redeployment_fight);
         this.cmd_b = new Cmd("cmd_wave_redeployment_top_flee",this.func_cmd_wave_redeployment_flee);
         this.gp_a = GuiGp.ctorPrimaryBitmap(GpControlButton.A,true);
         this.gp_b = GuiGp.ctorPrimaryBitmap(GpControlButton.B,true);
         super();
         mouseEnabled = false;
         mouseChildren = true;
         this._button$wave_fight = requireGuiChild("button$wave_fight") as ButtonWithIndex;
         this._button$wave_flee = requireGuiChild("button$wave_flee") as ButtonWithIndex;
         this._text$wave_fight = requireGuiChild("text$wave_fight") as TextField;
         this._text$wave_flee = requireGuiChild("text$wave_flee") as TextField;
         this.gp_a.scale = 0.75;
         addChild(this.gp_a);
         this.gp_b.scale = 0.75;
         addChild(this.gp_b);
         this.setGpButtonsVisible(false);
      }
      
      public function init(param1:IGuiContext, param2:IGuiBattleHudListener, param3:ISoundDriver) : void
      {
         super.initGuiBase(param1);
         this.listener = param2;
         this._button$wave_fight.guiButtonContext = param1;
         this._button$wave_flee.guiButtonContext = param1;
         this._button$wave_fight.setDownFunction(this.handleButtonFight);
         this._button$wave_flee.setDownFunction(this.handleButtonFlee);
         this._button$wave_fight.clickSound = null;
         this._button$wave_flee.clickSound = null;
         this._soundControllerManager = new SoundControllerManager("wave_battle_buttons_soundcontroller","saga3/sound/saga3_gui_wave_battle_buttons.sound.json.z",_context.resourceManager,param3,null,_context.logger);
         this.sbw_appear = new SoundBundleWrapper("gwrt_appear","world/saga3_ui/ui_flee_surrender_hud_appears",_context.soundDriver);
         this.handleLocaleChange();
      }
      
      override public function handleLocaleChange() : void
      {
         super.handleLocaleChange();
      }
      
      public function cleanup() : void
      {
         if(this.sbw_appear)
         {
            this.sbw_appear.cleanup();
            this.sbw_appear = null;
         }
         if(this.cmd_a)
         {
            GpBinder.gpbinder.unbind(this.cmd_a);
            this.cmd_a.cleanup();
            this.cmd_a = null;
         }
         if(this.cmd_b)
         {
            GpBinder.gpbinder.unbind(this.cmd_b);
            this.cmd_b.cleanup();
            this.cmd_b = null;
         }
         GuiGp.releasePrimaryBitmap(this.gp_a);
         GuiGp.releasePrimaryBitmap(this.gp_b);
         this._button$wave_fight.cleanup();
         this._button$wave_flee.cleanup();
         this._soundControllerManager.cleanup();
         super.cleanupGuiBase();
      }
      
      public function showRedeploymentTop(param1:Boolean) : void
      {
         if(this.visible == param1)
         {
            return;
         }
         this.visible = param1;
         this.setGpButtonsVisible(param1);
         if(param1)
         {
            this.bindRedeployTopNav();
            this.placeGpButtonIcons();
            if(this.sbw_appear)
            {
               this.sbw_appear.playSound();
            }
         }
         else
         {
            this.unbindRedeployTopNav();
         }
      }
      
      public function setGpButtonsVisible(param1:Boolean) : void
      {
         this.gp_a.visible = param1;
         this.gp_b.visible = param1;
         if(param1)
         {
            this.placeGpButtonIcons();
         }
      }
      
      private function placeGpButtonIcons() : void
      {
         GuiGp.placeIcon(this._button$wave_fight,null,this.gp_a,GuiGpAlignH.E_RIGHT,GuiGpAlignV.S_UP,-3,7);
         GuiGp.placeIcon(this._button$wave_flee,null,this.gp_b,GuiGpAlignH.W_LEFT,GuiGpAlignV.S_UP,3,7);
      }
      
      public function handleButtonFight(param1:*) : void
      {
         logger.info("fight!");
         if(this._soundControllerManager.isLoaded)
         {
            this._soundControllerManager.soundController.playSound("tbs3_ui_battlewaves_fight",null);
         }
         this.unbindRedeployTopNav();
         this.gp_a.pulse();
         this.listener.guiBattleHudWaveFight();
      }
      
      public function handleButtonFlee(param1:*) : void
      {
         logger.info("flee!");
         if(this._soundControllerManager.isLoaded)
         {
            this._soundControllerManager.soundController.playSound("tbs3_ui_battlewaves_retreat",null);
         }
         this.unbindRedeployTopNav();
         this.gp_b.pulse();
         this.listener.guiBattleHudWaveFlee();
      }
      
      private function bindRedeployTopNav() : void
      {
         GpBinder.gpbinder.bindPress(GpControlButton.A,this.cmd_a);
         GpBinder.gpbinder.bindPress(GpControlButton.B,this.cmd_b);
      }
      
      private function unbindRedeployTopNav() : void
      {
         GpBinder.gpbinder.unbind(this.cmd_a);
         GpBinder.gpbinder.unbind(this.cmd_b);
      }
      
      private function func_cmd_wave_redeployment_fight(param1:CmdExec) : void
      {
         this._button$wave_fight.press();
      }
      
      private function func_cmd_wave_redeployment_flee(param1:CmdExec) : void
      {
         this._button$wave_flee.press();
      }
   }
}

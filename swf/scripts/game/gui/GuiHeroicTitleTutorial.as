package game.gui
{
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.gui.GuiContextEvent;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpAlignH;
   import engine.gui.GuiGpAlignV;
   import engine.gui.GuiGpBitmap;
   import flash.display.DisplayObject;
   import flash.text.TextField;
   import game.gui.pages.GuiPgDetails;
   
   public class GuiHeroicTitleTutorial extends GuiBase
   {
      
      private static const HEROIC_TITLE_TUTORIAL_VAR:String = "tutorial_heroic_titles_viewed";
       
      
      private var _details:GuiPgDetails;
      
      public var _buttonTutorial$Continue:ButtonWithIndex;
      
      public var continueButtonCallback:Function;
      
      public var backButtonCallback:Function;
      
      private var _text$heroic_title:TextField;
      
      private var _text$heroic_title_tutorial_flavor:TextField;
      
      private var _text$heroic_title_tutorial_text:TextField;
      
      private var cmd_close:Cmd;
      
      private var cmd_back:Cmd;
      
      private var gp_a:GuiGpBitmap;
      
      private var gplayer:int;
      
      public function GuiHeroicTitleTutorial()
      {
         this.cmd_close = new Cmd("pg_heroictut_continue",this.cmdfunc_continue);
         this.cmd_back = new Cmd("pg_heroictut_continue",this.cmdfunc_back);
         this.gp_a = GuiGp.ctorPrimaryBitmap(GpControlButton.A,true);
         super();
      }
      
      public function init(param1:IGuiContext, param2:GuiPgDetails) : void
      {
         super.initGuiBase(param1);
         this._details = param2;
         this.visible = false;
         this._buttonTutorial$Continue = requireGuiChild("button_tutorial$continue") as ButtonWithIndex;
         this._buttonTutorial$Continue.guiButtonContext = param1;
         this._buttonTutorial$Continue.clickSound = "ui_heroic_title_continue";
         this._buttonTutorial$Continue.setDownFunction(this.onContinue);
         this._text$heroic_title = requireGuiChild("text$heroic_title") as TextField;
         registerScalableTextfieldAlign(this._text$heroic_title);
         this._text$heroic_title_tutorial_flavor = requireGuiChild("text$heroic_title_tutorial_flavor") as TextField;
         registerScalableTextfieldAlign(this._text$heroic_title_tutorial_flavor);
         this._text$heroic_title_tutorial_text = requireGuiChild("text$heroic_title_tutorial_text") as TextField;
         registerScalableTextfieldAlign(this._text$heroic_title_tutorial_text);
         this.gp_a.scale = 1;
         this.gp_a.visible = true;
         param2.addChild(this.gp_a);
         _context.addEventListener(GuiContextEvent.LOCALE,this.localeHandler);
      }
      
      private function localeHandler(param1:GuiContextEvent) : void
      {
         this.updateTextfields();
      }
      
      private function updateTextfields() : void
      {
         _context.locale.fixTextFieldFormat(this._text$heroic_title);
         _context.locale.fixTextFieldFormat(this._text$heroic_title_tutorial_flavor);
         _context.locale.fixTextFieldFormat(this._text$heroic_title_tutorial_text);
         scaleTextfields();
      }
      
      public function cleanup() : void
      {
         _context.removeEventListener(GuiContextEvent.LOCALE,this.localeHandler);
         this.visible = false;
         GpBinder.gpbinder.unbind(this.cmd_close);
         this.cmd_close.cleanup();
         this.cmd_close = null;
         GpBinder.gpbinder.unbind(this.cmd_back);
         this.cmd_back.cleanup();
         this.cmd_back = null;
         GuiGp.releasePrimaryBitmap(this.gp_a);
      }
      
      override public function set visible(param1:Boolean) : void
      {
         if(param1)
         {
            if(this.gplayer)
            {
               GpBinder.gpbinder.removeLayer(this.gplayer);
            }
            this.gplayer = GpBinder.gpbinder.createLayer("GuiHeroicTitleTutorial");
            GpBinder.gpbinder.bindPress(GpControlButton.B,this.cmd_back);
            GpBinder.gpbinder.bindPress(GpControlButton.A,this.cmd_close);
            this.gp_a.gplayer = this.gplayer;
            GuiGp.placeIcon(this._buttonTutorial$Continue as DisplayObject,null,this.gp_a,GuiGpAlignH.C,GuiGpAlignV.S);
            this.updateTextfields();
         }
         else
         {
            GpBinder.gpbinder.removeLayer(this.gplayer);
            this.gplayer = 0;
            GpBinder.gpbinder.unbind(this.cmd_close);
            GpBinder.gpbinder.unbind(this.cmd_back);
         }
         this.gp_a.visible = param1;
         super.visible = param1;
      }
      
      public function shouldDisplayTutorial() : Boolean
      {
         return !context.saga.getVarBool(HEROIC_TITLE_TUTORIAL_VAR);
      }
      
      private function onContinue(param1:*) : void
      {
         context.saga.setVar(HEROIC_TITLE_TUTORIAL_VAR,1);
         if(this.continueButtonCallback != null)
         {
            this.continueButtonCallback();
         }
      }
      
      private function cmdfunc_continue(param1:CmdExec) : void
      {
         this.gp_a.pulse();
         this._buttonTutorial$Continue.press();
      }
      
      private function cmdfunc_back(param1:CmdExec) : void
      {
         if(this.backButtonCallback != null)
         {
            this.backButtonCallback();
         }
      }
   }
}

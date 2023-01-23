package game.gui
{
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.gui.GuiGpNav;
   import flash.display.DisplayObject;
   import game.gui.pages.GuiTitleRankChanger;
   
   public class GuiHeroicTitles_Gp
   {
       
      
      private var _titles:GuiHeroicTitles;
      
      private var _titleTutorial:GuiHeroicTitleTutorial;
      
      private var _rankChanger:GuiTitleRankChanger;
      
      private var nav:GuiGpNav;
      
      private var cmd_close:Cmd;
      
      private var gplayer:int;
      
      private var _visible:Boolean = false;
      
      public function GuiHeroicTitles_Gp()
      {
         this.cmd_close = new Cmd("pg_heroic_close",this.cmdfunc_close);
         super();
      }
      
      public function set visible(param1:Boolean) : void
      {
         if(this._visible != param1)
         {
            if(param1)
            {
               if(this.gplayer)
               {
                  GpBinder.gpbinder.removeLayer(this.gplayer);
               }
               this.gplayer = GpBinder.gpbinder.createLayer("GuiHeroicTitles_Gp");
               GpBinder.gpbinder.bindPress(GpControlButton.B,this.cmd_close);
               this.nav.activate();
               this.nav.remap();
               this.nav.autoSelect();
            }
            else
            {
               GpBinder.gpbinder.removeLayer(this.gplayer);
               this.gplayer = 0;
               GpBinder.gpbinder.unbind(this.cmd_close);
               if(this.nav)
               {
                  this.nav.deactivate();
               }
            }
            this._visible = param1;
         }
      }
      
      public function init(param1:GuiHeroicTitles, param2:GuiTitleRankChanger) : void
      {
         this._titles = param1;
         this._titleTutorial = this._titles.pgDetails.guiHeroicTitleTutorial;
         this._rankChanger = param2;
         this.nav = new GuiGpNav(param1.context,"pgHeroicTitles",param1);
         this.nav.add(this._titles.pgDetails._button$heroic_titles);
         this.nav.add(this._titles._button$continue);
         this.nav.add(this._titles._button_left);
         this.nav.add(this._titles._button_right);
         this.nav.add(this._rankChanger.rankUpButton);
         this.nav.add(this._rankChanger.rankDownButton);
         this.nav.setCallbackPress(this.navControlPressHandler);
      }
      
      public function cleanup() : void
      {
         this.visible = false;
         this.nav.cleanup();
         GpBinder.gpbinder.unbind(this.cmd_close);
         this.cmd_close.cleanup();
         this.cmd_close = null;
      }
      
      private function navControlPressHandler(param1:DisplayObject, param2:Boolean) : Boolean
      {
         var _loc3_:ButtonWithIndex = param1 as ButtonWithIndex;
         if(_loc3_)
         {
            _loc3_.press();
            this.nav.remap();
            if(this._rankChanger.currentRank == this._rankChanger.maxRankValue)
            {
               this.nav.selected = this._titles._button$continue;
            }
         }
         return true;
      }
      
      private function cmdfunc_close(param1:CmdExec) : void
      {
         this._titles.buttonCancelPressed(null);
      }
   }
}

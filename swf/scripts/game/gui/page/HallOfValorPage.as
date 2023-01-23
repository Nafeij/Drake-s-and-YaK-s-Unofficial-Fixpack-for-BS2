package game.gui.page
{
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.KeyBindGroup;
   import engine.core.fsm.State;
   import flash.events.Event;
   import flash.ui.Keyboard;
   import game.cfg.GameConfig;
   import game.gui.GamePage;
   import game.session.states.TownState;
   
   public class HallOfValorPage extends GamePage implements IGuiHallOfValorListener
   {
       
      
      private var gui:IGuiHallOfValor;
      
      private var cmd_hall_valor_escape:Cmd;
      
      public function HallOfValorPage(param1:GameConfig)
      {
         this.cmd_hall_valor_escape = new Cmd("hall_valor_escape",this.cmdEscapeFunc);
         super(param1);
         if(param1.factions)
         {
            param1.factions.leaderboards.refresh();
         }
      }
      
      override public function cleanup() : void
      {
         if(config.factions)
         {
            config.factions.leaderboards.removeEventListener(Event.CHANGE,this.leaderboardsChangeHandler);
         }
         config.keybinder.unbind(this.cmd_hall_valor_escape);
         super.cleanup();
      }
      
      override protected function handleStart() : void
      {
         if(config.factions)
         {
            config.factions.leaderboards.addEventListener(Event.CHANGE,this.leaderboardsChangeHandler);
         }
         config.keybinder.bind(false,false,false,Keyboard.ESCAPE,this.cmd_hall_valor_escape,KeyBindGroup.TOWN);
         config.keybinder.bind(false,false,false,Keyboard.BACK,this.cmd_hall_valor_escape,KeyBindGroup.TOWN);
      }
      
      private function leaderboardsChangeHandler(param1:Event) : void
      {
         if(!this.gui)
         {
            return;
         }
         this.updateLeaderboards();
      }
      
      private function updateLeaderboards() : void
      {
         if(config.factions)
         {
            this.gui.updateLeaderboards(config.factions.leaderboards.data);
         }
      }
      
      override protected function handleLoaded() : void
      {
         if(fullScreenMc)
         {
            this.gui = fullScreenMc as IGuiHallOfValor;
            this.gui.init(config.gameGuiContext,this);
            this.updateLeaderboards();
         }
      }
      
      public function guiHallOfValorExit() : void
      {
         var _loc1_:State = config.fsm.current;
         config.fsm.transitionTo(TownState,_loc1_.data);
      }
      
      public function cmdEscapeFunc(param1:CmdExec) : void
      {
         if(!config.pageManager.escapeFromMarket())
         {
            this.guiHallOfValorExit();
         }
      }
   }
}

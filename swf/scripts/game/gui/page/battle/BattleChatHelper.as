package game.gui.page.battle
{
   import engine.battle.board.model.BattleBoard;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleFsmPlayerExitEvent;
   import game.cfg.GameConfig;
   import game.gui.GuiChatColor;
   import game.gui.page.BattleHudPage;
   import game.gui.page.GlobalChatHelper;
   import game.gui.page.ScenePage;
   
   public class BattleChatHelper extends GlobalChatHelper
   {
      
      public static var mcClazz:Class;
       
      
      private var _page:ScenePage;
      
      private var hudPage:BattleHudPage;
      
      private var _board:BattleBoard;
      
      private var battleId:String;
      
      private var fsm:BattleFsm;
      
      private var printedStart:Boolean;
      
      public function BattleChatHelper(param1:ScenePage, param2:BattleHudPage, param3:GameConfig)
      {
         super(param1,param3,null,mcClazz);
         this._page = param1;
         this.hudPage = param2;
         this.board = param2.board;
      }
      
      override public function cleanup() : void
      {
         super.cleanup();
         this.board = null;
      }
      
      public function set board(param1:BattleBoard) : void
      {
         if(param1 == this._board)
         {
            return;
         }
         if(this._board)
         {
            this._page.config.fsm.chat.exitRoom(this.battleId);
            this.fsm.removeEventListener(BattleFsmPlayerExitEvent.PLAYER_EXIT,this.playerExitHandler);
         }
         this._board = param1;
         if(this._board)
         {
            this.battleId = this._board.sim.fsm.battleId;
            checkChatInit();
            this.handlePostChatInit();
            this._page.config.fsm.chat.enterRoom(this.battleId);
            this.fsm = this._board.sim.fsm;
            this.fsm.addEventListener(BattleFsmPlayerExitEvent.PLAYER_EXIT,this.playerExitHandler);
            chatroom = this.fsm.battleId;
         }
         else
         {
            this.battleId = null;
            chatroom = null;
         }
      }
      
      override protected function handlePostChatInit() : void
      {
         var _loc1_:String = null;
         var _loc2_:GuiChatColor = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         if(chat && this._board && !this.printedStart)
         {
            this.printedStart = true;
            if(this._board.parties[0].isEnemy)
            {
               _loc1_ = this._board.parties[0].partyName;
            }
            else
            {
               _loc1_ = this._board.parties[1].partyName;
            }
            _loc2_ = GuiChatColor.BATTLE_ENEMY;
            _loc3_ = this._page.config.gameGuiContext.translate("btl_chat_playing_opponent_pfx");
            _loc4_ = this._page.config.gameGuiContext.translate("press_enter_to_chat");
            chat.appendText(_loc3_ + " " + _loc2_.getHtmlOpen() + _loc1_ + _loc2_.getHtmlClose());
            chat.appendText(_loc4_);
            this.hudPage.battleChat = chat;
            this._page.handlePostBattleChatInit();
         }
      }
      
      private function playerExitHandler(param1:BattleFsmPlayerExitEvent) : void
      {
         chat.appendMessage("BATTLE",GuiChatColor.GLOBAL,param1.display_name + " has left the battlefield.",true);
      }
   }
}

package game.gui.page
{
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.view.BattleBoardView;
   import engine.battle.fsm.BattleFinishedData;
   import engine.battle.fsm.BattleStateDataEnum;
   import engine.battle.fsm.BattleTurnOrder;
   import engine.battle.fsm.IBattleFsm;
   import engine.battle.fsm.state.BattleStateFinish;
   import engine.battle.fsm.state.BattleStateFinished;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.fsm.FsmEvent;
   import engine.core.fsm.State;
   import engine.core.logging.ILogger;
   import engine.resource.BitmapResource;
   import engine.saga.Saga;
   import engine.saga.SagaVar;
   import engine.scene.model.Scene;
   import engine.scene.model.SceneEvent;
   import flash.events.Event;
   import game.gui.page.battle.BattleChatHelper;
   import game.session.states.GameStateDataEnum;
   
   public class ScenePageBattleHandler
   {
       
      
      public var page:ScenePage;
      
      private var _focusedBoard:BattleBoard;
      
      private var _matchResolutionPage:MatchResolutionPage;
      
      private var _hud:BattleHudPage;
      
      private var chatHelper:BattleChatHelper;
      
      private var cmd_battle_hud_escape:Cmd;
      
      private var _fsm:IBattleFsm;
      
      private var scene:Scene;
      
      private var finishedData:BattleFinishedData;
      
      private var _battleChatEnabled:Boolean = true;
      
      public var _order:BattleTurnOrder;
      
      public function ScenePageBattleHandler(param1:ScenePage)
      {
         this.cmd_battle_hud_escape = new Cmd("battle_hud_escape",this.cmdEscapeFunc);
         super();
         this.page = param1;
         this.scene = param1.scene;
         if(this.scene)
         {
            this.scene.addEventListener(SceneEvent.FOCUSED_BOARD,this.sceneFocusedBoardHandler);
            if(this.scene.saga.getVarBool(SagaVar.VAR_MATCH_RESOLUTION_BANNER_TORN))
            {
               param1.getPageResource("common/gui/match_resolution/match_resolution_banner_torn.png",BitmapResource);
            }
            else
            {
               param1.getPageResource("common/gui/match_resolution/match_resolution_banner.png",BitmapResource);
            }
         }
         this.sceneFocusedBoardHandler(null);
      }
      
      public function set battleChatEnabled(param1:Boolean) : void
      {
         this._battleChatEnabled = param1;
         this.checkBattleChatEnabled();
      }
      
      private function checkBattleChatEnabled() : void
      {
         if(this._battleChatEnabled)
         {
            if(!this.chatHelper && this.focusedBoard && !this.page.config.saga)
            {
               this.chatHelper = new BattleChatHelper(this.page,this._hud,this.page.config);
            }
         }
         else if(this.chatHelper)
         {
            this.chatHelper.cleanup();
            this.chatHelper = null;
         }
      }
      
      public function get hud() : BattleHudPage
      {
         return this._hud;
      }
      
      public function cleanup() : void
      {
         if(this._matchResolutionPage)
         {
            this._matchResolutionPage.cleanup();
            this._matchResolutionPage = null;
         }
         this.page.config.keybinder.unbind(this.cmd_battle_hud_escape);
         this.cmd_battle_hud_escape.cleanup();
         this.cmd_battle_hud_escape = null;
         if(this.scene)
         {
            this.scene.removeEventListener(SceneEvent.FOCUSED_BOARD,this.sceneFocusedBoardHandler);
         }
         this.focusedBoard = null;
         this.destroyHud();
         if(this.chatHelper)
         {
            this.chatHelper.cleanup();
            this.chatHelper = null;
         }
         this.page = null;
         this.finishedData = null;
      }
      
      protected function sceneFocusedBoardHandler(param1:SceneEvent) : void
      {
         this.focusedBoard = !!this.scene ? this.scene.focusedBoard : null;
      }
      
      public function get focusedBoard() : BattleBoard
      {
         return this._focusedBoard;
      }
      
      public function set focusedBoard(param1:BattleBoard) : void
      {
         if(this._focusedBoard == param1)
         {
            return;
         }
         if(this._focusedBoard)
         {
            this._focusedBoard.sim.fsm.removeEventListener(FsmEvent.CURRENT,this.fsmCurrentHandler);
            if(Boolean(this._hud) && this._hud.board != this._focusedBoard)
            {
               if(this.page.logger.isDebugEnabled)
               {
                  this.page.logger.debug("ScenePageBattleHandler.focusedBoard " + param1 + " CLEANUP old HUD");
               }
               this.destroyHud();
            }
         }
         this._focusedBoard = param1;
         if(this._focusedBoard)
         {
            if(this.page.logger.isDebugEnabled)
            {
               this.page.logger.debug("ScenePageBattleHandler.focusedBoard " + param1 + " CREATE new HUD");
            }
            this.createHud();
            this._focusedBoard.sim.fsm.addEventListener(FsmEvent.CURRENT,this.fsmCurrentHandler);
         }
         this.fsm = !!this._focusedBoard ? this._focusedBoard.fsm : null;
      }
      
      private function destroyHud() : void
      {
         if(!this._hud)
         {
            return;
         }
         if(this._hud.parent)
         {
            this._hud.parent.removeChild(this._hud);
         }
         this._hud.cleanup();
         this._hud.removeEventListener(BattleHudPageEvent.BOARDCHANGE,this.hudBoardChanged);
         this._hud.removeEventListener(BattleHudPageEvent.CHAT_ENABLED,this.chatEnabled);
         this._hud = null;
      }
      
      private function createHud() : void
      {
         var _loc1_:BattleBoardView = this.page.view.boards.getBoardView(this._focusedBoard);
         if(!this._hud)
         {
            this._hud = new BattleHudPage(this.page.config,this,this._focusedBoard,_loc1_,this.page.view,this.page.shell);
            this._hud.addEventListener(BattleHudPageEvent.BOARDCHANGE,this.hudBoardChanged);
            this._hud.addEventListener(BattleHudPageEvent.CHAT_ENABLED,this.chatEnabled);
            this.page.addChild(this._hud);
         }
         else
         {
            this._hud.board = this._focusedBoard;
            this._hud.view = _loc1_;
            this._hud.visible = true;
         }
      }
      
      public function onPageSizeChanaged() : void
      {
         if(this._hud)
         {
            this._hud.setSize(this.page.width,this.page.height);
         }
      }
      
      protected function fsmCurrentHandler(param1:FsmEvent) : void
      {
         var _loc2_:BattleFinishedData = null;
         var _loc3_:Saga = null;
         var _loc4_:String = null;
         if(this._focusedBoard)
         {
            if(this._focusedBoard.sim.fsm.currentClass == BattleStateFinish)
            {
               if(this.page.config.saga)
               {
                  this.page.config.saga.triggerBattleFinish_begin(this.page.sceneState.loader.url);
               }
            }
            if(this._focusedBoard.sim.fsm.currentClass == BattleStateFinished)
            {
               _loc2_ = this._focusedBoard.sim.fsm.current.data.getValue(BattleStateDataEnum.FINISHED);
               if(this.finishedData != _loc2_)
               {
                  this.page.controller.enabled = false;
                  this._hud.checkVisible();
                  if(this.finishedData)
                  {
                     _loc2_.mergeAchievements(this.finishedData);
                  }
                  this.finishedData = _loc2_;
                  _loc3_ = this.page.config.saga;
                  if(_loc3_)
                  {
                     _loc4_ = this.page.sceneState.loader.url;
                     _loc3_.triggerBattleFinished(_loc4_);
                     return;
                  }
                  this.showBattleResolution(null,true);
               }
            }
            else
            {
               this._hud.checkVisible();
               if(this.page.controller)
               {
                  this.page.controller.enabled = true;
               }
               this.matchResolutionPage = null;
               if(this.chatHelper)
               {
                  this.chatHelper.makeChildOfPage(this.page);
               }
            }
         }
      }
      
      public function showBattleResolution(param1:BattleFinishedData, param2:Boolean) : void
      {
         if(!this._focusedBoard.matchResolutionEnabled)
         {
            this.resultsPageClosedHandler(null);
            return;
         }
         this.matchResolutionPage = new MatchResolutionPage(this.page.config,this._focusedBoard,this.resultsPageClosedHandler,param2);
         if(this.chatHelper)
         {
            this.chatHelper.makeChildOfPage(this.matchResolutionPage);
         }
      }
      
      private function resultsPageClosedHandler(param1:MatchResolutionPage) : void
      {
         var _loc3_:State = null;
         if(param1 != this._matchResolutionPage)
         {
            this.logger.info("ScenePageBattleHandler.resultsPageClosedHandler SKIP pages don\'t match");
            return;
         }
         var _loc2_:Saga = this.page.config.saga;
         if(_loc2_)
         {
            if(_loc2_.isSurvival)
            {
               if(_loc2_.triggerSurvivalBattleComplete())
               {
                  return;
               }
            }
         }
         if(this._focusedBoard)
         {
            if(this._focusedBoard.fsm.halted)
            {
               this.logger.info("ScenePageBattleHandler.resultsPageClosedHandler SKIP BattleFsm.halted");
               return;
            }
            _loc3_ = this._focusedBoard.sim.fsm.current;
            if(_loc3_)
            {
               _loc3_.data.setValue(GameStateDataEnum.SCENE_LOADER,null);
               _loc3_.data.setValue(GameStateDataEnum.LOCAL_PARTY,null);
               _loc3_.data.setValue(GameStateDataEnum.PLAYER_ORDER,null);
               _loc3_.data.setValue(GameStateDataEnum.OPPONENT_NAME,null);
               _loc3_.data.setValue(GameStateDataEnum.OPPONENT_ID,null);
               _loc3_.data.removeValue(GameStateDataEnum.BATTLE_INFO);
            }
            this._focusedBoard.sim.fsm.exitBattle();
         }
         this.matchResolutionPage = null;
         if(this.page.config.saga)
         {
            this.logger.info("ScenePageBattleHandler.resultsPageClosedHandler calling triggerWarResolutionClosed");
            this.page.config.saga.triggerWarResolutionClosed();
         }
         this.page.scene.focusedBoard = null;
      }
      
      public function get matchResolutionPage() : MatchResolutionPage
      {
         return this._matchResolutionPage;
      }
      
      public function set matchResolutionPage(param1:MatchResolutionPage) : void
      {
         if(this._matchResolutionPage == param1)
         {
            return;
         }
         if(this._matchResolutionPage)
         {
            if(this._matchResolutionPage.parent)
            {
               this._matchResolutionPage.parent.removeChild(this._matchResolutionPage);
            }
            this._matchResolutionPage.cleanup();
            this._matchResolutionPage = null;
         }
         this._matchResolutionPage = param1;
         if(this._matchResolutionPage)
         {
            this.page.addChild(this._matchResolutionPage);
            this.matchResolutionPage.start();
         }
      }
      
      private function cmdEscapeFunc(param1:CmdExec) : void
      {
         if(this.chatHelper)
         {
            this.chatHelper.handleEscape();
         }
      }
      
      private function hudBoardChanged(param1:Event) : void
      {
         this.checkBattleChatEnabled();
         if(this.chatHelper)
         {
            this.chatHelper.board = this._hud.board;
         }
      }
      
      private function chatEnabled(param1:Event) : void
      {
         if(!this.chatHelper)
         {
         }
      }
      
      public function get logger() : ILogger
      {
         return this.page.config.logger;
      }
      
      public function get order() : BattleTurnOrder
      {
         return this._order;
      }
      
      public function set order(param1:BattleTurnOrder) : void
      {
         if(this._order == param1)
         {
            return;
         }
         this._order = param1;
      }
      
      public function get fsm() : IBattleFsm
      {
         return this._fsm;
      }
      
      public function set fsm(param1:IBattleFsm) : void
      {
         if(this._fsm == param1)
         {
            return;
         }
         this._fsm = param1;
         this.order = !!this._fsm ? this.fsm.order as BattleTurnOrder : null;
      }
      
      public function handlePostBattleChatInit() : void
      {
         if(this.hud)
         {
            if(!this.matchResolutionPage)
            {
               this.page.bringChildToFront(this.hud);
            }
         }
      }
      
      public function updateInput(param1:int) : void
      {
         if(this._hud)
         {
            this._hud.updateInput(param1);
         }
      }
      
      public function update(param1:int) : void
      {
         if(this._hud)
         {
            this._hud.update(param1);
         }
      }
      
      public function configLocaleHandler() : void
      {
         if(this._hud)
         {
            this._hud.handleLocaleChange();
         }
      }
      
      public function handleOptionsButton() : void
      {
         if(this.hud)
         {
            this.hud.handleOptionsButton();
         }
      }
      
      public function handleOptionsShowing(param1:Boolean) : void
      {
         if(this.hud)
         {
            this.hud.handleOptionsShowing(param1);
         }
      }
   }
}

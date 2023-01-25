package game.gui
{
   import engine.ability.IAbilityDefLevel;
   import engine.ability.IAbilityDefLevels;
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.BattleAbilityTag;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.fsm.BattleTurn;
   import engine.battle.fsm.state.BattleStateAborted;
   import engine.battle.fsm.state.BattleStateError;
   import engine.battle.sim.IBattleParty;
   import engine.core.logging.ILogger;
   import engine.saga.Saga;
   import game.gui.battle.IGuiBattleHud;
   import game.gui.battle.IGuiBattleInfo;
   import game.gui.page.BattleHudPage;
   import game.gui.page.BattleHudPageLoadHelper;
   import game.session.states.SceneState;
   
   public class InfoBarHelper
   {
       
      
      private var _battleHudPage:BattleHudPage;
      
      public function InfoBarHelper(param1:BattleHudPage)
      {
         super();
         this._battleHudPage = param1;
      }
      
      public function cleanup() : void
      {
         this._battleHudPage = null;
      }
      
      public function updateInfo() : void
      {
         if(!this._battleHudPage.board)
         {
            return;
         }
         this._battleHudPage.turn = this._battleHudPage.fsm.turn as BattleTurn;
         var _loc1_:BattleHudPageLoadHelper = this._battleHudPage.bhpLoadHelper;
         var _loc2_:IGuiBattleHud = _loc1_.guihud;
         if(!_loc2_ || !_loc2_.initiative)
         {
            return;
         }
         var _loc3_:BattleStateError = this._battleHudPage.fsm.current as BattleStateError;
         if(_loc3_)
         {
            this.showErrorPage(_loc3_);
            return;
         }
         var _loc4_:BattleStateAborted = this._battleHudPage.fsm.current as BattleStateAborted;
         if(_loc4_)
         {
            this.logger.info("InfoBarHelper.updateInfo BattleStateAborted showAbortedPage()");
            this.showAbortedPage();
            return;
         }
         if(!this._battleHudPage.bhpLoadHelper.guihud.initiative.infobar.isVisible)
         {
            return;
         }
         var _loc5_:BattleTurn = this._battleHudPage.turn;
         var _loc6_:IBattleEntity = !!this._battleHudPage.fsm.interact ? this._battleHudPage.fsm.interact : (!!_loc5_ ? _loc5_.entity : null);
         if(Boolean(_loc6_) && !_loc6_.attackable)
         {
            _loc6_ = null;
         }
         this.updateInfoEntityName(_loc6_);
         var _loc7_:IGuiBattleInfo = this._battleHudPage.bhpLoadHelper.guihud.initiative.infobar;
         if(Boolean(_loc5_) && Boolean(_loc5_.ability))
         {
            this.showAbilityInfo();
         }
         else
         {
            _loc7_.showBattleEntityAbilities(_loc6_,!!Saga.instance ? !Saga.instance.battleItemsDisabled : true);
         }
         var _loc8_:SceneState = this._battleHudPage.config.fsm.current as SceneState;
         if(Boolean(_loc8_) && Boolean(_loc8_.battleHandler))
         {
            _loc8_.battleHandler.notifyUnitInfoShown();
         }
      }
      
      private function updateInfoEntityName(param1:IBattleEntity) : void
      {
         var _loc2_:uint = 44799;
         if(Boolean(param1) && Boolean(param1.isEnemy))
         {
            _loc2_ = 16718876;
         }
         this._battleHudPage.bhpLoadHelper.guihud.initiative.infobar.setEntityName(!!param1 ? String(param1.name) : "",_loc2_);
      }
      
      private function showErrorPage(param1:BattleStateError) : void
      {
         var _loc2_:IGuiDialog = this._battleHudPage.config.gameGuiContext.createDialog();
         _loc2_.init(this._battleHudPage.config.gameGuiContext);
         var _loc3_:String = this._battleHudPage.config.gameGuiContext.translate("battle_error_title");
         var _loc4_:String = this._battleHudPage.config.gameGuiContext.translate("battle_error_body_pfx");
         var _loc5_:String = this._battleHudPage.config.gameGuiContext.translate("ok");
         _loc4_ += param1.message;
         _loc2_.openDialog(_loc3_,_loc4_,_loc5_,this.errorDialogCallback);
      }
      
      private function showAbortedPage() : void
      {
         var _loc6_:int = 0;
         var _loc7_:IBattleParty = null;
         var _loc1_:IGuiDialog = this._battleHudPage.config.gameGuiContext.createDialog();
         _loc1_.init(this._battleHudPage.config.gameGuiContext);
         var _loc2_:String = "The other player";
         if(Boolean(this._battleHudPage.fsm) && Boolean(this._battleHudPage.fsm.board))
         {
            _loc6_ = 0;
            while(_loc6_ < this._battleHudPage.fsm.board.numParties)
            {
               _loc7_ = this._battleHudPage.fsm.board.getParty(_loc6_);
               if(_loc7_.aborted)
               {
                  _loc2_ = _loc7_.partyName;
                  break;
               }
               _loc6_++;
            }
         }
         var _loc3_:String = this._battleHudPage.config.gameGuiContext.translate("battle_abort_title");
         var _loc4_:String = this._battleHudPage.config.gameGuiContext.translate("battle_abort_body");
         _loc4_ = _loc4_.replace("$NAME",_loc2_);
         var _loc5_:String = this._battleHudPage.config.gameGuiContext.translate("battle_abort_typical");
         _loc1_.openDialog(_loc3_,_loc4_,_loc5_,this.abortedDialogCallback);
      }
      
      public function hideAbilityInfo() : void
      {
         this._battleHudPage.bhpLoadHelper.guihud.initiative.infobar.setVisible(false);
      }
      
      public function showAbilityInfo() : void
      {
         var _loc6_:String = null;
         var _loc7_:IAbilityDefLevels = null;
         var _loc8_:IAbilityDefLevel = null;
         var _loc9_:int = 0;
         var _loc1_:IGuiBattleInfo = this._battleHudPage.bhpLoadHelper.guihud.initiative.infobar;
         var _loc2_:BattleTurn = this._battleHudPage.turn;
         var _loc3_:BattleAbility = !!_loc2_ ? _loc2_.ability : null;
         var _loc4_:BattleAbilityDef = !!_loc3_ ? _loc3_.def : null;
         var _loc5_:IBattleEntity = !!_loc2_ ? _loc2_.entity : null;
         if(_loc4_ && _loc4_.tag == BattleAbilityTag.SPECIAL && _loc5_ && Boolean(_loc5_.playerControlled))
         {
            _loc6_ = _loc4_.id;
            _loc7_ = _loc5_.def.actives;
            _loc8_ = _loc7_.getAbilityDefLevelById(_loc6_);
            _loc9_ = !!_loc8_ ? int(Math.min(_loc8_.level,_loc8_.def.maxLevel)) : 1;
            _loc1_.showAbilityInfo(_loc4_,_loc9_);
         }
      }
      
      private function abortedDialogCallback(param1:String) : void
      {
         this._battleHudPage.board._scene.focusedBoard = null;
      }
      
      private function errorDialogCallback(param1:String) : void
      {
         this._battleHudPage.board._scene.focusedBoard = null;
      }
      
      public function get logger() : ILogger
      {
         return this._battleHudPage.logger;
      }
      
      public function handleLocaleChange() : void
      {
         this.updateInfo();
      }
   }
}

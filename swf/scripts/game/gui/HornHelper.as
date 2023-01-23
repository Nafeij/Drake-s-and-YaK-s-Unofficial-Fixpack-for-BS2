package game.gui
{
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.ability.model.BattleAbilityValidation;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.model.IBattleMove;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleTurn;
   import engine.battle.fsm.state.BattleStateTurnLocal;
   import engine.core.locale.LocaleCategory;
   import engine.gui.GuiGpBitmap;
   import engine.saga.Saga;
   import engine.stat.def.StatType;
   import engine.tile.Tile;
   import flash.display.MovieClip;
   import game.cfg.GameConfig;
   import game.gui.battle.IGuiArtifact;
   import game.gui.battle.IGuiArtifactListener;
   import game.gui.page.BattleHudPage;
   import game.view.GameScreenFlyTextManagerAdapter;
   
   public class HornHelper extends ArtifactHelper implements IGuiArtifactListener, IArtifactHelper
   {
      
      public static var mcClazz:Class;
       
      
      public function HornHelper(param1:BattleHudPage, param2:GuiGpBitmap)
      {
         super(param1,param2);
         this.hornResCreate();
      }
      
      private function hornResCreate() : void
      {
         if(!mcClazz || _artifact)
         {
            return;
         }
         _artifact = new mcClazz() as IGuiArtifact;
         if(!_artifact)
         {
            logger.error("Unable to load the horn");
            return;
         }
         _battleHudPage.addChild(_artifact as MovieClip);
         _artifact.init(_battleHudPage.config.gameGuiContext,this,_battleHudPage.config.saga,_gpbmp);
         resizeHandler();
         if(_board && _board.boardSetup)
         {
            _artifact.artifactVisible = true;
         }
         updateArtifactChargeCount();
         _battleHudPage.updateBattleHelp();
      }
      
      override public function useArtifact() : void
      {
         var _loc7_:String = null;
         var _loc17_:Tile = null;
         logger.debug("***HORN HornHelper.useHorn");
         if(!board)
         {
            logger.debug("***HORN HornHelper.useHorn !board");
            return;
         }
         var _loc1_:BattleFsm = board.sim.fsm;
         var _loc2_:BattleTurn = _loc1_.turn as BattleTurn;
         if(!_loc2_ || _loc2_.committed || !_loc2_.entity.playerControlled)
         {
            logger.debug("***HORN HornHelper.useHorn !turn || turn.committed || !turn.entity.playerControlled");
            return;
         }
         var _loc3_:BattleStateTurnLocal = _loc1_.current as BattleStateTurnLocal;
         if(!_loc3_)
         {
            logger.debug("***HORN HornHelper.useHorn !local");
            return;
         }
         var _loc4_:GameConfig = _battleHudPage.config;
         var _loc5_:Saga = _loc4_.saga;
         if(_loc5_ && !_loc5_.hudHornEnabled)
         {
            logger.debug("***HORN HornHelper.useHorn saga && !saga.hudHornEnabled");
            return;
         }
         if(!_loc4_.battleHudConfig.horn || !_loc4_.battleHudConfig.showHorn)
         {
            logger.debug("***HORN HornHelper.useHorn !config.battleHudConfig.horn || !config.battleHudConfig.showHorn");
            return;
         }
         var _loc6_:IBattleEntity = _loc3_.entity;
         var _loc8_:GameScreenFlyTextManagerAdapter = _battleHudPage.config.flyManager;
         if(_artifact.count <= 0)
         {
            _loc7_ = _battleHudPage.config.context.locale.translate(LocaleCategory.GUI,"horn_no_stars");
            _loc8_.purgeQueue();
            _loc8_.showScreenFlyText(_loc7_,16776960,"ui_error",1);
            return;
         }
         var _loc9_:int = int(_loc6_.stats.getBase(StatType.WILLPOWER));
         var _loc10_:int = int(_loc6_.def.stats.getValue(StatType.WILLPOWER));
         if(_loc9_ >= _loc10_)
         {
            _loc7_ = _battleHudPage.config.context.locale.translate(LocaleCategory.GUI,"horn_willpower_full");
            _loc8_.purgeQueue();
            _loc8_.showScreenFlyText(_loc7_,16776960,"ui_error",1);
            logger.debug("***HORN HornHelper.useHorn wil >= wilmax");
            return;
         }
         var _loc11_:BattleAbilityDef = _loc1_.board.abilityManager.getFactory.fetch("abl_horn") as BattleAbilityDef;
         if(BattleAbilityValidation.OK != BattleAbilityValidation.validate(_loc11_,_loc3_.entity,null,_loc3_.entity,null,false,true,true))
         {
            _battleHudPage.config.gameGuiContext.playSound("ui_error");
            logger.debug("***HORN HornHelper.useHorn no validation");
            return;
         }
         logger.debug("***HORN HornHelper.useHorn USING");
         _loc5_.incrementGlobalVar("survival_num_horn",1);
         var _loc12_:IBattleMove = _loc2_._move;
         var _loc13_:Tile = _loc12_.last;
         if(_loc13_ != _loc12_.wayPointTile)
         {
            if(!_loc12_.committed)
            {
               _loc12_.setWayPoint(_loc13_);
            }
         }
         var _loc14_:BattleAbility = new BattleAbility(_loc3_.entity,_loc11_,_loc1_.board.abilityManager);
         _loc3_.performAction(_loc14_);
         if(!_loc12_.committed)
         {
            _loc17_ = _loc12_.last;
            _loc12_.reset(_loc2_.entity.tile);
            _loc12_.process(_loc17_,true);
         }
         var _loc15_:int = BattleHudPage.calculateRemainingTurnMaxStars(_loc2_);
         _battleHudPage.popupEnemyHelper.updateWillpower(_loc15_);
         var _loc16_:int = int(_loc2_.entity.stats.getValue(StatType.WILLPOWER));
         _battleHudPage.popupSelfHelper.updateWillpower(_loc16_);
         _battleHudPage.positionAbilityPopup();
      }
      
      override public function guiArtifactUse() : void
      {
         logger.debug("***HORN HornHelper.guiHornUse");
         this.useArtifact();
      }
   }
}

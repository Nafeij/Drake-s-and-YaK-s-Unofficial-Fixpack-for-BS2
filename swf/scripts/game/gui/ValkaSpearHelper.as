package game.gui
{
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleTurn;
   import engine.battle.fsm.state.BattleStateTurnLocal;
   import engine.gui.GuiGpBitmap;
   import engine.stat.def.StatType;
   import flash.display.MovieClip;
   import game.gui.battle.IGuiArtifact;
   import game.gui.battle.IGuiArtifactListener;
   import game.gui.page.BattleHudPage;
   
   public class ValkaSpearHelper extends ArtifactHelper implements IGuiArtifactListener, IArtifactHelper
   {
      
      public static var mcSpearClazz:Class;
      
      private static const SPEAR_ABILITY:String = "abl_valka_spear";
       
      
      private var foo:int = 0;
      
      public function ValkaSpearHelper(param1:BattleHudPage, param2:GuiGpBitmap)
      {
         super(param1,param2);
         this.createResource();
      }
      
      private function createResource() : void
      {
         if(!mcSpearClazz || Boolean(_artifact))
         {
            return;
         }
         _artifact = new mcSpearClazz() as IGuiArtifact;
         if(!_artifact)
         {
            logger.error("Unable to load Valka Spear!");
            return;
         }
         _battleHudPage.addChild(_artifact as MovieClip);
         _artifact.init(_battleHudPage.config.gameGuiContext,this,_battleHudPage.config.saga,_gpbmp,_battleHudPage.config.soundSystem.driver);
         if(Boolean(_board) && _board.boardSetup)
         {
            _artifact.artifactVisible = true;
         }
         updateArtifactChargeCount();
         _battleHudPage.updateBattleHelp();
      }
      
      override public function useArtifact() : void
      {
         var _loc1_:BattleFsm = board.sim.fsm;
         if(!_loc1_)
         {
            return;
         }
         var _loc2_:BattleTurn = _loc1_.turn as BattleTurn;
         var _loc3_:BattleStateTurnLocal = _loc1_.current as BattleStateTurnLocal;
         if(!_loc3_ || !_loc2_)
         {
            return;
         }
         var _loc4_:BattleAbility = _loc2_.ability;
         if(Boolean(_loc4_) && (_loc4_.executed || _loc4_.executing))
         {
            return;
         }
         var _loc5_:BattleAbilityDef = _board.abilityManager.getFactory.fetch(SPEAR_ABILITY) as BattleAbilityDef;
         var _loc6_:BattleAbility = new BattleAbility(_loc3_.entity,_loc5_,_board.abilityManager);
         _loc6_.def.costs.removeStat(StatType.WILLPOWER);
         _loc2_.ability = _loc6_;
      }
      
      override public function guiArtifactUse() : void
      {
         this.useArtifact();
      }
   }
}

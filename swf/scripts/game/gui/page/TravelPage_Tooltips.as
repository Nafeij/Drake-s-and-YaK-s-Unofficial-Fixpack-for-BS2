package game.gui.page
{
   import com.greensock.TweenMax;
   import engine.core.TutorialTooltipAlign;
   import engine.core.TutorialTooltipAnchor;
   import engine.entity.def.IEntityListDef;
   import engine.landscape.def.LandscapeSpriteDef;
   import engine.saga.Saga;
   import engine.saga.SagaVar;
   import game.cfg.GameConfig;
   import game.view.TutorialTooltip;
   
   public class TravelPage_Tooltips
   {
       
      
      private var tp:TravelPage;
      
      private var config:GameConfig;
      
      private var saga:Saga;
      
      private var _tt:TutorialTooltip;
      
      private var _showedMorale:Boolean;
      
      private var _checkedInjury:Boolean;
      
      private var _checkedUpgrades:Boolean;
      
      public function TravelPage_Tooltips(param1:TravelPage)
      {
         super();
         this.tp = param1;
         this.config = param1.config;
         this.saga = Saga.instance;
      }
      
      public function cleanup() : void
      {
         TweenMax.killDelayedCallsTo(this.checkForTutorialTooltips);
         this.tt = null;
         this.config = null;
         this.saga = null;
         this.tp = null;
      }
      
      public function startTooltips() : void
      {
         TweenMax.delayedCall(0,this.checkForTutorialTooltips);
      }
      
      public function onRest() : void
      {
         this.tt = null;
      }
      
      public function set tt(param1:TutorialTooltip) : void
      {
         if(this._tt == param1)
         {
            return;
         }
         if(this._tt)
         {
            this.config.tutorialLayer.removeTooltip(this._tt);
         }
         this._tt = param1;
         if(this._tt)
         {
            this._tt.autoclose = true;
         }
      }
      
      private function canShowTooltip() : Boolean
      {
         if(!this.tp.ready || !this.tp.scenePage.scene.ready || this.saga.convo && !this.saga.convo.finished || !this.saga.caravan || this.config.dialogLayer.isShowingDialog || this.config.pageManager.isShowingOptions())
         {
            return false;
         }
         if(this.saga.getVarBool("camp_tips_disabled"))
         {
            return false;
         }
         return true;
      }
      
      private function checkForTutorialTooltips() : Boolean
      {
         if(!this.tp || this.tp.cleanedup || !this.config || !this.saga || !this.saga.camped || this.saga.def.survival || !this.tp.scenePage || !this.tp.scenePage.scene || this.saga.getVarBool("travel_hud_tips_disabled"))
         {
            return false;
         }
         if(!this.canShowTooltip())
         {
            TweenMax.delayedCall(4,this.checkForTutorialTooltips);
            return false;
         }
         if(!this.config.tutorialLayer.hasTooltips)
         {
            if(!this.checkForTutorialTooltips_morale())
            {
               if(!this.checkForTutorialTooltips_injury())
               {
                  if(this.checkForTutorialTooltips_upgrades())
                  {
                  }
               }
            }
         }
         TweenMax.delayedCall(2,this.checkForTutorialTooltips);
         return false;
      }
      
      private function checkForTutorialTooltips_morale() : Boolean
      {
         if(this._showedMorale || !this.tp.guiTop || !this.tp.guiTop.extended || this.tp.guiTop.animating || !this.tp.guiTop.movieClip.visible)
         {
            return false;
         }
         var _loc1_:int = this.saga.getVarInt(SagaVar.VAR_MORALE_CATEGORY);
         var _loc2_:String = "tip_battle_morale_" + _loc1_;
         var _loc3_:String = "tip_camp_morale_" + _loc1_;
         if(this.saga.getVarBool(_loc3_))
         {
            return false;
         }
         this._showedMorale = true;
         this.saga.setVar(_loc3_,1);
         var _loc4_:String = this.config.context.locale.translateGui(_loc2_);
         this.tt = this.config.tutorialLayer.createTooltip("ScenePage|TravelPage|GuiTravelTop|button_morale",TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.BOTTOM,0,_loc4_,true,true,0);
         return true;
      }
      
      private function checkForTutorialTooltips_injury() : Boolean
      {
         if(this._checkedInjury || !this.saga || !this.saga.caravan || !this.tp || !this.tp.scenePage || !this.tp.scenePage.view || !this.tp.scenePage.view.landscapeView)
         {
            return false;
         }
         var _loc1_:int = this.saga.getVarInt(SagaVar.VAR_MORALE_CATEGORY);
         var _loc2_:String = "tip_camp_injury";
         var _loc3_:String = _loc2_;
         if(this.saga.getVarBool(_loc3_))
         {
            return false;
         }
         var _loc4_:IEntityListDef = this.saga.caravan.legend.roster;
         if(!_loc4_.hasInjuredCombatants)
         {
            this._checkedInjury = true;
            return false;
         }
         var _loc5_:LandscapeSpriteDef = this.tp.scenePage.view.landscapeView.getSpriteDefFromPath("click_rest",true);
         if(!this.tp.scenePage.view.landscapeView.isClickableEnabled(_loc5_))
         {
            return false;
         }
         this.saga.setVar(_loc3_,1);
         var _loc6_:String = "ScenePage|scene_view|landscapeView|:";
         _loc6_ += _loc5_.layer.nameId + "." + _loc5_.nameId;
         var _loc7_:String = this.config.context.locale.translateGui(_loc2_);
         this.tt = this.config.tutorialLayer.createTooltip(_loc6_,TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.CENTER,0,_loc7_,true,true,0);
         return true;
      }
      
      private function checkForTutorialTooltips_upgrades() : Boolean
      {
         if(this._checkedUpgrades)
         {
            return false;
         }
         var _loc1_:int = this.saga.getVarInt(SagaVar.VAR_MORALE_CATEGORY);
         var _loc2_:String = "tip_camp_upgrades";
         var _loc3_:String = _loc2_;
         if(this.saga.getVarBool(_loc3_))
         {
            return false;
         }
         var _loc4_:IEntityListDef = this.saga.caravan.legend.roster;
         if(_loc4_.hasUpgradeableCombatants <= 0)
         {
            this._checkedUpgrades = true;
            return false;
         }
         var _loc5_:LandscapeSpriteDef = this.tp.scenePage.view.landscapeView.getSpriteDefFromPath("click_heroes",true);
         if(!this.tp.scenePage.view.landscapeView.isClickableEnabled(_loc5_))
         {
            return false;
         }
         this.saga.setVar(_loc3_,1);
         var _loc6_:String = "ScenePage|scene_view|landscapeView|:";
         _loc6_ += _loc5_.layer.nameId + "." + _loc5_.nameId;
         var _loc7_:String = this.config.context.locale.translateGui(_loc2_);
         this.tt = this.config.tutorialLayer.createTooltip(_loc6_,TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.CENTER,0,_loc7_,true,true,0);
         return true;
      }
   }
}

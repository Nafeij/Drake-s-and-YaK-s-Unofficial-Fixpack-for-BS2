package game.gui
{
   import com.greensock.TweenMax;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.IEntityListDef;
   import engine.entity.def.ILegend;
   
   public class GuiRoster_Animator_In
   {
       
      
      private var rosterComponent:GuiRoster;
      
      private var _context:IGuiContext;
      
      private var _animatedPartyHover:Boolean;
      
      private var _animatePartyHoverIndex:int = 0;
      
      private var _animatedRosterRecruited:Boolean;
      
      private var _animateRosterRecruitedIndex:int = 0;
      
      public function GuiRoster_Animator_In(param1:GuiRoster)
      {
         super();
         this.rosterComponent = param1;
         this._context = param1.context;
      }
      
      public function cleanup() : void
      {
         TweenMax.killDelayedCallsTo(this._animateOnePartyHover);
         TweenMax.killDelayedCallsTo(this.animatePartyHovers);
         TweenMax.killDelayedCallsTo(this._animateOneRosterRecruited);
      }
      
      public function startSurvivalAnimating_In() : void
      {
         this.animateRosterRecruited();
      }
      
      private function animatePartyHovers() : void
      {
         if(this._animatedPartyHover)
         {
            return;
         }
         this._animatedPartyHover = true;
         this._animatePartyHoverIndex = 0;
         TweenMax.delayedCall(0,this._animateOnePartyHover);
      }
      
      private function _finish() : void
      {
         this.rosterComponent.handleSurvivalAnimatorComplete_In();
      }
      
      private function _animateOnePartyHover() : void
      {
         if(this._animatePartyHoverIndex > 0 && this._animatePartyHoverIndex <= 6)
         {
            this.rosterComponent.partyRow.getIconSlot(this._animatePartyHoverIndex - 1).setHovering(false);
         }
         if(this._animatePartyHoverIndex >= 6)
         {
            if(this._context.saga.isSurvival)
            {
               this.rosterComponent.mouseEnabled = this.rosterComponent.mouseChildren = true;
               TweenMax.delayedCall(0.5,this._finish);
            }
            return;
         }
         this.rosterComponent.partyRow.getIconSlot(this._animatePartyHoverIndex).setHovering(true);
         this._context.playSound("ui_attack_button");
         ++this._animatePartyHoverIndex;
         TweenMax.delayedCall(0.15,this._animateOnePartyHover);
      }
      
      private function animateRosterRecruited() : void
      {
         if(this._animatedRosterRecruited)
         {
            return;
         }
         this.rosterComponent.mouseEnabled = this.rosterComponent.mouseChildren = false;
         this._animatedRosterRecruited = true;
         this._animateRosterRecruitedIndex = 0;
         TweenMax.delayedCall(1,this._animateOneRosterRecruited);
      }
      
      private function _recruitAll() : void
      {
         var _loc4_:IEntityDef = null;
         var _loc1_:ILegend = this._context.saga.caravan.legend;
         var _loc2_:IEntityListDef = _loc1_.roster;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_.numCombatants)
         {
            _loc4_ = _loc2_.getCombatantAt(_loc3_);
            if(_loc4_)
            {
               _loc4_.isSurvivalRecruited = true;
            }
            _loc3_++;
         }
      }
      
      private function _animateOneRosterRecruited() : void
      {
         var _loc2_:GuiCharacterIconSlots = null;
         var _loc3_:GuiCharacterIconSlot = null;
         var _loc4_:IEntityDef = null;
         if(this._animateRosterRecruitedIndex >= 9)
         {
            if(this._context.saga.isSurvival)
            {
               this._recruitAll();
               TweenMax.delayedCall(0.25,this.animatePartyHovers);
            }
            return;
         }
         var _loc1_:int = 0;
         while(_loc1_ < this.rosterComponent.rosterRows)
         {
            _loc2_ = this.rosterComponent.getRosterRow(_loc1_);
            _loc3_ = _loc2_.getIconSlot(this._animateRosterRecruitedIndex) as GuiCharacterIconSlot;
            if(_loc3_)
            {
               _loc4_ = _loc3_.character;
               _loc4_.isSurvivalRecruited = true;
               _loc3_.showRecruitable = false;
               _loc3_.dragEnabled = true;
               this._context.playSound("ui_movement_button");
            }
            _loc1_++;
         }
         ++this._animateRosterRecruitedIndex;
         TweenMax.delayedCall(0.15,this._animateOneRosterRecruited);
      }
   }
}

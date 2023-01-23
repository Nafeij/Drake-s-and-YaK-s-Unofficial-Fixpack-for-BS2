package game.gui
{
   import com.greensock.TweenMax;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.IEntityListDef;
   import engine.entity.def.IPartyDef;
   
   public class GuiRoster_Animator_Out
   {
       
      
      private var rosterComponent:GuiRoster;
      
      private var _context:IGuiContext;
      
      private var _animatedRosterRecruited:Boolean;
      
      private var _animateRosterRecruitedIndex:int = 0;
      
      public function GuiRoster_Animator_Out(param1:GuiRoster)
      {
         super();
         this.rosterComponent = param1;
         this._context = param1.context;
      }
      
      public function cleanup() : void
      {
         this.killAllTweens();
      }
      
      private function killAllTweens() : void
      {
         TweenMax.killDelayedCallsTo(this._animateOneRosterRecruited);
         TweenMax.killDelayedCallsTo(this._finishFinally);
         TweenMax.killDelayedCallsTo(this._finish);
      }
      
      private function _finish() : void
      {
         this.rosterComponent.fadeRoster(0.5);
         TweenMax.delayedCall(0.5,this._finishFinally);
      }
      
      private function _finishFinally() : void
      {
         this.rosterComponent.handleSurvivalAnimatorComplete_Out();
      }
      
      public function startSurvivalAnimating_Out() : void
      {
         this.animateRosterRecruited();
      }
      
      public function recoverState() : void
      {
         this.rosterComponent.showRoster(0.5);
         this.recruitAll();
      }
      
      private function animateRosterRecruited() : void
      {
         if(this._animatedRosterRecruited)
         {
            return;
         }
         this.rosterComponent.setMouseEnabled(false);
         this._animatedRosterRecruited = true;
         this._animateRosterRecruitedIndex = 0;
         this._animateOneRosterRecruited();
      }
      
      private function recruitAll() : void
      {
         var _loc4_:IEntityDef = null;
         var _loc5_:GuiCharacterIconSlots = null;
         var _loc6_:GuiCharacterIconSlot = null;
         var _loc1_:IEntityListDef = this._context.saga.caravan.roster;
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_.numCombatants)
         {
            _loc4_ = _loc1_.getCombatantAt(_loc2_);
            if(_loc4_)
            {
               _loc4_.isSurvivalRecruited = true;
            }
            _loc2_++;
         }
         var _loc3_:int = 0;
         while(_loc3_ < this.rosterComponent.rosterRows)
         {
            _loc5_ = this.rosterComponent.getRosterRow(_loc3_);
            _loc2_ = 0;
            while(_loc2_ < _loc5_.numSlots)
            {
               _loc6_ = _loc5_.getIconSlot(_loc2_) as GuiCharacterIconSlot;
               if(_loc6_)
               {
                  _loc6_.showRecruitable = false;
                  _loc6_.dragEnabled = true;
               }
               _loc2_++;
            }
            _loc3_++;
         }
      }
      
      private function _unrecruitAll() : void
      {
         var _loc4_:IEntityDef = null;
         var _loc1_:IEntityListDef = this._context.saga.caravan.roster;
         var _loc2_:IPartyDef = this._context.saga.caravan.party;
         var _loc3_:int = 0;
         while(_loc3_ < _loc1_.numCombatants)
         {
            _loc4_ = _loc1_.getCombatantAt(_loc3_);
            if(_loc4_)
            {
               if(!_loc2_.hasMemberId(_loc4_.id))
               {
                  _loc4_.isSurvivalRecruited = false;
               }
            }
            _loc3_++;
         }
      }
      
      private function _animateOneRosterRecruited() : void
      {
         var _loc3_:GuiCharacterIconSlots = null;
         var _loc4_:GuiCharacterIconSlot = null;
         var _loc5_:IEntityDef = null;
         var _loc1_:IPartyDef = this._context.saga.caravan.party;
         if(this._animateRosterRecruitedIndex >= 9)
         {
            if(this._context.saga.isSurvival)
            {
               this._unrecruitAll();
               TweenMax.delayedCall(0.25,this._finish);
            }
            return;
         }
         var _loc2_:int = 0;
         while(_loc2_ < this.rosterComponent.rosterRows)
         {
            _loc3_ = this.rosterComponent.getRosterRow(_loc2_);
            _loc4_ = _loc3_.getIconSlot(8 - this._animateRosterRecruitedIndex) as GuiCharacterIconSlot;
            if(_loc4_)
            {
               _loc5_ = _loc4_.character;
               if(!_loc1_.hasMemberId(_loc5_.id))
               {
                  _loc5_.isSurvivalRecruited = false;
                  _loc4_.showRecruitable = true;
                  _loc4_.dragEnabled = false;
                  this._context.playSound("ui_movement_button");
               }
            }
            _loc2_++;
         }
         ++this._animateRosterRecruitedIndex;
         TweenMax.delayedCall(0.15,this._animateOneRosterRecruited);
      }
   }
}

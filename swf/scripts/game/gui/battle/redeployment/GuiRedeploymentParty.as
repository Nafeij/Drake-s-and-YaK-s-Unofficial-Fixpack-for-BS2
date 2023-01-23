package game.gui.battle.redeployment
{
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.sim.IBattleParty;
   import engine.entity.def.EntityIconType;
   import engine.entity.def.IEntityDef;
   import engine.saga.ISaga;
   import game.gui.GuiBase;
   import game.gui.GuiCharacterIconSlot;
   import game.gui.GuiCharacterIconSlots;
   import game.gui.GuiIconSlotEvent;
   import game.gui.IGuiCharacterIconSlot;
   import game.gui.IGuiContext;
   
   public class GuiRedeploymentParty extends GuiBase
   {
       
      
      private var _characterSlots:GuiCharacterIconSlots;
      
      private var _saga:ISaga;
      
      private var _battleParty:IBattleParty;
      
      public function GuiRedeploymentParty()
      {
         super();
         this._characterSlots = requireGuiChild("party_icon_slots") as GuiCharacterIconSlots;
      }
      
      public function init(param1:IGuiContext, param2:IBattleParty) : void
      {
         initGuiBase(param1);
         this._battleParty = param2;
         this._characterSlots.statsTooltips = false;
         this._characterSlots.init(param1);
         this._characterSlots.iconSlots.reverse();
         this.updateDisplayedCharacters();
         this._characterSlots.addIconEventListener(GuiIconSlotEvent.DROP,this.onIconDrop);
         this._characterSlots.addIconEventListener(GuiIconSlotEvent.DRAG_START,this.onIconMove);
         this._characterSlots.addIconEventListener(GuiIconSlotEvent.DRAG_END,this.onIconMoveEnd);
      }
      
      public function updateDisplayedCharacters() : void
      {
         var _loc2_:IBattleEntity = null;
         var _loc3_:int = 0;
         var _loc4_:IGuiCharacterIconSlot = null;
         var _loc5_:IBattleEntity = null;
         this._characterSlots.clearAllGuiCharacterIconSlots();
         var _loc1_:Vector.<IBattleEntity> = new Vector.<IBattleEntity>();
         for each(_loc2_ in this._battleParty.getAllMembers(null))
         {
            if(!_loc2_.alive)
            {
               this._battleParty.removeMember(_loc2_);
            }
            else if(_loc2_.spawnedCaster == null)
            {
               _loc1_.push(_loc2_);
            }
         }
         _loc3_ = 0;
         while(_loc3_ < this._characterSlots.numSlots)
         {
            _loc4_ = this._characterSlots.getGuiCharacterIconSlot(_loc3_);
            _loc5_ = _loc1_.length > _loc3_ ? _loc1_[_loc3_] : null;
            _loc4_.setCharacter(!!_loc5_ ? _loc5_.def : null,EntityIconType.INIT_ORDER);
            _loc4_.iconEnabled = _loc5_ != null;
            _loc3_++;
         }
      }
      
      public function get characterSlots() : GuiCharacterIconSlots
      {
         return this._characterSlots;
      }
      
      public function cleanup() : void
      {
         this._characterSlots.removeIconEventListener(GuiIconSlotEvent.DROP,this.onIconDrop);
         this._characterSlots.removeIconEventListener(GuiIconSlotEvent.DRAG_START,this.onIconMove);
         this._characterSlots.removeIconEventListener(GuiIconSlotEvent.DRAG_END,this.onIconMoveEnd);
         this._characterSlots.cleanup();
         cleanupGuiBase();
      }
      
      public function getIconAtIndex(param1:int) : IGuiCharacterIconSlot
      {
         return this._characterSlots.getIconSlot(param1) as IGuiCharacterIconSlot;
      }
      
      private function onIconDrop(param1:GuiIconSlotEvent) : void
      {
      }
      
      private function onIconMove(param1:GuiIconSlotEvent) : void
      {
      }
      
      private function onIconMoveEnd(param1:GuiIconSlotEvent) : void
      {
      }
      
      public function updatePartyDropGlows(param1:IGuiCharacterIconSlot) : void
      {
         var _loc2_:IEntityDef = param1.character;
         var _loc3_:* = this._battleParty.getMemberByDefId(_loc2_.id) != null;
         var _loc4_:* = !_loc3_;
         this.showPartyDropTargetsForUnit(_loc2_,true,_loc4_);
      }
      
      private function showPartyDropTargetsForUnit(param1:IEntityDef, param2:Boolean, param3:Boolean) : void
      {
         var _loc6_:GuiCharacterIconSlot = null;
         var _loc7_:IEntityDef = null;
         var _loc8_:String = null;
         var _loc9_:Boolean = false;
         var _loc4_:String = param1.entityClass.partyTagDisplay;
         var _loc5_:int = 0;
         while(_loc5_ < this._characterSlots.numSlots)
         {
            _loc6_ = this._characterSlots.getGuiCharacterIconSlot(_loc5_) as GuiCharacterIconSlot;
            _loc7_ = _loc6_.character;
            _loc8_ = !!_loc7_ ? _loc7_.entityClass.partyTagDisplay : null;
            _loc9_ = false;
            if(!_loc7_)
            {
               _loc9_ = param3;
            }
            else if(_loc7_ == param1 || param2 || _loc8_ == _loc4_)
            {
               _loc9_ = true;
            }
            _loc6_.dropglowVisible = _loc9_;
            _loc6_.mouseEnabled = _loc9_;
            _loc6_.glowVisible = _loc9_ && _loc6_.glowVisible;
            _loc5_++;
         }
      }
   }
}

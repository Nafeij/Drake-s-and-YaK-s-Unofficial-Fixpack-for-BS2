package game.gui.battle.redeployment
{
   import com.stoicstudio.platform.Platform;
   import engine.battle.board.model.BattleBoard_Redeploy;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.fsm.BattleFsmEvent;
   import engine.battle.fsm.IBattleFsm;
   import engine.battle.fsm.IBattleStateUserDeploying;
   import engine.battle.sim.IBattleParty;
   import engine.core.render.BoundedCamera;
   import engine.entity.def.IEntityDef;
   import engine.gui.GuiUtil;
   import engine.resource.loader.SoundControllerManager;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.geom.Point;
   import game.gui.GuiBase;
   import game.gui.GuiCharacterIconSlot;
   import game.gui.GuiIconSlot;
   import game.gui.GuiIconSlotEvent;
   import game.gui.IGuiCharacterIconSlot;
   import game.gui.IGuiContext;
   import game.gui.battle.GuiBattleInfo;
   import game.gui.battle.IGuiRedeployment;
   import game.gui.page.BattleHudPage;
   
   public class GuiRedeployment extends GuiBase implements IGuiRedeployment
   {
       
      
      private var _info:GuiBattleInfo;
      
      private var _party:GuiRedeploymentParty;
      
      private var _roster:GuiRedeploymentRoster;
      
      private var _toggle:GuiRedeploymentRosterToggle;
      
      private var _redeployGp:GuiRedeployment_Gp;
      
      private var _rosterMask:MovieClip;
      
      private var _rosterTitleMC:MovieClip;
      
      private var _bbRedeploy:BattleBoard_Redeploy;
      
      private var _battleParty:IBattleParty;
      
      private var _battleFsm:IBattleFsm;
      
      private var _soundControllerManager:SoundControllerManager;
      
      private var _authorSize:Point;
      
      public function GuiRedeployment()
      {
         this._authorSize = new Point(1024,400);
         super();
         this.name = "GuiRedeployment";
         visible = false;
         this._info = requireGuiChild("infoBar") as GuiBattleInfo;
         this._party = requireGuiChild("order") as GuiRedeploymentParty;
         this._roster = requireGuiChild("__roster") as GuiRedeploymentRoster;
         this._toggle = requireGuiChild("toggle") as GuiRedeploymentRosterToggle;
         this._redeployGp = new GuiRedeployment_Gp(this,this._info,this._party,this._roster,this._toggle);
         this._rosterMask = requireGuiChild("roster_mask_mc") as MovieClip;
         this._rosterTitleMC = requireGuiChild("roster_title") as MovieClip;
      }
      
      public function setRedeploymentEntityFrameClazz(param1:Class) : void
      {
         this._roster.redeploymentEntityFrameClazz = param1;
      }
      
      public function get displayObject() : DisplayObject
      {
         return this as DisplayObject;
      }
      
      public function refresh() : void
      {
         this._party.updateDisplayedCharacters();
         this._roster.updateRosterIcons();
      }
      
      public function init(param1:IGuiContext, param2:BattleHudPage) : void
      {
         visible = true;
         initGuiBase(param1);
         this._bbRedeploy = param2.board.redeploy;
         this._battleParty = param2.board.getPartyById("0");
         this._battleFsm = param2.board.fsm;
         this._info.init(param1,null);
         this._info.visible = false;
         this._roster.initRoster(param1,param2,this._bbRedeploy,this._info,this._rosterTitleMC);
         this._roster.addIconEventListener(GuiIconSlotEvent.DROP,this.onRosterIconDrop);
         this._roster.addIconEventListener(GuiIconSlotEvent.DRAG_START,this.onRosterIconMove);
         this._roster.addIconEventListener(GuiIconSlotEvent.DRAG_END,this.onRosterIconMoveEnd);
         this._roster.addIconEventListener(GuiIconSlotEvent.CLICKED,this.onRedeployIconClicked);
         this._toggle.init(param1,this._roster,this._rosterTitleMC);
         this._party.init(param1,this._battleParty);
         this._party.characterSlots.addIconEventListener(GuiIconSlotEvent.CLICKED,this.onRedeployIconClicked);
         this._party.characterSlots.addIconEventListener(GuiIconSlotEvent.DROP,this.onRosterIconDrop);
         this._party.characterSlots.addIconEventListener(GuiIconSlotEvent.DRAG_START,this.onRosterIconMove);
         this._party.characterSlots.addIconEventListener(GuiIconSlotEvent.DRAG_END,this.onRosterIconMoveEnd);
         this._redeployGp.init(param1,param2);
         this._roster.setRosterExpandedCallback(this._redeployGp.activate);
         this.resizeHandler(param2.width,param2.height);
         this._roster.expand(0);
         this._soundControllerManager = new SoundControllerManager("wave_battle_buttons_soundcontroller","saga3/sound/saga3_gui_wave_battle_deploy.sound.json.z",param2.config.resman,param2.config.soundSystem.driver,null,param2.config.logger);
      }
      
      public function deactivateGp() : void
      {
         this._toggle.deactivateGp();
         this._redeployGp.deactivate();
         this._roster.killAllTweens();
      }
      
      public function activateGp() : void
      {
         this._toggle.activateGp();
         this._redeployGp.activate();
      }
      
      public function resizeHandler(param1:Number, param2:Number) : void
      {
         var _loc3_:Number = param1;
         var _loc4_:Number = param2 * 1 / 2;
         var _loc5_:Number = BoundedCamera.computeFitScale(_loc3_,_loc4_,this.authorSize.x,this.authorSize.y);
         _loc5_ = Math.min(1.5,_loc5_);
         x = 0;
         y = param2;
         this._roster.resizeHandler(param1,param2,this._rosterMask);
         scaleX = scaleY = _loc5_;
         if(Platform.requiresUiSafeZoneBuffer)
         {
            x += 80;
            y -= 50;
         }
      }
      
      public function cleanup() : void
      {
         this._redeployGp.cleanup();
         this._roster.removeIconEventListener(GuiIconSlotEvent.DROP,this.onRosterIconDrop);
         this._roster.removeIconEventListener(GuiIconSlotEvent.DRAG_START,this.onRosterIconMove);
         this._roster.removeIconEventListener(GuiIconSlotEvent.DRAG_END,this.onRosterIconMoveEnd);
         this._roster.removeIconEventListener(GuiIconSlotEvent.CLICKED,this.onRedeployIconClicked);
         this._party.characterSlots.removeIconEventListener(GuiIconSlotEvent.CLICKED,this.onRedeployIconClicked);
         this._party.characterSlots.removeIconEventListener(GuiIconSlotEvent.DROP,this.onRosterIconDrop);
         this._party.characterSlots.removeIconEventListener(GuiIconSlotEvent.DRAG_START,this.onRosterIconMove);
         this._party.characterSlots.removeIconEventListener(GuiIconSlotEvent.DRAG_END,this.onRosterIconMoveEnd);
         this._info.cleanup();
         this._party.cleanup();
         this._roster.cleanup();
         this._toggle.cleanup();
         this._soundControllerManager.cleanup();
         cleanupGuiBase();
      }
      
      public function notifyGpDrop() : void
      {
         this.onRosterIconDrop(null);
      }
      
      private function onRosterIconDrop(param1:GuiIconSlotEvent) : void
      {
         if(!(this._battleFsm.current is IBattleStateUserDeploying) || !this._battleFsm.waveDeploymentEnabled)
         {
            return;
         }
         var _loc2_:GuiCharacterIconSlot = GuiIconSlot.draggedTargetIconSlot as GuiCharacterIconSlot;
         var _loc3_:GuiCharacterIconSlot = GuiIconSlot.draggedSourceIconSlot as GuiCharacterIconSlot;
         if(!_loc3_ || _loc3_.character == null)
         {
            context.playSound("ui_error");
            return;
         }
         var _loc4_:IBattleEntity = this._bbRedeploy.board.getEntityByDefId(_loc3_.character.id,null,true);
         if(Boolean(_loc4_) && !_loc4_.alive)
         {
            context.playSound("ui_error");
            return;
         }
         if(Boolean(_loc2_) && _loc2_.parent == this._party.characterSlots)
         {
            this.addPartyCharacter(_loc3_,_loc2_);
         }
         else if(_loc3_.parent == this._party.characterSlots)
         {
            this.removePartyCharacter(_loc3_.character);
            context.playSound("ui_dismiss");
         }
         if(this._soundControllerManager.isLoaded)
         {
            this._soundControllerManager.soundController.playSound("ui_character_place",null);
         }
         this._party.updateDisplayedCharacters();
      }
      
      private function addPartyCharacter(param1:GuiCharacterIconSlot, param2:GuiCharacterIconSlot) : void
      {
         if(!param1 || !param1.character)
         {
            return;
         }
         if(param1.parent == this._party.characterSlots)
         {
            if(Boolean(param2) && Boolean(param2.character))
            {
               this._bbRedeploy.swapPartyMembers(param1.character.id,param2.character.id);
            }
            return;
         }
         var _loc3_:int = Math.max(0,Math.min(BattleBoard_Redeploy.MAX_PARTY - 1,this._party.characterSlots.getGuiCharacterIconSlotIndex(param2)));
         this._bbRedeploy.insertPartyMember(param1.character.id,_loc3_);
         this._party.updateDisplayedCharacters();
         this._roster.updateRosterIcons();
      }
      
      private function removePartyCharacter(param1:IEntityDef) : void
      {
         this._bbRedeploy.removePartyMemberById(param1.id);
         this._party.updateDisplayedCharacters();
         this._roster.updateRosterIcons();
      }
      
      private function onRosterIconMove(param1:GuiIconSlotEvent) : void
      {
         var _loc2_:GuiCharacterIconSlot = param1.target as GuiCharacterIconSlot;
         this.startUnitMove(_loc2_);
      }
      
      public function startUnitMove(param1:IGuiCharacterIconSlot) : void
      {
         if(!(this._battleFsm.current is IBattleStateUserDeploying) || !this._battleFsm.waveDeploymentEnabled)
         {
            return;
         }
         if(this._soundControllerManager.isLoaded)
         {
            this._soundControllerManager.soundController.playSound("ui_character_select",null);
         }
         this._party.updatePartyDropGlows(param1);
      }
      
      private function onRosterIconMoveEnd(param1:GuiIconSlotEvent) : void
      {
      }
      
      private function onRedeployIconClicked(param1:GuiIconSlotEvent) : void
      {
         var _loc2_:GuiCharacterIconSlot = param1.target as GuiCharacterIconSlot;
         var _loc3_:IBattleEntity = this._bbRedeploy.getBattleEntity(!!_loc2_ ? _loc2_.character : null);
         if(!_loc3_ && _loc2_ && Boolean(_loc2_.character))
         {
            _loc3_ = this._bbRedeploy.board.getEntityByDefId(_loc2_.character.id,null,false);
         }
         this.updateInfobarDisplay(_loc3_,_loc2_.character);
      }
      
      public function interactHandler(param1:BattleFsmEvent) : void
      {
         this.updateInfobarDisplay(this._battleFsm.interact,null);
      }
      
      private function updateInfobarDisplay(param1:IBattleEntity, param2:IEntityDef = null) : void
      {
         if(!param1 && !param2)
         {
            this._info.entity = null;
            this._info.showBattleEntityAbilities(null,false);
            this._info.setVisible(false);
            return;
         }
         if(Boolean(param1) && !param1.mobile)
         {
            return;
         }
         if(param1)
         {
            if(Boolean(param1.usable) || param1.party && param1.party.isEnemy)
            {
               this._info.entity = null;
               this._info.setVisible(false);
               return;
            }
            this._info.entity = param1;
            this._info.showBattleEntityAbilities(param1,true);
         }
         else
         {
            this._info.entityDef = param2;
            this._info.showEntityDefAbilities(param2,true);
         }
         this._info.setVisible(true);
         GuiUtil.updateDisplayListAtIndex(this._info,this,0);
      }
      
      public function get authorSize() : Point
      {
         return this._authorSize;
      }
      
      public function partyHasMemberId(param1:String) : Boolean
      {
         return this._battleParty.getMemberByDefId(param1) != null;
      }
      
      public function getBattlePartyNumMembers() : int
      {
         return this._battleParty.numMembers;
      }
   }
}

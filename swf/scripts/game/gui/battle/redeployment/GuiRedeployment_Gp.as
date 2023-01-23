package game.gui.battle.redeployment
{
   import engine.battle.fsm.IBattleFsm;
   import engine.battle.fsm.IBattleStateUserDeploying;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.entity.def.EntityIconType;
   import engine.gui.GuiGpAlignH;
   import engine.gui.GuiGpAlignV;
   import engine.gui.GuiGpNav;
   import engine.scene.SceneControllerConfig;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import game.gui.GuiCharacterIconSlot;
   import game.gui.GuiIcon;
   import game.gui.GuiIconSlot;
   import game.gui.IGuiCharacterIconSlot;
   import game.gui.IGuiContext;
   import game.gui.IGuiIconSlot;
   import game.gui.battle.GuiBattleInfo;
   import game.gui.battle.GuiWaveRedeploymentTop;
   import game.gui.battle.IGuiBattleHud;
   import game.gui.page.BattleHudPage;
   import game.gui.page.BattleHudPageLoadHelper;
   
   public class GuiRedeployment_Gp
   {
       
      
      private var _redeploy:GuiRedeployment;
      
      private var _info:GuiBattleInfo;
      
      private var _party:GuiRedeploymentParty;
      
      private var _roster:GuiRedeploymentRoster;
      
      private var _rosterBg:DisplayObject;
      
      private var _toggle:GuiRedeploymentRosterToggle;
      
      private var _waveRedeployTop:GuiWaveRedeploymentTop;
      
      private var _context:IGuiContext;
      
      private var _battleFsm:IBattleFsm;
      
      private var navSelect:GuiGpNav;
      
      private var navMove:GuiGpNav;
      
      private var _selectedUnit:IGuiCharacterIconSlot = null;
      
      private var cmd_b:Cmd;
      
      private const GP_TOK_ADD:String = "pg_roster_add";
      
      private const GP_TOK_INSERT:String = "pg_roster_insert";
      
      private const GP_TOK_SWAP:String = "pg_roster_swap";
      
      private const GP_TOK_BACK:String = "ctl_menu_x360_name";
      
      private const GP_TOK_SELECT:String = "ctl_menu_name";
      
      private const GP_TOK_REMOVE:String = "pg_roster_remove";
      
      public function GuiRedeployment_Gp(param1:GuiRedeployment, param2:GuiBattleInfo, param3:GuiRedeploymentParty, param4:GuiRedeploymentRoster, param5:GuiRedeploymentRosterToggle)
      {
         this.cmd_b = new Cmd("cmd_redeployGp_b",this.cmd_handleGpCancel);
         super();
         this._redeploy = param1;
         this._info = param2;
         this._party = param3;
         this._roster = param4;
         this._toggle = param5;
      }
      
      public function init(param1:IGuiContext, param2:BattleHudPage) : void
      {
         this._battleFsm = param2.board.fsm;
         this._context = param1;
         var _loc3_:BattleHudPageLoadHelper = param2.bhpLoadHelper;
         var _loc4_:IGuiBattleHud = _loc3_.guihud;
         this._waveRedeployTop = _loc4_.getWaveRedeployTop() as GuiWaveRedeploymentTop;
         this._roster.addEventListener(GuiRedeploymentRoster.ROSTER_DISPLAY_CHANGED,this.onRosterDisplayChanged);
         this._roster.addEventListener(GuiRedeploymentRoster.ROSTER_DISPLAY_EXPANDED,this.onRosterDisplayExpanded);
         this._rosterBg = this._roster.getChildByName("background");
         if(!this._rosterBg)
         {
            this._rosterBg = this._roster;
         }
      }
      
      private function updateNavSelectSlots() : void
      {
         var _loc2_:IGuiIconSlot = null;
         var _loc3_:IGuiCharacterIconSlot = null;
         var _loc1_:GuiCharacterIconSlot = this.cleanupNavs();
         this.navSelect = new GuiGpNav(this._context,"roster_sel",this._redeploy.parent);
         this.navSelect.alwaysHintControls = true;
         this.navSelect.setCallbackPress(this.navSelectClickHandler);
         this.navSelect.setAlignNavDefault(GuiGpAlignH.E_RIGHT,GuiGpAlignV.S_DOWN);
         this.navSelect.setAlignControlDefault(GuiGpAlignH.E_RIGHT,GuiGpAlignV.C);
         this.navSelect.scale = 0.75;
         for each(_loc2_ in this._roster.iconSlots)
         {
            this.navSelect.add(_loc2_ as DisplayObject,true,true);
            this.navSelect.setCaptionTokenControl(_loc2_,this.GP_TOK_SELECT);
         }
         for each(_loc3_ in this._party.characterSlots.iconSlots)
         {
            if(_loc3_.character)
            {
               this.navSelect.add(_loc3_);
               this.navSelect.setCaptionTokenControl(_loc3_,this.GP_TOK_SELECT);
            }
         }
         if(Boolean(_loc1_) && this.navSelect.canSelect(_loc1_))
         {
            this.navSelect.selected = _loc1_;
         }
         else
         {
            this.navSelect.autoSelect();
         }
         this._context.logger.debug("Using Select gp-nav");
         if(this._roster.visible)
         {
            this.navSelect.activate();
            this._context.logger.debug("Select gp-nav activated");
         }
      }
      
      private function navSelectClickHandler(param1:DisplayObject, param2:Boolean) : void
      {
         var _loc4_:GuiIcon = null;
         var _loc3_:IGuiCharacterIconSlot = param1 as IGuiCharacterIconSlot;
         if(_loc3_)
         {
            this._selectedUnit = _loc3_;
            this._redeploy.startUnitMove(_loc3_);
            this.updateNavMoveSlots();
            _loc4_ = this._context.getEntityIcon(this._selectedUnit.character,EntityIconType.INIT_ORDER);
            if(this.navMove)
            {
               this.navMove.setDecoration(_loc4_,1);
            }
         }
      }
      
      private function updateNavMoveSlots() : void
      {
         var _loc2_:IGuiCharacterIconSlot = null;
         var _loc3_:Boolean = false;
         var _loc4_:* = false;
         var _loc5_:int = 0;
         if(!this._selectedUnit || !this._selectedUnit.character)
         {
            return;
         }
         var _loc1_:GuiCharacterIconSlot = this.cleanupNavs();
         this.navMove = new GuiGpNav(this._context,"roster_move",this._redeploy.parent);
         this.navMove.alwaysHintControls = true;
         this.navMove.setCallbackPress(this.navMoveClickControlHandler);
         this.navMove.setAlternateButton(GpControlButton.X,this.navMoveClickAlternateHandler);
         this.navMove.setAlignNavDefault(GuiGpAlignH.E_RIGHT,GuiGpAlignV.S_DOWN);
         this.navMove.setAlignControlDefault(GuiGpAlignH.E_RIGHT,GuiGpAlignV.C);
         this.navMove.scale = 0.75;
         for each(_loc2_ in this._party.characterSlots.iconSlots)
         {
            if(_loc2_.dropglowVisible)
            {
               if(Boolean(this._selectedUnit) && this._selectedUnit.character == _loc2_.character)
               {
                  this._selectedUnit = _loc2_;
               }
               _loc3_ = this._redeploy.partyHasMemberId(this._selectedUnit.character.id);
               _loc4_ = _loc2_ != this._selectedUnit;
               _loc5_ = this._redeploy.getBattlePartyNumMembers();
               this.navMove.add(_loc2_ as DisplayObject,_loc3_,_loc4_);
               if(!_loc2_.character)
               {
                  this.navMove.setCaptionTokenControl(_loc2_,this.GP_TOK_ADD);
               }
               else if(_loc5_ == 6)
               {
                  this.navMove.setCaptionTokenControl(_loc2_,this.GP_TOK_SWAP);
               }
               else
               {
                  this.navMove.setCaptionTokenControl(_loc2_,this.GP_TOK_INSERT);
               }
               this.navMove.setCaptionTokenAlt(_loc2_,this.GP_TOK_REMOVE);
            }
         }
         if(Boolean(_loc1_) && this.navMove.canSelect(_loc1_))
         {
            this.navMove.selected = _loc1_;
         }
         else
         {
            this.navMove.autoSelect();
         }
         this._context.logger.debug("Using Move gp-nav");
         if(this._roster.visible)
         {
            this.navMove.activate();
            this._context.logger.debug("Move gp-nav activated");
         }
      }
      
      private function navMoveClickControlHandler(param1:DisplayObject, param2:Boolean) : Boolean
      {
         if(!this._context)
         {
            return false;
         }
         var _loc3_:IGuiCharacterIconSlot = param1 as IGuiCharacterIconSlot;
         if(Boolean(_loc3_) && Boolean(this._selectedUnit) && Boolean(this._selectedUnit.character))
         {
            GuiIconSlot.draggedSourceIconSlot = this._selectedUnit as GuiIconSlot;
            GuiIconSlot.draggedTargetIconSlot = _loc3_ as GuiIconSlot;
            this._redeploy.notifyGpDrop();
            this.stopUnitMove();
            return true;
         }
         return false;
      }
      
      private function navMoveClickAlternateHandler(param1:DisplayObject) : void
      {
         if(Boolean(this._selectedUnit) && Boolean(this._selectedUnit.character))
         {
            GuiIconSlot.draggedSourceIconSlot = this._selectedUnit as GuiIconSlot;
            GuiIconSlot.draggedTargetIconSlot = null;
            this._redeploy.notifyGpDrop();
         }
         this.stopUnitMove();
      }
      
      private function stopUnitMove() : void
      {
         this._selectedUnit = null;
         this.updateNavSelectSlots();
      }
      
      private function cleanupNavs() : GuiCharacterIconSlot
      {
         var _loc1_:GuiCharacterIconSlot = null;
         if(this.navSelect)
         {
            _loc1_ = this.navSelect.selected as GuiCharacterIconSlot;
            this.navSelect.cleanup();
            this.navSelect = null;
         }
         if(this.navMove)
         {
            _loc1_ = !!_loc1_ ? _loc1_ : this.navMove.selected as GuiCharacterIconSlot;
            this.navMove.cleanup();
            this.navMove = null;
         }
         return _loc1_;
      }
      
      private function cmd_handleGpCancel(param1:CmdExec) : void
      {
         if(this.navMove)
         {
            GuiIconSlot.draggedSourceIconSlot = null;
            GuiIconSlot.draggedTargetIconSlot = null;
            this.updateNavSelectSlots();
            this.navSelect.setSelected(this._selectedUnit,true);
         }
         if(!this.navSelect)
         {
         }
      }
      
      public function activate() : void
      {
         GpBinder.gpbinder.bindPress(GpControlButton.B,this.cmd_b);
         SceneControllerConfig.instance.redeployRosterInFocus = true;
         SceneControllerConfig.instance.notify();
         this._waveRedeployTop.setGpButtonsVisible(false);
         this.updateNavSelectSlots();
      }
      
      public function deactivate() : void
      {
         this._selectedUnit = null;
         SceneControllerConfig.instance.redeployRosterInFocus = false;
         GpBinder.gpbinder.unbind(this.cmd_b);
         GuiIconSlot.draggedTargetIconSlot = null;
         GuiIconSlot.draggedSourceIconSlot = null;
         this.cleanupNavs();
         SceneControllerConfig.instance.redeployRosterInFocus = false;
         SceneControllerConfig.instance.notify();
         if(this._waveRedeployTop.visible)
         {
            this._waveRedeployTop.setGpButtonsVisible(true);
         }
      }
      
      private function get canAssembleParty() : Boolean
      {
         return this._battleFsm.current is IBattleStateUserDeploying && this._battleFsm.waveDeploymentEnabled;
      }
      
      private function navCallbackPress(param1:IGuiIconSlot, param2:Boolean) : Boolean
      {
         return true;
      }
      
      public function cleanup() : void
      {
         this.deactivate();
         if(this._roster)
         {
            this._roster.removeEventListener(GuiRedeploymentRoster.ROSTER_DISPLAY_CHANGED,this.onRosterDisplayChanged);
            this._roster.removeEventListener(GuiRedeploymentRoster.ROSTER_DISPLAY_EXPANDED,this.onRosterDisplayExpanded);
         }
         this._rosterBg = null;
         GpBinder.gpbinder.unbind(this.cmd_b);
         this.cmd_b.cleanup();
         this.cmd_b = null;
         this.cleanupNavs();
      }
      
      private function onRosterDisplayChanged(param1:Event) : void
      {
         var _loc2_:Boolean = this._roster.rosterDisplayed;
         if(!_loc2_)
         {
            this.deactivate();
         }
      }
      
      private function onRosterDisplayExpanded(param1:Event) : void
      {
         var _loc2_:Boolean = this._roster.rosterDisplayed;
         if(_loc2_)
         {
            this.activate();
         }
      }
   }
}

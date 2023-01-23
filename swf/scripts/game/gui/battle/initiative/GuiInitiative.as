package game.gui.battle.initiative
{
   import engine.battle.board.model.IBattleEntity;
   import engine.core.gp.GpControlButton;
   import engine.entity.model.IEntity;
   import engine.gui.BattleHudConfig;
   import engine.gui.GuiContextEvent;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpBitmap;
   import engine.gui.GuiUtil;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.text.TextField;
   import game.gui.ButtonWithIndex;
   import game.gui.GuiBase;
   import game.gui.IGuiContext;
   import game.gui.battle.GuiBattleInfo;
   import game.gui.battle.IGuiBattleInfo;
   import game.gui.battle.IGuiInitiative;
   import game.gui.battle.IGuiInitiativeListener;
   import game.gui.battle.IGuiWaveTurnCounter;
   
   public class GuiInitiative extends GuiBase implements IGuiInitiative
   {
       
      
      private const REST_ICON_OFFSET:Number = -4.5;
      
      public var _activeFrame:GuiInitiativeActiveFrame;
      
      public var _statFlags:GuiInitiativeStatFlags;
      
      public var _nameflagPlayer:MovieClip;
      
      public var _nameflagEnemy:MovieClip;
      
      public var _order:GuiInitiativeOrder;
      
      public var _waveTurnCounter:GuiWaveTurnCounter;
      
      public var _waveTurnCounterBackground:MovieClip;
      
      public var _backing_texture_bottom:MovieClip;
      
      public var _backing_texture_left:MovieClip;
      
      private var _infobar:GuiBattleInfo;
      
      private var lowTime:ButtonWithIndex;
      
      public var entities:Vector.<IBattleEntity>;
      
      public var partition:int;
      
      public var round:int;
      
      public var frameMid:MovieClip;
      
      public var frameRight:MovieClip;
      
      public var frameleft:MovieClip;
      
      public var currentNameflag:MovieClip;
      
      private var listener:IGuiInitiativeListener;
      
      private var _turnCommited:Boolean;
      
      private var orderDeployX:int = 10;
      
      private var orderNormX:int = 131;
      
      private var deployMode:Boolean = false;
      
      private var startingParent:Sprite;
      
      private var _suppressVisible:Boolean = false;
      
      private var gp_d_left_right:GuiGpBitmap;
      
      private var gp_d_down:GuiGpBitmap;
      
      private var _tweening_flag_in:Boolean;
      
      private var _tweening_flag_out:Boolean;
      
      private var _tween_flag_duration:int;
      
      private var _tween_flag_elapsed:int;
      
      private var _tween_flag_target:int;
      
      private var _tween_flag_start:int;
      
      private var _tween_flag_range:int;
      
      private var nameTextY:int = -1000;
      
      private var _authorSize:Point;
      
      private var _authorSizeWaves:Point;
      
      public function GuiInitiative()
      {
         this.gp_d_left_right = GuiGp.ctorPrimaryBitmap(GpControlButton.D_LR,true);
         this.gp_d_down = GuiGp.ctorPrimaryBitmap(GpControlButton.D_D,true);
         this._authorSize = new Point(1024,400);
         this._authorSizeWaves = new Point(1124,400);
         super();
         visible = false;
         name = "assets.battle_initiative";
         this._activeFrame = requireGuiChild("activeFrame") as GuiInitiativeActiveFrame;
         this._statFlags = requireGuiChild("statFlags") as GuiInitiativeStatFlags;
         this._nameflagPlayer = requireGuiChild("nameflagPlayer") as MovieClip;
         this._nameflagEnemy = requireGuiChild("nameflagEnemy") as MovieClip;
         this._order = requireGuiChild("order") as GuiInitiativeOrder;
         this._waveTurnCounter = requireGuiChild("__waveTurnCounter") as GuiWaveTurnCounter;
         this._waveTurnCounterBackground = requireGuiChild("waveTurnCounterBackground") as MovieClip;
         this._backing_texture_bottom = requireGuiChild("backing_texture_bottom") as MovieClip;
         this._backing_texture_left = requireGuiChild("backing_texture_left") as MovieClip;
         this.gp_d_left_right.scale = this.gp_d_down.scale = 0.75;
         addChild(this.gp_d_left_right);
         addChild(this.gp_d_down);
      }
      
      public function get infobar() : IGuiBattleInfo
      {
         return this._infobar;
      }
      
      public function get waveTurnCounter() : IGuiWaveTurnCounter
      {
         return this._waveTurnCounter;
      }
      
      public function updateDisplayLists() : void
      {
         this._statFlags.updateDisplayLists();
      }
      
      public function init(param1:IGuiContext, param2:IGuiInitiativeListener, param3:Vector.<IEntity>) : void
      {
         this.listener = param2;
         initGuiBase(param1);
         this.startingParent = this.parent as Sprite;
         this.frameMid = this._order.getChildByName("frameMid") as MovieClip;
         this.frameRight = this._order.getChildByName("frameRight") as MovieClip;
         this.frameleft = getChildByName("frameLeft") as MovieClip;
         requireGuiChild("statFlags");
         this.lowTime = getChildByName("lowTime") as ButtonWithIndex;
         this.lowTime.mouseEnabled = false;
         this.lowTime.mouseChildren = false;
         this.lowTime.visible = false;
         GuiUtil.updateDisplayList(this.lowTime,this);
         this._nameflagPlayer.visible = false;
         this._nameflagPlayer.stop();
         GuiUtil.updateDisplayList(this._nameflagPlayer,this);
         this._nameflagEnemy.visible = false;
         this._nameflagEnemy.stop();
         GuiUtil.updateDisplayList(this._nameflagEnemy,this);
         this._nameflagPlayer.x = -this._nameflagPlayer.width;
         this._nameflagEnemy.x = -this._nameflagEnemy.width;
         this._activeFrame.init(param1,0,false,param3);
         this._order.init(param1,param3,this);
         this._statFlags.init(param1);
         this._activeFrame.addEventListener(Event.CHANGE,this.activeFrameChangeHandler);
         this._activeFrame.addEventListener(Event.COMPLETE,this.activeFrameCompleteHandler);
         this._activeFrame.addEventListener(GuiInitiativeActiveFrame.INTERACT,this.activeFrameInteractHandler);
         this._order.addEventListener(Event.CHANGE,this.orderChangeHandler);
         this.orderChangeHandler(null);
         this._infobar = getChildByName("infoBar") as GuiBattleInfo;
         this._infobar.init(param1,param2);
         this._waveTurnCounter.init(param1,this._waveTurnCounterBackground);
         mouseEnabled = false;
         mouseChildren = true;
         param1.battleHudConfig.addEventListener(BattleHudConfig.EVENT_CHANGED,this.battleHudConfigHandler);
         param1.addEventListener(GuiContextEvent.LOCALE,this.guiLocaleHandler);
      }
      
      public function cleanup() : void
      {
         GuiGp.releasePrimaryBitmap(this.gp_d_left_right);
         GuiGp.releasePrimaryBitmap(this.gp_d_down);
         context.removeEventListener(GuiContextEvent.LOCALE,this.guiLocaleHandler);
         context.battleHudConfig.removeEventListener(BattleHudConfig.EVENT_CHANGED,this.battleHudConfigHandler);
         this._activeFrame.removeEventListener(Event.CHANGE,this.activeFrameChangeHandler);
         this._activeFrame.removeEventListener(Event.COMPLETE,this.activeFrameCompleteHandler);
         this._activeFrame.removeEventListener(GuiInitiativeActiveFrame.INTERACT,this.activeFrameInteractHandler);
         this._order.removeEventListener(Event.CHANGE,this.orderChangeHandler);
         this._statFlags.cleanup();
         this._activeFrame.cleanup();
         this._order.cleanup();
         this._infobar.cleanup();
         this._waveTurnCounter.cleanup();
         this.entities = null;
         super.cleanupGuiBase();
      }
      
      public function get suppressVisible() : Boolean
      {
         return this._suppressVisible;
      }
      
      public function set suppressVisible(param1:Boolean) : void
      {
         if(param1 == this._suppressVisible)
         {
            return;
         }
         this._suppressVisible = param1;
      }
      
      private function guiLocaleHandler(param1:GuiContextEvent) : void
      {
         this.updateCurrentnameFlagText();
         if(this._statFlags)
         {
            this._statFlags.handleLocaleChange();
         }
         if(this._infobar)
         {
            this._infobar.handleLocaleChange();
         }
         if(this._waveTurnCounter)
         {
            this._waveTurnCounter.handleLocaleChange();
         }
      }
      
      private function battleHudConfigHandler(param1:Event) : void
      {
         this.updateIconPlacement();
      }
      
      private function activeFrameCompleteHandler(param1:Event) : void
      {
         if(this.listener)
         {
            this.listener.guiInitiativeEndTurn();
         }
      }
      
      public function displayLowOnTime(param1:Number, param2:Number) : void
      {
         this.lowTime.visible = true;
         GuiUtil.updateDisplayList(this.lowTime,this);
         this.resizehandler(param1,param2);
         this.lowTime.pulseHover(1000);
      }
      
      private function orderChangeHandler(param1:Event) : void
      {
         var _loc2_:Number = -139;
         this.frameRight.x = this._order.x + this._order.lastX + _loc2_;
         this.frameMid.scaleX = (this.frameRight.x - this.frameMid.x) / 2;
         this.updateTurnCounterXPos(this._order.x + this._order.lastX + 81);
         this.updateIconPlacement();
      }
      
      private function updateTurnCounterXPos(param1:Number) : void
      {
         this._waveTurnCounter.x = param1;
         this._waveTurnCounterBackground.x = param1;
      }
      
      public function updateIconPlacement() : void
      {
         this.gp_d_left_right.visible = context.battleHudConfig.initiative;
         if(Boolean(this._waveTurnCounter) && this._waveTurnCounter.visible)
         {
            GuiGp.placeIconRight(this._waveTurnCounterBackground,this.gp_d_left_right);
         }
         else
         {
            GuiGp.placeIconRight(this.frameRight,this.gp_d_left_right);
         }
         if(this._activeFrame.visible)
         {
            this.gp_d_down.visible = context.battleHudConfig.initiative;
            GuiGp.placeIconBottom(this._activeFrame,this.gp_d_down);
         }
         else
         {
            this.gp_d_down.visible = false;
         }
      }
      
      private function activeFrameChangeHandler(param1:Event) : void
      {
         var _loc2_:int = 1;
         if(this.deployMode)
         {
            _loc2_ = 0;
         }
         this._order.setOrderEntities(this.entities,_loc2_);
      }
      
      public function setInitiativeEntities(param1:Vector.<IBattleEntity>, param2:Boolean, param3:IBattleEntity) : void
      {
         this.entities = param1;
         if(this.deployMode && !param2 || !param3)
         {
            this._order.clearHighlights();
         }
         this.deployMode = param2;
         if(Boolean(this.entities) && this.entities.length > 0)
         {
            this._activeFrame.entity = this.entities[0];
            this._activeFrame.updateBuffs(this.entities[0].effects);
            this._statFlags.entity = this.entities[0];
            if(!visible)
            {
               visible = !this._suppressVisible;
               GuiUtil.updateDisplayList(this,this.startingParent);
               this.updateIconPlacement();
            }
            if(this.deployMode && this._statFlags.visible)
            {
               this._order.x = this.orderDeployX;
               this._statFlags.visible = false;
               GuiUtil.updateDisplayList(this._statFlags,this);
               this._activeFrame.visible = false;
               GuiUtil.updateDisplayList(this._activeFrame,this);
               this.frameleft.visible = true;
               GuiUtil.updateDisplayListAtIndex(this.frameleft,this,0);
               if(this._backing_texture_bottom != null)
               {
                  this._backing_texture_bottom.visible = false;
                  this._backing_texture_left.visible = false;
               }
               this.updateIconPlacement();
            }
            else if(!this.deployMode)
            {
               this._order.x = this.orderNormX;
               this._activeFrame.visible = true;
               GuiUtil.updateDisplayListAtIndex(this._activeFrame,this,2);
               if(this._backing_texture_bottom != null)
               {
                  this._backing_texture_bottom.visible = true;
                  this._backing_texture_left.visible = true;
                  GuiUtil.updateDisplayListAtIndex(this._backing_texture_bottom,this,1);
                  GuiUtil.updateDisplayListAtIndex(this._backing_texture_left,this,1);
               }
               this._statFlags.visible = true;
               GuiUtil.updateDisplayListAtIndex(this._statFlags,this,0);
               this.tweenFlagIn();
               this.orderChangeHandler(null);
               this.activeFrameChangeHandler(null);
               if(this.frameleft.visible)
               {
                  this.frameleft.visible = false;
                  GuiUtil.updateDisplayList(this.frameleft,this);
               }
               this.updateIconPlacement();
            }
         }
         else
         {
            this._activeFrame.entity = null;
            this._statFlags.entity = null;
            visible = false;
            GuiUtil.updateDisplayList(this,this.startingParent);
         }
      }
      
      private function startTweeningNameFlag(param1:Boolean, param2:int) : void
      {
         this._tweening_flag_in = param1;
         this._tweening_flag_out = !param1;
         this._tween_flag_duration = 250;
         this._tween_flag_elapsed = 0;
         this._tween_flag_target = param2;
         this._tween_flag_start = this.currentNameflag.x;
         this._tween_flag_range = param2 - this._tween_flag_start;
      }
      
      public function update(param1:int) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         if(this._tweening_flag_in || this._tweening_flag_out)
         {
            if(this.currentNameflag)
            {
               this._tween_flag_elapsed += param1;
               _loc2_ = this._tween_flag_elapsed / this._tween_flag_duration;
               _loc2_ = Math.min(1,_loc2_);
               _loc3_ = this._tween_flag_start + this._tween_flag_range * _loc2_;
               this.currentNameflag.x = _loc3_;
               if(_loc2_ >= 1)
               {
                  this._tweening_flag_out = false;
                  if(this._tweening_flag_in)
                  {
                     this.tweenInCompleteHandler();
                  }
               }
            }
         }
      }
      
      private function tweenFlagOut() : void
      {
         if(!this.currentNameflag)
         {
            return;
         }
         var _loc1_:TextField = this.currentNameflag.getChildByName("text") as TextField;
         var _loc2_:Number = _loc1_.width / _loc1_.scaleX - _loc1_.textWidth + this.REST_ICON_OFFSET;
         this.startTweeningNameFlag(false,-_loc2_);
      }
      
      private function tweenFlagIn() : void
      {
         if(this.currentNameflag)
         {
            this.startTweeningNameFlag(true,-this.currentNameflag.width);
         }
         else
         {
            this.tweenInCompleteHandler();
         }
      }
      
      private function tweenInCompleteHandler() : void
      {
         this._tweening_flag_in = false;
         if(this.currentNameflag)
         {
            this.currentNameflag.visible = false;
            GuiUtil.updateDisplayList(this.currentNameflag,this);
            this.currentNameflag = null;
         }
         this.updateCurrentnameFlagText();
         this.tweenFlagOut();
      }
      
      private function updateCurrentnameFlagText() : void
      {
         var _loc1_:IEntity = this.entities.length > 0 ? this.entities[0] : null;
         if(!_loc1_ || !_loc1_.def)
         {
            return;
         }
         this.currentNameflag = _loc1_.isPlayer ? this._nameflagPlayer : this._nameflagEnemy;
         this.currentNameflag.visible = true;
         GuiUtil.updateDisplayListAtIndex(this.currentNameflag,this,0);
         var _loc2_:TextField = this.currentNameflag.getChildByName("text") as TextField;
         var _loc3_:String = _loc1_.name;
         if(!_loc3_)
         {
            _context.logger.error("GuiInitiative entity " + _loc1_ + " has no name");
            _loc3_ = _loc1_.id;
         }
         _loc2_.text = !!_loc3_ ? _loc3_ : "¡¡¡unknown!!!";
         _context.currentLocale.fixTextFieldFormat(_loc2_);
         GuiUtil.scaleTextToFit(_loc2_,_loc2_.width);
         if(this.nameTextY == -1000)
         {
            this.nameTextY = _loc2_.y;
         }
         _loc2_.y = this.nameTextY;
         _loc2_.mouseEnabled = _loc2_.selectable = false;
         this.tweenFlagOut();
      }
      
      public function set timerPercent(param1:Number) : void
      {
         this._activeFrame.timerPercent = param1;
      }
      
      public function clearEndButton() : void
      {
      }
      
      public function interact(param1:IBattleEntity, param2:Boolean, param3:Boolean) : void
      {
         var _loc4_:GuiInitiativeFrame = null;
         if(Boolean(param1) && !param1.mobile)
         {
            this._order.interact = null;
            this._infobar.entity = null;
            this._infobar.setVisible(false);
            return;
         }
         this._order.interact = param1;
         if(param1)
         {
            this._infobar.setVisible(true);
            this._infobar.entity = param1;
            _loc4_ = !!this._order.selectedFrame ? this._order.selectedFrame : this._activeFrame;
            this._infobar.displayBuffs(_loc4_);
         }
         else
         {
            this._infobar.setVisible(false);
            this._infobar.entity = null;
            this._infobar.displayBuffs(null);
         }
      }
      
      private function activeFrameInteractHandler(param1:Event) : void
      {
         this.listener.guiInitiativeInteract(this._activeFrame.entity);
      }
      
      public function set turnCommitted(param1:Boolean) : void
      {
         this._turnCommited = param1;
         this._activeFrame.canShowTimer = !this._turnCommited;
         if(this._turnCommited && this.lowTime.visible)
         {
            this.lowTime.setStateToNormal();
            this.lowTime.visible = false;
            GuiUtil.updateDisplayList(this.lowTime,this);
         }
      }
      
      public function resizehandler(param1:Number, param2:Number) : void
      {
         this.lowTime.x = param1 * 0.5 - this.lowTime.width * 0.5;
         this.updateIconPlacement();
      }
      
      public function handleInitiativeInteract(param1:IBattleEntity) : Boolean
      {
         return this.listener.guiInitiativeInteract(param1);
      }
      
      public function getPositionForEntity(param1:IBattleEntity) : Point
      {
         if(this._order)
         {
            return this._order.getPositionForEntity(param1);
         }
         if(this._activeFrame)
         {
            return this._activeFrame.getCenterPosition_g();
         }
         return null;
      }
      
      public function handleOptionsShowing(param1:Boolean) : void
      {
         if(this._statFlags)
         {
            this._statFlags.handleOptionsShowing(param1);
         }
      }
      
      public function get authorSize() : Point
      {
         return Boolean(this._waveTurnCounter) && this._waveTurnCounter.enabled ? this._authorSizeWaves : this._authorSize;
      }
   }
}

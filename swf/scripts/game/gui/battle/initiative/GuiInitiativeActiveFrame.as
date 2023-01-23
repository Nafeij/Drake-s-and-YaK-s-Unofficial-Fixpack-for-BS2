package game.gui.battle.initiative
{
   import engine.battle.board.model.IBattleEntity;
   import engine.entity.def.EntityIconType;
   import engine.entity.model.IEntity;
   import engine.gui.GuiUtil;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import game.gui.IGuiContext;
   
   public class GuiInitiativeActiveFrame extends GuiInitiativeFrame
   {
      
      public static const INTERACT:String = "GuiInitiativeActiveFrame.INTERACT";
       
      
      public var _timerRingPlayer:MovieClip;
      
      public var _timerRingEnemy:MovieClip;
      
      private var _activeTimerRing:MovieClip;
      
      private var _canRest:Boolean;
      
      private var _showButton:Boolean;
      
      private var _canShowTimer:Boolean;
      
      public function GuiInitiativeActiveFrame()
      {
         super();
      }
      
      override public function cleanup() : void
      {
         super.cleanup();
      }
      
      override public function init(param1:IGuiContext, param2:int, param3:Boolean, param4:Vector.<IEntity>) : void
      {
         iconType = EntityIconType.INIT_ACTIVE;
         super.init(param1,0,false,param4);
         this._timerRingPlayer = requireGuiChild("timerRingPlayer") as MovieClip;
         this._timerRingEnemy = requireGuiChild("timerRingEnemy") as MovieClip;
         this._timerRingPlayer.visible = false;
         GuiUtil.updateDisplayList(this._timerRingPlayer,this);
         this._timerRingEnemy.visible = false;
         GuiUtil.updateDisplayList(this._timerRingEnemy,this);
         this._timerRingPlayer.gotoAndStop(1);
         this._timerRingEnemy.gotoAndStop(1);
         willTweenOut = true;
      }
      
      override protected function mouseUpHandler(param1:MouseEvent) : void
      {
         if(!context.battleHudConfig.initiative)
         {
            return;
         }
         this.handleClick(param1);
         super.wasDown = false;
      }
      
      override protected function handleClick(param1:MouseEvent) : void
      {
         if(!context.battleHudConfig.initiative)
         {
            return;
         }
         super.handleClick(param1);
         dispatchEvent(new Event(INTERACT));
      }
      
      public function set timerPercent(param1:Number) : void
      {
         if(!this.activeTimerRing)
         {
            return;
         }
         var _loc2_:int = 1 + (this.activeTimerRing.framesLoaded - 1) * param1;
         this.activeTimerRing.gotoAndStop(_loc2_);
      }
      
      override public function set entity(param1:IBattleEntity) : void
      {
         super.entity = param1;
         if(entity)
         {
            if(entity.isPlayer)
            {
               this.activeTimerRing = this._timerRingPlayer;
               return;
            }
            this.activeTimerRing = this._timerRingEnemy;
         }
         else
         {
            this.activeTimerRing = null;
         }
      }
      
      public function get activeTimerRing() : MovieClip
      {
         return this._activeTimerRing;
      }
      
      public function set activeTimerRing(param1:MovieClip) : void
      {
         if(this._activeTimerRing == param1)
         {
            return;
         }
         if(this._activeTimerRing)
         {
            this._activeTimerRing.visible = false;
            GuiUtil.updateDisplayList(this._activeTimerRing,this);
         }
         this._activeTimerRing = param1;
         this.updateTimerState();
      }
      
      public function get canShowTimer() : Boolean
      {
         return this._canShowTimer;
      }
      
      public function set canShowTimer(param1:Boolean) : void
      {
         this._canShowTimer = param1;
         this.updateTimerState();
      }
      
      private function updateTimerState() : void
      {
         if(Boolean(this._activeTimerRing) && this._activeTimerRing.visible != this._canShowTimer)
         {
            this._activeTimerRing.visible = this._canShowTimer;
            GuiUtil.updateDisplayListAtIndex(this._activeTimerRing,this,1);
         }
      }
   }
}

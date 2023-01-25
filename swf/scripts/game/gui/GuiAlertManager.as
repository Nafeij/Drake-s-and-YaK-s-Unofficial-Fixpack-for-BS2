package game.gui
{
   import com.greensock.TweenMax;
   import engine.core.render.ScreenAspectHelper;
   import engine.gui.core.GuiSprite;
   import engine.resource.event.ResourceLoadedEvent;
   import engine.session.Alert;
   import engine.session.AlertEvent;
   import engine.session.AlertManager;
   import engine.session.AlertOrientationType;
   import engine.session.AlertStyleType;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   
   public class GuiAlertManager extends GuiSprite implements IGuiAlertListener
   {
      
      public static const ALERT_REAPPEAR_DELAY:int = 5 * 60 * 1000;
      
      public static var mcClazz_left_red:Class;
      
      public static var mcClazz_left_tourney:Class;
      
      public static var mcClazz_right_green:Class;
      
      public static var mcClazz_right_red:Class;
      
      public static var mcClazz_right_tourney:Class;
       
      
      public var manager:AlertManager;
      
      public var allAlerts:Dictionary;
      
      public var alertsByOrientation:Dictionary;
      
      public var holders:Dictionary;
      
      public var clazzesByOrientationAndStyle:Dictionary;
      
      public var context:IGuiContext;
      
      public var _alertScale:Number = 1;
      
      public var reappearTimersByOrientation:Dictionary;
      
      public var current:IGuiAlert;
      
      private var _numAlerts:int;
      
      private var _vsCanUse:Boolean = false;
      
      public function GuiAlertManager(param1:AlertManager, param2:IGuiContext)
      {
         this.allAlerts = new Dictionary();
         this.alertsByOrientation = new Dictionary();
         this.holders = new Dictionary();
         this.clazzesByOrientationAndStyle = new Dictionary();
         this.reappearTimersByOrientation = new Dictionary();
         super();
         name = "alerts";
         this.manager = param1;
         this.context = param2;
         this.manager.addEventListener(AlertEvent.ALERT_ADDED,this.alertAddedHandler);
         this.manager.addEventListener(AlertEvent.ALERT_REMOVED,this.alertRemovedHandler);
         this.manager.addEventListener(AlertEvent.ALERTS_ENABLED,this.alertsEnabledHandler);
         this.clazzesByOrientationAndStyle[AlertOrientationType.LEFT] = new Dictionary();
         this.clazzesByOrientationAndStyle[AlertOrientationType.RIGHT] = new Dictionary();
         this.clazzesByOrientationAndStyle[AlertOrientationType.RIGHT_BOTTOM_VS] = new Dictionary();
         this.addClazzByOrientation(mcClazz_left_red,AlertOrientationType.LEFT,AlertStyleType.NORMAL);
         this.addClazzByOrientation(mcClazz_left_tourney,AlertOrientationType.LEFT,AlertStyleType.TOURNEY);
         this.addClazzByOrientation(mcClazz_right_green,AlertOrientationType.RIGHT,AlertStyleType.NORMAL);
         this.addClazzByOrientation(mcClazz_right_red,AlertOrientationType.RIGHT_BOTTOM_VS,AlertStyleType.VS_QUICK);
         this.addClazzByOrientation(mcClazz_right_red,AlertOrientationType.RIGHT_BOTTOM_VS,AlertStyleType.VS_RANKED);
         this.addClazzByOrientation(mcClazz_right_tourney,AlertOrientationType.RIGHT_BOTTOM_VS,AlertStyleType.VS_TOURNEY);
         addEventListener(Event.ADDED_TO_STAGE,this.addedToStageHandler);
         this.alertsEnabledHandler(null);
      }
      
      private function alertsEnabledHandler(param1:Event) : void
      {
         this.visible = this.manager.enabled && Boolean(this._numAlerts);
      }
      
      private function addClazzByOrientation(param1:Class, param2:AlertOrientationType, param3:AlertStyleType) : void
      {
         this.clazzesByOrientationAndStyle[param2][param3] = param1;
      }
      
      private function getClazzByOrientation(param1:AlertOrientationType, param2:AlertStyleType) : Class
      {
         return this.clazzesByOrientationAndStyle[param1][param2];
      }
      
      private function getReappearTimerByOrientation(param1:AlertOrientationType) : Timer
      {
         var _loc2_:Timer = this.reappearTimersByOrientation[param1];
         if(!_loc2_)
         {
            _loc2_ = new Timer(ALERT_REAPPEAR_DELAY,1);
            _loc2_.addEventListener(TimerEvent.TIMER_COMPLETE,this.timerCompleteHandler);
            this.reappearTimersByOrientation[param1] = _loc2_;
         }
         return _loc2_;
      }
      
      private function getAlertsByOrientation(param1:AlertOrientationType) : Vector.<IGuiAlert>
      {
         var _loc2_:Vector.<IGuiAlert> = this.alertsByOrientation[param1];
         if(!_loc2_)
         {
            _loc2_ = new Vector.<IGuiAlert>();
            this.alertsByOrientation[param1] = _loc2_;
         }
         return _loc2_;
      }
      
      private function addedToStageHandler(param1:Event) : void
      {
         this.updateFromSize(true);
      }
      
      override protected function resizeHandler() : void
      {
         super.resizeHandler();
         this.updateFromSize(true);
      }
      
      private function updateFromSize(param1:Boolean) : void
      {
         this._alertScale = Math.min(1,Math.min(width / ScreenAspectHelper.WIDTH_STANDARD,height / ScreenAspectHelper.HEIGHT_NATIVE));
         this.updateFromSizeOrientation(param1,AlertOrientationType.LEFT);
         this.updateFromSizeOrientation(param1,AlertOrientationType.RIGHT);
         this.updateFromSizeOrientation(param1,AlertOrientationType.RIGHT_BOTTOM_VS);
      }
      
      private function getOrientationScale(param1:AlertOrientationType) : Number
      {
         return 1;
      }
      
      private function updateFromSizeOrientation(param1:Boolean, param2:AlertOrientationType) : void
      {
         var _loc5_:IGuiAlert = null;
         var _loc6_:Sprite = null;
         var _loc7_:Number = NaN;
         var _loc3_:Vector.<IGuiAlert> = this.getAlertsByOrientation(param2);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc5_ = _loc3_[_loc4_];
            _loc6_ = this.holders[_loc5_];
            _loc7_ = 0;
            if(param2 == AlertOrientationType.RIGHT_BOTTOM_VS)
            {
               _loc7_ = this.getVsAlertY(_loc5_.alert.style);
            }
            else
            {
               _loc7_ = this.getAlertY(_loc4_) * this._alertScale;
            }
            if(param1)
            {
               TweenMax.killTweensOf(_loc6_);
               _loc6_.y = _loc7_;
            }
            else
            {
               TweenMax.to(_loc6_,0.3,{"y":_loc7_});
            }
            _loc6_.scaleX = _loc6_.scaleY = this._alertScale * this.getOrientationScale(param2);
            if(param2 == AlertOrientationType.LEFT)
            {
               _loc6_.x = 0;
            }
            else
            {
               _loc6_.x = width;
            }
            _loc4_++;
         }
      }
      
      private function mcrListener(param1:ResourceLoadedEvent) : void
      {
         this.initExistingAlerts();
      }
      
      private function alertRemovedHandler(param1:AlertEvent) : void
      {
         var _loc2_:IGuiAlert = this.getGuiAlert(param1.alert);
         if(_loc2_)
         {
            if(_loc2_ == this.current)
            {
               this.current = null;
            }
            _loc2_.depart();
         }
      }
      
      private function getGuiAlert(param1:Alert) : IGuiAlert
      {
         return this.allAlerts[param1];
      }
      
      private function alertAddedHandler(param1:AlertEvent) : void
      {
         this.addAlert(param1.alert);
      }
      
      private function removeAlert(param1:Alert) : void
      {
         var _loc4_:Vector.<IGuiAlert> = null;
         var _loc2_:IGuiAlert = this.getGuiAlert(param1);
         if(!_loc2_)
         {
            return;
         }
         if(_loc2_ == this.current)
         {
            this.current = null;
         }
         --this._numAlerts;
         _loc2_.cleanup();
         var _loc3_:Sprite = this.holders[_loc2_];
         removeChild(_loc3_);
         delete this.holders[_loc2_];
         _loc4_ = this.getAlertsByOrientation(param1.orientation);
         var _loc5_:int = _loc4_.indexOf(_loc2_);
         _loc4_.splice(_loc5_,1);
         delete this.allAlerts[param1];
         param1.removeEventListener(AlertEvent.ALERT_CHANGED,this.alertChangedHandler);
         this.updateFromSize(false);
         this.alertsEnabledHandler(null);
      }
      
      private function addAlert(param1:Alert) : void
      {
         var _loc6_:Sprite = null;
         var _loc2_:Class = this.getClazzByOrientation(param1.orientation,param1.style);
         if(!_loc2_)
         {
            return;
         }
         var _loc3_:IGuiAlert = this.getGuiAlert(param1);
         if(_loc3_)
         {
            return;
         }
         ++this._numAlerts;
         param1.addEventListener(AlertEvent.ALERT_CHANGED,this.alertChangedHandler);
         var _loc4_:IGuiAlert = new _loc2_() as IGuiAlert;
         this.allAlerts[param1] = _loc4_;
         var _loc5_:Vector.<IGuiAlert> = this.getAlertsByOrientation(param1.orientation);
         _loc5_.push(_loc4_);
         _loc4_.init(this.context,param1,this);
         _loc6_ = new Sprite();
         this.holders[_loc4_] = _loc6_;
         addChild(_loc6_);
         _loc6_.addChild(_loc4_.movieClip);
         _loc6_.scaleX = _loc6_.scaleY = this._alertScale * this.getOrientationScale(param1.orientation);
         if(param1.orientation == AlertOrientationType.RIGHT_BOTTOM_VS)
         {
            _loc4_.movieClip.visible = this._vsCanUse;
            _loc6_.y = this.getVsAlertY(param1.style);
            if(this._vsCanUse)
            {
               this.context.playSound("ui_players_turn");
            }
         }
         else
         {
            _loc6_.y = this.getAlertY(_loc5_.length - 1) * this._alertScale;
         }
         if(param1.orientation == AlertOrientationType.LEFT)
         {
            _loc6_.x = 0;
         }
         else
         {
            _loc6_.x = width;
         }
         if(!this.current || param1.orientation == AlertOrientationType.RIGHT_BOTTOM_VS)
         {
            _loc4_.maximize();
         }
         else
         {
            _loc4_.minimize();
         }
         this.alertsEnabledHandler(null);
      }
      
      private function getVsAlertY(param1:AlertStyleType) : Number
      {
         switch(param1)
         {
            case AlertStyleType.VS_QUICK:
               return height - 600 * this._alertScale;
            case AlertStyleType.VS_RANKED:
               return height - 425 * this._alertScale;
            case AlertStyleType.VS_TOURNEY:
               return height - 250 * this._alertScale;
            default:
               return 0;
         }
      }
      
      private function initExistingAlerts() : void
      {
         var _loc1_:Alert = null;
         for each(_loc1_ in this.manager.alerts)
         {
            this.addAlert(_loc1_);
         }
      }
      
      private function getAlertY(param1:int) : Number
      {
         var _loc2_:int = 100;
         var _loc3_:int = 200;
         return _loc2_ + param1 * _loc3_;
      }
      
      public function guiAlertMaximized(param1:IGuiAlert) : void
      {
         var _loc3_:IGuiAlert = null;
         var _loc2_:Timer = this.getReappearTimerByOrientation(param1.alert.orientation);
         _loc2_.stop();
         this.current = param1;
         if(this.current.alert.orientation != AlertOrientationType.RIGHT_BOTTOM_VS)
         {
            for each(_loc3_ in this.allAlerts)
            {
               if(_loc3_ != this.current && _loc3_.alert.orientation == this.current.alert.orientation)
               {
                  _loc3_.minimize();
               }
            }
         }
      }
      
      public function guiAlertMinimized(param1:IGuiAlert) : void
      {
         var _loc2_:Timer = null;
         if(this.current == param1)
         {
            this.current = null;
            _loc2_ = this.getReappearTimerByOrientation(param1.alert.orientation);
            _loc2_.reset();
            _loc2_.start();
         }
      }
      
      public function guiAlertDeparted(param1:IGuiAlert) : void
      {
         this.removeAlert(param1.alert);
      }
      
      private function getOrientationForTimer(param1:Timer) : AlertOrientationType
      {
         var _loc2_:Object = null;
         var _loc3_:AlertOrientationType = null;
         var _loc4_:Timer = null;
         for(_loc2_ in this.reappearTimersByOrientation)
         {
            _loc3_ = _loc2_ as AlertOrientationType;
            _loc4_ = this.reappearTimersByOrientation[_loc3_];
            if(_loc4_ == param1)
            {
               return _loc3_;
            }
         }
         return null;
      }
      
      private function timerCompleteHandler(param1:TimerEvent) : void
      {
         var _loc2_:AlertOrientationType = null;
         var _loc3_:Vector.<IGuiAlert> = null;
         if(this.current == null)
         {
            _loc2_ = this.getOrientationForTimer(param1.target as Timer);
            _loc3_ = this.getAlertsByOrientation(_loc2_);
            if(_loc3_.length > 0)
            {
               _loc3_[0].maximize();
            }
         }
      }
      
      private function alertChangedHandler(param1:AlertEvent) : void
      {
      }
      
      public function updateVsCanUse(param1:Boolean) : void
      {
         var _loc3_:IGuiAlert = null;
         this._vsCanUse = param1;
         var _loc2_:Vector.<IGuiAlert> = this.getAlertsByOrientation(AlertOrientationType.RIGHT_BOTTOM_VS);
         for each(_loc3_ in _loc2_)
         {
            if(this._vsCanUse && !_loc3_.movieClip.visible)
            {
               this.context.playSound("ui_players_turn");
            }
            _loc3_.movieClip.visible = this._vsCanUse;
         }
      }
   }
}

package engine.scene.view
{
   import com.greensock.TweenMax;
   import com.stoicstudio.platform.PlatformInput;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.KeyBindGroup;
   import engine.core.cmd.KeyBinder;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.core.gp.GpDevice;
   import engine.core.gp.GpSource;
   import engine.core.render.BoundedCamera;
   import engine.core.render.Camera;
   import engine.gui.IGuiTalkie;
   import engine.gui.page.PageManagerAdapter;
   import engine.landscape.def.LandscapeSpriteDef;
   import engine.landscape.model.Landscape;
   import engine.landscape.view.ILandscapeView;
   import engine.landscape.view.LandscapeViewController;
   import engine.math.MathUtil;
   import engine.saga.Saga;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.ui.Keyboard;
   
   public class SceneMouseAdapterGp
   {
      
      public static var ZOOM_USING_GP_TRIGGERS:Boolean = false;
      
      public static const BINDGROUP:String = KeyBindGroup.SCENE;
       
      
      private const TOUCH_PAD_MAX_X:Number = 1920;
      
      private const TOUCH_PAD_MAX_Y:Number = 900;
      
      private const TOUCH_PAD_PAN_SPEED:Number = 0.65;
      
      private var cmd_clickable_next:Cmd;
      
      private var cmd_clickable_prev:Cmd;
      
      private var cmd_clickable_click:Cmd;
      
      private var cmd_clickable_cancel:Cmd;
      
      private var controllerCameraPauseDirty:Boolean;
      
      private var c:BoundedCamera;
      
      private var gpbinder:GpBinder;
      
      private var adapter:SceneMouseAdapter;
      
      public var landscapeController:LandscapeViewController;
      
      public var landscape:Landscape;
      
      public var view:SceneViewSprite;
      
      public var landscapeView:ILandscapeView;
      
      public var gpbindid:int;
      
      private var touches:Array;
      
      private var saga:Saga;
      
      private var _sleeping:Boolean;
      
      private var _leftSticking:Boolean;
      
      private var _rightSticking:Boolean;
      
      private var wasEnabled:Boolean;
      
      private var _ready:Boolean;
      
      private var _withClickables:Boolean;
      
      public function SceneMouseAdapterGp(param1:BoundedCamera, param2:SceneMouseAdapter, param3:Saga)
      {
         this.cmd_clickable_next = new Cmd("cmd_clickable_next",this.func_cmd_clickable_next);
         this.cmd_clickable_prev = new Cmd("cmd_clickable_prev",this.func_cmd_clickable_prev);
         this.cmd_clickable_click = new Cmd("cmd_clickable_click",this.func_cmd_clickable_click);
         this.cmd_clickable_cancel = new Cmd("cmd_clickable_cancel",this.func_cmd_clickable_cancel);
         super();
         this.gpbinder = GpBinder.gpbinder;
         this.c = param1;
         this.adapter = param2;
         this.landscapeController = param2.landscapeController;
         this.landscape = this.landscapeController.landscape;
         this.view = param2.view;
         this.landscapeView = this.view.landscapeView;
         this.touches = new Array();
         this.touches.push(new TouchItem());
         this.saga = param3;
      }
      
      public function cleanup() : void
      {
         this.landscapeController.removeEventListener(LandscapeViewController.EVENT_SELECTED_CLICKABLE,this.landscapeClickableHandler);
         if(this.gpbinder)
         {
            this.gpbinder.unbind(this.cmd_clickable_prev);
            this.gpbinder.unbind(this.cmd_clickable_next);
            this.gpbinder.unbind(this.cmd_clickable_click);
            this.gpbinder.unbind(this.cmd_clickable_cancel);
         }
         KeyBinder.keybinder.unbind(this.cmd_clickable_next);
         KeyBinder.keybinder.unbind(this.cmd_clickable_prev);
         this.cmd_clickable_prev.cleanup();
         this.cmd_clickable_next.cleanup();
         this.cmd_clickable_click.cleanup();
         this.cmd_clickable_cancel.cleanup();
      }
      
      private function pointIsZero(param1:Point) : Boolean
      {
         return param1.x == 0 && param1.y == 0;
      }
      
      private function setPoint(param1:Point, param2:Point) : void
      {
         param1.setTo(param2.x,param2.y);
      }
      
      public function updateCamera(param1:int) : void
      {
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc2_:Number = 0.001 * GpSource.stickSensitivityFactor;
         var _loc3_:Number = 2 * GpSource.stickSensitivityFactor;
         var _loc4_:Number = 0.2;
         var _loc5_:GpDevice = GpSource.primaryDevice;
         if(!_loc5_)
         {
            return;
         }
         this.touches[0].curr.setTo(_loc5_.getStickValue(GpControlButton.TOUCH_PAD_0_X),_loc5_.getStickValue(GpControlButton.TOUCH_PAD_0_Y));
         var _loc6_:* = !this.pointIsZero(this.touches[0].curr);
         if(_loc6_ && this.pointIsZero(this.touches[0].prev) && this.pointIsZero(this.touches[0].start))
         {
            this.setPoint(this.touches[0].start,this.touches[0].curr);
         }
         else if(!_loc6_)
         {
            this.touches[0].clearPoints();
         }
         var _loc7_:Number = Number(this.touches[0].curr.x) - Number(this.touches[0].start.x);
         var _loc8_:Number = Number(this.touches[0].curr.y) - Number(this.touches[0].start.y);
         var _loc9_:Number = MathUtil.map(_loc7_,-this.TOUCH_PAD_MAX_X,this.TOUCH_PAD_MAX_X,-1,1);
         var _loc10_:Number = MathUtil.map(_loc8_,-this.TOUCH_PAD_MAX_Y,this.TOUCH_PAD_MAX_Y,-1,1);
         var _loc11_:Number = _loc5_.getStickValue(GpControlButton.AXIS_RIGHT_H);
         var _loc12_:Number = _loc5_.getStickValue(GpControlButton.AXIS_RIGHT_V);
         var _loc13_:Number = _loc6_ ? _loc9_ : _loc11_;
         var _loc14_:Number = _loc6_ ? _loc10_ : _loc12_;
         var _loc15_:Number = 0;
         var _loc16_:Number = 0;
         var _loc17_:Number = 0;
         if(SceneMouseAdapterGp.ZOOM_USING_GP_TRIGGERS && Camera.ALLOW_ZOOM)
         {
            _loc18_ = MathUtil.map(_loc5_.getStickValue(GpControlButton.AXIS_LEFT_T),-1,1,0,1);
            _loc19_ = MathUtil.map(_loc5_.getStickValue(GpControlButton.AXIS_RIGHT_T),-1,1,0,1);
            _loc17_ = _loc18_ == _loc19_ ? 0 : (_loc18_ > _loc19_ ? -_loc18_ : _loc19_) * param1 * _loc2_;
         }
         if(_loc6_ || Math.abs(_loc13_) > _loc4_ || Math.abs(_loc14_) > _loc4_ || _loc17_ != 0)
         {
            this.rightSticking = true;
            TweenMax.killDelayedCallsTo(this.sleepPointer);
            this.sleeping = false;
            this.adapter.controller.setGpPointerEnabled(true);
            this.controllerCameraPauseDirty = true;
            this.c.pause = true;
            if(_loc6_)
            {
               if(!this.pointIsZero(this.touches[0].prev))
               {
                  _loc15_ = (Number(this.touches[0].prev.x) - Number(this.touches[0].curr.x)) * this.TOUCH_PAD_PAN_SPEED;
                  _loc16_ = (Number(this.touches[0].prev.y) - Number(this.touches[0].curr.y)) * this.TOUCH_PAD_PAN_SPEED;
               }
            }
            else
            {
               _loc13_ *= Math.min(1,Math.abs(_loc13_));
               _loc14_ *= Math.min(1,Math.abs(_loc14_));
               if(GpSource.invertRightStick)
               {
                  _loc14_ = -_loc14_;
               }
               _loc15_ = _loc13_ * param1 * _loc3_;
               _loc16_ = _loc14_ * param1 * _loc3_;
            }
            if(!SceneMouseAdapterGp.ZOOM_USING_GP_TRIGGERS && _loc5_.getControlValue(GpControlButton.R3) == 1 && Camera.ALLOW_ZOOM)
            {
               _loc17_ = -_loc14_ * param1 * _loc2_;
               _loc15_ = 0;
               _loc16_ = 0;
            }
            _loc20_ = this.c.panClampedX - this.c.actualTiltOffset.x;
            _loc21_ = this.c.panClampedY - this.c.actualTiltOffset.y;
            if(this.adapter.canPan)
            {
               this.c.setPosition(_loc20_ + _loc15_,_loc21_ + _loc16_);
            }
            this.adapter.scale += _loc17_;
         }
         else
         {
            this.rightSticking = false;
            if(this.controllerCameraPauseDirty && _loc17_ == 0)
            {
               this.controllerCameraPauseDirty = false;
               this.c.pause = false;
            }
         }
         this.setPoint(this.touches[0].prev,this.touches[0].curr);
      }
      
      public function get sleeping() : Boolean
      {
         if(this.saga.mapCamp)
         {
            return false;
         }
         return this._sleeping;
      }
      
      public function set sleeping(param1:Boolean) : void
      {
         if(this._sleeping == param1 || this.saga.mapCamp)
         {
            return;
         }
         this._sleeping = param1;
         TweenMax.killDelayedCallsTo(this.sleepPointer);
         if(this._sleeping)
         {
            this._leftSticking = false;
         }
         this.adapter.controller.setGpPointerEnabled(!this._sleeping);
      }
      
      public function get leftSticking() : Boolean
      {
         return this._leftSticking;
      }
      
      public function set leftSticking(param1:Boolean) : void
      {
         if(this._leftSticking == param1)
         {
            return;
         }
         this._leftSticking = param1;
         if(!this._leftSticking)
         {
            this.delayedSleepPointer();
         }
         else
         {
            TweenMax.killDelayedCallsTo(this.sleepPointer);
            this.sleeping = false;
         }
      }
      
      public function get rightSticking() : Boolean
      {
         return this._rightSticking;
      }
      
      public function set rightSticking(param1:Boolean) : void
      {
         if(this._rightSticking == param1)
         {
            return;
         }
         this._rightSticking = param1;
         if(!this._rightSticking)
         {
            this.delayedSleepPointer();
         }
         else
         {
            TweenMax.killDelayedCallsTo(this.sleepPointer);
         }
      }
      
      public function delayedSleepPointer() : void
      {
         var _loc1_:Number = 5;
         TweenMax.delayedCall(_loc1_,this.sleepPointer);
      }
      
      public function updatePointer(param1:int) : void
      {
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc2_:GpDevice = GpSource.primaryDevice;
         if(!_loc2_ || !this.adapter.controller)
         {
            return;
         }
         if(this.view && this.view.scene && Boolean(this.view.scene.focusedBoard))
         {
            if(this._leftSticking)
            {
               this.leftSticking = false;
            }
            if(!this._sleeping)
            {
               this.sleeping = true;
            }
            return;
         }
         var _loc3_:Number = _loc2_.getControlValue(GpControlButton.AXIS_LEFT_H);
         var _loc4_:Number = _loc2_.getControlValue(GpControlButton.AXIS_LEFT_V);
         var _loc5_:Number = 0.002 * GpSource.stickSensitivityFactor;
         var _loc6_:Number = 0.2;
         var _loc7_:Number = Math.min(1,Math.abs(_loc3_));
         var _loc8_:Number = Math.min(1,Math.abs(_loc4_));
         if(_loc7_ > _loc6_ || _loc8_ > _loc6_)
         {
            if(!PlatformInput.lastInputGp)
            {
               this.adapter.controller.syncGpPointerWithMouse();
            }
            this.leftSticking = true;
            _loc3_ *= _loc7_;
            _loc4_ *= _loc8_;
            if(GpSource.invertLeftStick)
            {
               _loc4_ = -_loc4_;
            }
            this.controllerCameraPauseDirty = true;
            this.c.pause = true;
            _loc9_ = _loc3_ * param1 * _loc5_;
            _loc10_ = _loc4_ * param1 * _loc5_;
            _loc11_ = this.adapter.controller.gpPointerX;
            _loc12_ = this.adapter.controller.gpPointerY;
            this.adapter.controller.setGpPointerPos(_loc11_ + _loc9_,_loc12_ + _loc10_);
         }
         else
         {
            this.leftSticking = false;
         }
      }
      
      private function sleepPointer() : void
      {
         this.sleeping = true;
      }
      
      public function update(param1:int) : void
      {
         if(!this._ready || !this.adapter || !this.adapter.controller || !GpSource.instance.enabled || !this.gpbinder)
         {
            return;
         }
         if(PageManagerAdapter.IS_LOADING || GpBinder.DISALLOW_INPUT_DURING_LOAD || PageManagerAdapter.OVERLAY_VISIBLE)
         {
            return;
         }
         if(!this.adapter.controller.enabled)
         {
            if(this.wasEnabled && !this.sleeping)
            {
               this.rightSticking = false;
               this.leftSticking = false;
               TweenMax.killDelayedCallsTo(this.sleepPointer);
            }
            this.wasEnabled = false;
            return;
         }
         this.updateCamera(param1);
         if(!this._withClickables)
         {
            return;
         }
         if(this.gpbinder.topLayer > this.gpbindid)
         {
            if(this.wasEnabled && !this.sleeping)
            {
               this.leftSticking = false;
               TweenMax.killDelayedCallsTo(this.sleepPointer);
            }
            this.wasEnabled = false;
            return;
         }
         if(!this.wasEnabled)
         {
            if(!this.sleeping)
            {
               this.delayedSleepPointer();
            }
         }
         this.wasEnabled = true;
         if(!PlatformInput.lastInputGp && !this._sleeping)
         {
            this.sleeping = true;
         }
         this.updatePointer(param1);
      }
      
      private function func_cmd_clickable_next(param1:CmdExec) : void
      {
         var _loc2_:Point = null;
         var _loc8_:Boolean = false;
         var _loc9_:Boolean = false;
         if(!this.view || !this.landscape || !this.landscape.scene.ready)
         {
            return;
         }
         TweenMax.killDelayedCallsTo(this.sleepPointer);
         var _loc3_:LandscapeSpriteDef = this.landscapeView.hoverClickable;
         if(_loc3_)
         {
            _loc2_ = this.landscapeView.getClickablePointGlobal(_loc3_);
         }
         else if(this.adapter.controller.hoverTalkie)
         {
            _loc2_ = this.adapter.controller.hoverTalkie.talkieCenterPoint_g;
         }
         var _loc4_:LandscapeSpriteDef = this.landscapeView.selectClickable_next(_loc3_,_loc2_);
         var _loc5_:IGuiTalkie = this.adapter.controller.selectTalkie_next(_loc2_);
         var _loc6_:Point = !!_loc4_ ? this.landscapeView.getClickablePointGlobal(_loc4_) : null;
         var _loc7_:Point = !!_loc5_ ? _loc5_.talkieCenterPoint_g : null;
         if(Boolean(_loc6_) && !_loc7_)
         {
            this.adapter.controller.hoverGpPointerClickable(_loc4_);
         }
         else if(Boolean(_loc7_) && !_loc6_)
         {
            this.adapter.controller.hoverGpPointerTalkie(_loc5_,_loc7_);
         }
         else if(Boolean(_loc7_) && Boolean(_loc6_))
         {
            if(_loc2_)
            {
               _loc8_ = _loc7_.x > _loc2_.x || _loc7_.x == _loc2_.x && _loc7_.y > _loc2_.y;
               _loc9_ = _loc6_.x > _loc2_.x || _loc6_.x == _loc2_.x && _loc6_.y > _loc2_.y;
               if(_loc8_ && !_loc9_)
               {
                  this.adapter.controller.hoverGpPointerTalkie(_loc5_,_loc7_);
                  return;
               }
               if(!_loc8_ && _loc9_)
               {
                  this.adapter.controller.hoverGpPointerClickable(_loc4_);
                  return;
               }
            }
            if(_loc7_.x < _loc6_.x || _loc7_.x == _loc6_.x && _loc7_.y < _loc6_.y)
            {
               this.adapter.controller.hoverGpPointerTalkie(_loc5_,_loc7_);
            }
            else
            {
               this.adapter.controller.hoverGpPointerClickable(_loc4_);
            }
         }
      }
      
      private function func_cmd_clickable_prev(param1:CmdExec) : void
      {
         var _loc2_:Point = null;
         var _loc8_:Boolean = false;
         var _loc9_:Boolean = false;
         if(!this.view || !this.landscape || !this.landscape.scene.ready)
         {
            return;
         }
         TweenMax.killDelayedCallsTo(this.sleepPointer);
         var _loc3_:LandscapeSpriteDef = this.landscapeView.hoverClickable;
         if(_loc3_)
         {
            _loc2_ = this.landscapeView.getClickablePointGlobal(_loc3_);
         }
         else if(this.adapter.controller.hoverTalkie)
         {
            _loc2_ = this.adapter.controller.hoverTalkie.talkieCenterPoint_g;
         }
         var _loc4_:LandscapeSpriteDef = this.landscapeView.selectClickable_prev(_loc3_,_loc2_);
         var _loc5_:IGuiTalkie = this.adapter.controller.selectTalkie_prev(_loc2_);
         var _loc6_:Point = !!_loc4_ ? this.landscapeView.getClickablePointGlobal(_loc4_) : null;
         var _loc7_:Point = !!_loc5_ ? _loc5_.talkieCenterPoint_g : null;
         if(Boolean(_loc6_) && !_loc7_)
         {
            this.adapter.controller.hoverGpPointerClickable(_loc4_);
         }
         else if(Boolean(_loc7_) && !_loc6_)
         {
            this.adapter.controller.hoverGpPointerTalkie(_loc5_,_loc7_);
         }
         else if(Boolean(_loc7_) && Boolean(_loc6_))
         {
            if(_loc2_)
            {
               _loc8_ = _loc7_.x < _loc2_.x || _loc7_.x == _loc2_.x && _loc7_.y < _loc2_.y;
               _loc9_ = _loc6_.x < _loc2_.x || _loc6_.x == _loc2_.x && _loc6_.y < _loc2_.y;
               if(_loc8_ && !_loc9_)
               {
                  this.adapter.controller.hoverGpPointerTalkie(_loc5_,_loc7_);
                  return;
               }
               if(!_loc8_ && _loc9_)
               {
                  this.adapter.controller.hoverGpPointerClickable(_loc4_);
                  return;
               }
            }
            if(_loc7_.x > _loc6_.x || _loc7_.x == _loc6_.x && _loc7_.y > _loc6_.y)
            {
               this.adapter.controller.hoverGpPointerTalkie(_loc5_,_loc7_);
            }
            else
            {
               this.adapter.controller.hoverGpPointerClickable(_loc4_);
            }
         }
      }
      
      private function func_cmd_clickable_click(param1:CmdExec) : void
      {
         if(!this.adapter || !this.adapter.controller)
         {
            return;
         }
         this.adapter.controller.clickGpSelection();
      }
      
      private function func_cmd_clickable_cancel(param1:CmdExec) : void
      {
         if(!this.view || !this.landscape || !this.landscape.scene.ready || !this.landscapeController)
         {
            return;
         }
         PlatformInput.dispatcher.dispatchEvent(new Event(PlatformInput.EVENT_CURSOR_CANCEL_PRESS));
         this.sleeping = true;
      }
      
      private function landscapeClickableHandler(param1:Event) : void
      {
         var _loc2_:LandscapeSpriteDef = this.landscapeController.landscapeClickable;
      }
      
      public function handleSceneReady() : void
      {
         this._ready = true;
         this.landscapeController.addEventListener(LandscapeViewController.EVENT_SELECTED_CLICKABLE,this.landscapeClickableHandler);
         this.adapter.controller.gpHoverDisabledByScene = true;
         if(!this.view || !this.view.scene)
         {
            return;
         }
         if(this.view.scene.focusedBoard)
         {
            return;
         }
         if(this.view.scene.convo)
         {
            return;
         }
         if(this.view.scene.isStartScene)
         {
            return;
         }
         this.adapter.controller.gpHoverDisabledByScene = false;
         this._withClickables = true;
         if(this.gpbinder)
         {
            this.gpbindid = this.gpbinder.topLayer;
            this.gpbinder.bindPress(GpControlButton.L1,this.cmd_clickable_prev,BINDGROUP,true);
            this.gpbinder.bindPress(GpControlButton.R1,this.cmd_clickable_next,BINDGROUP,true);
         }
         KeyBinder.keybinder.bind(false,false,false,Keyboard.RIGHT,this.cmd_clickable_next,BINDGROUP);
         KeyBinder.keybinder.bind(false,false,false,Keyboard.LEFT,this.cmd_clickable_prev,BINDGROUP);
      }
      
      public function handleGpSelection(param1:Boolean) : void
      {
         if(!this._withClickables || !this.gpbinder)
         {
            return;
         }
         this.gpbinder.unbind(this.cmd_clickable_click);
         this.gpbinder.unbind(this.cmd_clickable_cancel);
         if(param1)
         {
            this.gpbinder.bindPress(GpControlButton.A,this.cmd_clickable_click,BINDGROUP,true);
            this.gpbinder.bindPress(GpControlButton.B,this.cmd_clickable_cancel,BINDGROUP,true);
         }
      }
   }
}

import flash.geom.Point;

class TouchItem
{
    
   
   public var start:Point;
   
   public var prev:Point;
   
   public var curr:Point;
   
   public function TouchItem()
   {
      super();
      this.start = new Point();
      this.prev = new Point();
      this.curr = new Point();
   }
   
   public function clearPoints() : void
   {
      this.start.setTo(0,0);
      this.prev.setTo(0,0);
      this.curr.setTo(0,0);
   }
   
   public function toString() : String
   {
      return "start: " + this.start.toString() + ", prev: " + this.prev.toString() + ", curr: " + this.curr.toString();
   }
}

package engine.scene.view
{
   import com.stoicstudio.platform.Platform;
   import com.stoicstudio.platform.PlatformFlash;
   import com.stoicstudio.platform.PlatformInput;
   import com.stoicstudio.platform.PlatformStarling;
   import engine.battle.board.BattleBoardEvent;
   import engine.battle.board.controller.BattleBoardController;
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.view.BattleBoardView;
   import engine.core.render.BoundedCamera;
   import engine.gui.IEngineGuiContext;
   import engine.gui.IGuiTalkie;
   import engine.landscape.def.LandscapeSpriteDef;
   import engine.landscape.model.Landscape;
   import engine.landscape.travel.view.TravelView;
   import engine.landscape.view.ClickablePair;
   import engine.landscape.view.ILandscapeView;
   import engine.landscape.view.LandscapeViewConfig;
   import engine.landscape.view.LandscapeViewController;
   import engine.math.MathUtil;
   import engine.saga.Saga;
   import engine.saga.SagaEvent;
   import engine.scene.model.Scene;
   import engine.scene.model.SceneEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.system.Capabilities;
   import flash.system.TouchscreenType;
   import org.gestouch.core.GestureState;
   import org.gestouch.events.GestureEvent;
   import org.gestouch.gestures.ZoomGesture;
   import starling.core.Starling;
   import starling.display.DisplayObject;
   import starling.events.Touch;
   import starling.events.TouchEvent;
   import starling.events.TouchPhase;
   
   public class SceneViewController extends EventDispatcher
   {
       
      
      public var view:SceneViewSprite;
      
      private var mouseAdapter:SceneMouseAdapter;
      
      public var boardController:BattleBoardController;
      
      public var landscapeController:LandscapeViewController;
      
      public var landscape:Landscape;
      
      public var scene:Scene;
      
      public var mouseDown:Boolean;
      
      private var saga:Saga;
      
      private var _panDisabled:Boolean;
      
      private var zg:ZoomGesture;
      
      private var _enabled:Boolean;
      
      public var guiContext:IEngineGuiContext;
      
      private var gpPointerCallback:Function;
      
      private var camera:BoundedCamera;
      
      private var talkieNextPrevCallback:Function;
      
      private var _lastCameraViewChangeCounter:uint;
      
      private var _board:BattleBoard;
      
      public var gpPointerX:Number = 0;
      
      public var gpPointerY:Number = 0;
      
      public var gpPointerEnabled:Boolean;
      
      public var gpPointerX_s:Number = 0;
      
      public var gpPointerY_s:Number = 0;
      
      private var _hoverTalkie:IGuiTalkie;
      
      private var _gpPointerAllowHover:Boolean;
      
      private var _gpHoverDisabledByScene:Boolean;
      
      public function SceneViewController(param1:SceneViewSprite, param2:IEngineGuiContext, param3:Function, param4:Function, param5:Function)
      {
         super();
         this.view = param1;
         this.scene = param1.scene;
         this.guiContext = param2;
         this.gpPointerCallback = param3;
         this.landscape = this.scene.landscape;
         this.camera = this.scene._camera;
         this.talkieNextPrevCallback = param5;
         this.scene.addEventListener(SceneEvent.FOCUSED_BOARD,this.sceneFocusedBoardHandler);
         this.scene.addEventListener(SceneEvent.READY,this.sceneReadyHandler);
         this.landscape.addEventListener(Landscape.EVENT_ENABLE_HOVER,this.landscapeEnableHoverHandler);
         PlatformInput.dispatcher.addEventListener(PlatformInput.EVENT_CURSOR_LOST_FOCUS,this.handleCursorLostFocus);
         if(param1.landscapeView)
         {
            this.landscapeController = new LandscapeViewController(param1.landscapeView,param4);
         }
         this.saga = param1.scene._context.saga as Saga;
         if(this.saga)
         {
            this.saga.addEventListener(SagaEvent.EVENT_SHOW_CARAVAN,this.sagaShowCaravanHandler);
            this.saga.addEventListener(SagaEvent.EVENT_HALT,this.sagaHaltHandler);
            this.saga.addEventListener(SagaEvent.EVENT_CARAVAN_CAMERA_LOCK,this.sagaCaravanCameraLockHandler);
            this.saga.addEventListener(SagaEvent.EVENT_CAMERA_PANNING,this.sagaCameraPanningHandler);
            this.saga.addEventListener(SagaEvent.EVENT_CAMP,this.sagaCampHandler);
         }
         this.mouseAdapter = new SceneMouseAdapter(this,param1,1,this.saga);
         this.sceneFocusedBoardHandler(null);
         this.zg = new ZoomGesture(PlatformFlash.stage);
         this.enabled = false;
      }
      
      public function update(param1:int) : void
      {
         if(Boolean(this.camera) && this.camera.viewChangeCounter != this._lastCameraViewChangeCounter)
         {
            this.gpPointerAllowHover = true;
            this._lastCameraViewChangeCounter = this.camera.viewChangeCounter;
            if(this.gpPointerEnabled && !this.saga.paused)
            {
               this.updateGpPointerPos_s(true);
            }
         }
         this.mouseAdapter.update(param1);
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         param1 = param1 && !this.scene._def.inputDisabled;
         if(Boolean(this.saga) && this.saga.mapCampCinema)
         {
            param1 = false;
         }
         this._enabled = param1;
         if(this._enabled)
         {
            this.enableInput();
         }
         else
         {
            this.disableInput();
         }
         this.checkCanPan();
      }
      
      public function cleanup() : void
      {
         this.board = null;
         if(this.landscape)
         {
            this.landscape.removeEventListener(Landscape.EVENT_ENABLE_HOVER,this.landscapeEnableHoverHandler);
            this.landscape = null;
         }
         if(this.landscapeController)
         {
            this.landscapeController.cleanup();
            this.landscapeController = null;
         }
         if(this.saga)
         {
            this.saga.removeEventListener(SagaEvent.EVENT_CARAVAN_CAMERA_LOCK,this.sagaCaravanCameraLockHandler);
            this.saga.removeEventListener(SagaEvent.EVENT_SHOW_CARAVAN,this.sagaShowCaravanHandler);
            this.saga.removeEventListener(SagaEvent.EVENT_HALT,this.sagaHaltHandler);
            this.saga.removeEventListener(SagaEvent.EVENT_CAMERA_PANNING,this.sagaCameraPanningHandler);
            this.saga.removeEventListener(SagaEvent.EVENT_CAMP,this.sagaCampHandler);
         }
         if(this.boardController)
         {
            this.boardController.cleanup();
            this.boardController = null;
         }
         this.disableInput();
         this.disableStageInput();
         if(this.zg)
         {
            this.zg.dispose();
            this.zg = null;
         }
         this.scene.removeEventListener(SceneEvent.FOCUSED_BOARD,this.sceneFocusedBoardHandler);
         this.scene.removeEventListener(SceneEvent.READY,this.sceneReadyHandler);
         this.scene = null;
         PlatformInput.dispatcher.removeEventListener(PlatformInput.EVENT_CURSOR_LOST_FOCUS,this.handleCursorLostFocus);
         this.view = null;
         this.saga = null;
      }
      
      public function get panDisabled() : Boolean
      {
         return this._panDisabled;
      }
      
      public function set panDisabled(param1:Boolean) : void
      {
         this._panDisabled = param1;
         this.checkCanPan();
      }
      
      private function handleCursorLostFocus(param1:Event) : void
      {
         this.saga.logger.info("Cursor lost focus");
         this.setGpPointerEnabled(false);
      }
      
      private function zoomGestureChanged(param1:GestureEvent) : void
      {
         var _loc2_:Point = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         if(PlatformStarling.blockStarling)
         {
            this.zg.reset();
            this.checkCanPan();
         }
         else
         {
            _loc2_ = this.zg._location;
            _loc3_ = Math.max(this.zg.scaleX,this.zg.scaleY);
            _loc4_ = this.mouseAdapter.scale * _loc3_;
            if(Boolean(this.scene) && Boolean(this.scene._camera))
            {
               this.scene._camera.pause = true;
            }
            this.mouseAdapter.handlePinchZoom(_loc4_,_loc2_.x,_loc2_.y);
            if(this.landscapeController)
            {
               this.landscapeController.clear();
            }
         }
      }
      
      private function zoomGestureBegan(param1:GestureEvent) : void
      {
         if(PlatformStarling.blockStarling)
         {
            this.zg.reset();
         }
         this.checkCanPan();
      }
      
      private function zoomGestureEnded(param1:GestureEvent) : void
      {
         if(PlatformStarling.blockStarling)
         {
            this.zg.reset();
         }
         this.checkCanPan();
      }
      
      private function zoomGestureStateChange(param1:GestureEvent) : void
      {
      }
      
      private function enableInput() : void
      {
         var _loc1_:DisplayObject = null;
         this.zg.enabled = true;
         this.view.mouseEnabled = true;
         if(PlatformStarling.instance)
         {
            _loc1_ = Starling.current.root;
            _loc1_.addEventListener(TouchEvent.TOUCH,this.touchHandler);
            PlatformFlash.stage.addEventListener(MouseEvent.MOUSE_MOVE,this.mouseMoveHandler);
         }
         else
         {
            this.view.addEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler);
            this.view.addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler);
            this.view.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN,this.mouseDownHandler);
            this.view.addEventListener(MouseEvent.MOUSE_MOVE,this.mouseMoveHandler);
         }
         if(PlatformFlash.stage)
         {
            PlatformFlash.stage.addEventListener(MouseEvent.MOUSE_WHEEL,this.mouseWheelHandler);
         }
         this.zg.addEventListener(GestureEvent.GESTURE_CHANGED,this.zoomGestureChanged);
         this.zg.addEventListener(GestureEvent.GESTURE_BEGAN,this.zoomGestureBegan);
         this.zg.addEventListener(GestureEvent.GESTURE_ENDED,this.zoomGestureEnded);
         this.zg.addEventListener(GestureEvent.GESTURE_STATE_CHANGE,this.zoomGestureStateChange);
      }
      
      private function disableInput() : void
      {
         var _loc1_:DisplayObject = null;
         this.zg.enabled = false;
         this.view.mouseEnabled = false;
         if(this.zg)
         {
            this.zg.removeEventListener(GestureEvent.GESTURE_CHANGED,this.zoomGestureChanged);
            this.zg.removeEventListener(GestureEvent.GESTURE_BEGAN,this.zoomGestureBegan);
            this.zg.removeEventListener(GestureEvent.GESTURE_ENDED,this.zoomGestureEnded);
            this.zg.removeEventListener(GestureEvent.GESTURE_STATE_CHANGE,this.zoomGestureStateChange);
         }
         if(PlatformStarling.instance)
         {
            _loc1_ = Starling.current.root;
            _loc1_.removeEventListener(TouchEvent.TOUCH,this.touchHandler);
            PlatformFlash.stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.mouseMoveHandler);
         }
         else
         {
            this.view.removeEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler);
            this.view.removeEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler);
            this.view.removeEventListener(MouseEvent.RIGHT_MOUSE_DOWN,this.mouseDownHandler);
            this.view.removeEventListener(MouseEvent.MOUSE_MOVE,this.mouseMoveHandler);
         }
         if(PlatformFlash.stage)
         {
            PlatformFlash.stage.removeEventListener(MouseEvent.MOUSE_WHEEL,this.mouseWheelHandler);
         }
      }
      
      private function disableStageInput() : void
      {
         this.disableInput();
         if(this.mouseAdapter)
         {
            this.mouseAdapter.cleanup();
            this.mouseAdapter = null;
         }
      }
      
      protected function sceneReadyHandler(param1:SceneEvent) : void
      {
         this.enabled = true;
         this.mouseAdapter.handleSceneReady();
      }
      
      public function get board() : BattleBoard
      {
         return this._board;
      }
      
      public function set board(param1:BattleBoard) : void
      {
         if(this._board == param1)
         {
            return;
         }
         if(this._board)
         {
            this._board.removeEventListener(BattleBoardEvent.BOARD_ENTITY_FORCE_CAMERA_CENTER,this.entityForceCameraCenterHandler);
         }
         this._board = param1;
         if(this._board)
         {
            this._board.addEventListener(BattleBoardEvent.BOARD_ENTITY_FORCE_CAMERA_CENTER,this.entityForceCameraCenterHandler);
         }
         this._gpHoverDisabledByScene = this._board != null;
      }
      
      private function entityForceCameraCenterHandler(param1:BattleBoardEvent) : void
      {
         this.checkCanPan();
      }
      
      protected function sceneFocusedBoardHandler(param1:SceneEvent) : void
      {
         var _loc2_:BattleBoardView = null;
         if(this.boardController)
         {
            this.boardController.cleanup();
            this.boardController = null;
         }
         this.board = this.scene.focusedBoard;
         if(Boolean(this.board) && Boolean(this.view.boards))
         {
            _loc2_ = this.view.boards.getBoardView(this.board);
            if(_loc2_)
            {
               this.boardController = new BattleBoardController(this.board,_loc2_);
            }
         }
      }
      
      private function computeCanPan() : Boolean
      {
         if(LandscapeViewConfig.FORCE_UNLOCK_CAMERA_PAN)
         {
            return true;
         }
         if(!this.view || !this.scene || !this.scene._context)
         {
            return false;
         }
         if(this.scene.cameraGlobalLock)
         {
            return false;
         }
         if(!this.enabled)
         {
            return false;
         }
         if(this.zg)
         {
            if(this.zg.state == GestureState.CHANGED || this.zg.state == GestureState.BEGAN)
            {
               return false;
            }
         }
         var _loc1_:TravelView = !!this.view.landscapeView ? this.view.landscapeView.travelView : null;
         if(this.panDisabled)
         {
            return false;
         }
         if(!this.scene.ready)
         {
            return false;
         }
         if(Boolean(_loc1_) && Boolean(this.saga))
         {
            if(this.saga.showCaravan && !this.saga.camped && this.saga.caravanCameraLock)
            {
               return false;
            }
         }
         if(this.saga)
         {
            if(this.saga.cameraPanning > 0)
            {
               return false;
            }
         }
         if(this.scene.focusedBoard)
         {
            if(this.scene.focusedBoard.forceCameraCenterEntity)
            {
               return false;
            }
         }
         return true;
      }
      
      private function checkCanPan() : void
      {
         if(!this.mouseAdapter)
         {
            return;
         }
         this.mouseAdapter.canPan = this.computeCanPan();
         if(Boolean(this.scene) && Boolean(this.scene._camera))
         {
            if(this.zg.state == GestureState.CHANGED || this.zg.state == GestureState.BEGAN)
            {
               this.scene._camera.pause = true;
            }
            else if(this.mouseDown)
            {
               this.scene._camera.pause = true;
            }
            else
            {
               this.scene._camera.pause = false;
            }
         }
      }
      
      private function sagaCampHandler(param1:Event) : void
      {
         this.checkCanPan();
      }
      
      private function sagaCameraPanningHandler(param1:Event) : void
      {
         this.checkCanPan();
      }
      
      private function sagaHaltHandler(param1:Event) : void
      {
         this.checkCanPan();
      }
      
      private function sagaShowCaravanHandler(param1:Event) : void
      {
         this.checkCanPan();
      }
      
      private function sagaCaravanCameraLockHandler(param1:Event) : void
      {
         this.checkCanPan();
      }
      
      final protected function mouseWheelHandler(param1:MouseEvent) : void
      {
         if(!this.scene || !this.scene._context || this.scene._context.eater.isEventEaten(param1))
         {
            return;
         }
         if(Boolean(this.scene) && Boolean(this.scene._camera))
         {
            if(!this.scene._camera.pause)
            {
               this.scene._camera.pause = true;
               this.scene._camera.pause = false;
            }
         }
         if(Boolean(this.mouseAdapter) && this.mouseAdapter.onMouseWheel(param1.stageX,param1.stageY,param1.delta))
         {
            return;
         }
         if(this.boardController)
         {
            this.boardController.mouseWheelHandler(param1);
         }
      }
      
      final protected function handleMouseTouchMove(param1:Number, param2:Number) : void
      {
         if(!this.scene || !this.scene._context || !this.mouseAdapter)
         {
            return;
         }
         var _loc3_:Boolean = false;
         if(this.mouseAdapter.onMouseMove(param1,param2,_loc3_))
         {
            if(this.landscapeController)
            {
               this.landscapeController.clear();
            }
            return;
         }
         if(this.zg)
         {
            if(this.zg.state == GestureState.CHANGED || this.zg.state == GestureState.BEGAN)
            {
               return;
            }
         }
         if(this.landscapeController)
         {
            this.landscapeController.mouseMoveHandler(param1,param2);
         }
         if(this.boardController)
         {
            this.boardController.mouseMoveHandler(param1,param2);
         }
      }
      
      final protected function mouseMoveHandler(param1:MouseEvent) : void
      {
         if(!this.scene || !this.scene._context || this.scene._context.eater.isEventEaten(param1))
         {
            return;
         }
         this.handleMouseTouchMove(param1.stageX,param1.stageY);
      }
      
      final protected function handleMouseTouchUp(param1:Number, param2:Number) : void
      {
         if(!this.scene._context)
         {
            return;
         }
         if(!this.mouseDown)
         {
            return;
         }
         this.mouseDown = false;
         if(this.scene._camera)
         {
            this.scene._camera.pause = false;
         }
         if(this.view.landscapeView)
         {
            this.view.landscapeView.pressedClickable = null;
            this.view.landscapeView.displayHover(null);
         }
         if(this.mouseAdapter.onMouseUp())
         {
            if(this.landscapeController)
            {
               this.landscapeController.clear();
            }
            return;
         }
         if(this.boardController)
         {
            this.boardController.mouseUpHandler(param1,param2);
         }
         if(this.landscapeController)
         {
            this.landscapeController.mouseUpHandler(param1,param2);
         }
      }
      
      final protected function mouseUpHandler(param1:MouseEvent) : void
      {
         if(!this.scene._context)
         {
            return;
         }
         if(this.scene._context.eater.isEventEaten(param1))
         {
            return;
         }
         this.handleMouseTouchUp(param1.stageX,param1.stageY);
      }
      
      final private function touchHandler(param1:TouchEvent) : void
      {
         var _loc3_:Touch = null;
         var _loc2_:int = 0;
         for(; _loc2_ < param1.touches.length; _loc2_++)
         {
            _loc3_ = param1.touches[_loc2_];
            if(!_loc3_.target)
            {
               continue;
            }
            switch(_loc3_.phase)
            {
               case TouchPhase.BEGAN:
                  this.handleMouseTouchDown(_loc3_.globalX,_loc3_.globalY);
                  break;
               case TouchPhase.ENDED:
                  this.handleMouseTouchUp(_loc3_.globalX,_loc3_.globalY);
                  break;
               case TouchPhase.MOVED:
                  this.handleMouseTouchMove(_loc3_.globalX,_loc3_.globalY);
                  break;
            }
         }
      }
      
      final private function handleMouseTouchDown(param1:Number, param2:Number) : void
      {
         if(!this.scene || !this.scene._context || this.scene.cleanedup)
         {
            return;
         }
         Platform.toucher.touchInputActive();
         this.mouseDown = true;
         if(Boolean(this.mouseAdapter) && this.mouseAdapter.canPan)
         {
            this.scene._camera.pause = true;
         }
         if(this.mouseAdapter.onMouseDown(param1,param2))
         {
            return;
         }
         if(this.boardController)
         {
            this.boardController.mouseDownHandler(param1,param2);
         }
         if(this.landscapeController)
         {
            this.landscapeController.mouseDownHandler(param1,param2);
         }
      }
      
      final protected function mouseDownHandler(param1:MouseEvent) : void
      {
         if(!this.scene || !this.scene._context || this.scene.cleanedup || this.scene._context.eater.isEventEaten(param1))
         {
            return;
         }
         this.handleMouseTouchDown(param1.stageX,param1.stageY);
      }
      
      final protected function keyDownHandler(param1:KeyboardEvent) : void
      {
      }
      
      public function doFf() : Boolean
      {
         if(this.landscapeController)
         {
            if(this.landscapeController.doFf(false))
            {
               return true;
            }
         }
         return false;
      }
      
      public function syncMouseAdapter() : void
      {
         var _loc1_:* = false;
         if(this.mouseAdapter)
         {
            _loc1_ = false;
            _loc1_ = Capabilities.touchscreenType != TouchscreenType.NONE;
            this.mouseAdapter.syncToCamera(!_loc1_);
         }
      }
      
      public function setGpPointerPos(param1:Number, param2:Number) : void
      {
         var _loc3_:Boolean = this._gpPointerAllowHover;
         this.gpPointerAllowHover = true;
         if(this._gpHoverDisabledByScene)
         {
            this.gpPointerEnabled = false;
            return;
         }
         param1 = MathUtil.clampValue(param1,-1,1);
         param2 = MathUtil.clampValue(param2,-1,1);
         if(!_loc3_ || !this.gpPointerEnabled || this.gpPointerX != param1 || this.gpPointerY != param2)
         {
            this.gpPointerEnabled = true;
            this.gpPointerX = param1;
            this.gpPointerY = param2;
            this.updateGpPointerPos_s(!_loc3_);
         }
      }
      
      public function syncGpPointerWithMouse() : void
      {
         this.syncGpPointerWithScreenPoint(PlatformFlash.stage.mouseX,PlatformFlash.stage.mouseY);
      }
      
      public function syncGpPointerWithScreenPoint(param1:Number, param2:Number) : void
      {
         if(this.gpPointerX_s == param1 && this.gpPointerY_s == param2)
         {
            return;
         }
         this.gpPointerX_s = param1;
         this.gpPointerY_s = param2;
         var _loc3_:Number = PlatformFlash.stage.stageWidth;
         var _loc4_:Number = PlatformFlash.stage.stageHeight;
         this.gpPointerX = this.gpPointerX_s * 2 / _loc3_ - 1;
         this.gpPointerY = this.gpPointerY_s * 2 / _loc4_ - 1;
         this.notifyGpPointer();
      }
      
      private function updateGpPointerPos_s(param1:Boolean) : void
      {
         var _loc2_:Number = PlatformFlash.stage.stageWidth;
         var _loc3_:Number = PlatformFlash.stage.stageHeight;
         var _loc4_:Number = _loc2_ * (this.gpPointerX + 1) / 2;
         var _loc5_:Number = _loc3_ * (this.gpPointerY + 1) / 2;
         if(_loc4_ != this.gpPointerX_s || _loc5_ != this.gpPointerY_s)
         {
            this.gpPointerX_s = _loc4_;
            this.gpPointerY_s = _loc5_;
            this.notifyGpPointer();
         }
         else if(param1)
         {
            this.notifyGpPointer();
         }
         if(Boolean(this.view) && Boolean(this.view._landscapeView))
         {
            this.view._landscapeView.setDisplayHoverStagePosition(_loc4_,_loc5_);
            this.view._landscapeView.setDisplayHoverStagePositionEnabled(true);
         }
      }
      
      public function get gpHoverDisabledByScene() : Boolean
      {
         return this._gpHoverDisabledByScene;
      }
      
      public function set gpHoverDisabledByScene(param1:Boolean) : void
      {
         this._gpHoverDisabledByScene = param1;
      }
      
      public function setGpPointerEnabled(param1:Boolean) : void
      {
         if(this._gpHoverDisabledByScene)
         {
            param1 = false;
            return;
         }
         if(this.gpPointerEnabled != param1)
         {
            this.gpPointerEnabled = param1;
            if(!this.gpPointerEnabled)
            {
               this.hoverTalkie = null;
               if(Boolean(this.view) && Boolean(this.view.landscapeView))
               {
                  this.view.landscapeView.displayHover(null);
               }
            }
            else
            {
               PlatformInput.touchInputGp();
            }
            this.notifyGpPointer();
         }
      }
      
      private function notifyGpPointer() : void
      {
         if(this.gpPointerCallback != null)
         {
            this.gpPointerCallback();
         }
         this.checkClickableGpHover();
      }
      
      private function checkClickableGpHover() : void
      {
         var _loc1_:LandscapeSpriteDef = null;
         if(!this.view || !this.view.landscapeView)
         {
            return;
         }
         if(!this.gpPointerEnabled)
         {
            this.hoverTalkie = null;
            _loc1_ = null;
         }
         else if(this._hoverTalkie)
         {
            _loc1_ = null;
         }
         else if(!this.landscape.enableHover)
         {
            _loc1_ = null;
         }
         else if(this._gpPointerAllowHover)
         {
            _loc1_ = this.view.landscapeView.getClickableUnderMouse(this.gpPointerX_s,this.gpPointerY_s);
            this.view.landscapeView.setClickableHasBeenClicked(_loc1_);
         }
         if(this._gpPointerAllowHover)
         {
            this.view.landscapeView.displayHover(_loc1_);
         }
         this.mouseAdapter.handleGpSelection(_loc1_ != null || this._hoverTalkie != null);
      }
      
      public function get hoverTalkie() : IGuiTalkie
      {
         return this._hoverTalkie;
      }
      
      public function set hoverTalkie(param1:IGuiTalkie) : void
      {
         if(this._hoverTalkie === param1)
         {
            return;
         }
         if(this._hoverTalkie)
         {
            this._hoverTalkie.setHovering(false);
         }
         this._hoverTalkie = param1;
         if(this._hoverTalkie)
         {
            this._hoverTalkie.setHovering(true);
         }
      }
      
      public function clickGpSelection() : void
      {
         var _loc2_:ClickablePair = null;
         if(this._hoverTalkie)
         {
            this._hoverTalkie.press();
            return;
         }
         var _loc1_:LandscapeSpriteDef = this.view.landscapeView.hoverClickable;
         if(Boolean(_loc1_) && this.landscape.enableHover)
         {
            _loc2_ = this.view.landscapeView.getClickablePair(_loc1_);
            _loc2_.pulseGpPress();
            this.landscapeController.performLandscapeClick(_loc1_);
         }
      }
      
      public function get gpPointerAllowHover() : Boolean
      {
         return this._gpPointerAllowHover;
      }
      
      public function set gpPointerAllowHover(param1:Boolean) : void
      {
         this._gpPointerAllowHover = param1 && !this.board;
      }
      
      public function hoverGpPointerClickable(param1:LandscapeSpriteDef) : void
      {
         var _loc2_:Point = null;
         var _loc3_:Boolean = false;
         var _loc4_:ILandscapeView = null;
         var _loc5_:ClickablePair = null;
         if(this._gpHoverDisabledByScene)
         {
            this.gpPointerEnabled = false;
            return;
         }
         this.gpPointerAllowHover = false;
         if(this._hoverTalkie)
         {
            this.hoverTalkie = null;
         }
         this.view.landscapeView.displayHover(param1);
         this.view.landscapeView.setClickableHasBeenClicked(param1);
         if(param1)
         {
            _loc2_ = this.view.landscapeView.getClickablePointGlobal(param1);
            this.syncGpPointerWithScreenPoint(_loc2_.x,_loc2_.y);
            _loc3_ = true;
            _loc4_ = this.view.landscapeView;
            _loc5_ = _loc4_.getClickablePair(param1);
            if(Boolean(_loc5_) && _loc5_.shouldTooltip)
            {
               _loc5_.setHoverStagePosition(_loc2_.x,_loc2_.y);
               _loc5_.setHoverStagePositionEnabled(true);
               if(this.view.landscapeView.showTooltips)
               {
                  _loc3_ = false;
               }
            }
            this.setGpPointerEnabled(_loc3_);
         }
         this.mouseAdapter.handleGpSelection(param1 != null);
      }
      
      public function hoverGpPointerTalkie(param1:IGuiTalkie, param2:Point) : void
      {
         this.gpPointerAllowHover = true;
         this.hoverTalkie = param1;
         this.view.landscapeView.displayHover(null);
         if(param1)
         {
            this.syncGpPointerWithScreenPoint(param2.x,param2.y);
            this.setGpPointerEnabled(true);
         }
         this.mouseAdapter.handleGpSelection(param1 != null);
      }
      
      private function landscapeEnableHoverHandler(param1:Event) : void
      {
         this.checkClickableGpHover();
      }
      
      public function selectTalkie_next(param1:Point) : IGuiTalkie
      {
         return this.talkieNextPrevCallback(this._hoverTalkie,param1,true);
      }
      
      public function selectTalkie_prev(param1:Point) : IGuiTalkie
      {
         return this.talkieNextPrevCallback(this._hoverTalkie,param1,false);
      }
   }
}

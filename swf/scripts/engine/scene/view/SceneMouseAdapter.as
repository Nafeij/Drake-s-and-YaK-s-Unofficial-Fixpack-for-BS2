package engine.scene.view
{
   import com.greensock.TweenMax;
   import com.stoicstudio.platform.PlatformFlash;
   import com.stoicstudio.platform.PlatformInput;
   import com.stoicstudio.platform.PlatformStarling;
   import engine.convo.view.ConvoView;
   import engine.core.logging.ILogger;
   import engine.core.render.BoundedCamera;
   import engine.core.render.Camera;
   import engine.core.util.InputUtil;
   import engine.gui.GuiMouse;
   import engine.gui.page.PageManagerAdapter;
   import engine.landscape.view.LandscapeViewController;
   import engine.saga.Saga;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   import flash.ui.Keyboard;
   import uk.co.bigroom.input.KeyPoll;
   import uk.co.bigroom.input.KeyPollEvent;
   
   public class SceneMouseAdapter extends EventDispatcher
   {
      
      private static const KEYBIND_ZOOM:uint = 0;
      
      private static const KEYBIND_PAN:uint = 0;
      
      private static const KEYBIND_PAN_SNAP:uint = Keyboard.SHIFT;
      
      public static var instanceCamera:BoundedCamera;
      
      public static var ALLOW_EDGE_PAN:Boolean;
      
      public static var EDGE_PAN_SPEED:Number = 600;
      
      private static var EDGE_PAN_THRESHOLD:int = 4;
       
      
      public var m_scale:Number = 1;
      
      private var _targetScale:Number = 1;
      
      private var m_mouseDownPoint:Point = null;
      
      private var m_didDrag:Boolean = false;
      
      private var panning:Boolean = false;
      
      private var keypoll:KeyPoll;
      
      public var view:SceneViewSprite;
      
      public var panMouseStartPoint:Point;
      
      public var panViewStartPoint:Point;
      
      private var inputUtil:InputUtil;
      
      private var lerpScale:Boolean = false;
      
      private var _canPan:Boolean = true;
      
      private var camera:BoundedCamera;
      
      public var convoView:ConvoView;
      
      private var _inputEnabled:Boolean = true;
      
      public var gp:SceneMouseAdapterGp;
      
      public var controller:SceneViewController;
      
      public var landscapeController:LandscapeViewController;
      
      public var logger:ILogger;
      
      private var _lastMouseX:Number = -1;
      
      private var _lastMouseY:Number = -1;
      
      public var zoomStops:Array;
      
      private var DEFAULT_ZOOM:int = 5;
      
      private var _zoomIndex:int;
      
      private var zoomPoint:Point;
      
      private var _maximumZoom:Number;
      
      private var _minimumZoom:Number;
      
      private var _minimumZoomIndex:int = 0;
      
      public function SceneMouseAdapter(param1:SceneViewController, param2:SceneViewSprite, param3:Number, param4:Saga)
      {
         this.panMouseStartPoint = new Point();
         this.panViewStartPoint = new Point();
         this.inputUtil = new InputUtil();
         this.zoomStops = [0.5,0.6,0.7,0.8,0.9,1,1.1,1.2,1.3,1.4,1.5,1.6,1.7,1.8,1.9,2];
         this._zoomIndex = this.DEFAULT_ZOOM;
         this.zoomPoint = new Point();
         this._maximumZoom = this.zoomStops[this.zoomStops.length - 1];
         this._minimumZoom = this.zoomStops[0];
         super();
         this.view = param2;
         this.convoView = param2.convoView;
         this.controller = param1;
         this.logger = param2.scene.logger;
         this.landscapeController = param1.landscapeController;
         this.camera = param2.scene._camera;
         this.camera.addEventListener(Camera.EVENT_CAMERA_SIZE_CHANGED,this.cameraSizeChangedHandler);
         param2.addEventListener(SceneViewSprite.EVENT_INPUT_DISABLE,this.viewInputDisableHandler);
         param2.addEventListener(SceneViewSprite.EVENT_INPUT_DISABLE,this.viewInputEnableHandler);
         param2.addEventListener(SceneViewSprite.EVENT_ZOOM_RESET,this.viewZoomResetHandler);
         this.scale = param3;
         this.targetScale = param3;
         this.computeMinimumZoom();
         this.keypoll = new KeyPoll(PlatformFlash.stage);
         this.keypoll.addEventListener(KeyPollEvent.CHANGED,this.keyPollChangedHandler);
         instanceCamera = this.camera;
         this.gp = new SceneMouseAdapterGp(this.camera,this,param4);
      }
      
      public function update(param1:int) : void
      {
         if(this.gp)
         {
            this.gp.update(param1);
         }
         if(ALLOW_EDGE_PAN)
         {
         }
      }
      
      private function handleEdgePan(param1:int) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         if(!this._inputEnabled || !this.canPan)
         {
            return;
         }
         if(!this.view.stage || this.panning)
         {
            return;
         }
         if(this.camera.drift)
         {
            if(Boolean(this.camera.drift.anchor) || this.camera.drift.isAnchorAnimating)
            {
               return;
            }
         }
         if(!this.controller || !this.controller.scene || !this.controller.scene.ready)
         {
            return;
         }
         if(!PlatformFlash.fullscreen || PlatformInput.lastInputGp)
         {
            return;
         }
         if(Boolean(GuiMouse.instance) && GuiMouse.instance.isInputActive)
         {
            _loc2_ = 0;
            _loc3_ = 0;
            _loc4_ = this.view.stage.mouseX;
            _loc5_ = this.view.stage.mouseY;
            _loc6_ = this.view.stage.stageWidth;
            _loc7_ = this.view.stage.stageHeight;
            if(_loc4_ <= EDGE_PAN_THRESHOLD)
            {
               _loc2_ = -1;
            }
            else if(_loc4_ >= _loc6_ - EDGE_PAN_THRESHOLD - 1)
            {
               _loc2_ = 1;
            }
            if(_loc5_ <= EDGE_PAN_THRESHOLD)
            {
               _loc3_ = -1;
            }
            else if(_loc5_ >= _loc7_ - EDGE_PAN_THRESHOLD - 1)
            {
               _loc3_ = 1;
            }
            if(Boolean(_loc2_) || Boolean(_loc3_))
            {
               _loc8_ = EDGE_PAN_SPEED * param1 / 1000;
               _loc2_ *= _loc8_;
               _loc3_ *= _loc8_;
               this.camera.setPosition(this.camera.clamped.x + _loc2_,this.camera.clamped.y + _loc3_);
               if(!this.camera._pause)
               {
                  this.camera.pause = true;
               }
               GuiMouse.instance.touchInputActive();
               return;
            }
         }
      }
      
      public function get canPan() : Boolean
      {
         return this._canPan && this._inputEnabled;
      }
      
      public function set canPan(param1:Boolean) : void
      {
         if(this._canPan != param1)
         {
            if(param1)
            {
               this._canPan = param1;
            }
            else
            {
               if(!this.m_didDrag && this.panning)
               {
                  this.stopPan();
               }
               this._canPan = param1;
            }
         }
      }
      
      public function cleanup() : void
      {
         if(instanceCamera == this.camera)
         {
            instanceCamera = null;
         }
         if(this.gp)
         {
            this.gp.cleanup();
            this.gp = null;
         }
         this.view.removeEventListener(SceneViewSprite.EVENT_INPUT_DISABLE,this.viewInputDisableHandler);
         this.view.removeEventListener(SceneViewSprite.EVENT_INPUT_DISABLE,this.viewInputEnableHandler);
         this.view.removeEventListener(SceneViewSprite.EVENT_ZOOM_RESET,this.viewZoomResetHandler);
         this.view = null;
         this.camera.removeEventListener(Camera.EVENT_CAMERA_SIZE_CHANGED,this.cameraSizeChangedHandler);
         this.camera = null;
         this.keypoll.removeEventListener(KeyPollEvent.CHANGED,this.keyPollChangedHandler);
         this.keypoll.cleanup();
         this.keypoll = null;
      }
      
      public function get zoomIndex() : int
      {
         return this._zoomIndex;
      }
      
      private function cameraSizeChangedHandler(param1:Event) : void
      {
         this.computeMinimumZoom();
      }
      
      public function set zoomIndex(param1:int) : void
      {
         if(param1 < 0)
         {
            this._zoomIndex = -1;
            return;
         }
         var _loc2_:int = Math.max(0,Math.min(this.zoomStops.length - 1,param1));
         this._zoomIndex = Math.max(_loc2_,this._minimumZoomIndex);
         var _loc3_:Number = Number(this.zoomStops[this._zoomIndex]);
         _loc3_ = Math.max(this._minimumZoom,_loc3_);
         _loc3_ = Math.min(this._maximumZoom,_loc3_);
         if(_loc3_ == this._targetScale)
         {
            return;
         }
         this.targetScale = _loc3_;
      }
      
      public function get targetScale() : Number
      {
         return this._targetScale;
      }
      
      private function offsetCameraForNextScale(param1:Number) : void
      {
         if(this.camera.caravanCameraLocked)
         {
            return;
         }
         var _loc2_:Number = this.scale;
         var _loc3_:Number = this.view.width;
         var _loc4_:Number = this.view.height;
         var _loc5_:Number = this.zoomPoint.x - _loc3_ / 2;
         var _loc6_:Number = this.zoomPoint.y - _loc4_ / 2;
         var _loc7_:Number = _loc5_ * param1 / _loc2_;
         var _loc8_:Number = _loc6_ * param1 / _loc2_;
         var _loc9_:Number = _loc7_ - _loc5_;
         var _loc10_:Number = _loc8_ - _loc6_;
         this.view.scene._camera.panClampedX += _loc9_ - this.camera.actualTiltOffset.x;
         this.view.scene._camera.panClampedY += _loc10_ - this.camera.actualTiltOffset.y;
      }
      
      public function set targetScale(param1:Number) : void
      {
         var _loc2_:Number = param1;
         _loc2_ = Math.max(this._minimumZoom,_loc2_);
         _loc2_ = Math.min(this._maximumZoom,_loc2_);
         if(this._targetScale == _loc2_)
         {
            return;
         }
         this.offsetCameraForNextScale(_loc2_);
         this._targetScale = _loc2_;
         if(this.lerpScale)
         {
            TweenMax.killTweensOf(this);
            TweenMax.to(this,0.2,{"scale":this._targetScale});
         }
         else
         {
            this.scale = this._targetScale;
         }
      }
      
      protected function keyPollChangedHandler(param1:KeyPollEvent) : void
      {
         if(param1.keyCode == KEYBIND_PAN)
         {
            this.checkPan();
         }
      }
      
      public function get isMouseDown() : Boolean
      {
         return this.m_mouseDownPoint != null;
      }
      
      public function get scale() : Number
      {
         return this.m_scale;
      }
      
      public function set scale(param1:Number) : void
      {
         param1 = Math.max(this._minimumZoom,param1);
         param1 = Math.min(this._maximumZoom,param1);
         if(param1 != this.m_scale)
         {
            this.m_scale = param1;
            this.view.scene._camera.zoom = param1;
         }
      }
      
      private function checkPan() : void
      {
         if(this.m_mouseDownPoint)
         {
            if(KEYBIND_PAN == 0 || this.keypoll.isDown(KEYBIND_PAN))
            {
               this.startPan();
               return;
            }
         }
         this.stopPan();
      }
      
      private function startPan() : void
      {
         if(!this._canPan)
         {
            return;
         }
         if(this.panning)
         {
            return;
         }
         if(!this.view.scene)
         {
            return;
         }
         PlatformStarling.setPanning(true,this.logger,"SceneMouseAdapter.startPan");
         this.panning = true;
         var _loc1_:Stage = PlatformFlash.stage;
         this.panMouseStartPoint = new Point(_loc1_.mouseX,_loc1_.mouseY);
         this.panViewStartPoint = new Point(this.camera.panClampedX - this.camera.actualTiltOffset.x,this.camera.panClampedY - this.camera.actualTiltOffset.y);
      }
      
      private function stopPan() : void
      {
         if(!this.panning)
         {
            return;
         }
         PlatformStarling.setPanning(false,this.logger,"SceneMouseAdapter.stopPan");
         this.panning = false;
         this.panViewStartPoint = null;
      }
      
      public function onMouseDown(param1:Number, param2:Number) : Boolean
      {
         if(!this._inputEnabled)
         {
            return false;
         }
         this.m_mouseDownPoint = new Point(param1,param2);
         this.m_didDrag = false;
         this.checkPan();
         return false;
      }
      
      public function onMouseUp() : Boolean
      {
         if(!this._inputEnabled)
         {
            return false;
         }
         this.m_mouseDownPoint = null;
         this.checkPan();
         return this.m_didDrag;
      }
      
      private function snapTo(param1:int, param2:uint) : int
      {
         if(param1 < 0)
         {
            return int((param1 - param2 / 2) / param2) * param2;
         }
         return int((param1 + param2 / 2) / param2) * param2;
      }
      
      public function handlePan(param1:Number, param2:Number, param3:Boolean) : Boolean
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         if(!this._inputEnabled)
         {
            return false;
         }
         if(this.panning)
         {
            _loc4_ = param1 - this.panMouseStartPoint.x;
            _loc5_ = param2 - this.panMouseStartPoint.y;
            _loc6_ = _loc4_ * _loc4_ + _loc5_ * _loc5_;
            if(this.m_didDrag || _loc6_ > this.inputUtil.clickDistancePixelsSq)
            {
               this.m_didDrag = true;
               if(!param3)
               {
                  _loc7_ = this.view.scene._camera.scale;
                  _loc8_ = _loc4_ / _loc7_;
                  _loc9_ = _loc5_ / _loc7_;
                  _loc10_ = this.panViewStartPoint.x - _loc8_;
                  _loc11_ = this.panViewStartPoint.y - _loc9_;
                  this.view.scene._camera.setPosition(_loc10_,_loc11_);
                  _loc12_ = this.view.scene._camera.panClamped.x - _loc10_ - this.camera.actualTiltOffset.x;
                  _loc13_ = this.view.scene._camera.panClamped.y - _loc11_ - this.camera.actualTiltOffset.y;
                  _loc12_ *= _loc7_;
                  _loc13_ *= _loc7_;
                  this.panMouseStartPoint.x += _loc12_;
                  this.panMouseStartPoint.y += _loc13_;
               }
               return true;
            }
         }
         return false;
      }
      
      public function onMouseMove(param1:Number, param2:Number, param3:Boolean) : Boolean
      {
         this._lastMouseX = param1;
         this._lastMouseY = param2;
         if(!this._inputEnabled)
         {
            return false;
         }
         if(this.handlePan(param1,param2,param3))
         {
            return true;
         }
         return false;
      }
      
      public function computeMinimumZoom() : void
      {
         var _loc2_:Number = NaN;
         var _loc1_:Number = this.view.scene._camera.width / this.view.scene._camera.maxWidth;
         this._minimumZoom = _loc1_;
         if(this._zoomIndex >= 0)
         {
            this._minimumZoomIndex = 1;
            while(this._minimumZoomIndex < this.zoomStops.length)
            {
               _loc2_ = Number(this.zoomStops[this._minimumZoomIndex]);
               if(_loc2_ >= this._minimumZoom)
               {
                  break;
               }
               ++this._minimumZoomIndex;
            }
            this.zoomPoint.setTo(this.view.width / 2,this.view.height / 2);
            this.zoomIndex = Math.max(this._minimumZoomIndex,this._zoomIndex);
         }
      }
      
      public function resetZoomIndex() : void
      {
         this.zoomPoint.setTo(this.view.width / 2,this.view.height / 2);
         this.zoomIndex = this.DEFAULT_ZOOM;
      }
      
      public function handlePinchZoom(param1:Number, param2:Number, param3:Number) : void
      {
         if(!this._inputEnabled || PageManagerAdapter.OVERLAY_VISIBLE)
         {
            return;
         }
         this._zoomIndex = -1;
         this.zoomPoint.setTo(param2,param3);
         this.targetScale = param1;
      }
      
      public function onMouseWheel(param1:Number, param2:Number, param3:int) : Boolean
      {
         if(!this._inputEnabled || PageManagerAdapter.OVERLAY_VISIBLE)
         {
            return false;
         }
         if(KEYBIND_ZOOM == 0 || this.keypoll.isDown(KEYBIND_ZOOM))
         {
            this.zoomPoint.setTo(param1,param2);
            if(this.zoomIndex < 0)
            {
               this.zoomIndex = this.DEFAULT_ZOOM;
               this.computeMinimumZoom();
            }
            else if(param3 > 0)
            {
               ++this.zoomIndex;
            }
            else if(this.zoomIndex > 0)
            {
               --this.zoomIndex;
            }
            return true;
         }
         return false;
      }
      
      private function viewInputDisableHandler(param1:Event) : void
      {
         this._inputEnabled = false;
         this.stopPan();
      }
      
      private function viewInputEnableHandler(param1:Event) : void
      {
         this._inputEnabled = true;
      }
      
      private function viewZoomResetHandler(param1:Event) : void
      {
         this.resetZoomIndex();
      }
      
      public function findZoomIndex(param1:Number) : int
      {
         var _loc3_:Number = NaN;
         var _loc2_:int = 0;
         while(_loc2_ < this.zoomStops.length)
         {
            _loc3_ = Number(this.zoomStops[_loc2_]);
            if(_loc3_ >= param1)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return this.zoomStops.length - 1;
      }
      
      public function syncToCamera(param1:Boolean) : void
      {
         if(Boolean(this.controller) && Boolean(this.controller.view))
         {
            if(this.controller.view.isSplining)
            {
               return;
            }
         }
         if(param1)
         {
            this.zoomIndex = this.findZoomIndex(this.camera.zoom);
            if(this._zoomIndex > 0)
            {
               this.targetScale = this.zoomStops[this._zoomIndex];
            }
         }
         else
         {
            this.zoomIndex = -1;
            this.targetScale = this.camera.zoom;
         }
      }
      
      public function handleSceneReady() : void
      {
         if(this.gp)
         {
            this.gp.handleSceneReady();
         }
      }
      
      public function handleGpSelection(param1:Boolean) : void
      {
         if(this.gp)
         {
            this.gp.handleGpSelection(param1);
         }
      }
   }
}

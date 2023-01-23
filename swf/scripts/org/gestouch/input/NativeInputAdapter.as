package org.gestouch.input
{
   import flash.display.InteractiveObject;
   import flash.display.Stage;
   import flash.events.EventPhase;
   import flash.events.MouseEvent;
   import flash.events.TouchEvent;
   import flash.ui.Multitouch;
   import flash.ui.MultitouchInputMode;
   import org.gestouch.core.IInputAdapter;
   import org.gestouch.core.TouchesManager;
   import org.gestouch.core.gestouch_internal;
   
   public class NativeInputAdapter implements IInputAdapter
   {
      
      protected static const MOUSE_TOUCH_POINT_ID:uint = 0;
      
      {
         Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
      }
      
      protected var _stage:Stage;
      
      protected var _explicitlyHandleTouchEvents:Boolean;
      
      protected var _explicitlyHandleMouseEvents:Boolean;
      
      protected var _touchesManager:TouchesManager;
      
      public function NativeInputAdapter(param1:Stage, param2:Boolean = false, param3:Boolean = false)
      {
         super();
         if(!param1)
         {
            throw new ArgumentError("Stage must be not null.");
         }
         this._stage = param1;
         this._explicitlyHandleTouchEvents = param2;
         this._explicitlyHandleMouseEvents = param3;
      }
      
      public function set touchesManager(param1:TouchesManager) : void
      {
         this._touchesManager = param1;
      }
      
      public function init() : void
      {
         if(Multitouch.supportsTouchEvents || this._explicitlyHandleTouchEvents)
         {
            this._stage.addEventListener(TouchEvent.TOUCH_BEGIN,this.touchBeginHandler,true);
            this._stage.addEventListener(TouchEvent.TOUCH_BEGIN,this.touchBeginHandler,false);
            this._stage.addEventListener(TouchEvent.TOUCH_MOVE,this.touchMoveHandler,true);
            this._stage.addEventListener(TouchEvent.TOUCH_MOVE,this.touchMoveHandler,false);
            this._stage.addEventListener(TouchEvent.TOUCH_END,this.touchEndHandler,true,int.MAX_VALUE);
            this._stage.addEventListener(TouchEvent.TOUCH_END,this.touchEndHandler,false,int.MAX_VALUE);
         }
         if(!Multitouch.supportsTouchEvents || this._explicitlyHandleMouseEvents)
         {
            this._stage.addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler,true);
            this._stage.addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler,false);
         }
      }
      
      public function onDispose() : void
      {
         this._touchesManager = null;
         this._stage.removeEventListener(TouchEvent.TOUCH_BEGIN,this.touchBeginHandler,true);
         this._stage.removeEventListener(TouchEvent.TOUCH_BEGIN,this.touchBeginHandler,false);
         this._stage.removeEventListener(TouchEvent.TOUCH_MOVE,this.touchMoveHandler,true);
         this._stage.removeEventListener(TouchEvent.TOUCH_MOVE,this.touchMoveHandler,false);
         this._stage.removeEventListener(TouchEvent.TOUCH_END,this.touchEndHandler,true);
         this._stage.removeEventListener(TouchEvent.TOUCH_END,this.touchEndHandler,false);
         this._stage.removeEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler,true);
         this._stage.removeEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler,false);
         this.unstallMouseListeners();
      }
      
      protected function installMouseListeners() : void
      {
         this._stage.addEventListener(MouseEvent.MOUSE_MOVE,this.mouseMoveHandler,true);
         this._stage.addEventListener(MouseEvent.MOUSE_MOVE,this.mouseMoveHandler,false);
         this._stage.addEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler,true,int.MAX_VALUE);
         this._stage.addEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler,false,int.MAX_VALUE);
      }
      
      protected function unstallMouseListeners() : void
      {
         this._stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.mouseMoveHandler,true);
         this._stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.mouseMoveHandler,false);
         this._stage.removeEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler,true);
         this._stage.removeEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler,false);
      }
      
      protected function touchBeginHandler(param1:TouchEvent) : void
      {
         if(param1.eventPhase == EventPhase.BUBBLING_PHASE)
         {
            return;
         }
         this._touchesManager.gestouch_internal::onTouchBegin(param1.touchPointID,param1.stageX,param1.stageY,param1.target as InteractiveObject);
      }
      
      protected function touchMoveHandler(param1:TouchEvent) : void
      {
         if(param1.eventPhase == EventPhase.BUBBLING_PHASE)
         {
            return;
         }
         this._touchesManager.gestouch_internal::onTouchMove(param1.touchPointID,param1.stageX,param1.stageY);
      }
      
      protected function touchEndHandler(param1:TouchEvent) : void
      {
         if(param1.eventPhase == EventPhase.BUBBLING_PHASE)
         {
            return;
         }
         if(param1.hasOwnProperty("isTouchPointCanceled") && Boolean(param1["isTouchPointCanceled"]))
         {
            this._touchesManager.gestouch_internal::onTouchCancel(param1.touchPointID,param1.stageX,param1.stageY);
         }
         else
         {
            this._touchesManager.gestouch_internal::onTouchEnd(param1.touchPointID,param1.stageX,param1.stageY);
         }
      }
      
      protected function mouseDownHandler(param1:MouseEvent) : void
      {
         if(param1.eventPhase == EventPhase.BUBBLING_PHASE)
         {
            return;
         }
         var _loc2_:Boolean = this._touchesManager.gestouch_internal::onTouchBegin(MOUSE_TOUCH_POINT_ID,param1.stageX,param1.stageY,param1.target as InteractiveObject);
         if(_loc2_)
         {
            this.installMouseListeners();
         }
      }
      
      protected function mouseMoveHandler(param1:MouseEvent) : void
      {
         if(param1.eventPhase == EventPhase.BUBBLING_PHASE)
         {
            return;
         }
         this._touchesManager.gestouch_internal::onTouchMove(MOUSE_TOUCH_POINT_ID,param1.stageX,param1.stageY);
      }
      
      protected function mouseUpHandler(param1:MouseEvent) : void
      {
         if(param1.eventPhase == EventPhase.BUBBLING_PHASE)
         {
            return;
         }
         this._touchesManager.gestouch_internal::onTouchEnd(MOUSE_TOUCH_POINT_ID,param1.stageX,param1.stageY);
         if(this._touchesManager.activeTouchesCount == 0)
         {
            this.unstallMouseListeners();
         }
      }
   }
}

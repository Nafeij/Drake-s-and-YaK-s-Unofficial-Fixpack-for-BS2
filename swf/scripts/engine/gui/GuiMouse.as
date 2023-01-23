package engine.gui
{
   import com.stoicstudio.platform.IUserInputToucher;
   import com.stoicstudio.platform.PlatformFlash;
   import com.stoicstudio.platform.PlatformInput;
   import engine.core.logging.ILogger;
   import engine.core.util.AppInfo;
   import engine.resource.BitmapResource;
   import engine.resource.ResourceManager;
   import engine.resource.event.ResourceLoadedEvent;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.ui.Mouse;
   import flash.ui.MouseCursor;
   import flash.ui.MouseCursorData;
   import flash.utils.Timer;
   
   public class GuiMouse implements IUserInputToucher
   {
      
      public static var instance:GuiMouse;
      
      private static var _gamePaused:Boolean;
       
      
      private var cursor:MovieClip;
      
      private var stage:Stage;
      
      private var cursorHardwareRes:BitmapResource;
      
      private var logger:ILogger;
      
      private var timer:Timer;
      
      private var appInfo:AppInfo;
      
      private var _inputActive:Boolean;
      
      public function GuiMouse()
      {
         this.timer = new Timer(4000,1);
         super();
         instance = this;
      }
      
      public static function performVanishCursor() : void
      {
         if(instance)
         {
            instance.vanishCursor();
         }
      }
      
      public static function set gamePaused(param1:Boolean) : void
      {
         if(_gamePaused == param1)
         {
            return;
         }
         _gamePaused = param1;
         if(instance)
         {
            instance.checkGamePaused();
         }
      }
      
      public function init(param1:ResourceManager, param2:AppInfo, param3:Stage, param4:Boolean) : void
      {
         Mouse.hide();
         this.logger = param1.logger;
         this.appInfo = param2;
         param2.addEventListener(Event.ACTIVATE,this.activateHandler);
         param2.addEventListener(Event.DEACTIVATE,this.activateHandler);
         this.cursorHardwareRes = param1.getResource("common/mouse/mouse_cursor.png",BitmapResource,null) as BitmapResource;
         this.cursorHardwareRes.addResourceListener(this.cursorHardwareLoadedHandler);
         this.stage = param3;
         this.timer.addEventListener(TimerEvent.TIMER_COMPLETE,this.timerHandler);
      }
      
      private function activateHandler(param1:Event) : void
      {
         this.checkGamePaused();
      }
      
      private function timerHandler(param1:TimerEvent) : void
      {
         this.vanishCursor();
      }
      
      private function dragCursor(param1:MouseEvent) : void
      {
         if(!this.appInfo.activated)
         {
            return;
         }
         if(this.cursor)
         {
            this.cursor.x = this.stage.mouseX;
            this.cursor.y = this.stage.mouseY;
         }
         this.touchInputActive();
      }
      
      public function get isInputActive() : Boolean
      {
         return this._inputActive;
      }
      
      public function touchInputActive() : void
      {
         if(!this.appInfo.activated)
         {
            return;
         }
         this.touchInputTimers();
         PlatformInput.touchInputMouse();
      }
      
      private function touchInputTimers() : void
      {
         if(!this.appInfo.activated)
         {
            return;
         }
         if(this.cursorHardwareRes)
         {
            Mouse.show();
         }
         else if(this.cursor)
         {
            this.cursor.visible = true;
         }
         this._inputActive = true;
         if(this.timer.running)
         {
            this.timer.reset();
         }
         this.timer.start();
      }
      
      private function vanishCursor() : void
      {
         if(!this.appInfo.activated)
         {
            return;
         }
         if(_gamePaused)
         {
            return;
         }
         if(this.cursorHardwareRes)
         {
            Mouse.hide();
         }
         else if(this.cursor)
         {
            this.cursor.visible = false;
         }
         this._inputActive = false;
      }
      
      private function checkGamePaused() : void
      {
         if(_gamePaused || !this.appInfo.activated)
         {
            this.handleGamePaused();
         }
         else
         {
            this.handleGameUnpaused();
         }
      }
      
      private function handleGamePaused() : void
      {
         Mouse.cursor = MouseCursor.AUTO;
         if(this.cursorHardwareRes)
         {
            Mouse.show();
         }
         if(this.cursor)
         {
            this.cursor.visible = false;
         }
      }
      
      private function handleGameUnpaused() : void
      {
         if(this.cursorHardwareRes.ok)
         {
            Mouse.cursor = "TBSF";
         }
         if(!PlatformInput.lastInputGp)
         {
            this.touchInputActive();
         }
         else
         {
            Mouse.hide();
         }
      }
      
      private function cursorHardwareLoadedHandler(param1:ResourceLoadedEvent) : void
      {
         var _loc2_:Vector.<BitmapData> = null;
         var _loc3_:MouseCursorData = null;
         if(this.cursorHardwareRes.ok)
         {
            _loc2_ = new Vector.<BitmapData>();
            _loc2_.push(this.cursorHardwareRes.bitmapData);
            _loc3_ = new MouseCursorData();
            _loc3_.data = _loc2_;
            _loc3_.hotSpot = new Point(0,0);
            Mouse.registerCursor("TBSF",_loc3_);
            Mouse.cursor = "TBSF";
            PlatformFlash.stage.addEventListener(MouseEvent.MOUSE_MOVE,this.dragCursor);
            this.touchInputTimers();
         }
      }
   }
}

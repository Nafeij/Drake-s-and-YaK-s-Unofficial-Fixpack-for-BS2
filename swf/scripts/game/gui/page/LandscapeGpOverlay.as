package game.gui.page
{
   import com.stoicstudio.platform.PlatformInput;
   import engine.core.gp.GpControlButton;
   import engine.core.render.Camera;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpBitmap;
   import engine.landscape.view.LandscapeViewController;
   import engine.scene.model.Scene;
   import engine.scene.view.SceneViewController;
   import flash.display.Sprite;
   import flash.events.Event;
   
   public class LandscapeGpOverlay extends Sprite
   {
       
      
      public var bmp_pointer:GuiGpBitmap;
      
      private var scene:Scene;
      
      private var page:ScenePage;
      
      private var camera:Camera;
      
      private var landscapeController:LandscapeViewController;
      
      private var controller:SceneViewController;
      
      private var _displayDirty:Boolean = true;
      
      private var _pointerDirty:Boolean = true;
      
      public function LandscapeGpOverlay(param1:ScenePage)
      {
         this.bmp_pointer = GuiGp.ctorPrimaryBitmap(GpControlButton.POINTER,true);
         super();
         this.name = "LandscapeGpOverlay";
         this.scene = param1.scene;
         this.page = param1;
         this.landscapeController = param1.controller.landscapeController;
         this.controller = param1.controller;
         this.camera = this.scene._camera;
         this.mouseEnabled = this.mouseChildren = false;
         this.landscapeController.addEventListener(LandscapeViewController.EVENT_SELECTED_CLICKABLE,this.dirtyHandler);
         this.camera.addEventListener(Camera.EVENT_CAMERA_MOVED,this.dirtyHandler);
         addChild(this.bmp_pointer);
         this.bmp_pointer.global = true;
         PlatformInput.dispatcher.addEventListener(PlatformInput.EVENT_LAST_INPUT,this.lastInputHandler);
      }
      
      public function cleanup() : void
      {
         PlatformInput.dispatcher.removeEventListener(PlatformInput.EVENT_LAST_INPUT,this.lastInputHandler);
         this.landscapeController.removeEventListener(LandscapeViewController.EVENT_SELECTED_CLICKABLE,this.dirtyHandler);
         this.camera.removeEventListener(Camera.EVENT_CAMERA_MOVED,this.dirtyHandler);
         GuiGp.releasePrimaryBitmap(this.bmp_pointer);
         this.scene = null;
         this.page = null;
         this.landscapeController = null;
      }
      
      public function dirty() : void
      {
         this._displayDirty = true;
      }
      
      public function pointerDirty() : void
      {
         this._pointerDirty = true;
      }
      
      private function lastInputHandler(param1:Event) : void
      {
         this.dirty();
      }
      
      private function dirtyHandler(param1:Event) : void
      {
         this.dirty();
      }
      
      private function resetDisplay() : void
      {
         this._displayDirty = false;
      }
      
      private function resetPointerDisplay() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:int = 0;
         this._pointerDirty = false;
         this.bmp_pointer.visible = this.controller.gpPointerEnabled;
         if(this.bmp_pointer.visible)
         {
            _loc1_ = this.page.width / 2;
            _loc2_ = this.page.height / 2;
            _loc3_ = 10;
            this.bmp_pointer.x = int(Math.min(this.page.width - _loc3_,_loc1_ + this.controller.gpPointerX * _loc1_));
            this.bmp_pointer.y = int(Math.min(this.page.height - _loc3_,_loc2_ + this.controller.gpPointerY * _loc2_));
         }
      }
      
      public function update(param1:int) : void
      {
         if(this._displayDirty)
         {
            this.resetDisplay();
         }
         if(this._pointerDirty)
         {
            this.resetPointerDisplay();
         }
      }
   }
}

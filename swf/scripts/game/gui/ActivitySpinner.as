package game.gui
{
   import engine.resource.BitmapResource;
   import engine.resource.ResourceManager;
   import engine.resource.event.ResourceLoadedEvent;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.errors.IllegalOperationError;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class ActivitySpinner extends Sprite
   {
       
      
      private var spinnerBMPResource:BitmapResource;
      
      private var displayObject:DisplayObject;
      
      private var timer:Timer;
      
      private var resman:ResourceManager;
      
      private var _targetWidth:int;
      
      private var _targetHeight:int;
      
      private var released:Boolean = false;
      
      private var _sourceWidth:int;
      
      private var _sourceHeight:int;
      
      public function ActivitySpinner(param1:ResourceManager, param2:String, param3:int, param4:int, param5:Number)
      {
         super();
         this.resman = param1;
         super.visible = false;
         var _loc6_:int = 0;
         this.timer = new Timer(param5,_loc6_);
         this.timer.addEventListener(TimerEvent.TIMER,this.onTick);
         this.spinnerBMPResource = this.resman.getResource(param2,BitmapResource) as BitmapResource;
         this.spinnerBMPResource.addResourceListener(this.finishLoadingSpinnerBitmap);
         this._targetWidth = param3;
         this._targetHeight = param4;
      }
      
      public function get targetWidth() : int
      {
         return this._targetWidth;
      }
      
      public function get targetHeight() : int
      {
         return this._targetHeight;
      }
      
      override public function set visible(param1:Boolean) : void
      {
         var _loc2_:Boolean = super.visible;
         if(_loc2_ == param1)
         {
            return;
         }
         super.visible = param1;
         if(param1)
         {
            this.showSpinner();
         }
         else
         {
            this.timer.stop();
            if(Boolean(this.displayObject) && contains(this.displayObject))
            {
               removeChild(this.displayObject);
            }
         }
      }
      
      private function showSpinner() : void
      {
         if(this.spinnerBMPResource.ok)
         {
            if(!this.displayObject)
            {
               this._sourceWidth = this.spinnerBMPResource.bitmapData.width;
               this._sourceHeight = this.spinnerBMPResource.bitmapData.height;
               this.displayObject = this.spinnerBMPResource.bmp;
            }
            addChild(this.displayObject);
            this.resetPositionAndSize();
            this.timer.start();
         }
      }
      
      public function release() : void
      {
         if(this.released)
         {
            throw new IllegalOperationError("Double-release of ActivitySpinner");
         }
         this.released = true;
         this.spinnerBMPResource.removeResourceListener(this.finishLoadingSpinnerBitmap);
         if(Boolean(this.displayObject) && contains(this.displayObject))
         {
            removeChild(this.displayObject);
            this.displayObject = null;
         }
         this.spinnerBMPResource.release();
      }
      
      private function onTick(param1:TimerEvent) : void
      {
         var _loc2_:Number = NaN;
         if(visible && this.displayObject != null)
         {
            _loc2_ = this.timer.delay / 1000 * 45;
            rotation += _loc2_;
         }
      }
      
      private function resetPositionAndSize() : void
      {
         if(Boolean(this._sourceWidth) && Boolean(this._sourceHeight))
         {
            this.displayObject.scaleX = this.targetWidth / this._sourceWidth;
            this.displayObject.scaleY = this.targetHeight / this._sourceHeight;
         }
         this.displayObject.x = -this.displayObject.width * 0.5;
         this.displayObject.y = -this.displayObject.height * 0.5;
      }
      
      private function finishLoadingSpinnerBitmap(param1:ResourceLoadedEvent) : void
      {
         this.spinnerBMPResource.removeResourceListener(this.finishLoadingSpinnerBitmap);
         if(visible)
         {
            this.showSpinner();
         }
      }
   }
}

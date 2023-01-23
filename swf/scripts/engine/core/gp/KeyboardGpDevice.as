package engine.core.gp
{
   import com.stoicstudio.platform.PlatformFlash;
   import com.stoicstudio.platform.PlatformInput;
   import engine.core.logging.ILogger;
   import flash.events.KeyboardEvent;
   import flash.ui.Keyboard;
   
   public class KeyboardGpDevice extends GpDevice
   {
       
      
      public function KeyboardGpDevice(param1:GpSource, param2:GpDeviceType, param3:String, param4:String, param5:ILogger)
      {
         super(param1,param2,param3,param4,param5);
      }
      
      override public function handleActiveChanged() : void
      {
         var _loc1_:Boolean = _active && GpSource.instance.enabled;
         if(_loc1_)
         {
            PlatformFlash.stage.addEventListener(KeyboardEvent.KEY_DOWN,this.handleKeyDown,true,255);
         }
         else
         {
            PlatformFlash.stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.handleKeyDown);
         }
      }
      
      private function handleKeyDown(param1:KeyboardEvent) : void
      {
         var _loc2_:GpControlButton = null;
         if(param1.ctrlKey || param1.altKey || param1.shiftKey)
         {
            return;
         }
         if(param1.keyCode == Keyboard.ESCAPE)
         {
            return;
         }
         param1.preventDefault();
         var _loc3_:String = "BUTTON_" + param1.keyCode.toString();
         if(allwatcher != null)
         {
            allwatcher(this,_loc3_,1);
            return;
         }
         _loc2_ = type.getControl(_loc3_);
         if(GpSource.GP_DEBUG)
         {
            logger.i("GP","KeyboardGpDevice " + _loc3_ + " (" + _loc2_ + ")");
         }
         if(_loc2_)
         {
            GpSource.primaryDevice = this;
            PlatformInput.touchInputGp();
            source.notifyBinders(_loc2_,1);
         }
      }
   }
}

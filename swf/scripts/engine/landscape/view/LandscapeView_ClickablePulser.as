package engine.landscape.view
{
   import engine.saga.Saga;
   import flash.utils.Dictionary;
   
   public class LandscapeView_ClickablePulser
   {
      
      private static var clicksThisSession:Dictionary = new Dictionary();
       
      
      private var lv:LandscapeViewBase;
      
      private var clickablesCanPulse:Dictionary;
      
      private var pulse_check_countdown:int = 0;
      
      private var PULSE_CHECK_TIME_MS:int = 5000;
      
      private var enabled:Boolean = true;
      
      private var _paused:Boolean = false;
      
      public function LandscapeView_ClickablePulser(param1:LandscapeViewBase)
      {
         this.clickablesCanPulse = new Dictionary();
         super();
         this.lv = param1;
         var _loc2_:Saga = param1.saga;
         this.enabled = Boolean(_loc2_) && !_loc2_.mapCamp;
         this.paused = Boolean(_loc2_) && _loc2_.paused;
      }
      
      public function cleanup() : void
      {
         this.clickablesCanPulse = null;
         this.lv = null;
      }
      
      public function handleClickableAdded(param1:ClickablePair) : void
      {
         if(!this.enabled)
         {
            return;
         }
         if(param1.enabled && !clicksThisSession[param1.id])
         {
            this.clickablesCanPulse[param1] = param1;
            this.lv.logger.debug("LandscapeView_ClickablePulser.handleClickableAdded canPulse[" + param1.id + "]");
         }
      }
      
      public function handleClickableEnabled(param1:ClickablePair) : void
      {
         if(!this.enabled)
         {
            return;
         }
         if(param1.enabled && !clicksThisSession[param1.id])
         {
            if(!this.clickablesCanPulse[param1])
            {
               this.clickablesCanPulse[param1] = param1;
               this.lv.logger.debug("LandscapeView_ClickablePulser.handleClickableEnabled canPulse[" + param1.id + "]");
            }
         }
         else
         {
            delete this.clickablesCanPulse[param1];
         }
      }
      
      public function handleClickableClicked(param1:ClickablePair) : void
      {
         if(!this.enabled || this._paused)
         {
            return;
         }
         if(!clicksThisSession[param1.id])
         {
            clicksThisSession[param1.id] = true;
            this.lv.logger.debug("ClickablePair.setHasBeenClicked [" + param1.id + "]");
         }
         delete this.clickablesCanPulse[param1];
      }
      
      public function update(param1:int) : void
      {
         var _loc2_:ClickablePair = null;
         if(!this.enabled || this._paused)
         {
            return;
         }
         this.pulse_check_countdown -= param1;
         if(this.pulse_check_countdown <= 0)
         {
            this.pulse_check_countdown = this.PULSE_CHECK_TIME_MS;
            for each(_loc2_ in this.clickablesCanPulse)
            {
               _loc2_.pulse();
            }
         }
      }
      
      public function set paused(param1:Boolean) : void
      {
         if(this._paused == param1)
         {
            return;
         }
         this._paused = param1;
         if(!this._paused)
         {
            this.pulse_check_countdown = this.PULSE_CHECK_TIME_MS;
         }
      }
      
      public function get paused() : Boolean
      {
         return this._paused;
      }
   }
}

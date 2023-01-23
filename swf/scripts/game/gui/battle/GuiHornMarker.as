package game.gui.battle
{
   import com.greensock.TweenLite;
   import com.greensock.TweenMax;
   import engine.core.util.MovieClipAdapter;
   import flash.display.MovieClip;
   import game.gui.GuiBase;
   import game.gui.IGuiContext;
   
   public class GuiHornMarker extends GuiBase
   {
       
      
      private var _markerEnabled:Boolean;
      
      private var _markerGlow:Number = 0;
      
      private var _markerAnim:MovieClip;
      
      private var markerAdapter:MovieClipAdapter;
      
      public function GuiHornMarker()
      {
         super();
      }
      
      public function cleanup() : void
      {
         if(this.markerAdapter)
         {
            this.markerAdapter.cleanup();
            this.markerAdapter = null;
         }
      }
      
      public function get markerGlow() : Number
      {
         return this._markerGlow;
      }
      
      public function set markerGlow(param1:Number) : void
      {
         if(this._markerGlow == param1)
         {
            return;
         }
         this._markerGlow = param1;
         this.updateMarkerState();
      }
      
      public function init(param1:IGuiContext) : void
      {
         initGuiBase(param1);
         this.updateMarkerState();
      }
      
      public function set markerEnabled(param1:Boolean) : void
      {
         if(this._markerEnabled == param1)
         {
            return;
         }
         if(!this._markerEnabled)
         {
            this._markerGlow = 0;
         }
         this._markerEnabled = param1;
         this.updateMarkerState();
      }
      
      public function get markerEnabled() : Boolean
      {
         return this._markerEnabled;
      }
      
      private function updateMarkerState() : void
      {
         if(this.markerAdapter)
         {
            this.markerAdapter.cleanup();
            this.markerAdapter = null;
         }
         TweenLite.killTweensOf(this);
         if(this._markerGlow > 0)
         {
            gotoAndStop(3);
            TweenMax.delayedCall(0.25,function():void
            {
               markerGlow = 0;
            });
         }
         else if(this._markerEnabled)
         {
            gotoAndStop(2);
            this._markerAnim = getChildByName("starAnim") as MovieClip;
            if(this._markerAnim)
            {
               this.markerAdapter = new MovieClipAdapter(this._markerAnim,30,0,false,context.logger);
               this.markerAdapter.playOnce();
            }
         }
         else
         {
            gotoAndStop(1);
         }
      }
   }
}

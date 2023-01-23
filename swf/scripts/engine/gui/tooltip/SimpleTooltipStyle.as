package engine.gui.tooltip
{
   import engine.resource.IResourceManager;
   
   public class SimpleTooltipStyle
   {
       
      
      public var def:SimpleTooltipStyleDef;
      
      private var loadedCallback:Function;
      
      private var waitCallback:Function;
      
      public var triplet_bg:SimpleTooltipStyleDisplayTriplet;
      
      public var triplet_glow:SimpleTooltipStyleDisplayTriplet;
      
      private var _handledLoaded:Boolean;
      
      public function SimpleTooltipStyle(param1:SimpleTooltipStyleDef)
      {
         super();
         this.def = param1;
         this.triplet_bg = new SimpleTooltipStyleDisplayTriplet(this,param1.triplet_bg);
         this.triplet_glow = new SimpleTooltipStyleDisplayTriplet(this,param1.triplet_glow);
      }
      
      public function loadTooltip(param1:IResourceManager, param2:Function) : void
      {
         this.loadedCallback = param2;
         this.triplet_bg.loadTooltip(param1);
         this.triplet_glow.loadTooltip(param1);
      }
      
      public function cleanup() : void
      {
         this.triplet_bg.cleanup();
         this.triplet_bg = null;
         this.triplet_glow.cleanup();
         this.triplet_glow = null;
      }
      
      private function handleLoaded() : void
      {
         if(this._handledLoaded)
         {
            return;
         }
         this._handledLoaded = true;
         var _loc1_:Function = this.loadedCallback;
         this.loadedCallback = null;
         if(_loc1_ != null)
         {
            _loc1_(this);
         }
         _loc1_ = this.waitCallback;
         this.waitCallback = null;
         if(_loc1_ != null)
         {
            _loc1_(this);
         }
      }
      
      public function waitStyleLoaded(param1:Function) : void
      {
         if(this._handledLoaded)
         {
            this.waitCallback = null;
            param1(this);
            return;
         }
         this.waitCallback = param1;
      }
      
      public function handleStyleDisplayTripletLoaded(param1:SimpleTooltipStyleDisplayTriplet) : void
      {
         if(this.triplet_bg.loaded && this.triplet_glow.loaded)
         {
            this.handleLoaded();
         }
      }
   }
}

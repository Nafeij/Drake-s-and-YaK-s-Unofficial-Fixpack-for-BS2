package engine.gui.tooltip
{
   import engine.resource.BitmapResource;
   import engine.resource.IResource;
   import engine.resource.IResourceManager;
   import engine.resource.event.ResourceLoadedEvent;
   
   public class SimpleTooltipStyleDisplayTriplet
   {
       
      
      public var style:SimpleTooltipStyle;
      
      public var def:SimpleTooltipStyleDisplayTripletDef;
      
      public var bmpr_left:BitmapResource;
      
      public var bmpr_right:BitmapResource;
      
      public var bmpr_center:BitmapResource;
      
      public var loaded:Boolean;
      
      public function SimpleTooltipStyleDisplayTriplet(param1:SimpleTooltipStyle, param2:SimpleTooltipStyleDisplayTripletDef)
      {
         super();
         this.style = param1;
         this.def = param2;
      }
      
      public function cleanup() : void
      {
         this.style = null;
         this.def = null;
         if(this.bmpr_left)
         {
            this.bmpr_left.removeResourceListener(this.bmprHandler);
            this.bmpr_left.release();
            this.bmpr_left = null;
         }
         if(this.bmpr_right)
         {
            this.bmpr_right.removeResourceListener(this.bmprHandler);
            this.bmpr_right.release();
            this.bmpr_right = null;
         }
         if(this.bmpr_center)
         {
            this.bmpr_center.removeResourceListener(this.bmprHandler);
            this.bmpr_center.release();
            this.bmpr_center = null;
         }
      }
      
      public function loadTooltip(param1:IResourceManager) : void
      {
         if(this.def.url_left)
         {
            this.bmpr_left = param1.getResource(this.def.url_left,BitmapResource) as BitmapResource;
            this.bmpr_left.addResourceListener(this.bmprHandler);
         }
         if(this.def.url_right)
         {
            this.bmpr_right = param1.getResource(this.def.url_right,BitmapResource) as BitmapResource;
            this.bmpr_right.addResourceListener(this.bmprHandler);
         }
         if(this.def.url_center)
         {
            this.bmpr_center = param1.getResource(this.def.url_center,BitmapResource) as BitmapResource;
            this.bmpr_center.addResourceListener(this.bmprHandler);
         }
      }
      
      private function bmprHandler(param1:ResourceLoadedEvent) : void
      {
         var _loc2_:IResource = param1.resource;
         _loc2_.removeResourceListener(this.bmprHandler);
         if(Boolean(this.bmpr_left) && !this.bmpr_left.did_load)
         {
            return;
         }
         if(Boolean(this.bmpr_right) && !this.bmpr_right.did_load)
         {
            return;
         }
         if(Boolean(this.bmpr_center) && !this.bmpr_center.did_load)
         {
            return;
         }
         this.handleLoaded();
      }
      
      private function handleLoaded() : void
      {
         if(this.loaded)
         {
            return;
         }
         this.loaded = true;
         if(Boolean(this.bmpr_left) && !this.bmpr_left.ok)
         {
            this.bmpr_left.release();
            this.bmpr_left = null;
         }
         if(Boolean(this.bmpr_right) && !this.bmpr_right.ok)
         {
            this.bmpr_right.release();
            this.bmpr_right = null;
         }
         if(Boolean(this.bmpr_center) && !this.bmpr_center.ok)
         {
            this.bmpr_center.release();
            this.bmpr_center = null;
         }
         this.style.handleStyleDisplayTripletLoaded(this);
      }
   }
}

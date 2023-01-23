package engine.gui
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class GuiGpNavButtonGlowy extends MovieClip implements IGuiGpNavButton
   {
       
      
      public var glow_filt:Array;
      
      public var navrect_pt:Point;
      
      public var navrect:Rectangle;
      
      public function GuiGpNavButtonGlowy()
      {
         this.glow_filt = [new GlowFilter(10145518,1,6,6,2,1)];
         this.navrect_pt = new Point(1044,0);
         this.navrect = new Rectangle();
         super();
      }
      
      public function press() : void
      {
         dispatchEvent(new Event(Event.SELECT));
      }
      
      public function setHovering(param1:Boolean) : void
      {
         if(param1)
         {
            filters = this.glow_filt;
         }
         else
         {
            filters = [];
         }
      }
      
      public function getNavRectangle(param1:DisplayObject) : Rectangle
      {
         this.navrect_pt.y = this.y;
         var _loc2_:Point = parent.localToGlobal(this.navrect_pt);
         var _loc3_:Point = param1.globalToLocal(_loc2_);
         this.navrect.setTo(_loc3_.x,_loc3_.y,height,height);
         return this.navrect;
      }
   }
}

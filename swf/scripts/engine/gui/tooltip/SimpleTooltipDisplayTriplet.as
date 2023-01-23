package engine.gui.tooltip
{
   import engine.landscape.view.ISimpleTooltipsLayer;
   import engine.landscape.view.ISimpleTooltipsLayerHandle;
   
   public class SimpleTooltipDisplayTriplet
   {
       
      
      public var triplet:SimpleTooltipStyleDisplayTriplet;
      
      public var qh_bg_left:ISimpleTooltipsLayerHandle;
      
      public var qh_bg_right:ISimpleTooltipsLayerHandle;
      
      public var qh_bg_center:ISimpleTooltipsLayerHandle;
      
      public var depth:int;
      
      private var _visible:Boolean;
      
      public var centerX:Number = 0;
      
      public function SimpleTooltipDisplayTriplet(param1:int, param2:SimpleTooltipStyleDisplayTriplet)
      {
         super();
         this.triplet = param2;
         this.depth = param1;
      }
      
      public function setGroupPos(param1:Number, param2:Number) : void
      {
         this.qh_bg_left && this.qh_bg_left.setGroupPos(param1,param2);
         this.qh_bg_right && this.qh_bg_right.setGroupPos(param1,param2);
         this.qh_bg_center && this.qh_bg_center.setGroupPos(param1,param2);
      }
      
      public function get visible() : Boolean
      {
         return this._visible;
      }
      
      public function set visible(param1:Boolean) : void
      {
         this._visible = param1;
         if(this.qh_bg_left)
         {
            this.qh_bg_left.visible = param1;
         }
         if(this.qh_bg_right)
         {
            this.qh_bg_right.visible = param1;
         }
         if(this.qh_bg_center)
         {
            this.qh_bg_center.visible = param1;
         }
      }
      
      public function handleStyleLoaded(param1:ISimpleTooltipsLayer) : void
      {
         var _loc2_:* = this.triplet.style.def.id + "_";
         this.qh_bg_left = param1.addQuad_BitmapResource(this.depth,_loc2_ + "left",this.triplet.bmpr_left);
         this.qh_bg_center = param1.addQuad_BitmapResource(this.depth,_loc2_ + "center",this.triplet.bmpr_center);
         this.qh_bg_right = param1.addQuad_BitmapResource(this.depth,_loc2_ + "right",this.triplet.bmpr_right);
      }
      
      public function cleanup() : void
      {
         this.qh_bg_left && this.qh_bg_left.remove();
         this.qh_bg_center && this.qh_bg_center.remove();
         this.qh_bg_right && this.qh_bg_right.remove();
      }
      
      public function arrangeBackground(param1:Number) : void
      {
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc2_:Number = param1 / 2;
         var _loc3_:Number = param1;
         var _loc4_:Number = -_loc2_;
         if(this.qh_bg_left)
         {
            _loc5_ = this.qh_bg_left.width;
            this.qh_bg_left.x = _loc4_;
            _loc3_ -= _loc5_;
            _loc4_ += _loc5_;
         }
         if(this.qh_bg_right)
         {
            _loc6_ = this.qh_bg_left.width;
            _loc3_ -= _loc6_;
            this.qh_bg_right.x = _loc4_ + _loc3_;
         }
         if(this.qh_bg_center)
         {
            this.qh_bg_center.scaleX = 1;
            this.qh_bg_center.scaleX = _loc3_ / this.qh_bg_center.width;
            this.qh_bg_center.x = _loc4_;
         }
         this.applyOffsets();
      }
      
      private function alignRight(param1:ISimpleTooltipsLayerHandle, param2:ISimpleTooltipsLayerHandle) : void
      {
         if(!param1 || !param2)
         {
            return;
         }
         param1.x = param2.x + param2.width - param1.width;
         param1.y = 0;
      }
      
      private function alignLeft(param1:ISimpleTooltipsLayerHandle, param2:ISimpleTooltipsLayerHandle) : void
      {
         if(!param1 || !param2)
         {
            return;
         }
         param1.x = param2.x;
         param1.y = 0;
      }
      
      public function arrangeOther(param1:SimpleTooltipDisplayTriplet) : void
      {
         this.alignRight(this.qh_bg_left,param1.qh_bg_left);
         this.alignLeft(this.qh_bg_center,param1.qh_bg_center);
         if(Boolean(this.qh_bg_center) && Boolean(param1.qh_bg_center))
         {
            this.qh_bg_center.scaleX = param1.qh_bg_center.scaleX;
         }
         this.alignLeft(this.qh_bg_right,param1.qh_bg_right);
         this.applyOffsets();
      }
      
      public function applyOffsets() : void
      {
         if(this.qh_bg_left)
         {
            this.qh_bg_left.y += this.triplet.def.offset_left;
         }
         if(this.qh_bg_center)
         {
            this.qh_bg_center.y += this.triplet.def.offset_center;
         }
         if(this.qh_bg_right)
         {
            this.qh_bg_right.y += this.triplet.def.offset_right;
         }
      }
   }
}

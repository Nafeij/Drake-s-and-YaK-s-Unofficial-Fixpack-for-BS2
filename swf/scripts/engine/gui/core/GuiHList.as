package engine.gui.core
{
   import flash.display.DisplayObject;
   
   public class GuiHList extends GuiSprite
   {
       
      
      public var margin:Number = 4;
      
      public var padding:Number = 4;
      
      public var fill:Boolean = true;
      
      public function GuiHList()
      {
         super();
      }
      
      override public function layoutChildren() : void
      {
         var _loc7_:int = 0;
         var _loc8_:DisplayObject = null;
         if(!numChildren)
         {
            return;
         }
         var _loc1_:Number = int(this.height - this.margin * 2);
         var _loc2_:Number = 0;
         var _loc3_:Number = 0;
         var _loc4_:Number = this.width - this.margin * 2 - (this.padding * numChildren - 1);
         if(this.fill)
         {
            _loc7_ = this.numVisibleChildren;
            _loc3_ = int(_loc4_ / _loc7_);
         }
         else
         {
            _loc3_ = _loc1_;
         }
         var _loc5_:Number = _loc3_ * numChildren + (this.padding * numChildren - 1);
         _loc2_ = (this.width - _loc5_) / 2;
         var _loc6_:int = 0;
         while(_loc6_ < numChildren)
         {
            _loc8_ = getChildAt(_loc6_);
            if(_loc8_.visible)
            {
               _loc8_.y = this.margin;
               _loc8_.x = _loc2_;
               _loc8_.height = _loc1_;
               _loc8_.width = _loc3_;
               _loc2_ += _loc3_ + this.padding;
            }
            _loc6_++;
         }
      }
      
      public function get numVisibleChildren() : int
      {
         var _loc3_:DisplayObject = null;
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         while(_loc2_ < numChildren)
         {
            _loc3_ = getChildAt(_loc2_);
            if(_loc3_.visible)
            {
               _loc1_++;
            }
            _loc2_++;
         }
         return _loc1_;
      }
   }
}

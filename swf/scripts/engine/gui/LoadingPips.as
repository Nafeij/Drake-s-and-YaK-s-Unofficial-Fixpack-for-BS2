package engine.gui
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class LoadingPips
   {
       
      
      private var _elapsed:int;
      
      private var PIPS_MS:int = 400;
      
      private var _pips:Vector.<DisplayObject>;
      
      public function LoadingPips(param1:MovieClip)
      {
         var _loc2_:int = 0;
         var _loc3_:DisplayObject = null;
         this._pips = new Vector.<DisplayObject>();
         super();
         if(param1)
         {
            _loc2_ = 0;
            while(_loc2_ < param1.numChildren)
            {
               _loc3_ = param1.getChildAt(_loc2_);
               this._pips.push(_loc3_);
               _loc2_++;
            }
         }
      }
      
      public function update(param1:int) : void
      {
         var _loc7_:DisplayObject = null;
         this._elapsed += param1;
         var _loc2_:int = this._elapsed / this.PIPS_MS;
         var _loc3_:int = _loc2_ / this._pips.length;
         var _loc4_:* = _loc3_ % 2 == 0;
         var _loc5_:int = _loc2_ - _loc3_ * this._pips.length;
         var _loc6_:int = 0;
         while(_loc6_ < this._pips.length)
         {
            _loc7_ = this._pips[_loc6_];
            _loc7_.visible = _loc6_ < _loc5_ == _loc4_;
            _loc6_++;
         }
      }
      
      public function reset() : void
      {
         this._elapsed = 0;
      }
   }
}

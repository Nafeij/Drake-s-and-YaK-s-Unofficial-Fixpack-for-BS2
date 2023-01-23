package game.gui.travel
{
   import flash.display.Graphics;
   import flash.display.MovieClip;
   import flash.text.TextField;
   import game.gui.GuiBase;
   import game.gui.IGuiContext;
   
   public class GuiTravelTimer extends GuiBase
   {
       
      
      public var _chit:MovieClip;
      
      public var _ringholder:MovieClip;
      
      public var radius:Number = 56;
      
      private var _day:Number = 0;
      
      private var _ringcolor:uint = 16711935;
      
      public function GuiTravelTimer()
      {
         super();
         this._chit = requireGuiChild("chit") as MovieClip;
         this._ringholder = requireGuiChild("ringholder") as MovieClip;
         var _loc1_:MovieClip = requireGuiChild("ringcolorSample") as MovieClip;
         var _loc2_:TextField = _loc1_.getChildAt(0) as TextField;
         this._ringcolor = _loc2_.textColor;
         _loc1_.visible = false;
         mouseEnabled = mouseChildren = false;
      }
      
      public function init(param1:IGuiContext) : void
      {
         super.initGuiBase(param1);
      }
      
      public function cleanup() : void
      {
         cleanupGuiBase();
      }
      
      public function get day() : Number
      {
         return this._day;
      }
      
      public function set day(param1:Number) : void
      {
         if(Math.abs(param1 - this._day) < 0.001 && Math.floor(param1) == Math.floor(this._day))
         {
            return;
         }
         this._day = param1;
         this.redraw();
      }
      
      private function redraw() : void
      {
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc1_:Graphics = this._ringholder.graphics;
         _loc1_.clear();
         var _loc2_:Number = this._day - Math.floor(this._day);
         this._chit.rotation = _loc2_ * 360;
         if(_loc2_ == 0)
         {
            return;
         }
         _loc1_.beginFill(this._ringcolor,1);
         _loc1_.moveTo(0,0);
         var _loc3_:Number = _loc2_ * Math.PI * 2;
         var _loc4_:int = Math.max(4,25 * _loc2_);
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            _loc6_ = Number(_loc5_) / (_loc4_ - 1);
            _loc7_ = Math.sin(_loc6_ * _loc3_);
            _loc8_ = -Math.cos(_loc6_ * _loc3_);
            _loc1_.lineTo(_loc7_ * this.radius,_loc8_ * this.radius);
            _loc5_++;
         }
         _loc1_.endFill();
      }
   }
}

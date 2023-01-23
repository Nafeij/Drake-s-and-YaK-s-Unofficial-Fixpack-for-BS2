package game.gui.battle
{
   import flash.display.DisplayObject;
   
   public class GuiSelfPopupBasic_Tweener
   {
       
      
      public var _d:DisplayObject;
      
      public var _delay:int;
      
      public var _duration:int;
      
      public var _elapsed:int;
      
      public var _active:Boolean;
      
      public function GuiSelfPopupBasic_Tweener(param1:DisplayObject)
      {
         super();
         this._d = param1;
      }
      
      public function cleanup() : void
      {
         this._d = null;
         this._active = false;
      }
      
      public function startTween(param1:int, param2:int) : void
      {
         if(!this._d.visible)
         {
            this._active = false;
            return;
         }
         this._d.scaleX = this._d.scaleY = 0;
         this._delay = param1;
         this._duration = param2;
         this._elapsed = 0;
         this._active = true;
      }
      
      public function updateTween(param1:int) : Boolean
      {
         if(!this._active)
         {
            return false;
         }
         this._elapsed += param1;
         if(this._elapsed <= this._delay)
         {
            return true;
         }
         var _loc2_:Number = (this._elapsed - this._delay) / this._duration;
         _loc2_ = Math.min(1,_loc2_);
         this._d.scaleX = this._d.scaleY = _loc2_;
         this._active = _loc2_ < 1;
         return this._active;
      }
   }
}

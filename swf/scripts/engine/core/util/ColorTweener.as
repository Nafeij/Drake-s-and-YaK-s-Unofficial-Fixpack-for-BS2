package engine.core.util
{
   import com.greensock.TweenMax;
   
   public class ColorTweener
   {
       
      
      public var color:uint = 0;
      
      private var _colorA:uint = 0;
      
      private var _colorB:uint = 0;
      
      private var _colorT:Number = 0;
      
      private var _callback:Function;
      
      public function ColorTweener(param1:uint, param2:Function)
      {
         super();
         this.color = 16777215;
         this._callback = param2;
      }
      
      public function cleanup() : void
      {
         TweenMax.killTweensOf(this);
      }
      
      public function set colorT(param1:Number) : void
      {
         this._colorT = param1;
         var _loc2_:uint = ColorUtil.lerpColor(this._colorA,this._colorB,this._colorT);
         if(_loc2_ != this.color)
         {
            this.color = _loc2_;
            if(this._callback != null)
            {
               this._callback(this.color);
            }
         }
      }
      
      public function get colorT() : Number
      {
         return this._colorT;
      }
      
      public function tweenTo(param1:uint, param2:Number) : void
      {
         this._colorA = this.color;
         this._colorB = param1;
         this._colorT = 0;
         TweenMax.killTweensOf(this);
         if(this._colorB != this.color)
         {
            if(param2)
            {
               TweenMax.to(this,param2,{"colorT":1});
            }
            else
            {
               this.color = this._colorB;
               if(this._callback != null)
               {
                  this._callback(this.color);
               }
            }
         }
      }
   }
}

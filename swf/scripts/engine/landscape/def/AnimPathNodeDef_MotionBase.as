package engine.landscape.def
{
   public class AnimPathNodeDef_MotionBase extends AnimPathNodeDef
   {
       
      
      public var ease:String = "linear";
      
      public var easeIn:Boolean = true;
      
      public var easeOut:Boolean = true;
      
      public var _easeFunction:Function;
      
      private var _easeFunction_ease:String;
      
      private var _easeFunction_in:Boolean;
      
      private var _easeFunction_out:Boolean;
      
      public function AnimPathNodeDef_MotionBase()
      {
         super();
         _durationSecs = 1;
      }
      
      public function copyFromMotionBase(param1:AnimPathNodeDef_MotionBase) : AnimPathNodeDef_MotionBase
      {
         this.ease = param1.ease;
         this.easeIn = param1.easeIn;
         this.easeOut = param1.easeOut;
         this._easeFunction = param1._easeFunction;
         this._easeFunction_in = param1._easeFunction_in;
         this._easeFunction_out = param1._easeFunction_out;
         this._easeFunction_ease = param1._easeFunction_ease;
         this.copyFromBase(param1);
         return this;
      }
      
      public function getEaseFunction() : Function
      {
         if(this._easeFunction != null)
         {
            if(this._easeFunction_ease == this.ease && this._easeFunction_in == this.easeIn && this._easeFunction_out == this.easeOut)
            {
               return this._easeFunction;
            }
         }
         this._easeFunction_ease = this.ease;
         this._easeFunction_in = this.easeIn;
         this._easeFunction_out = this.easeOut;
         this._easeFunction = LandscapeSplineDef.computeEaseFunction(this.ease,this.easeIn,this.easeOut);
         return this._easeFunction;
      }
   }
}

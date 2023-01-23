package engine.landscape.travel.model
{
   import engine.landscape.travel.def.TravelParamControlDef;
   import engine.math.MathUtil;
   
   public class TravelParamControl extends LandscapeParamControl
   {
       
      
      public var def:TravelParamControlDef;
      
      public var travel:Travel;
      
      public var last_pos:Number = -1;
      
      public var lerpPosRange:Number;
      
      public function TravelParamControl(param1:Travel, param2:TravelParamControlDef)
      {
         super();
         this.travel = param1;
         this.def = param2;
         this.lerpPosRange = param2.lerpPosEnd - param2.lerpPosStart;
         this.update();
      }
      
      public function update() : void
      {
         var _loc3_:Number = NaN;
         var _loc1_:Number = this.travel.position;
         if(this.last_pos == _loc1_)
         {
            return;
         }
         this.last_pos = _loc1_;
         if(_loc1_ > this.def.boundPosEnd || _loc1_ < this.def.boundPosStart)
         {
            valid = false;
            return;
         }
         valid = true;
         var _loc2_:Number = 0;
         if(_loc1_ > this.def.lerpPosEnd)
         {
            _loc2_ = this.def.valueEnd;
         }
         else if(_loc1_ < this.def.lerpPosStart)
         {
            _loc2_ = this.def.valueStart;
         }
         else
         {
            _loc3_ = (_loc1_ - this.def.lerpPosStart) / this.lerpPosRange;
            _loc2_ = MathUtil.lerp(this.def.valueStart,this.def.valueEnd,_loc3_);
         }
         if(_loc2_ != value)
         {
            value = _loc2_;
            ++ordinal;
         }
      }
   }
}

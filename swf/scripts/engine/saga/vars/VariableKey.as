package engine.saga.vars
{
   import engine.core.util.StringUtil;
   
   public class VariableKey
   {
      
      public static const DEFAULT_MIN:Number = 0;
      
      public static const DEFAULT_MAX:Number = 200;
       
      
      public var varname:String;
      
      public var min:Number = 0;
      
      public var max:Number = 200;
      
      public var factor:Number = 1;
      
      public var modulus:int = 0;
      
      public function VariableKey()
      {
         super();
      }
      
      public function clone() : VariableKey
      {
         var _loc1_:VariableKey = new VariableKey();
         _loc1_.varname = this.varname;
         _loc1_.varname = StringUtil.stripSurroundingSpace(_loc1_.varname);
         _loc1_.varname = _loc1_.varname.replace(/ /g,"_");
         _loc1_.min = this.min;
         _loc1_.max = this.max;
         _loc1_.factor = this.factor;
         _loc1_.modulus = this.modulus;
         return _loc1_;
      }
      
      public function toString() : String
      {
         if(this.factor == 1)
         {
            if(this.min == this.max)
            {
               return this.varname + " = " + this.max;
            }
            return this.varname + " [" + this.min + "," + this.max + "]";
         }
         if(this.min == this.max)
         {
            return this.varname + " * " + this.factor + " = " + this.max;
         }
         return this.varname + " * " + this.factor + " [" + this.min + "," + this.max + "]";
      }
      
      public function check(param1:IVariableProvider) : Boolean
      {
         var _loc2_:Number = 0;
         var _loc3_:IVariable = param1.getVar(this.varname,null);
         if(_loc3_)
         {
            _loc2_ = _loc3_.asNumber * this.factor;
         }
         if(this.modulus)
         {
            _loc2_ %= this.modulus;
         }
         return _loc2_ >= this.min && _loc2_ <= this.max;
      }
      
      public function compute(param1:IVariableProvider) : Number
      {
         var _loc3_:Number = NaN;
         var _loc2_:IVariable = param1.getVar(this.varname,null);
         if(_loc2_)
         {
            _loc3_ = _loc2_.asNumber * this.factor;
            if(this.modulus)
            {
               _loc3_ %= this.modulus;
            }
            return Math.max(this.min,Math.min(this.max,_loc3_));
         }
         return this.min;
      }
   }
}

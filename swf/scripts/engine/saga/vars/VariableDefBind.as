package engine.saga.vars
{
   public class VariableDefBind
   {
       
      
      public var src:String;
      
      public var src_multiplier:String;
      
      public var src_divisor:String;
      
      public var src_constant:String;
      
      public var dst:VariableDef;
      
      public var multiplier:Number = 1;
      
      public var divisor:Number = 1;
      
      public var constant:Number = 0;
      
      public function VariableDefBind(param1:VariableDef)
      {
         super();
         this.dst = param1;
      }
      
      public function clone() : VariableDefBind
      {
         var _loc1_:VariableDefBind = new VariableDefBind(this.dst);
         _loc1_.src = this.src;
         _loc1_.src_multiplier = this.src_divisor;
         _loc1_.src_divisor = this.src_divisor;
         _loc1_.src_constant = this.src_constant;
         _loc1_.multiplier = this.multiplier;
         _loc1_.divisor = this.divisor;
         _loc1_.constant = this.constant;
         return _loc1_;
      }
      
      public function compute(param1:IVariableBag) : Number
      {
         var _loc2_:IVariable = param1.fetch(this.src,null);
         var _loc3_:IVariable = !!this.src_multiplier ? param1.fetch(this.src_multiplier,null) : null;
         var _loc4_:IVariable = !!this.src_divisor ? param1.fetch(this.src_divisor,null) : null;
         var _loc5_:IVariable = !!this.src_constant ? param1.fetch(this.src_constant,null) : null;
         var _loc6_:Number = !!_loc2_ ? _loc2_.asNumber : 0;
         var _loc7_:Number = !!_loc3_ ? _loc3_.asNumber : this.multiplier;
         var _loc8_:Number = !!_loc4_ ? _loc4_.asNumber : this.divisor;
         var _loc9_:Number = !!_loc5_ ? _loc5_.asNumber : this.constant;
         if(_loc8_ == 0)
         {
            return 0;
         }
         return _loc9_ + _loc6_ * _loc7_ / _loc8_;
      }
      
      public function isBound(param1:String) : Boolean
      {
         return Boolean(param1) && (this.src == param1 || this.src_multiplier == param1 || this.src_divisor == param1 || this.src_constant == param1);
      }
      
      public function toString() : String
      {
         return "((" + this.src + " * " + this.labelMultiplier + " / " + this.labelDivisor + " ) + " + this.labelConstant + ")";
      }
      
      private function get labelMultiplier() : String
      {
         return !!this.src_multiplier ? this.src_multiplier : this.multiplier.toFixed(1);
      }
      
      private function get labelDivisor() : String
      {
         return !!this.src_divisor ? this.src_divisor : this.divisor.toFixed(1);
      }
      
      private function get labelConstant() : String
      {
         return !!this.src_constant ? this.src_constant : this.constant.toFixed(1);
      }
   }
}

package engine.saga.action
{
   import com.greensock.TweenMax;
   import engine.saga.Saga;
   import engine.saga.SagaVar;
   import engine.saga.vars.IVariable;
   import engine.saga.vars.VariableType;
   
   public class Action_TweenVariable extends Action
   {
       
      
      private var _v:IVariable = null;
      
      private var _finalValue:Number;
      
      private var _suppressFlytext:Boolean = false;
      
      private var _halted:Boolean;
      
      public function Action_TweenVariable(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      private function _checkHalting() : void
      {
         if(!this._v || !this._v.def || saga.camped)
         {
            return;
         }
         if(this._v.def.name == SagaVar.VAR_DAYS_REMAINING)
         {
            this._halted = true;
            saga.halted = true;
         }
      }
      
      private function _checkUnhalting() : void
      {
         if(this._halted)
         {
            this._halted = false;
            saga.cancelHalting("tween " + this);
            saga.halted = false;
         }
      }
      
      override protected function handleEnded() : void
      {
         this._checkUnhalting();
         saga.isProcessingActionTween = false;
      }
      
      override protected function handleStarted() : void
      {
         var _loc4_:IVariable = null;
         if(!def.varname)
         {
            throw new ArgumentError("No varname for " + this);
         }
         this._v = saga.getVar(def.varname,VariableType.DECIMAL);
         if(!this._v)
         {
            throw new ArgumentError("Invalid varname: " + def.varname);
         }
         this._checkHalting();
         var _loc1_:Number = def.time > 0 ? def.time : 0.5;
         var _loc2_:Number = def.varvalue;
         var _loc3_:String = !!def.param ? def.param : "+";
         if(def.varother)
         {
            _loc4_ = saga.getVar(def.varother,null);
            if(_loc4_)
            {
               _loc2_ = _loc4_.asNumber;
            }
         }
         this._finalValue = this._v.asNumber;
         switch(_loc3_)
         {
            case "+":
               this._finalValue += _loc2_;
               break;
            case "-":
               this._finalValue -= _loc2_;
               break;
            case "*":
               this._finalValue *= _loc2_;
               break;
            case "/":
               this._finalValue /= _loc2_;
               break;
            case "%":
               this._finalValue %= _loc2_;
               break;
            default:
               throw new ArgumentError("Invalid operation [" + _loc3_ + "].  Must be one of [+ - * / %]");
         }
         this._finalValue = this._v.def.clamp(this._finalValue,logger);
         if(this._finalValue == this.value)
         {
            this.onComplete();
            return;
         }
         TweenMax.to(this,_loc1_,{
            "value":this._finalValue,
            "onComplete":this.onComplete
         });
         saga.isProcessingActionTween = true;
      }
      
      public function get value() : Number
      {
         return this._v.asNumber;
      }
      
      public function set value(param1:Number) : void
      {
         var _loc2_:Boolean = saga.suppressVariableFlytext;
         saga.suppressVariableFlytext = this._suppressFlytext;
         this._v.asNumber = param1;
         saga.suppressVariableFlytext = _loc2_;
      }
      
      private function onComplete() : void
      {
         end();
      }
      
      override public function fastForward() : Boolean
      {
         TweenMax.killTweensOf(this);
         this.value = this._finalValue;
         this.onComplete();
         return true;
      }
   }
}

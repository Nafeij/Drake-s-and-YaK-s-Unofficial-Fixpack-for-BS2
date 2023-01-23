package engine.landscape.view
{
   import com.greensock.TweenMax;
   import engine.core.util.ColorTweener;
   import engine.math.MathUtil;
   import engine.saga.Caravan;
   import engine.saga.Saga;
   import engine.saga.SagaVar;
   import engine.saga.vars.IVariable;
   import engine.saga.vars.IVariableBag;
   import engine.saga.vars.VariableEvent;
   import engine.saga.vars.VariableType;
   
   public class WeatherManager_Fog
   {
       
      
      public var manager:WeatherManager;
      
      public var color:uint = 16777215;
      
      public var colorTweener:ColorTweener;
      
      public var unmodifiedDensity:Number = 0;
      
      public var variance:Number = 0;
      
      private var densityModifier:Number = 0;
      
      private var _tweenDensity:TweenMax;
      
      private var _varianceT:Number = 0;
      
      private var _variancePulseDurationMs:int = 0;
      
      private var _variancePulseAmplitude:Number = 0;
      
      private var _varianceNextPulseTime:int = 0;
      
      private var _variancePulsing:Boolean;
      
      private var _elapsed:int;
      
      public function WeatherManager_Fog(param1:WeatherManager)
      {
         this.colorTweener = new ColorTweener(this.color,this.tweenerSetColor);
         super();
         this.manager = param1;
      }
      
      public function getDensity() : Number
      {
         return MathUtil.clampValue(this.unmodifiedDensity + this.densityModifier,0,1);
      }
      
      public function cleanup() : void
      {
         this._tweenDensity = null;
         this.colorTweener.cleanup();
         this.colorTweener = null;
         TweenMax.killTweensOf(this);
      }
      
      private function get fogTweenTime() : Number
      {
         var _loc1_:Saga = this.manager.saga;
         var _loc2_:Caravan = !!_loc1_ ? _loc1_.caravan : null;
         var _loc3_:IVariableBag = !!_loc2_ ? _loc2_.vars : null;
         if(_loc3_)
         {
            return _loc3_.fetch(SagaVar.VAR_WEATHER_FOG_TWEENTIME,VariableType.DECIMAL).asNumber;
         }
         return 1;
      }
      
      public function tweenFogDensity(param1:Number) : void
      {
         if(isNaN(param1))
         {
            return;
         }
         var _loc2_:Number = this.fogTweenTime;
         if(this._tweenDensity)
         {
            this._tweenDensity.kill();
            this._tweenDensity = null;
         }
         this._tweenDensity = TweenMax.to(this,_loc2_,{"unmodifiedDensity":param1});
      }
      
      public function tweenFogColor(param1:uint) : void
      {
         this.colorTweener.tweenTo(param1,this.fogTweenTime);
      }
      
      public function variableHandler(param1:VariableEvent) : Boolean
      {
         switch(param1.value.def.name)
         {
            case SagaVar.VAR_WEATHER_FOG_DENSITY:
               this.tweenFogDensity(param1.value.asNumber);
               break;
            case SagaVar.VAR_WEATHER_FOG_COLOR:
               this.tweenFogColor(param1.value.asUnsigned);
               break;
            case SagaVar.VAR_WEATHER_FOG_VARIANCE:
               this.variance = param1.value.asNumber;
               break;
            default:
               return false;
         }
         return true;
      }
      
      public function getVariables(param1:IVariableBag) : void
      {
         if(!param1)
         {
            return;
         }
         this.unmodifiedDensity = param1.fetch(SagaVar.VAR_WEATHER_FOG_DENSITY,VariableType.DECIMAL).asNumber;
         var _loc2_:IVariable = param1.fetch(SagaVar.VAR_WEATHER_FOG_COLOR,VariableType.DECIMAL);
         _loc2_.def.upperBound = uint.MAX_VALUE;
         _loc2_.def.lowerBound = int.MIN_VALUE;
         this.colorTweener.color = _loc2_.asUnsigned;
         this.color = this.colorTweener.color;
         this.variance = param1.fetch(SagaVar.VAR_WEATHER_FOG_VARIANCE,VariableType.DECIMAL).asNumber;
      }
      
      private function tweenerSetColor(param1:uint) : void
      {
         this.color = param1;
      }
      
      public function update(param1:int) : void
      {
         var _loc5_:int = 0;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         if(!this.variance || !this.unmodifiedDensity && !this._variancePulsing)
         {
            this._varianceNextPulseTime = 0;
            this.densityModifier = 0;
            return;
         }
         this._elapsed += param1;
         if(this._varianceNextPulseTime > 0)
         {
            if(this._elapsed < this._varianceNextPulseTime)
            {
               return;
            }
            if(!this._variancePulsing)
            {
               this._varianceNextPulseTime = this._elapsed;
               this._variancePulsing = true;
            }
         }
         if(this._variancePulsing)
         {
            _loc5_ = this._elapsed - this._varianceNextPulseTime;
            if(_loc5_ < this._variancePulseDurationMs)
            {
               _loc6_ = _loc5_ / this._variancePulseDurationMs;
               _loc7_ = this._variancePulseAmplitude * this.variance * this.unmodifiedDensity;
               this.densityModifier = Math.sin(_loc6_ * Math.PI) * _loc7_;
               return;
            }
            this.densityModifier = 0;
         }
         var _loc2_:int = 200 + Math.random() * 4000;
         var _loc3_:int = 2000 + Math.random() * 10000;
         var _loc4_:Number = Math.min(5,this.manager.wind);
         _loc7_ = 0.2 + Math.random() * 0.8;
         if(_loc4_ >= 1)
         {
            param1 /= _loc4_;
            _loc3_ /= _loc4_;
            _loc3_ = Math.max(500,_loc3_);
         }
         this._varianceNextPulseTime = this._elapsed + _loc2_;
         this._variancePulseDurationMs = _loc3_;
         this._variancePulseAmplitude = _loc7_;
      }
   }
}

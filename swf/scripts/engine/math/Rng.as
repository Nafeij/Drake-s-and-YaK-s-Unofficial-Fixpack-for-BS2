package engine.math
{
   import engine.core.logging.ILogger;
   import flash.utils.ByteArray;
   
   public class Rng
   {
      
      public static var DEBUG:Boolean;
       
      
      private var _sampler:IRngSampler;
      
      private var _logger:ILogger;
      
      public function Rng(param1:IRngSampler, param2:ILogger = null)
      {
         super();
         this._sampler = param1;
         this._logger = param2;
      }
      
      public function get sampler() : IRngSampler
      {
         return this._sampler;
      }
      
      private function getSampleForLargeRange() : Number
      {
         var _loc1_:int = this._sampler.integerSample();
         if(this._sampler.integerSample() % 2 == 0)
         {
            _loc1_ = -_loc1_;
         }
         var _loc2_:Number = _loc1_;
         _loc2_ += 2147483646;
         return _loc2_ / 4294967293;
      }
      
      public function get sampleCount() : int
      {
         if(DEBUG && this._logger && this._logger.isDebugEnabled)
         {
            this._logger.d("RNG ","Sampler count: " + this._sampler.sampleCount);
         }
         return this._sampler.sampleCount;
      }
      
      public function nextInt() : int
      {
         var _loc1_:int = this._sampler.integerSample();
         if(DEBUG && this._logger && this._logger.isDebugEnabled)
         {
            this._logger.d("RNG ","Sampled integer: " + _loc1_);
         }
         return _loc1_;
      }
      
      public function nextMax(param1:int) : int
      {
         if(param1 < 0)
         {
            throw new ArgumentError("Argument \"maxValue\" must be positive.");
         }
         var _loc2_:int = Math.round(this.sample() * param1);
         if(DEBUG && this._logger && this._logger.isDebugEnabled)
         {
            this._logger.d("RNG ","Sampled max value integer: " + _loc2_ + " .." + param1 + "]");
         }
         return _loc2_;
      }
      
      public function nextMinMax(param1:int, param2:int) : int
      {
         if(param1 > param2)
         {
            throw new ArgumentError("Argument \"minValue\" must be less than or equal to \"maxValue\".");
         }
         var _loc3_:Number = param2 - param1;
         var _loc4_:int = param1;
         if(_loc3_ <= 2147483647)
         {
            _loc4_ = Math.round(this.sample() * _loc3_) + param1;
         }
         else
         {
            _loc4_ = Math.round(Number(this.getSampleForLargeRange() * _loc3_)) + param1;
         }
         if(DEBUG && this._logger && this._logger.isDebugEnabled)
         {
            this._logger.d("RNG ","Sampled min-max integer: " + _loc4_ + " [" + param1 + ".." + param2 + "]");
         }
         return _loc4_;
      }
      
      public function nextBytes(param1:ByteArray, param2:int) : void
      {
         if(param1 == null)
         {
            throw new ArgumentError("Argument \"buffer\" cannot be null.");
         }
         var _loc3_:int = 0;
         while(_loc3_ < param2)
         {
            param1.writeByte(this._sampler.integerSample() % 256);
            _loc3_++;
         }
      }
      
      public function nextNumber() : Number
      {
         var _loc1_:Number = this.sample();
         if(DEBUG && this._logger && this._logger.isDebugEnabled)
         {
            this._logger.d("RNG ","Sampled number: " + _loc1_);
         }
         return _loc1_;
      }
      
      protected function sample() : Number
      {
         return this._sampler.integerSample() * 4.656612875245797e-10;
      }
   }
}

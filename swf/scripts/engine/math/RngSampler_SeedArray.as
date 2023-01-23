package engine.math
{
   import engine.core.logging.ILogger;
   
   public class RngSampler_SeedArray implements IRngSampler
   {
       
      
      private var _inext:int;
      
      private var _inextp:int;
      
      private const MBIG:int = 2147483647;
      
      private const MSEED:int = 161803398;
      
      private const MZ:int = 0;
      
      private var _seed:int;
      
      private var _seedArray:Vector.<int>;
      
      public var _sampleCount:int;
      
      public function RngSampler_SeedArray(param1:int)
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         super();
         this._seed = param1;
         this._seedArray = new Vector.<int>(56,true);
         var _loc2_:int = 161803398 - Math.abs(param1);
         this._seedArray[55] = _loc2_;
         var _loc3_:int = 1;
         var _loc4_:int = 1;
         while(_loc4_ < 55)
         {
            _loc6_ = 21 * _loc4_ % 55;
            this._seedArray[_loc6_] = _loc3_;
            _loc3_ = _loc2_ - _loc3_;
            if(_loc3_ < 0)
            {
               _loc3_ += 2147483647;
            }
            _loc2_ = this._seedArray[_loc6_];
            _loc4_++;
         }
         var _loc5_:int = 1;
         while(_loc5_ < 5)
         {
            _loc7_ = 1;
            while(_loc7_ < 56)
            {
               this._seedArray[_loc7_] -= this._seedArray[1 + (_loc7_ + 30) % 55];
               if(this._seedArray[_loc7_] < 0)
               {
                  this._seedArray[_loc7_] += 2147483647;
               }
               _loc7_++;
            }
            _loc5_++;
         }
         this._inext = 0;
         this._inextp = 21;
      }
      
      public static function ctor(param1:int, param2:ILogger = null) : Rng
      {
         return new Rng(new RngSampler_SeedArray(param1),param2);
      }
      
      public function integerSample() : int
      {
         var _loc1_:int = this._inext;
         var _loc2_:int = this._inextp;
         if(++_loc1_ >= 56)
         {
            _loc1_ = 1;
         }
         if(++_loc2_ >= 56)
         {
            _loc2_ = 1;
         }
         var _loc3_:int = this._seedArray[_loc1_] - this._seedArray[_loc2_];
         if(_loc3_ < 0)
         {
            _loc3_ += 2147483647;
         }
         this._seedArray[_loc1_] = _loc3_;
         this._inext = _loc1_;
         this._inextp = _loc2_;
         ++this._sampleCount;
         return _loc3_;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : void
      {
         this._seed = param1.seed;
         if(this._seedArray.length != this._seedArray.length)
         {
            param2.e("RNG","Rng mismatch array");
         }
         var _loc3_:int = 0;
         while(_loc3_ < param1.seedArray.length)
         {
            this._seedArray[_loc3_] = param1.seedArray[_loc3_];
            _loc3_++;
         }
         this._inext = param1.inext;
         this._inextp = param1.inextp;
         this._sampleCount = param1._sampleCount;
         param2.i("RNG","RNG loaded from save: " + this._seed);
      }
      
      public function toJson() : Object
      {
         var _loc2_:int = 0;
         var _loc1_:Object = {
            "seed":this._seed,
            "inext":this._inext,
            "inextp":this._inextp,
            "_sampleCount":this._sampleCount,
            "seedArray":[]
         };
         for each(_loc2_ in this._seedArray)
         {
            _loc1_.seedArray.push(_loc2_);
         }
         return _loc1_;
      }
      
      public function get sampleCount() : int
      {
         return this._sampleCount;
      }
   }
}

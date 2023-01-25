package engine.saga
{
   import flash.utils.Dictionary;
   
   public class SagaBuckets
   {
       
      
      public var buckets:Vector.<SagaBucket>;
      
      public var bucketsByName:Dictionary;
      
      public var saga:SagaDef;
      
      public function SagaBuckets(param1:SagaDef)
      {
         this.buckets = new Vector.<SagaBucket>();
         this.bucketsByName = new Dictionary();
         super();
         this.saga = param1;
      }
      
      public function getSagaBucket(param1:String) : SagaBucket
      {
         return this.bucketsByName[param1] as SagaBucket;
      }
      
      public function removeBucket(param1:SagaBucket) : void
      {
         var _loc2_:int = 0;
         if(param1)
         {
            delete this.bucketsByName[param1.name];
            _loc2_ = this.buckets.indexOf(param1);
            if(_loc2_ >= 0)
            {
               this.buckets.splice(_loc2_,1);
            }
         }
      }
      
      public function addBucket(param1:SagaBucket) : void
      {
         if(param1)
         {
            this.buckets.push(param1);
            this.bucketsByName[param1.name] = param1;
         }
      }
      
      public function renameBucket(param1:SagaBucket, param2:String) : void
      {
         var _loc3_:String = null;
         if(param1)
         {
            _loc3_ = param1.name;
            delete this.bucketsByName[param1.name];
            param1.name = param2;
            this.bucketsByName[param1.name] = param1;
            this.saga.happenings.handleRenameBucket(_loc3_,param1.name);
         }
      }
      
      public function createNewBucket() : SagaBucket
      {
         var _loc2_:String = null;
         var _loc3_:SagaBucket = null;
         var _loc1_:int = int(this.buckets.length);
         while(_loc1_ < 1000)
         {
            _loc2_ = "New Bucket " + _loc1_;
            if(!this.bucketsByName[_loc2_])
            {
               _loc3_ = new SagaBucket();
               _loc3_.name = _loc2_;
               this.addBucket(_loc3_);
               return _loc3_;
            }
            _loc1_++;
         }
         return null;
      }
      
      public function promoteBucket(param1:SagaBucket) : void
      {
         var _loc2_:int = this.buckets.indexOf(param1);
         if(_loc2_ > 0)
         {
            this.buckets.splice(_loc2_,1);
            this.buckets.splice(_loc2_ - 1,0,param1);
         }
      }
      
      public function demoteBucket(param1:SagaBucket) : void
      {
         var _loc2_:int = this.buckets.indexOf(param1);
         if(_loc2_ >= 0 && _loc2_ < this.buckets.length - 1)
         {
            this.buckets.splice(_loc2_,1);
            this.buckets.splice(_loc2_ + 1,0,param1);
         }
      }
   }
}

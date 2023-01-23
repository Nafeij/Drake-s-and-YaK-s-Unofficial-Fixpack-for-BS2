package engine.saga
{
   import flash.utils.Dictionary;
   
   public class SagaBucket
   {
       
      
      public var name:String;
      
      public var _ents:Vector.<SagaBucketEnt>;
      
      public var idToEnt:Dictionary;
      
      public var shitlistId:String;
      
      public var minRequirements:Dictionary;
      
      public function SagaBucket()
      {
         this._ents = new Vector.<SagaBucketEnt>();
         this.idToEnt = new Dictionary();
         this.minRequirements = new Dictionary();
         super();
      }
      
      public function toString() : String
      {
         return this.name;
      }
      
      public function addEntity(param1:SagaBucketEnt, param2:Boolean) : Boolean
      {
         param1 = param1.clone();
         if(this.idToEnt[param1.entityId])
         {
            return false;
         }
         this.idToEnt[param1.entityId] = param1;
         this._ents.push(param1);
         return true;
      }
      
      public function indexOf(param1:String) : int
      {
         var _loc2_:int = 0;
         while(_loc2_ < this._ents.length)
         {
            if(this._ents[_loc2_].entityId == param1)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return -1;
      }
      
      public function hasEntity(param1:String) : Boolean
      {
         return this.idToEnt[param1] != undefined;
      }
      
      public function findEntity(param1:String) : SagaBucketEnt
      {
         return this.idToEnt[param1];
      }
      
      public function clear() : void
      {
         this._ents.splice(0,this._ents.length);
         this.idToEnt = new Dictionary();
      }
      
      public function removeEntity(param1:String) : void
      {
         var _loc2_:int = this.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this._ents.splice(_loc2_,1);
         }
         delete this.idToEnt[param1];
      }
      
      public function promoteEntity(param1:String) : void
      {
         var _loc3_:SagaBucketEnt = null;
         var _loc2_:int = this.indexOf(param1);
         if(_loc2_ > 0)
         {
            _loc3_ = this._ents[_loc2_];
            this._ents.splice(_loc2_,1);
            this._ents.splice(_loc2_ - 1,0,_loc3_);
         }
      }
      
      public function demoteEntity(param1:String) : void
      {
         var _loc3_:SagaBucketEnt = null;
         var _loc2_:int = this.indexOf(param1);
         if(_loc2_ >= 0 && _loc2_ < this._ents.length - 1)
         {
            _loc3_ = this._ents[_loc2_];
            this._ents.splice(_loc2_,1);
            this._ents.splice(_loc2_ + 1,0,_loc3_);
         }
      }
      
      public function renameEntity(param1:String, param2:String) : SagaBucketEnt
      {
         if(this.idToEnt[param1])
         {
            return null;
         }
         var _loc3_:SagaBucketEnt = this.idToEnt[param1];
         delete this.idToEnt[param1];
         _loc3_.entityId = param2;
         this.idToEnt[param2] = _loc3_;
         return _loc3_;
      }
      
      protected function _updateMinRequirements() : void
      {
         var _loc1_:SagaBucketEnt = null;
         var _loc2_:int = 0;
         for each(_loc1_ in this._ents)
         {
            if(_loc1_.min > 0)
            {
               _loc2_ = int(this.minRequirements[_loc1_.entityId]);
               _loc2_ += _loc1_.min;
               this.minRequirements[_loc1_.entityId] = _loc2_;
            }
         }
      }
   }
}

package engine.core.util
{
   import flash.utils.Dictionary;
   
   public class ObjectPool
   {
       
      
      public var pool:Array;
      
      public var ctor:Function;
      
      public var dtor:Function;
      
      public var limit:int;
      
      public var initial:int;
      
      public var clazz:Class;
      
      public var popped:Dictionary;
      
      public var name:String;
      
      public var numPopped:int;
      
      public var numDestroyed:int;
      
      public function ObjectPool(param1:String, param2:Class, param3:Function, param4:Function, param5:int, param6:int)
      {
         this.pool = [];
         this.popped = new Dictionary();
         super();
         if(param2 == null && param3 == null)
         {
            throw new ArgumentError("Null clazz and ctor for ObjectPool, fool.");
         }
         this.ctor = param3;
         this.clazz = param2;
         this.dtor = param4;
         this.initial = param5;
         this.limit = param6;
         this.name = param1;
      }
      
      public function toString() : String
      {
         return "ObjectPool " + this.name;
      }
      
      public function checkInitials() : void
      {
         var _loc3_:* = undefined;
         var _loc1_:int = this.pool.length + this.numPopped;
         var _loc2_:int = _loc1_;
         while(_loc2_ < this.initial)
         {
            _loc3_ = this.create();
            if(!_loc3_)
            {
               break;
            }
            this.pool.push(_loc3_);
            _loc2_++;
         }
      }
      
      public function cleanup() : void
      {
         var _loc1_:* = undefined;
         while(this.pool.length > 0)
         {
            _loc1_ = this.pool.pop();
            if(this.dtor != null)
            {
               this.dtor(_loc1_);
            }
         }
         this.dtor = null;
         this.ctor = null;
         this.pool = null;
         this.clazz = null;
         this.popped = null;
      }
      
      public function pop() : *
      {
         var _loc1_:* = null;
         if(this.pool.length > 0)
         {
            _loc1_ = this.pool.pop();
         }
         else
         {
            _loc1_ = this.create();
         }
         if(_loc1_)
         {
            this.popped[_loc1_] = _loc1_;
            ++this.numPopped;
            if(this.numPopped > this.limit * 2)
            {
            }
         }
         return _loc1_;
      }
      
      public function reclaim(param1:*) : void
      {
         if(this.popped[param1])
         {
            --this.numPopped;
            delete this.popped[param1];
            this.push(param1);
         }
      }
      
      private function create() : *
      {
         if(null != this.ctor)
         {
            return this.ctor(this);
         }
         return new this.clazz();
      }
      
      public function push(param1:*) : void
      {
         if(this.popped[param1])
         {
            --this.numPopped;
            delete this.popped[param1];
         }
         if(this.pool.length < this.limit)
         {
            this.pool.push(param1);
         }
         else if(null != this.dtor)
         {
            this.dtor(param1);
            ++this.numDestroyed;
         }
      }
   }
}

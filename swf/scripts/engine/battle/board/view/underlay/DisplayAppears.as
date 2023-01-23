package engine.battle.board.view.underlay
{
   import engine.landscape.view.DisplayObjectWrapper;
   import flash.errors.IllegalOperationError;
   
   public class DisplayAppears
   {
       
      
      internal var entries:Vector.<DisplayAppearEntry>;
      
      internal var pool:Vector.<DisplayAppearEntry>;
      
      internal var poolAvailableCount:int;
      
      internal var entriesValidCount:int;
      
      internal var entriesNextNull:int;
      
      public var sorted:Boolean;
      
      public function DisplayAppears(param1:int = 0, param2:int = 0)
      {
         super();
         this.entries = new Vector.<DisplayAppearEntry>(param1);
         this.pool = new Vector.<DisplayAppearEntry>(param1);
         if(param2 > param1)
         {
            throw new ArgumentError("poolstart larger than size");
         }
         var _loc3_:int = 0;
         while(_loc3_ < param2)
         {
            this.pool[_loc3_] = new DisplayAppearEntry();
            _loc3_++;
         }
         this.poolAvailableCount = param2;
      }
      
      public static function compareFunctionRemaining(param1:DisplayAppearEntry, param2:DisplayAppearEntry) : int
      {
         if(param1 == null)
         {
            return 1;
         }
         if(param2 == null)
         {
            return -1;
         }
         if(param1.remaining < param2.remaining)
         {
            return 1;
         }
         if(param1.remaining > param2.remaining)
         {
            return -1;
         }
         return 0;
      }
      
      public function cleanup() : void
      {
         this.entries = null;
         this.pool = null;
      }
      
      public function clear() : void
      {
         var _loc2_:DisplayAppearEntry = null;
         var _loc1_:int = 0;
         while(_loc1_ < this.entries.length)
         {
            _loc2_ = this.entries[_loc1_];
            if(_loc2_)
            {
               this.entries[_loc1_] = null;
               this._recoverPoolEntry(_loc2_);
            }
            _loc1_++;
         }
         this.entriesValidCount = 0;
         this.entriesNextNull = 0;
      }
      
      public function removeAppear(param1:DisplayObjectWrapper) : void
      {
         var _loc3_:DisplayAppearEntry = null;
         var _loc4_:int = 0;
         var _loc5_:DisplayAppearEntry = null;
         var _loc2_:int = 0;
         while(_loc2_ < this.entries.length)
         {
            _loc3_ = this.entries[_loc2_];
            if(Boolean(_loc3_) && _loc3_.bmp == param1)
            {
               this.entries[_loc2_] = null;
               --this.entriesValidCount;
               this._recoverPoolEntry(_loc3_);
               if(this.entriesNextNull >= _loc2_)
               {
                  --this.entriesNextNull;
               }
               _loc4_ = _loc2_ + 1;
               while(_loc4_ < this.entries.length)
               {
                  _loc5_ = this.entries[_loc4_];
                  this.entries[_loc4_ - 1] = _loc5_;
                  this.entries[_loc4_] = null;
                  _loc4_++;
               }
               return;
            }
            _loc2_++;
         }
      }
      
      public function beginAppear(param1:int, param2:DisplayObjectWrapper, param3:Number, param4:Number, param5:Number, param6:Number) : DisplayAppearEntry
      {
         var _loc7_:DisplayAppearEntry = this.obtainAppearEntry();
         _loc7_.beginAppear(param1,param2,param3,param4,param5,param6);
         return _loc7_;
      }
      
      public function sortByRemaining() : void
      {
         this.sorted = true;
         this.entries.sort(compareFunctionRemaining);
         this.entriesNextNull = this.entriesValidCount;
      }
      
      public function update(param1:int) : void
      {
         var _loc3_:DisplayAppearEntry = null;
         if(!this.sorted)
         {
            this.sortByRemaining();
         }
         var _loc2_:int = this.entriesValidCount - 1;
         while(_loc2_ >= 0)
         {
            _loc3_ = this.entries[_loc2_];
            if(_loc3_)
            {
               if(!_loc3_.update(param1))
               {
                  this.entries[_loc2_] = null;
                  --this.entriesValidCount;
                  --this.entriesNextNull;
                  this._recoverPoolEntry(_loc3_);
               }
            }
            _loc2_--;
         }
      }
      
      internal function obtainAppearEntry() : DisplayAppearEntry
      {
         var _loc1_:DisplayAppearEntry = null;
         if(this.poolAvailableCount)
         {
            _loc1_ = this.pool[--this.poolAvailableCount];
            this.pool[this.poolAvailableCount] = null;
         }
         else
         {
            _loc1_ = new DisplayAppearEntry();
         }
         this._insertEntry(_loc1_);
         return _loc1_;
      }
      
      private function _insertEntry(param1:DisplayAppearEntry) : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = -1;
         if(this.entriesValidCount < this.entries.length)
         {
            if(this.entriesNextNull >= 0 && this.entriesNextNull < this.entries.length)
            {
               this.entries[this.entriesNextNull] = param1;
               _loc2_ = this.entriesNextNull;
               this.entriesNextNull = -1;
            }
            else
            {
               _loc3_ = 0;
               while(_loc3_ <= this.entries.length)
               {
                  if(this.entries[_loc3_] == null)
                  {
                     _loc2_ = _loc3_;
                     this.entries[_loc3_] = param1;
                     break;
                  }
                  _loc3_++;
               }
            }
            if(_loc2_ < 0)
            {
               throw new IllegalOperationError("nowhere to put it?");
            }
            this.sorted = false;
            ++this.entriesValidCount;
            this._scanEntriesForNextNull(_loc2_);
         }
         else
         {
            this.entries.push(param1);
            this.entriesNextNull = this.entries.length;
            ++this.entriesValidCount;
         }
      }
      
      private function _scanEntriesForNextNull(param1:int) : void
      {
         if(this.entriesValidCount == 0)
         {
            this.entriesNextNull = 0;
            return;
         }
         if(this.entriesValidCount == this.entries.length)
         {
            this.entriesNextNull = this.entries.length;
            return;
         }
         this.entriesNextNull = param1;
         while(this.entriesNextNull < this.entries.length)
         {
            if(null == this.entries[this.entriesNextNull])
            {
               break;
            }
            ++this.entriesNextNull;
         }
      }
      
      internal function releaseAppearEntry(param1:DisplayAppearEntry, param2:int = -1) : void
      {
         if(param2 < 0)
         {
            param2 = this.entries.indexOf(param1);
            if(param2 < 0)
            {
               throw new ArgumentError("failure entry");
            }
         }
         if(param2 >= this.entriesValidCount)
         {
            throw new ArgumentError("outside of valid area");
         }
         if(this.entries[param2] != param1)
         {
            throw new ArgumentError("entry mismatch");
         }
         this.entries[param2] = null;
         --this.entriesValidCount;
         if(this.entriesNextNull >= param2)
         {
            this._scanEntriesForNextNull(param2);
         }
         this._recoverPoolEntry(param1);
      }
      
      private function _recoverPoolEntry(param1:DisplayAppearEntry) : void
      {
         if(this.pool.length > this.poolAvailableCount)
         {
            var _loc2_:* = this.poolAvailableCount++;
            this.pool[_loc2_] = param1;
         }
         else
         {
            this.pool.push(param1);
            ++this.poolAvailableCount;
         }
      }
   }
}

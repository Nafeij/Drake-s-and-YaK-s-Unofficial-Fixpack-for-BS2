package engine.session
{
   public class NewsDef
   {
       
      
      public var entries:Vector.<NewsEntryDef>;
      
      public function NewsDef()
      {
         this.entries = new Vector.<NewsEntryDef>();
         super();
      }
      
      public function findFirstIndexAfterDate(param1:Date) : int
      {
         var _loc3_:NewsEntryDef = null;
         if(param1 == null)
         {
            return -1;
         }
         var _loc2_:int = 0;
         while(_loc2_ < this.entries.length)
         {
            _loc3_ = this.entries[_loc2_];
            if(_loc3_.date.time > param1.time)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return -1;
      }
      
      public function getLastDate() : Date
      {
         return this.entries.length > 0 ? this.entries[this.entries.length - 1].date : null;
      }
      
      public function sortEntries() : void
      {
         this.entries = this.entries.sort(function(param1:NewsEntryDef, param2:NewsEntryDef):Number
         {
            return param1.date.time - param2.date.time;
         });
      }
   }
}

package com.sociodox.theminer.data
{
   public class InternalEventEntry
   {
      
      private static const CHARACTER_ENTER:String = "\n";
      
      private static const CHARACTER_TAB:String = "\t";
      
      private static const CHARACTER_UNION:String = "-";
       
      
      public var qName:String = null;
      
      public var mStack:String = null;
      
      public var mStackFrame:Array = null;
      
      public var entryCount:int;
      
      public var entryCountTotal:int;
      
      public var entryTime:int;
      
      public var entryTimeTotal:int;
      
      public var lastUpdateId:int = 0;
      
      public var needSkip:Boolean = false;
      
      public function InternalEventEntry()
      {
         super();
      }
      
      public function SetStack(param1:Array) : void
      {
         var _loc3_:int = 0;
         this.mStackFrame = param1;
         this.mStack = "";
         var _loc2_:int = int(param1.length - 1);
         while(_loc2_ >= 0)
         {
            this.mStack += CHARACTER_UNION + param1[_loc2_].name;
            if(_loc2_ > 0)
            {
               this.mStack += CHARACTER_ENTER;
               _loc3_ = int(param1.length - 1);
               while(_loc3_ >= _loc2_)
               {
                  this.mStack += CHARACTER_TAB;
                  _loc3_--;
               }
            }
            _loc2_--;
         }
      }
      
      public function Add(param1:Number, param2:int = 0) : void
      {
         this.lastUpdateId = param2;
         ++this.entryCount;
         ++this.entryCountTotal;
         this.entryTime += param1;
         this.entryTimeTotal += param1;
      }
      
      public function AddParentTime(param1:Number, param2:int = 0) : void
      {
         this.lastUpdateId = param2;
         this.entryTimeTotal += param1;
      }
      
      public function Reset() : void
      {
         this.entryTime = 0;
         this.entryCount = 0;
      }
      
      public function Clear() : void
      {
         this.entryCount = 0;
         this.entryCountTotal = 0;
         this.entryTime = 0;
         this.entryTimeTotal = 0;
      }
   }
}

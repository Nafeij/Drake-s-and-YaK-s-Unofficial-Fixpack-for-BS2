package com.sociodox.theminer.data
{
   public class ClassTypeStatsHolder
   {
       
      
      public var Added:uint = 0;
      
      public var Current:uint = 0;
      
      public var Cumul:uint = 0;
      
      public var Removed:uint = 0;
      
      public var AllocSize:uint = 0;
      
      public var CollectSize:uint = 0;
      
      public var Type:Class = null;
      
      public var TypeName:String = null;
      
      public var mFrameID:int = 0;
      
      public var AddedFrame:uint = 0;
      
      public var RemovedFrame:uint = 0;
      
      public function ClassTypeStatsHolder()
      {
         super();
      }
   }
}

package com.sociodox.theminer.data
{
   public class FrameStatistics
   {
       
      
      public var FpsCurrent:int = 0;
      
      public var FpsMin:int = 2147483647;
      
      public var FpsMax:int = 0;
      
      public var MemoryCurrent:int = 0;
      
      public var MemoryMin:int = 2147483647;
      
      public var MemoryMax:int = 0;
      
      public var MemoryFree:uint = 0;
      
      public var MemoryPrivate:uint = 0;
      
      public function FrameStatistics()
      {
         super();
      }
      
      public function Copy(param1:FrameStatistics) : void
      {
         this.FpsCurrent = param1.FpsCurrent;
         this.FpsMin = param1.FpsMin;
         this.FpsMax = param1.FpsMax;
         this.MemoryCurrent = param1.MemoryCurrent;
         this.MemoryMin = param1.MemoryMin;
         this.MemoryMax = param1.MemoryMax;
         this.MemoryFree = param1.MemoryFree;
         this.MemoryPrivate = param1.MemoryPrivate;
      }
   }
}

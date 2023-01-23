package com.sociodox.theminer.data
{
   public class InternalEventsStatsHolder
   {
      
      private static const EMPTY_STRING:String = "";
       
      
      public var mVerify:InternalEventEntry;
      
      public var mReap:InternalEventEntry;
      
      public var mMark:InternalEventEntry;
      
      public var mSweep:InternalEventEntry;
      
      public var mEnterFrame:InternalEventEntry;
      
      public var mTimers:InternalEventEntry;
      
      public var mPreRender:InternalEventEntry;
      
      public var mRender:InternalEventEntry;
      
      public var mAvm1:InternalEventEntry;
      
      public var mMouse:InternalEventEntry;
      
      public var mIo:InternalEventEntry;
      
      public var mExecuteQueue:InternalEventEntry;
      
      public var mFree:InternalEventEntry;
      
      public function InternalEventsStatsHolder()
      {
         this.mVerify = new InternalEventEntry();
         this.mReap = new InternalEventEntry();
         this.mMark = new InternalEventEntry();
         this.mSweep = new InternalEventEntry();
         this.mEnterFrame = new InternalEventEntry();
         this.mTimers = new InternalEventEntry();
         this.mPreRender = new InternalEventEntry();
         this.mRender = new InternalEventEntry();
         this.mAvm1 = new InternalEventEntry();
         this.mMouse = new InternalEventEntry();
         this.mIo = new InternalEventEntry();
         this.mExecuteQueue = new InternalEventEntry();
         this.mFree = new InternalEventEntry();
         super();
      }
      
      public function get FrameTime() : Number
      {
         return this.mReap.entryTime + this.mEnterFrame.entryTime + this.mMark.entryTime + this.mPreRender.entryTime + this.mRender.entryTime + this.mVerify.entryTime + this.mTimers.entryTime + this.mFree.entryTime;
      }
      
      public function TraceFrame() : void
      {
         var _loc1_:String = EMPTY_STRING;
      }
      
      public function ResetFrame() : void
      {
         this.mVerify.Reset();
         this.mReap.Reset();
         this.mMark.Reset();
         this.mSweep.Reset();
         this.mEnterFrame.Reset();
         this.mTimers.Reset();
         this.mPreRender.Reset();
         this.mRender.Reset();
         this.mAvm1.Reset();
         this.mMouse.Reset();
         this.mIo.Reset();
         this.mExecuteQueue.Reset();
         this.mFree.Reset();
      }
   }
}

package com.sociodox.theminer.manager
{
   import by.blooddy.crypto.image.JPEGEncoder;
   import com.sociodox.theminer.data.ClassTypeStatsHolder;
   import com.sociodox.theminer.data.FunctionCall;
   import com.sociodox.theminer.data.InternalEventEntry;
   import com.sociodox.theminer.ui.ToolTip;
   import com.sociodox.theminer.window.Configuration;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Stage;
   import flash.net.FileReference;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.sampler.pauseSampling;
   import flash.sampler.startSampling;
   import flash.system.System;
   import flash.trace.Trace;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   
   public class Controller
   {
      
      private static const ZERO_PERCENT:String = "0.00";
      
      private static const ENTRY_TIME_PROPERTY:String = "entryTime";
      
      private static const CUMUL_PROPERTY:String = "Cumul";
       
      
      public const SAVE_SWF_EVENT:String = "SaveSWFEvent";
      
      public const SAVE_RECORDING_EVENT:String = "SaveRecordingEvent";
      
      public const SAVE_RECORDING_TRACE_EVENT:String = "SaveRecordingTraceEvent";
      
      public const TOGGLE_MINIMIZE:String = "ToggleMinimizeEvent";
      
      public const TOGGLE_QUIT:String = "ToggleQuitEvent";
      
      public const SAVE_SNAPSHOT_EVENT:String = "saveSnapshotEvent";
      
      public const SCREEN_CAPTURE_EVENT:String = "screenCaptureEvent";
      
      private var mRoot:DisplayObject;
      
      private var mNumberStack:Vector.<int>;
      
      public var mTempNoGCFunctionCallHolder:Dictionary;
      
      private var mTraceBuffer:ByteArray;
      
      public var mIsCollectingSamplesData:Boolean = false;
      
      public var mIsCollectingTracesData:Boolean = false;
      
      private var mRecordingTime:int = 0;
      
      private var mRecordingTraceTime:int = 0;
      
      private var mRefreshSpeed:int = 0;
      
      private var mInterfaceOpacity:int = 0;
      
      public function Controller()
      {
         this.mNumberStack = new Vector.<int>(25,true);
         this.mTempNoGCFunctionCallHolder = new Dictionary();
         this.mTraceBuffer = new ByteArray();
         super();
      }
      
      public function Init(param1:DisplayObject) : void
      {
         this.mRoot = param1;
      }
      
      public function get Opacity() : int
      {
         return this.mInterfaceOpacity;
      }
      
      public function set Opacity(param1:int) : void
      {
         this.mInterfaceOpacity = param1;
      }
      
      public function get RefreshRate() : int
      {
         return this.mRefreshSpeed;
      }
      
      public function set RefreshRate(param1:int) : void
      {
         this.mRefreshSpeed = param1;
      }
      
      public function BuyPro(param1:String = null) : void
      {
         if(param1 == null)
         {
            Analytics.Track("BuyPro","default");
            navigateToURL(new URLRequest("http://www.sociodox.com/theminer/product.html#ProVersion"),"_blank");
         }
         else
         {
            Analytics.Track("BuyPro",param1);
            navigateToURL(new URLRequest("http://www.sociodox.com/theminer/feature.html#" + param1),"_blank");
         }
      }
      
      public function SaveSnapshot() : void
      {
         var samplingRequired:Boolean;
         var mScreenCaptureFile:FileReference = null;
         var bmp:BitmapData = null;
         var isTooltipVisible:Boolean = false;
         var ba:ByteArray = null;
         var date:Date = null;
         if(this.mRoot == null)
         {
            return;
         }
         samplingRequired = Configuration.IsSamplingRequired();
         pauseSampling();
         try
         {
            Analytics.Track("Action","Screen Capture");
            mScreenCaptureFile = new FileReference();
            if(this.mRoot is Stage)
            {
               bmp = new BitmapData((this.mRoot as Stage).stageWidth,(this.mRoot as Stage).stageHeight,false);
            }
            else
            {
               bmp = new BitmapData(this.mRoot.width,this.mRoot.height,false);
            }
            isTooltipVisible = ToolTip.Visible;
            ToolTip.Visible = false;
            bmp.draw(this.mRoot);
            ToolTip.Visible = isTooltipVisible;
            ba = JPEGEncoder.encode(bmp);
            date = new Date();
            mScreenCaptureFile.save(ba,"TheMinerCapture" + date.fullYear.toString() + date.month.toString() + date.day.toString() + date.hours.toString() + "_" + date.minutes + date.seconds + ".jpg");
         }
         catch(e:Error)
         {
            ToolTip.Text = "Error:" + e.message;
            ToolTip.Visible = true;
         }
         if(samplingRequired)
         {
            startSampling();
         }
      }
      
      public function SavePerformanceSnapshot(param1:Boolean = false) : String
      {
         var _loc5_:InternalEventEntry = null;
         var _loc7_:String = null;
         var _loc8_:Number = NaN;
         var _loc2_:Array = SampleAnalyzer.GetFunctionTimes();
         _loc2_.sortOn(ENTRY_TIME_PROPERTY,Array.NUMERIC | Array.DESCENDING);
         var _loc3_:ByteArray = new ByteArray();
         var _loc4_:int = _loc2_.length;
         var _loc6_:int = 0;
         for each(_loc5_ in _loc2_)
         {
            _loc6_ += _loc5_.entryTime;
         }
         _loc3_.writeUTFBytes(Localization.Lbl_LA_Percent);
         _loc3_.writeByte(9);
         _loc3_.writeUTFBytes(Localization.Lbl_FP_Self);
         _loc3_.writeByte(9);
         _loc3_.writeUTFBytes(Localization.Lbl_LA_Percent);
         _loc3_.writeByte(9);
         _loc3_.writeUTFBytes(Localization.Lbl_FP_Total);
         _loc3_.writeByte(9);
         _loc3_.writeUTFBytes(Localization.Lbl_FP_FunctionName);
         _loc3_.writeByte(13);
         _loc3_.writeByte(10);
         for each(_loc5_ in _loc2_)
         {
            _loc8_ = int(_loc5_.entryTime / _loc6_ * 10000) / 100;
            if(_loc8_ == 0)
            {
               _loc3_.writeUTFBytes(ZERO_PERCENT);
            }
            else
            {
               _loc3_.writeUTFBytes(String(_loc8_));
            }
            _loc3_.writeByte(9);
            _loc3_.writeUTFBytes(_loc5_.entryTime.toString());
            _loc3_.writeByte(9);
            _loc8_ = int(_loc5_.entryTimeTotal / _loc6_ * 10000) / 100;
            if(_loc8_ == 0)
            {
               _loc3_.writeUTFBytes(ZERO_PERCENT);
            }
            else
            {
               _loc3_.writeUTFBytes(String(_loc8_));
            }
            _loc3_.writeByte(9);
            _loc3_.writeUTFBytes(_loc5_.entryTimeTotal.toString());
            _loc3_.writeByte(9);
            _loc3_.writeUTFBytes(String(_loc5_.mStackFrame));
            _loc3_.writeByte(13);
            _loc3_.writeByte(10);
         }
         _loc3_.position = 0;
         _loc7_ = _loc3_.readUTFBytes(_loc3_.length);
         if(param1)
         {
            System.setClipboard(_loc7_);
         }
         return _loc7_;
      }
      
      public function SaveMemorySnapshot(param1:Boolean = false) : String
      {
         var _loc4_:ClassTypeStatsHolder = null;
         var _loc5_:String = null;
         var _loc2_:Array = SampleAnalyzer.GetClassInstanciationStats();
         _loc2_.sortOn(CUMUL_PROPERTY,Array.NUMERIC | Array.DESCENDING);
         var _loc3_:ByteArray = new ByteArray();
         _loc3_.writeUTFBytes(Localization.Lbl_MP_HEADERS_QNAME);
         _loc3_.writeByte(9);
         _loc3_.writeUTFBytes(Localization.Lbl_MP_HEADERS_ADD);
         _loc3_.writeByte(9);
         _loc3_.writeUTFBytes(Localization.Lbl_MP_HEADERS_DEL);
         _loc3_.writeByte(9);
         _loc3_.writeUTFBytes(Localization.Lbl_MP_HEADERS_CURRENT);
         _loc3_.writeByte(9);
         _loc3_.writeUTFBytes(Localization.Lbl_MP_HEADERS_CUMUL);
         _loc3_.writeByte(13);
         _loc3_.writeByte(10);
         for each(_loc4_ in _loc2_)
         {
            _loc3_.writeUTFBytes(_loc4_.TypeName);
            _loc3_.writeByte(9);
            _loc3_.writeUTFBytes(_loc4_.Added.toString());
            _loc3_.writeByte(9);
            _loc3_.writeUTFBytes(_loc4_.Removed.toString());
            _loc3_.writeByte(9);
            _loc3_.writeUTFBytes(_loc4_.Current.toString());
            _loc3_.writeByte(9);
            _loc3_.writeUTFBytes(_loc4_.Cumul.toString());
            _loc3_.writeByte(13);
            _loc3_.writeByte(10);
         }
         _loc3_.position = 0;
         _loc5_ = _loc3_.readUTFBytes(_loc3_.length);
         if(param1)
         {
            System.setClipboard(_loc5_);
         }
         return _loc5_;
      }
      
      public function StartRecordingSamples() : void
      {
         this.mIsCollectingSamplesData = true;
         this.mRecordingTime = getTimer();
      }
      
      public function get IsRecordingSamples() : Boolean
      {
         return this.mIsCollectingSamplesData;
      }
      
      public function StopRecordingSamples(param1:Boolean) : String
      {
         var _loc4_:* = undefined;
         var _loc5_:ByteArray = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc2_:String = null;
         var _loc3_:Boolean = Configuration.IsSamplingRequired();
         pauseSampling();
         if(this.mIsCollectingSamplesData)
         {
            this.mIsCollectingSamplesData = false;
            _loc5_ = SampleAnalyzer.GetFrameDataByteArray();
            if(param1)
            {
               System.setClipboard(_loc5_.toString());
            }
            else
            {
               _loc2_ = _loc5_.toString();
            }
            _loc5_.length = 0;
            _loc6_ = int(getTimer() - this.mRecordingTime);
            _loc6_ /= 100;
            if(!this.mIsCollectingTracesData)
            {
               Analytics.Track("Action","RecordingSamples","Recording Samples",_loc6_);
            }
         }
         if(this.mIsCollectingTracesData)
         {
            this.mTraceBuffer.length = 0;
            this.mIsCollectingTracesData = false;
            Trace.setLevel(Trace.OFF,Trace.LISTENER);
            Trace.setListener(null);
            _loc7_ = int(getTimer() - this.mRecordingTime);
            _loc7_ /= 100;
            Analytics.Track("Action","RecordingSamples","Recording Interlaced Samples",_loc7_);
         }
         for(_loc4_ in this.mTempNoGCFunctionCallHolder)
         {
            delete this.mTempNoGCFunctionCallHolder[_loc4_];
         }
         if(_loc3_)
         {
            startSampling();
         }
         return _loc2_;
      }
      
      public function StartRecordingTraces() : void
      {
         this.mTraceBuffer.writeUTFBytes(Localization.Lbl_TracesDump_FunctionName);
         this.mTraceBuffer.writeByte(9);
         this.mTraceBuffer.writeUTFBytes(Localization.Lbl_TracesDump_Arguments);
         this.mTraceBuffer.writeByte(9);
         this.mTraceBuffer.writeUTFBytes(Localization.Lbl_TracesDump_File);
         this.mTraceBuffer.writeByte(9);
         this.mTraceBuffer.writeUTFBytes(Localization.Lbl_TracesDump_LineNumber);
         this.mTraceBuffer.writeByte(13);
         this.mTraceBuffer.writeByte(10);
         this.mIsCollectingTracesData = true;
         this.mRecordingTraceTime = getTimer();
      }
      
      public function get IsRecordingTraces() : Boolean
      {
         return this.mIsCollectingTracesData;
      }
      
      public function StopRecordingTraces(param1:Boolean) : String
      {
         var _loc4_:ByteArray = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc2_:String = null;
         var _loc3_:Boolean = Configuration.IsSamplingRequired();
         pauseSampling();
         if(this.mIsCollectingSamplesData)
         {
            this.mIsCollectingSamplesData = false;
            _loc4_ = SampleAnalyzer.GetFrameDataByteArray();
            if(param1)
            {
               System.setClipboard(_loc4_.toString());
            }
            else
            {
               _loc2_ = _loc4_.toString();
            }
            _loc5_ = int(getTimer() - this.mRecordingTime);
            _loc5_ /= 100;
            Analytics.Track("Action","RecordingSamples","Recording Interlaced Samples",_loc5_);
            Trace.setLevel(Trace.OFF,Trace.LISTENER);
            Trace.setListener(null);
            this.mIsCollectingTracesData = false;
         }
         else if(this.mIsCollectingTracesData)
         {
            this.mIsCollectingTracesData = false;
            Trace.setLevel(Trace.OFF,Trace.LISTENER);
            Trace.setListener(null);
            this.mTraceBuffer.position = 0;
            if(param1)
            {
               System.setClipboard(this.mTraceBuffer.readUTFBytes(this.mTraceBuffer.length));
            }
            else
            {
               _loc2_ = this.mTraceBuffer.readUTFBytes(this.mTraceBuffer.length);
            }
            this.mTraceBuffer.length = 0;
            _loc6_ = int(getTimer() - this.mRecordingTraceTime);
            _loc6_ /= 100;
            Analytics.Track("Action","RecordingSamples","Recording Traces",_loc6_);
         }
         if(_loc3_)
         {
            startSampling();
         }
         return _loc2_;
      }
      
      public function get FunctionCallHolder() : Dictionary
      {
         return this.mTempNoGCFunctionCallHolder;
      }
      
      public function OnTraceReceive(param1:String, param2:uint, param3:String, param4:String) : void
      {
         var _loc5_:Number = NaN;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         if(this.mIsCollectingSamplesData)
         {
            this.mTempNoGCFunctionCallHolder[new FunctionCall(param1,param2,param3,param4)] = true;
         }
         else
         {
            this.mTraceBuffer.writeUTFBytes(param3);
            this.mTraceBuffer.writeByte(40);
            this.mTraceBuffer.writeByte(41);
            this.mTraceBuffer.writeByte(9);
            this.mTraceBuffer.writeUTFBytes(param4);
            this.mTraceBuffer.writeByte(9);
            if(param1 != null)
            {
               this.mTraceBuffer.writeUTFBytes(param1);
               this.mTraceBuffer.writeByte(9);
               if(param2 > 0)
               {
                  _loc5_ = param2;
                  _loc6_ = 0;
                  _loc7_ = 0;
                  while(_loc5_ >= 1)
                  {
                     _loc7_ = _loc5_ % 10;
                     this.mNumberStack[_loc6_] = _loc7_;
                     _loc5_ /= 10;
                     _loc6_++;
                  }
                  _loc8_ = _loc6_ - 1;
                  while(_loc8_ >= 0)
                  {
                     this.mTraceBuffer.writeByte(48 + this.mNumberStack[_loc8_]);
                     _loc8_--;
                  }
               }
            }
            this.mTraceBuffer.writeByte(13);
            this.mTraceBuffer.writeByte(10);
         }
      }
   }
}

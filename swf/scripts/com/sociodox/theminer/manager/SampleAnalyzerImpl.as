package com.sociodox.theminer.manager
{
   import com.sociodox.theminer.TheMiner;
   import com.sociodox.theminer.data.ClassTypeStatsHolder;
   import com.sociodox.theminer.data.FunctionCall;
   import com.sociodox.theminer.data.InternalEventEntry;
   import com.sociodox.theminer.data.InternalEventsStatsHolder;
   import com.sociodox.theminer.window.Configuration;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.net.LocalConnection;
   import flash.net.URLLoader;
   import flash.net.URLStream;
   import flash.sampler.DeleteObjectSample;
   import flash.sampler.NewObjectSample;
   import flash.sampler.Sample;
   import flash.sampler.StackFrame;
   import flash.sampler.clearSamples;
   import flash.sampler.getSamples;
   import flash.sampler.pauseSampling;
   import flash.sampler.setSamplerCallback;
   import flash.sampler.startSampling;
   import flash.sampler.stopSampling;
   import flash.system.ApplicationDomain;
   import flash.system.System;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   
   public class SampleAnalyzerImpl
   {
      
      private static const INTERNAL_EVENT_VERIFY:String = "[verify]";
      
      private static const INTERNAL_EVENT_MARK:String = "[mark]";
      
      private static const INTERNAL_EVENT_REAP:String = "[reap]";
      
      private static const INTERNAL_EVENT_SWEEP:String = "[sweep]";
      
      private static const INTERNAL_EVENT_ENTERFRAME:String = "[enterFrameEvent]";
      
      private static const INTERNAL_EVENT_TIMER_TICK:String = "flash.utils::Timer/tick";
      
      private static const INTERNAL_EVENT_PRE_RENDER:String = "[pre-render]";
      
      private static const INTERNAL_EVENT_RENDER:String = "[render]";
      
      private static const INTERNAL_EVENT_AVM1:String = "[avm1]";
      
      private static const INTERNAL_EVENT_MOUSE:String = "[mouseEvent]";
      
      private static const INTERNAL_EVENT_IO:String = "[io]";
      
      private static const INTERNAL_EVENT_EXECUTE_QUEUE:String = "[execute-queued]";
      
      private static var mEnterFrameName:String = null;
      
      private static var FRAME_SAMPLE:ByteArray = new ByteArray();
      
      private static var OBJECT_COLLECTED:ByteArray = new ByteArray();
      
      private static var NEW_OBJECT_STRING:ByteArray = new ByteArray();
      
      private static var DELETE_OBJECT_STRING:ByteArray = new ByteArray();
      
      private static var BASE_OBJECT_STRING:ByteArray = new ByteArray();
       
      
      private var mInternalStats:InternalEventsStatsHolder;
      
      private var mFullObjectDict:Dictionary = null;
      
      private var mFullObjectInfoDict:Dictionary = null;
      
      public var mObjectTypeDict:Dictionary = null;
      
      public var mClassNameBuffer:Dictionary = null;
      
      private var mFunctionTimes:Dictionary = null;
      
      private var mFunctionTimesArray:Array = null;
      
      private var mStatsTypeList:Array = null;
      
      private var lastSampleTime:Number = 0;
      
      private var lastSample:Sample = null;
      
      private var mIsSampling:Boolean = false;
      
      private var mIsSamplingPaused:Boolean = false;
      
      private var mMinerInstance:TheMiner = null;
      
      private var tempArrayOut:ByteArray;
      
      private var mIsRecording:Boolean = false;
      
      public var mLineString:Dictionary;
      
      private var mNumberStack:Vector.<int>;
      
      private var mSamplingFrameCount:int = 0;
      
      private var mSocioTrace:String;
      
      private var mCurrentFrameID:int = 0;
      
      public var mFrameCounter:int = 0;
      
      public var mSamplerFrameCounter:int = 0;
      
      public function SampleAnalyzerImpl()
      {
         this.mInternalStats = new InternalEventsStatsHolder();
         this.tempArrayOut = new ByteArray();
         this.mLineString = new Dictionary(true);
         this.mNumberStack = new Vector.<int>(25,true);
         super();
         this.mFullObjectDict = new Dictionary();
         this.mFullObjectInfoDict = new Dictionary();
         this.mObjectTypeDict = new Dictionary();
         this.mClassNameBuffer = new Dictionary();
         this.mFunctionTimes = new Dictionary();
         this.mFunctionTimesArray = new Array();
         this.mStatsTypeList = new Array();
         this.lastSampleTime = 0;
         if(ApplicationDomain.currentDomain.hasDefinition("flash.sampler.setSamplerCallback"))
         {
            setSamplerCallback(this.SamplerCallBack);
         }
         FRAME_SAMPLE.writeUTFBytes("\t\t" + Localization.Lbl_SA_SamplingFrame + " ");
         NEW_OBJECT_STRING.writeUTFBytes("\t" + Localization.Lbl_SA_NewObject + "\t");
         OBJECT_COLLECTED.writeUTFBytes("\t" + Localization.Lbl_SA_Collected + "\t");
         DELETE_OBJECT_STRING.writeUTFBytes("\t" + Localization.Lbl_SA_DeletedObject + "\t");
         BASE_OBJECT_STRING.writeUTFBytes("\t" + Localization.Lbl_SA_BaseSample + "\t");
      }
      
      public function Init(param1:TheMiner) : void
      {
         this.mMinerInstance = param1;
         var _loc2_:Boolean = Configuration.IsSamplingRequired();
         pauseSampling();
         if(_loc2_)
         {
            startSampling();
         }
         this.mFrameCounter = 0;
         this.mSamplerFrameCounter = 0;
      }
      
      public function StartSampling() : void
      {
         this.mIsSampling = true;
         this.mIsSamplingPaused = false;
         startSampling();
      }
      
      public function PauseSampling() : void
      {
         if(this.mIsSampling && !this.mIsSamplingPaused)
         {
            pauseSampling();
            this.mIsSamplingPaused = true;
         }
      }
      
      public function IsSamplingPaused() : Boolean
      {
         return this.mIsSamplingPaused;
      }
      
      public function ResumeSampling() : void
      {
         if(this.mIsSampling && this.mIsSamplingPaused)
         {
            startSampling();
            this.mIsSamplingPaused = false;
         }
      }
      
      public function StopSampling() : void
      {
         this.mIsSampling = false;
         this.mIsSamplingPaused = false;
         stopSampling();
      }
      
      public function ClearSamples() : void
      {
         clearSamples();
      }
      
      public function ForceGC() : void
      {
         try
         {
            System.gc();
         }
         catch(e:Error)
         {
         }
         try
         {
            new LocalConnection().connect("Force GC!");
            new LocalConnection().connect("Force GC!");
         }
         catch(e:Error)
         {
         }
      }
      
      public function GetInternalsEvents() : InternalEventsStatsHolder
      {
         return this.mInternalStats;
      }
      
      public function GetFunctionTimes() : Array
      {
         return this.mFunctionTimesArray;
      }
      
      public function GetClassInstanciationStats() : Array
      {
         return this.mStatsTypeList;
      }
      
      public function GetFrameDataByteArray() : ByteArray
      {
         return this.tempArrayOut;
      }
      
      public function ResetMemoryStats() : void
      {
         var _loc1_:ClassTypeStatsHolder = null;
         for each(_loc1_ in this.mStatsTypeList)
         {
            _loc1_.Added = 0;
            _loc1_.Removed = 0;
            _loc1_.Current = 0;
            _loc1_.Cumul = 0;
            _loc1_.AllocSize = 0;
            _loc1_.CollectSize = 0;
         }
      }
      
      public function ResetPerformanceStats() : void
      {
         var _loc1_:InternalEventEntry = null;
         this.mFrameCounter = 0;
         this.mSamplerFrameCounter = 0;
         for each(_loc1_ in this.mFunctionTimes)
         {
            _loc1_.Clear();
         }
      }
      
      private function SamplerCallBack(param1:* = null) : void
      {
         pauseSampling();
         trace("The Miner: SamplerCallBack");
         this.ProcessSampling();
         startSampling();
      }
      
      public function ProcessSampling() : void
      {
         var _loc2_:NewObjectSample = null;
         var _loc3_:DeleteObjectSample = null;
         var _loc15_:StackFrame = null;
         var _loc16_:String = null;
         var _loc19_:Sample = null;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc22_:int = 0;
         var _loc23_:int = 0;
         var _loc24_:Number = NaN;
         var _loc25_:int = 0;
         var _loc26_:int = 0;
         var _loc27_:Class = null;
         var _loc28_:* = undefined;
         var _loc29_:Event = null;
         var _loc30_:FunctionCall = null;
         var _loc31_:int = 0;
         var _loc32_:* = false;
         var _loc33_:String = null;
         var _loc34_:int = 0;
         var _loc35_:int = 0;
         var _loc36_:* = false;
         var _loc37_:String = null;
         var _loc38_:StackFrame = null;
         var _loc39_:String = null;
         var _loc40_:* = undefined;
         var _loc41_:InternalEventEntry = null;
         var _loc42_:InternalEventEntry = null;
         var _loc43_:int = 0;
         var _loc44_:StackFrame = null;
         var _loc45_:String = null;
         var _loc46_:* = undefined;
         var _loc47_:InternalEventEntry = null;
         var _loc48_:String = null;
         var _loc1_:* = getSamples();
         var _loc4_:ClassTypeStatsHolder = null;
         ++this.mCurrentFrameID;
         ++this.mFrameCounter;
         ++this.mSamplerFrameCounter;
         var _loc5_:String = null;
         var _loc6_:String = null;
         if(Configuration.SAVED_FILTER_MEMORY != null && Configuration.SAVED_FILTER_MEMORY != "")
         {
            _loc5_ = Configuration.SAVED_FILTER_MEMORY;
         }
         if(Configuration.SAVED_FILTER_PERFORMANCE != null && Configuration.SAVED_FILTER_MEMORY != "")
         {
            _loc6_ = Configuration.SAVED_FILTER_PERFORMANCE;
         }
         if(Commands.IsRecordingSamples)
         {
            if(!this.mIsRecording)
            {
               this.tempArrayOut.length = 0;
               this.tempArrayOut.writeUTFBytes(Localization.Lbl_SamplesDump_Time);
               this.tempArrayOut.writeByte(9);
               this.tempArrayOut.writeUTFBytes(Localization.Lbl_SamplesDump_TimeDiff);
               this.tempArrayOut.writeByte(9);
               this.tempArrayOut.writeUTFBytes(Localization.Lbl_SamplesDump_SampleType);
               this.tempArrayOut.writeByte(9);
               this.tempArrayOut.writeUTFBytes(Localization.Lbl_SamplesDump_ObjectID);
               this.tempArrayOut.writeByte(9);
               this.tempArrayOut.writeUTFBytes(Localization.Lbl_SamplesDump_SampleSize);
               this.tempArrayOut.writeByte(9);
               this.tempArrayOut.writeUTFBytes(Localization.Lbl_SamplesDump_ObjectType);
               this.tempArrayOut.writeByte(9);
               this.tempArrayOut.writeUTFBytes(Localization.Lbl_SamplesDump_WasCollected);
               this.tempArrayOut.writeByte(9);
               this.tempArrayOut.writeUTFBytes(Localization.Lbl_SamplesDump_InstanciationStack);
               this.tempArrayOut.writeByte(13);
               this.tempArrayOut.writeByte(10);
               this.mIsRecording = true;
            }
         }
         else
         {
            this.mIsRecording = false;
         }
         var _loc7_:Array = null;
         var _loc8_:Boolean = Boolean(Commands.IsRecordingSamples);
         var _loc9_:Boolean = Configuration.PROFILE_LOADERS || Configuration.COMMAND_LINE_SAMPLING_LSTENER;
         var _loc10_:Boolean = Configuration.PROFILE_FUNCTION || Configuration.COMMAND_LINE_SAMPLING_LSTENER;
         var _loc11_:Boolean = Configuration.PROFILE_MEMORY || Configuration.COMMAND_LINE_SAMPLING_LSTENER;
         var _loc12_:Boolean = Configuration.PROFILE_INTERNAL_EVENTS || Configuration.COMMAND_LINE_SAMPLING_LSTENER;
         var _loc13_:LoaderAnalyser = LoaderAnalyser.GetInstance();
         var _loc14_:int = 0;
         if(_loc8_)
         {
            ++this.mSamplingFrameCount;
         }
         else
         {
            this.mSamplingFrameCount = 0;
         }
         var _loc17_:Boolean = true;
         var _loc18_:int = 0;
         for each(_loc19_ in _loc1_)
         {
            if(_loc19_ == null)
            {
               _loc18_++;
            }
            else
            {
               _loc20_ = _loc19_.time;
               if(this.lastSampleTime == 0)
               {
                  this.lastSampleTime = _loc20_;
               }
               _loc21_ = _loc20_ - this.lastSampleTime;
               _loc22_ = 0;
               _loc4_ = null;
               if(_loc17_)
               {
                  if(_loc8_)
                  {
                     _loc24_ = _loc20_;
                     _loc22_ = 0;
                     while(_loc24_ >= 1)
                     {
                        _loc26_ = _loc24_ % 10;
                        this.mNumberStack[_loc22_] = _loc26_;
                        _loc24_ /= 10;
                        _loc22_++;
                     }
                     _loc25_ = _loc22_ - 1;
                     while(_loc25_ >= 0)
                     {
                        this.tempArrayOut.writeByte(48 + this.mNumberStack[_loc25_]);
                        _loc25_--;
                     }
                     this.tempArrayOut.writeBytes(FRAME_SAMPLE);
                     _loc24_ = this.mSamplingFrameCount;
                     _loc22_ = 0;
                     while(_loc24_ >= 1)
                     {
                        _loc26_ = _loc24_ % 10;
                        this.mNumberStack[_loc22_] = _loc26_;
                        _loc24_ /= 10;
                        _loc22_++;
                     }
                     _loc25_ = _loc22_ - 1;
                     while(_loc25_ >= 0)
                     {
                        this.tempArrayOut.writeByte(48 + this.mNumberStack[_loc25_]);
                        _loc25_--;
                     }
                     this.tempArrayOut.writeByte(13);
                     this.tempArrayOut.writeByte(10);
                  }
                  _loc17_ = false;
               }
               _loc2_ = _loc19_ as NewObjectSample;
               _loc7_ = _loc19_.stack;
               _loc23_ = 0;
               _loc24_ = 0;
               _loc25_ = 0;
               if(_loc2_ != null)
               {
                  _loc27_ = _loc2_.type;
                  _loc28_ = _loc2_.object;
                  if(_loc8_)
                  {
                     if(_loc27_ == FunctionCall)
                     {
                        _loc30_ = _loc28_ as FunctionCall;
                        if(_loc30_ != null)
                        {
                           this.tempArrayOut.writeUTFBytes(_loc30_._methodName);
                           this.tempArrayOut.writeByte(40);
                           this.tempArrayOut.writeByte(41);
                           this.tempArrayOut.writeByte(9);
                           this.tempArrayOut.writeUTFBytes(_loc30_._methodArguments);
                           this.tempArrayOut.writeByte(9);
                           if(_loc30_._fqcn != null)
                           {
                              this.tempArrayOut.writeUTFBytes(_loc30_._fqcn);
                              this.tempArrayOut.writeByte(9);
                              if(_loc30_._lineNumber > 0)
                              {
                                 _loc24_ = _loc30_._lineNumber;
                                 _loc22_ = 0;
                                 _loc26_ = 0;
                                 while(_loc24_ >= 1)
                                 {
                                    _loc26_ = _loc24_ % 10;
                                    this.mNumberStack[_loc22_] = _loc26_;
                                    _loc24_ /= 10;
                                    _loc22_++;
                                 }
                                 _loc31_ = _loc22_ - 1;
                                 while(_loc31_ >= 0)
                                 {
                                    this.tempArrayOut.writeByte(48 + this.mNumberStack[_loc31_]);
                                    _loc31_--;
                                 }
                              }
                           }
                           this.tempArrayOut.writeByte(13);
                           this.tempArrayOut.writeByte(10);
                           delete Commands.FunctionCallHolder[_loc30_];
                        }
                     }
                     else if(_loc7_ != null)
                     {
                        _loc32_ = false;
                        if(_loc5_ != null)
                        {
                           if(_loc4_ == null)
                           {
                              _loc4_ = this.mObjectTypeDict[_loc27_] as ClassTypeStatsHolder;
                           }
                           _loc32_ = _loc4_.TypeName.indexOf(_loc5_) == -1;
                        }
                        if(!_loc32_)
                        {
                           _loc23_ = _loc7_.length;
                           _loc24_ = _loc20_;
                           _loc22_ = 0;
                           while(_loc24_ >= 1)
                           {
                              _loc26_ = _loc24_ % 10;
                              this.mNumberStack[_loc22_] = _loc26_;
                              _loc24_ /= 10;
                              _loc22_++;
                           }
                           _loc25_ = _loc22_ - 1;
                           while(_loc25_ >= 0)
                           {
                              this.tempArrayOut.writeByte(48 + this.mNumberStack[_loc25_]);
                              _loc25_--;
                           }
                           this.tempArrayOut.writeByte(9);
                           _loc24_ = _loc21_;
                           _loc22_ = 0;
                           while(_loc24_ >= 1)
                           {
                              _loc26_ = _loc24_ % 10;
                              this.mNumberStack[_loc22_] = _loc26_;
                              _loc24_ /= 10;
                              _loc22_++;
                           }
                           _loc25_ = _loc22_ - 1;
                           while(_loc25_ >= 0)
                           {
                              this.tempArrayOut.writeByte(48 + this.mNumberStack[_loc25_]);
                              _loc25_--;
                           }
                           this.tempArrayOut.writeBytes(NEW_OBJECT_STRING);
                           _loc24_ = _loc2_.id;
                           _loc22_ = 0;
                           while(_loc24_ >= 1)
                           {
                              _loc26_ = _loc24_ % 10;
                              this.mNumberStack[_loc22_] = _loc26_;
                              _loc24_ /= 10;
                              _loc22_++;
                           }
                           _loc25_ = _loc22_ - 1;
                           while(_loc25_ >= 0)
                           {
                              this.tempArrayOut.writeByte(48 + this.mNumberStack[_loc25_]);
                              _loc25_--;
                           }
                           this.tempArrayOut.writeByte(9);
                           _loc33_ = this.mLineString[_loc2_.size];
                           if(_loc33_ == null)
                           {
                              this.mLineString[_loc2_.size] = _loc33_ = String(_loc2_.size);
                           }
                           this.tempArrayOut.writeUTFBytes(_loc33_);
                           this.tempArrayOut.writeByte(9);
                           _loc16_ = this.mClassNameBuffer[_loc27_];
                           if(_loc16_ == null)
                           {
                              this.mClassNameBuffer[_loc27_] = _loc16_ = String(_loc27_);
                           }
                           this.tempArrayOut.writeUTFBytes(_loc16_);
                           if(_loc2_.object != null)
                           {
                              this.tempArrayOut.writeByte(9);
                              this.tempArrayOut.writeByte(9);
                           }
                           else
                           {
                              this.tempArrayOut.writeBytes(OBJECT_COLLECTED);
                           }
                           _loc14_ = 0;
                           while(_loc14_ < _loc23_)
                           {
                              _loc15_ = _loc7_[_loc14_];
                              if(_loc15_.name != null)
                              {
                                 this.tempArrayOut.writeUTFBytes(_loc15_.name);
                                 this.tempArrayOut.writeByte(40);
                                 this.tempArrayOut.writeByte(41);
                              }
                              if(_loc15_.file != null)
                              {
                                 this.tempArrayOut.writeByte(91);
                                 this.tempArrayOut.writeUTFBytes(_loc15_.file);
                                 if(_loc15_.line > 0)
                                 {
                                    this.tempArrayOut.writeByte(58);
                                    _loc33_ = this.mLineString[_loc15_.line];
                                    if(_loc33_ == null)
                                    {
                                       this.mLineString[_loc15_.line] = _loc33_ = String(_loc15_.line);
                                    }
                                    this.tempArrayOut.writeUTFBytes(_loc33_);
                                 }
                                 this.tempArrayOut.writeByte(93);
                              }
                              this.tempArrayOut.writeByte(44);
                              _loc14_++;
                           }
                           this.tempArrayOut.writeByte(13);
                           this.tempArrayOut.writeByte(10);
                        }
                     }
                  }
                  _loc29_ = _loc28_ as Event;
                  if(_loc29_ && _loc7_ != null && _loc7_.length == 1)
                  {
                     if(mEnterFrameName == null)
                     {
                        if(_loc7_[0].name == INTERNAL_EVENT_ENTERFRAME)
                        {
                           mEnterFrameName = _loc7_[0].name;
                        }
                     }
                     else if(mEnterFrameName === _loc7_[0].name)
                     {
                        this.mInternalStats.mFree.Add(_loc21_);
                     }
                     if(_loc29_.target === this.mMinerInstance)
                     {
                        this.lastSampleTime = _loc20_;
                        continue;
                     }
                  }
                  if(_loc9_)
                  {
                     if(_loc28_ is Loader)
                     {
                        _loc13_.PushLoader(_loc28_);
                     }
                     else if(_loc28_ is URLStream)
                     {
                        _loc13_.PushLoader(_loc28_);
                     }
                     else if(_loc28_ is URLLoader)
                     {
                        _loc13_.PushLoader(_loc28_);
                     }
                  }
                  if(_loc11_)
                  {
                     if(_loc4_ == null)
                     {
                        _loc4_ = this.mObjectTypeDict[_loc27_] as ClassTypeStatsHolder;
                     }
                     _loc34_ = 0;
                     if(_loc2_.size > 0)
                     {
                        _loc34_ = int(_loc2_.size);
                     }
                     if(_loc4_ == null)
                     {
                        _loc4_ = new ClassTypeStatsHolder();
                        _loc4_.Type = _loc27_;
                        _loc4_.TypeName = getQualifiedClassName(_loc27_);
                        this.mStatsTypeList.push(_loc4_);
                        this.mObjectTypeDict[_loc27_] = _loc4_;
                        this.mFullObjectDict[_loc2_.id] = _loc4_;
                        this.mFullObjectInfoDict[_loc2_.id] = _loc34_;
                        _loc4_.AllocSize += _loc34_;
                     }
                     else
                     {
                        if(this.mCurrentFrameID != _loc4_.mFrameID)
                        {
                           _loc4_.AddedFrame = 0;
                           _loc4_.RemovedFrame = 0;
                           _loc4_.mFrameID = this.mCurrentFrameID;
                        }
                        ++_loc4_.AddedFrame;
                        ++_loc4_.Added;
                        ++_loc4_.Cumul;
                        ++_loc4_.Current;
                        this.mFullObjectDict[_loc2_.id] = _loc4_;
                        this.mFullObjectInfoDict[_loc2_.id] = _loc34_;
                        _loc4_.AllocSize += _loc34_;
                     }
                  }
               }
               else if((_loc3_ = _loc19_ as DeleteObjectSample) != null)
               {
                  _loc4_ = this.mFullObjectDict[_loc3_.id];
                  _loc35_ = int(this.mFullObjectInfoDict[_loc3_.id]);
                  if(_loc4_)
                  {
                     delete this.mFullObjectDict[_loc4_];
                     delete this.mFullObjectInfoDict[_loc4_];
                  }
                  if(_loc8_ && _loc4_ != null)
                  {
                     if(_loc4_.Type != FunctionCall)
                     {
                        _loc36_ = false;
                        if(_loc5_ != null)
                        {
                           _loc36_ = _loc4_.TypeName.indexOf(_loc5_) == -1;
                        }
                        if(!_loc36_)
                        {
                           _loc24_ = _loc20_;
                           _loc22_ = 0;
                           while(_loc24_ >= 1)
                           {
                              _loc26_ = _loc24_ % 10;
                              this.mNumberStack[_loc22_] = _loc26_;
                              _loc24_ /= 10;
                              _loc22_++;
                           }
                           _loc25_ = _loc22_ - 1;
                           while(_loc25_ >= 0)
                           {
                              this.tempArrayOut.writeByte(48 + this.mNumberStack[_loc25_]);
                              _loc25_--;
                           }
                           this.tempArrayOut.writeByte(9);
                           _loc24_ = _loc21_;
                           _loc22_ = 0;
                           while(_loc24_ >= 1)
                           {
                              _loc26_ = _loc24_ % 10;
                              this.mNumberStack[_loc22_] = _loc26_;
                              _loc24_ /= 10;
                              _loc22_++;
                           }
                           _loc25_ = _loc22_ - 1;
                           while(_loc25_ >= 0)
                           {
                              this.tempArrayOut.writeByte(48 + this.mNumberStack[_loc25_]);
                              _loc25_--;
                           }
                           this.tempArrayOut.writeBytes(DELETE_OBJECT_STRING);
                           _loc24_ = _loc3_.id;
                           _loc22_ = 0;
                           while(_loc24_ >= 1)
                           {
                              _loc26_ = _loc24_ % 10;
                              this.mNumberStack[_loc22_] = _loc26_;
                              _loc24_ /= 10;
                              _loc22_++;
                           }
                           _loc25_ = _loc22_ - 1;
                           while(_loc25_ >= 0)
                           {
                              this.tempArrayOut.writeByte(48 + this.mNumberStack[_loc25_]);
                              _loc25_--;
                           }
                           this.tempArrayOut.writeByte(9);
                           _loc37_ = this.mLineString[_loc3_.size];
                           if(_loc37_ == null)
                           {
                              this.mLineString[_loc3_.size] = _loc37_ = String(_loc3_.size);
                           }
                           this.tempArrayOut.writeUTFBytes(_loc37_);
                           if(_loc4_ != null)
                           {
                              this.tempArrayOut.writeByte(9);
                              _loc16_ = this.mClassNameBuffer[_loc4_.Type];
                              if(_loc16_ == null)
                              {
                                 this.mClassNameBuffer[_loc4_.Type] = _loc16_ = String(_loc4_.Type);
                              }
                              this.tempArrayOut.writeUTFBytes(_loc16_);
                           }
                           this.tempArrayOut.writeByte(13);
                           this.tempArrayOut.writeByte(10);
                        }
                     }
                  }
                  if(_loc11_)
                  {
                     if(_loc4_ != null)
                     {
                        if(this.mCurrentFrameID != _loc4_.mFrameID)
                        {
                           _loc4_.AddedFrame = 0;
                           _loc4_.RemovedFrame = 0;
                           _loc4_.mFrameID = this.mCurrentFrameID;
                        }
                        ++_loc4_.RemovedFrame;
                        ++_loc4_.Removed;
                        if(_loc4_.Current > 0)
                        {
                           --_loc4_.Current;
                        }
                        if(_loc3_.size)
                        {
                           _loc4_.CollectSize += _loc3_.size;
                        }
                        if(_loc3_.size > _loc35_)
                        {
                           _loc4_.AllocSize += _loc3_.size - _loc35_;
                        }
                     }
                     else
                     {
                        _loc18_++;
                     }
                  }
               }
               else
               {
                  _loc23_ = _loc7_.length;
                  if(_loc8_)
                  {
                     if(_loc7_ != null)
                     {
                        if(_loc6_)
                        {
                           _loc38_ = _loc7_[0];
                           _loc39_ = _loc38_.name;
                           _loc40_ = this.mFunctionTimes[_loc39_];
                           if(_loc40_ != null)
                           {
                              _loc41_ = _loc40_ as InternalEventEntry;
                              _loc32_ = _loc41_.qName.indexOf(_loc6_) == -1;
                           }
                        }
                        if(!_loc32_)
                        {
                           _loc24_ = _loc20_;
                           _loc22_ = 0;
                           while(_loc24_ >= 1)
                           {
                              _loc26_ = _loc24_ % 10;
                              this.mNumberStack[_loc22_] = _loc26_;
                              _loc24_ /= 10;
                              _loc22_++;
                           }
                           _loc25_ = _loc22_ - 1;
                           while(_loc25_ >= 0)
                           {
                              this.tempArrayOut.writeByte(48 + this.mNumberStack[_loc25_]);
                              _loc25_--;
                           }
                           this.tempArrayOut.writeByte(9);
                           _loc24_ = _loc21_;
                           _loc22_ = 0;
                           while(_loc24_ >= 1)
                           {
                              _loc26_ = _loc24_ % 10;
                              this.mNumberStack[_loc22_] = _loc26_;
                              _loc24_ /= 10;
                              _loc22_++;
                           }
                           _loc25_ = _loc22_ - 1;
                           while(_loc25_ >= 0)
                           {
                              this.tempArrayOut.writeByte(48 + this.mNumberStack[_loc25_]);
                              _loc25_--;
                           }
                           this.tempArrayOut.writeBytes(BASE_OBJECT_STRING);
                           this.tempArrayOut.writeByte(9);
                           this.tempArrayOut.writeByte(9);
                           this.tempArrayOut.writeByte(9);
                           this.tempArrayOut.writeByte(9);
                           _loc14_ = 0;
                           while(_loc14_ < _loc23_)
                           {
                              _loc15_ = _loc7_[_loc14_];
                              if(_loc15_.name != null)
                              {
                                 this.tempArrayOut.writeUTFBytes(_loc15_.name);
                                 this.tempArrayOut.writeByte(40);
                                 this.tempArrayOut.writeByte(41);
                              }
                              if(_loc15_.file != null)
                              {
                                 this.tempArrayOut.writeByte(91);
                                 this.tempArrayOut.writeUTFBytes(_loc15_.file);
                                 if(_loc15_.line > 0)
                                 {
                                    this.tempArrayOut.writeByte(58);
                                    _loc33_ = this.mLineString[_loc15_.line];
                                    if(_loc33_ == null)
                                    {
                                       this.mLineString[_loc15_.line] = _loc33_ = String(_loc15_.line);
                                    }
                                    this.tempArrayOut.writeUTFBytes(_loc33_);
                                 }
                                 this.tempArrayOut.writeByte(93);
                              }
                              this.tempArrayOut.writeByte(44);
                              _loc14_++;
                           }
                           this.tempArrayOut.writeByte(13);
                           this.tempArrayOut.writeByte(10);
                        }
                     }
                  }
                  if(_loc10_)
                  {
                     _loc43_ = 0;
                     while(_loc43_ < _loc23_)
                     {
                        _loc44_ = _loc7_[_loc43_];
                        _loc45_ = _loc44_.name;
                        _loc46_ = this.mFunctionTimes[_loc45_];
                        if(_loc46_ == undefined)
                        {
                           _loc46_ = new InternalEventEntry();
                           _loc46_.SetStack(_loc7_);
                           _loc46_.qName = _loc45_;
                           this.mFunctionTimesArray.push(_loc46_);
                           this.mFunctionTimes[_loc45_] = _loc46_;
                           if(_loc45_.indexOf("sociodox") != -1)
                           {
                              _loc46_.needSkip = true;
                           }
                           if(_loc45_.indexOf("sampler::") != -1)
                           {
                              _loc46_.needSkip = true;
                           }
                        }
                        _loc47_ = _loc46_;
                        if(_loc43_ == 0)
                        {
                           _loc42_ = _loc46_;
                           if(_loc47_.lastUpdateId != _loc20_)
                           {
                              _loc47_.Add(_loc21_,_loc20_);
                           }
                        }
                        else if(_loc42_ != _loc46_ && _loc47_.lastUpdateId != _loc20_)
                        {
                           _loc47_.AddParentTime(_loc21_,_loc20_);
                        }
                        _loc43_++;
                     }
                  }
                  if(_loc12_)
                  {
                     _loc48_ = null;
                     if(_loc48_ == null)
                     {
                        _loc48_ = _loc7_[_loc23_ - 1].name;
                     }
                     switch(_loc48_)
                     {
                        case INTERNAL_EVENT_ENTERFRAME:
                           this.mInternalStats.mEnterFrame.Add(_loc21_);
                           break;
                        case INTERNAL_EVENT_MARK:
                           this.mInternalStats.mMark.Add(_loc21_);
                           break;
                        case INTERNAL_EVENT_REAP:
                           this.mInternalStats.mReap.Add(_loc21_);
                           break;
                        case INTERNAL_EVENT_SWEEP:
                           this.mInternalStats.mSweep.Add(_loc21_);
                           break;
                        case INTERNAL_EVENT_PRE_RENDER:
                           this.mInternalStats.mPreRender.Add(_loc21_);
                           break;
                        case INTERNAL_EVENT_RENDER:
                           this.mInternalStats.mRender.Add(_loc21_);
                           break;
                        case INTERNAL_EVENT_VERIFY:
                           this.mInternalStats.mVerify.Add(_loc21_);
                           break;
                        case INTERNAL_EVENT_TIMER_TICK:
                           this.mInternalStats.mTimers.Add(_loc21_);
                           break;
                        case INTERNAL_EVENT_AVM1:
                           this.mInternalStats.mAvm1.Add(_loc21_);
                           break;
                        case INTERNAL_EVENT_MOUSE:
                           this.mInternalStats.mMouse.Add(_loc21_);
                           break;
                        case INTERNAL_EVENT_IO:
                           this.mInternalStats.mIo.Add(_loc21_);
                           break;
                        case INTERNAL_EVENT_EXECUTE_QUEUE:
                           this.mInternalStats.mExecuteQueue.Add(_loc21_);
                     }
                  }
               }
               this.lastSampleTime = _loc20_;
            }
         }
         this.lastSample = _loc19_;
         clearSamples();
      }
   }
}

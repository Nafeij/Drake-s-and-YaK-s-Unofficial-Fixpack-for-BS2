package engine.saga
{
   import engine.core.logging.ILogger;
   import flash.errors.IllegalOperationError;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   
   public class SagaLog implements ISagaLog
   {
      
      public static var ENABLED:Boolean;
       
      
      public var root:SagaLogEntry;
      
      public var entriesByItem:Dictionary;
      
      public var logger:ILogger;
      
      public function SagaLog(param1:ILogger)
      {
         this.root = new SagaLogEntry();
         this.entriesByItem = new Dictionary();
         super();
         this.logger = param1;
      }
      
      public function appendItemInstant(param1:*, param2:*) : void
      {
         this._appendItemStart(param1,param2,true);
      }
      
      public function appendItemStart(param1:*, param2:*) : void
      {
         this._appendItemStart(param1,param2,false);
      }
      
      private function _appendItemStart(param1:*, param2:*, param3:Boolean) : SagaLogEntry
      {
         if(!ENABLED)
         {
            return null;
         }
         var _loc4_:SagaLogEntry = this.entriesByItem[param2];
         if(!_loc4_)
         {
            if(param2)
            {
               _loc4_ = this._appendItemStart(param2,null,false);
               _loc4_.ephemeral = true;
            }
            else
            {
               _loc4_ = this.root;
            }
         }
         var _loc5_:SagaLogEntry = new SagaLogEntry().create(param1,_loc4_);
         _loc5_.timeStart = getTimer();
         _loc5_.frameStart = this.logger.frameNumber;
         if(param3)
         {
            _loc5_.timeEnd = _loc5_.timeStart;
            _loc5_.frameEnd = _loc5_.frameStart;
         }
         this.entriesByItem[param1] = _loc5_;
         return _loc5_;
      }
      
      public function appendItemEnd(param1:*) : void
      {
         if(!ENABLED)
         {
            return;
         }
         var _loc2_:SagaLogEntry = this.entriesByItem[param1];
         if(!_loc2_)
         {
            throw new IllegalOperationError("end without start " + param1);
         }
         _loc2_.timeEnd = getTimer();
         _loc2_.frameEnd = this.logger.frameNumber;
      }
      
      public function reportSagaLog() : String
      {
         SagaLogEntry.resetLastTimes();
         return this.root.reportSagaLog("",null);
      }
   }
}

import engine.core.util.StringUtil;

class SagaLogEntry
{
   
   private static var _reportLastTime:int;
   
   private static var _reportLastFrame:int;
    
   
   public var item;
   
   public var msg:String;
   
   public var timeStart:int;
   
   public var frameStart:int;
   
   public var timeEnd:int;
   
   public var frameEnd:int;
   
   public var ephemeral:Boolean;
   
   public var children:Vector.<SagaLogEntry>;
   
   public var parent:SagaLogEntry;
   
   public function SagaLogEntry()
   {
      super();
   }
   
   public static function resetLastTimes() : void
   {
      _reportLastTime = 0;
      _reportLastFrame = 0;
   }
   
   public function create(param1:*, param2:SagaLogEntry) : SagaLogEntry
   {
      this.item = param1;
      this.msg = param1;
      this.parent = param2;
      param2.addChild(this);
      return this;
   }
   
   public function addChild(param1:SagaLogEntry) : void
   {
      if(!this.children)
      {
         this.children = new Vector.<SagaLogEntry>();
      }
      this.children.push(param1);
   }
   
   private function _makeTimestamp(param1:int, param2:int) : String
   {
      var _loc3_:String = "";
      var _loc4_:int = param2 / 1000;
      var _loc5_:int = Number(_reportLastTime) / 1000;
      _loc3_ += _reportLastFrame != param1 ? "=" : " ";
      _loc3_ += StringUtil.padLeft(param1.toString()," ",6) + " ";
      _loc3_ += _loc4_ != _loc5_ ? "_" : " ";
      _loc3_ += StringUtil.padLeft(param2.toString()," ",8) + " ";
      _reportLastFrame = param1;
      _reportLastTime = param2;
      return _loc3_;
   }
   
   public function reportSagaLog(param1:String, param2:SagaLogEntry) : String
   {
      var _loc6_:* = null;
      var _loc7_:int = 0;
      var _loc8_:SagaLogEntry = null;
      var _loc9_:SagaLogEntry = null;
      var _loc3_:String = "";
      var _loc4_:String = this._makeTimestamp(this.frameStart,this.timeStart);
      if(this.frameEnd == this.frameStart)
      {
         if(!this.children)
         {
            if(!param2 || param2.timeStart >= this.timeEnd)
            {
               return _loc3_ + (_loc4_ + param1 + "*       " + this.msg + "\n");
            }
         }
      }
      var _loc5_:String = "> ";
      if(this.ephemeral)
      {
         _loc5_ = "  ";
      }
      else if(!this.frameEnd)
      {
         _loc5_ = "? ";
      }
      _loc3_ += _loc4_ + param1 + _loc5_ + "START " + this.msg + "\n";
      if(this.children)
      {
         _loc6_ = param1;
         if(this.ephemeral)
         {
            _loc6_ += "   ";
         }
         else
         {
            _loc6_ += "|  ";
         }
         _loc7_ = 0;
         while(_loc7_ < this.children.length)
         {
            _loc8_ = this.children[_loc7_];
            _loc9_ = _loc7_ < this.children.length - 1 ? this.children[_loc7_ + 1] : null;
            _loc3_ += _loc8_.reportSagaLog(_loc6_,_loc9_);
            _loc7_++;
         }
      }
      if(this.frameEnd)
      {
         _loc4_ = this._makeTimestamp(this.frameEnd,this.timeEnd);
         _loc3_ += _loc4_ + param1 + "<   END " + this.msg + "\n";
      }
      return _loc3_;
   }
}

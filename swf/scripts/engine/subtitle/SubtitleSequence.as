package engine.subtitle
{
   import engine.core.logging.ILogger;
   import engine.core.util.StringUtil;
   import engine.def.EngineJsonDef;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class SubtitleSequence extends EventDispatcher
   {
      
      public static const EVENT_CURRENT:String = "SubtitleSequence.EVENT_CURRENT";
      
      public static const schema:Object = {
         "name":"SubtitleSequence",
         "type":"object",
         "properties":{"subtitles":{
            "type":"array",
            "items":Subtitle.schema
         }}
      };
       
      
      public var subtitles:Vector.<Subtitle>;
      
      public var index:int = -1;
      
      public var elapsed:int = 0;
      
      private var _current:Subtitle;
      
      public var url:String;
      
      private var logger:ILogger;
      
      private var started:Boolean;
      
      private var _paused:Boolean;
      
      private var _nextTime:int = -1;
      
      public function SubtitleSequence(param1:ILogger)
      {
         this.subtitles = new Vector.<Subtitle>();
         super();
         this.logger = param1;
      }
      
      public static function parseTimestamp(param1:String) : int
      {
         var _loc11_:String = null;
         if(!param1)
         {
            return 0;
         }
         var _loc2_:Array = param1.split(":");
         if(_loc2_.length > 4)
         {
            throw new ArgumentError("Invalid timestamp [" + param1 + "]");
         }
         var _loc3_:int = -3 + _loc2_.length;
         var _loc4_:int = -2 + _loc2_.length;
         var _loc5_:int = -1 + _loc2_.length;
         var _loc6_:String = String(_loc2_[_loc5_]);
         var _loc7_:String = _loc4_ >= 0 ? String(_loc2_[_loc4_]) : "0";
         var _loc8_:String = _loc3_ >= 0 ? String(_loc2_[_loc3_]) : "0";
         var _loc9_:int = _loc6_.indexOf(".");
         var _loc10_:int = 0;
         if(_loc9_ > 0)
         {
            _loc2_[2] = _loc6_.substr(0,_loc9_);
            _loc11_ = _loc6_.substr(_loc9_);
            _loc6_ = String(_loc2_[2]);
            _loc10_ += 1000 * Number(_loc11_);
         }
         _loc10_ += int(_loc6_) * 1000;
         _loc10_ += int(_loc7_) * 1000 * 60;
         return _loc10_ + int(_loc8_) * 1000 * 60 * 60;
      }
      
      public static function pl(param1:int, param2:int = 2) : String
      {
         return StringUtil.padLeft(param1.toString(),"0",param2);
      }
      
      public static function formatTimestamp(param1:Number) : String
      {
         var _loc2_:String = "";
         var _loc3_:int = param1 / 1000;
         var _loc4_:int = param1 - _loc3_ * 1000;
         var _loc5_:int = _loc3_ / 60;
         var _loc6_:int = _loc5_ / 60;
         _loc5_ -= _loc6_ * 60;
         _loc3_ -= _loc5_ * 60;
         return pl(_loc6_) + ":" + pl(_loc5_) + ":" + pl(_loc3_) + "." + pl(_loc4_);
      }
      
      public function get current() : Subtitle
      {
         return this._current;
      }
      
      public function set current(param1:Subtitle) : void
      {
         if(this._current == param1)
         {
            return;
         }
         if(this._current)
         {
            this.logger.info("SubtitleSequence   END at " + this.elapsed + ": " + this._current);
         }
         this._current = param1;
         if(this._current)
         {
            this.logger.info("SubtitleSequence START at " + this.elapsed + ": " + this._current);
         }
         dispatchEvent(new Event(EVENT_CURRENT));
      }
      
      public function stop() : void
      {
         this.started = false;
         this.current = null;
         this.index = 0;
         this.elapsed = 0;
      }
      
      public function pause() : void
      {
         if(this._paused)
         {
            return;
         }
         this._paused = true;
      }
      
      public function resume() : void
      {
         if(!this._paused)
         {
            return;
         }
         this._paused = false;
      }
      
      public function startSubtitles() : void
      {
         this.started = true;
         this.index = -1;
         this.elapsed = 0;
         this.queueNext();
      }
      
      public function queueNext() : void
      {
         var _loc1_:Subtitle = this.peekNext;
         if(_loc1_)
         {
            this._nextTime = _loc1_.start;
         }
         else
         {
            this._nextTime = -1;
         }
      }
      
      public function get peekNext() : Subtitle
      {
         var _loc1_:int = this.index + 1;
         if(_loc1_ >= this.subtitles.length)
         {
            return null;
         }
         return this.subtitles[_loc1_];
      }
      
      public function next() : void
      {
         var _loc1_:int = this.index + 1;
         if(_loc1_ >= this.subtitles.length)
         {
            return;
         }
         this.index = _loc1_;
         this.current = this.subtitles[this.index];
         var _loc2_:int = this.current.end;
         var _loc3_:Subtitle = this.peekNext;
         if(_loc3_)
         {
            _loc2_ = Math.min(_loc3_.start,_loc2_);
         }
         this.queueNext();
      }
      
      public function fromJson(param1:Object, param2:ILogger) : SubtitleSequence
      {
         var _loc3_:Object = null;
         var _loc4_:Subtitle = null;
         EngineJsonDef.validateThrow(param1,schema,param2);
         for each(_loc3_ in param1.subtitles)
         {
            _loc4_ = new Subtitle().fromJson(_loc3_,param2);
            this.subtitles.push(_loc4_);
         }
         return this;
      }
      
      public function toJson() : Object
      {
         var _loc2_:Subtitle = null;
         var _loc3_:Object = null;
         var _loc1_:Object = {"subtitles":[]};
         for each(_loc2_ in this.subtitles)
         {
            _loc3_ = _loc2_.toJson();
            _loc1_.subtitles.push(_loc3_);
         }
         return _loc1_;
      }
      
      public function fromSbv(param1:String) : SubtitleSequence
      {
         var cs:Subtitle = null;
         var linenum:int = 0;
         var line:String = null;
         var tsv:Array = null;
         var s:String = param1;
         s = s.replace(/\r/gi,"");
         var lines:Array = s.split("\n");
         linenum = 0;
         while(linenum < lines.length)
         {
            line = String(lines[linenum]);
            if(!line)
            {
               if(cs)
               {
                  cs = null;
               }
            }
            else if(!cs)
            {
               cs = new Subtitle();
               this.subtitles.push(cs);
               tsv = line.split(",");
               if(tsv.length != 2)
               {
                  throw new ArgumentError("Line [" + linenum + "] expected timestamp range, found [" + line + "]");
               }
               try
               {
                  cs.start = parseTimestamp(tsv[0]);
                  cs.end = parseTimestamp(tsv[1]);
               }
               catch(e:Error)
               {
                  throw new ArgumentError("Line [" + linenum + "] error: " + e.message);
               }
            }
            else if(cs.text)
            {
               cs.text += "\n" + line;
            }
            else
            {
               cs.text = line;
            }
            linenum++;
         }
         return this;
      }
      
      public function toSbv() : String
      {
         var _loc2_:Subtitle = null;
         var _loc3_:String = null;
         var _loc1_:* = "";
         for each(_loc2_ in this.subtitles)
         {
            _loc1_ += formatTimestamp(_loc2_.start);
            _loc1_ += ",";
            _loc1_ += formatTimestamp(_loc2_.end);
            _loc1_ += "\n";
            _loc1_ += _loc2_.text;
            _loc3_ = !!_loc2_.text ? _loc2_.text.charAt(_loc2_.text.length - 1) : null;
            if(_loc3_ != "\n")
            {
               _loc1_ += "\n";
            }
            _loc1_ += "\n";
         }
         return _loc1_;
      }
      
      public function update(param1:int) : void
      {
         this.elapsed += param1;
         if(this._nextTime >= 0 && this.elapsed > this._nextTime)
         {
            this.next();
         }
         if(this._current)
         {
            if(this.elapsed > this._current.end)
            {
               this.current = null;
            }
         }
      }
   }
}

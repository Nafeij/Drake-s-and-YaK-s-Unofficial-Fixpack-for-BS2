package engine.saga.convo.def
{
   import engine.core.logging.ILogger;
   
   public class ConvoDefVars extends ConvoDef
   {
       
      
      public var checkedMarkless:Boolean;
      
      public function ConvoDefVars(param1:ConvoStringsDef)
      {
         super(param1);
      }
      
      public function reparseJson(param1:ConvoStringsDef, param2:ILogger) : void
      {
         this.strings = param1;
         this.fromJson(json,param2,false);
      }
      
      public function fromJson(param1:Object, param2:ILogger, param3:Boolean) : ConvoDefVars
      {
         var n:ConvoNodeDefVars = null;
         var cameras:Boolean = false;
         var sid:String = null;
         var f:ConvoFlagDef = null;
         var json:Object = param1;
         var logger:ILogger = param2;
         var withSkipLine:Boolean = param3;
         if(!json)
         {
            throw new ArgumentError("no json for convo? [" + url + "]");
         }
         if(this.json)
         {
            return this;
         }
         this.json = json;
         inkleUrlKey = json.url_key;
         if(!json.data)
         {
            throw new ArgumentError("no data");
         }
         initial = json.data.initial;
         if(!json.data.stitches)
         {
            throw new ArgumentError("null stitches");
         }
         for(sid in json.data.stitches)
         {
            n = new ConvoNodeDefVars(this);
            n.id = sid;
            try
            {
               n.fromJson(json.data.stitches[sid],logger,withSkipLine);
               if(n.id in nodesById)
               {
                  logger.error("Already parsed node [" + n.id + "]");
               }
               nodesById[n.id] = n;
               nodesArray.push(n);
               if(n.pageNum == 1)
               {
                  for each(f in n.metaflags)
                  {
                  }
               }
               if(n.speaker)
               {
                  speakers[n.speaker] = n.speaker;
               }
               cameras = cameras || Boolean(n.camera);
            }
            catch(e:Error)
            {
               logger.error("Failed to parse node [" + sid + "] convo [" + url + "]: " + e.getStackTrace());
               break;
            }
         }
         nodesArray.sortOn("id",Array.CASEINSENSITIVE);
         if(cameras)
         {
            this.checkMarkless(logger);
         }
         this.processCameras(logger);
         if(CALCULATE_WORD_COUNT)
         {
            countWords();
         }
         return this;
      }
      
      private function processCameras(param1:ILogger) : void
      {
         var _loc2_:ConvoNodeDef = null;
         for each(var _loc5_ in nodesById)
         {
            _loc2_ = _loc5_;
            _loc5_;
            _loc2_.processCamera(param1);
         }
      }
      
      public function checkMarkless(param1:ILogger) : void
      {
         var _loc2_:ConvoNodeDef = null;
         if(this.checkedMarkless)
         {
            return;
         }
         this.checkedMarkless = true;
         for each(var _loc5_ in nodesById)
         {
            _loc2_ = _loc5_;
            _loc5_;
            this._checkMarkForUnit(_loc2_.id,_loc2_.speaker,param1);
            this._checkMarkForUnit(_loc2_.id,_loc2_.camera,param1);
         }
      }
      
      private function _checkMarkForUnit(param1:String, param2:String, param3:ILogger) : void
      {
         var _loc4_:int = 0;
         if(!param2)
         {
            return;
         }
         if(!getMarkFromUnit(param2))
         {
            this.assignFirstAvailableMark(param2,param3);
            _loc4_ = getMarkFromUnit(param2);
            if(!_loc4_)
            {
               param3.error("ConvoDef " + url + " @" + param1 + " Auto-mark failed for [" + param2 + "]");
            }
            else
            {
               param3.debug("Convodef " + url + " @" + param1 + " Auto-mark " + param2 + " to " + _loc4_);
            }
         }
      }
      
      private function assignFirstAvailableMark(param1:String, param2:ILogger) : void
      {
         if(!mark1.length)
         {
            mark1.push(param1);
         }
         else if(!mark2.length)
         {
            mark2.push(param1);
         }
         else if(!mark3.length)
         {
            mark3.push(param1);
         }
         else if(!mark4.length)
         {
            mark4.push(param1);
         }
         else
         {
            param2.error("ConvoDef " + url + " assignFirstAvailableMark failed for [" + param1 + "]");
         }
      }
   }
}

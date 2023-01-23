package engine.saga.convo.def
{
   import engine.core.logging.ILogger;
   import flash.errors.IllegalOperationError;
   
   public class ConvoNodeDefVars extends ConvoNodeDef
   {
       
      
      public function ConvoNodeDefVars(param1:ConvoDef)
      {
         super(param1);
      }
      
      private function handleParseText(param1:String, param2:Boolean) : void
      {
         parseText(param1 as String,param2,true);
      }
      
      private function handleParseOption(param1:Object, param2:int, param3:ILogger) : void
      {
         if(link)
         {
            throw new ArgumentError("found options [" + param1.option + "] alongside a divert");
         }
         if(!options)
         {
            options = new Vector.<ConvoOptionDef>();
         }
         var _loc4_:ConvoOptionDef = null;
         if(param2 < options.length)
         {
            throw new IllegalOperationError("I don\'t think this should happen anymore with loc strings");
         }
         _loc4_ = new ConvoOptionDefVars(this).fromJson(param1,id,param2,param3);
         _loc4_._text = ConvoNodeDef.parseInkleCodes(_loc4_._text);
         if(param2 >= options.length)
         {
            options.push(_loc4_);
         }
      }
      
      public function fromJson(param1:Object, param2:ILogger, param3:Boolean) : void
      {
         var _loc6_:Object = null;
         var _loc7_:ConvoFlagDef = null;
         var _loc4_:* = this.json == null;
         this.json = param1;
         if(!param1.content)
         {
            return;
         }
         var _loc5_:int = 0;
         for each(_loc6_ in param1.content)
         {
            if(_loc6_ is String)
            {
               this.handleParseText(_loc6_ as String,param3);
            }
            else if("option" in _loc6_)
            {
               this.handleParseOption(_loc6_,_loc5_,param2);
               _loc5_++;
            }
            else if(_loc4_)
            {
               if("runOn" in _loc6_)
               {
                  runOn = _loc6_.runOn;
               }
               else if("divert" in _loc6_)
               {
                  if(_loc4_)
                  {
                     if(options)
                     {
                        throw new ArgumentError("found a divert [" + _loc6_.divert + "] alongside options");
                     }
                     link = new ConvoLinkDefVars(convo);
                     (link as ConvoLinkDefVars).fromDivertJson(_loc6_);
                  }
               }
               else if("flagName" in _loc6_)
               {
                  _loc7_ = new ConvoFlagDef();
                  _loc7_.parse(_loc6_.flagName,param2);
                  if(_loc7_.meta)
                  {
                     if(!metaflags)
                     {
                        metaflags = new Vector.<ConvoFlagDef>();
                     }
                     metaflags.push(_loc7_);
                  }
                  else
                  {
                     if(!flags)
                     {
                        flags = new Vector.<ConvoFlagDef>();
                     }
                     flags.push(_loc7_);
                  }
               }
               else if("pageNum" in _loc6_)
               {
                  pageNum = _loc6_.pageNum;
               }
               else if("pageLabel" in _loc6_)
               {
                  pageLabel = _loc6_.pageLabel;
               }
               else if("notIfCondition" in _loc6_)
               {
                  if(!conditions)
                  {
                     conditions = new ConvoConditionsDef();
                  }
                  conditions.addNotIfCondition(_loc6_.notIfCondition);
               }
               else if("ifCondition" in _loc6_)
               {
                  if(!conditions)
                  {
                     conditions = new ConvoConditionsDef();
                  }
                  conditions.addIfCondition(_loc6_.ifCondition);
               }
            }
         }
      }
   }
}

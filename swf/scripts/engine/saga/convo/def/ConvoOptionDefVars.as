package engine.saga.convo.def
{
   import engine.core.logging.ILogger;
   
   public class ConvoOptionDefVars extends ConvoOptionDef
   {
       
      
      public function ConvoOptionDefVars(param1:ConvoNodeDef)
      {
         super(param1);
      }
      
      public function fromJson(param1:Object, param2:String, param3:int, param4:ILogger) : ConvoOptionDefVars
      {
         var _loc5_:String = null;
         if(param1.linkPath)
         {
            link = new ConvoLinkDefVars(node.convo);
            (link as ConvoLinkDefVars).fromOptionJson(param1,param4);
         }
         _text = param1.option;
         if(param1.flags)
         {
            this.flags = new Vector.<ConvoFlagDef>();
            for each(_loc5_ in param1.flags)
            {
               flags.push(new ConvoFlagDef().parse(_loc5_,param4));
            }
         }
         branch = _text == "{branch}";
         this.nodeId = param2;
         this.index = param3;
         if(_text.indexOf("[") >= 0 && _text.indexOf("]") > 0)
         {
            throw new ArgumentError("Option looks like it attempted to have an actor block in it: " + _text);
         }
         return this;
      }
   }
}

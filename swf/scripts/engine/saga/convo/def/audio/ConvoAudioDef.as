package engine.saga.convo.def.audio
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   import flash.utils.Dictionary;
   
   public class ConvoAudioDef
   {
      
      public static const schema:Object = {
         "name":"ConvoAudioDef",
         "type":"object",
         "properties":{
            "cmdss":{
               "type":"array",
               "items":ConvoAudioCmdsDef.schema
            },
            "convoUrl":{"type":"string"}
         }
      };
       
      
      public var cmdss:Vector.<ConvoAudioCmdsDef>;
      
      public var cmdssById:Dictionary;
      
      public var convoUrl:String;
      
      public function ConvoAudioDef()
      {
         this.cmdss = new Vector.<ConvoAudioCmdsDef>();
         this.cmdssById = new Dictionary();
         super();
      }
      
      private function makeId(param1:String, param2:int) : String
      {
         if(param2 >= 0)
         {
            return param1 + ":" + param2.toString;
         }
         return param1;
      }
      
      public function addCmds(param1:String, param2:int) : ConvoAudioCmdsDef
      {
         var _loc3_:String = this.makeId(param1,param2);
         if(this.cmdssById[_loc3_])
         {
            return this.cmdssById[_loc3_];
         }
         var _loc4_:ConvoAudioCmdsDef = new ConvoAudioCmdsDef();
         _loc4_.id = _loc3_;
         this.internalAddCmds(_loc4_);
         return _loc4_;
      }
      
      private function internalAddCmds(param1:ConvoAudioCmdsDef) : void
      {
         this.cmdss.push(param1);
         this.cmdssById[param1.id] = param1;
      }
      
      public function getCmdsById(param1:String) : ConvoAudioCmdsDef
      {
         return this.cmdssById[param1];
      }
      
      public function getCmdsByStitchOption(param1:String, param2:int) : ConvoAudioCmdsDef
      {
         return this.cmdssById[this.makeId(param1,param2)];
      }
      
      public function deleteCmdsById(param1:String) : void
      {
         var _loc3_:int = 0;
         var _loc2_:ConvoAudioCmdsDef = this.cmdssById[param1];
         if(_loc2_)
         {
            delete this.cmdssById[param1];
            _loc3_ = this.cmdss.indexOf(_loc2_);
            if(_loc3_ >= 0)
            {
               this.cmdss.splice(_loc3_,1);
            }
         }
      }
      
      public function fromJson(param1:Object, param2:ILogger) : ConvoAudioDef
      {
         var _loc3_:Object = null;
         var _loc4_:ConvoAudioCmdsDef = null;
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.convoUrl = param1.convoUrl;
         for each(_loc3_ in param1.cmdss)
         {
            _loc4_ = new ConvoAudioCmdsDef().fromJson(_loc3_,param2);
            this.internalAddCmds(_loc4_);
         }
         return this;
      }
      
      public function save() : Object
      {
         var _loc2_:ConvoAudioCmdsDef = null;
         var _loc1_:Object = {
            "cmdss":[],
            "convoUrl":(!!this.convoUrl ? this.convoUrl : "")
         };
         for each(_loc2_ in this.cmdss)
         {
            _loc1_.cmdss.push(_loc2_.save());
         }
         return _loc1_;
      }
   }
}

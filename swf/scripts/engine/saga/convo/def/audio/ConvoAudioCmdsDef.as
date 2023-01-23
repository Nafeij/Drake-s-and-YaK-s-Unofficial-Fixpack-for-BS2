package engine.saga.convo.def.audio
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   
   public class ConvoAudioCmdsDef
   {
      
      public static const schema:Object = {
         "name":"ConvoAudioCmdsDef",
         "type":"object",
         "properties":{
            "cmds":{
               "type":"array",
               "items":ConvoAudioCmdDef.schema
            },
            "id":{"type":"string"}
         }
      };
       
      
      public var id:String;
      
      public var cmds:Vector.<ConvoAudioCmdDef>;
      
      public function ConvoAudioCmdsDef()
      {
         this.cmds = new Vector.<ConvoAudioCmdDef>();
         super();
      }
      
      public function toString() : String
      {
         return "id=" + this.id + ", cmds=" + this.cmds.length;
      }
      
      public function addNewCmd() : ConvoAudioCmdDef
      {
         var _loc1_:ConvoAudioCmdDef = new ConvoAudioCmdDef();
         this.cmds.push(_loc1_);
         return _loc1_;
      }
      
      public function deleteCmd(param1:ConvoAudioCmdDef) : void
      {
         var _loc2_:int = this.cmds.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this.cmds.splice(_loc2_,1);
         }
      }
      
      public function fromJson(param1:Object, param2:ILogger) : ConvoAudioCmdsDef
      {
         var _loc3_:Object = null;
         var _loc4_:ConvoAudioCmdDef = null;
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.id = param1.id;
         for each(_loc3_ in param1.cmds)
         {
            _loc4_ = new ConvoAudioCmdDef().fromJson(_loc3_,param2);
            this.cmds.push(_loc4_);
         }
         return this;
      }
      
      public function save() : Object
      {
         var _loc2_:ConvoAudioCmdDef = null;
         var _loc1_:Object = {
            "cmds":[],
            "id":(!!this.id ? this.id : "")
         };
         for each(_loc2_ in this.cmds)
         {
            _loc1_.cmds.push(_loc2_.save());
         }
         return _loc1_;
      }
   }
}

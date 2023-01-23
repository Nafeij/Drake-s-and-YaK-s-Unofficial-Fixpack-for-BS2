package engine.saga.convo.def.audio
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   import flash.utils.Dictionary;
   
   public class ConvoAudioListDef
   {
      
      public static const schema:Object = {
         "name":"ConvoAudioDefList",
         "type":"object",
         "properties":{"audios":{
            "type":"array",
            "items":ConvoAudioDef.schema
         }}
      };
       
      
      public var defs:Vector.<ConvoAudioDef>;
      
      public var defsByConvoUrl:Dictionary;
      
      public var url:String;
      
      public function ConvoAudioListDef()
      {
         this.defs = new Vector.<ConvoAudioDef>();
         this.defsByConvoUrl = new Dictionary();
         super();
      }
      
      public function addDef(param1:ConvoAudioDef) : void
      {
         this.defs.push(param1);
         this.defsByConvoUrl[param1.convoUrl] = param1;
      }
      
      public function removeDef(param1:ConvoAudioDef) : void
      {
         delete this.defsByConvoUrl[param1.convoUrl];
         var _loc2_:int = this.defs.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this.defs.splice(_loc2_,1);
         }
      }
      
      public function getAudioForConvo(param1:String) : ConvoAudioDef
      {
         return this.defsByConvoUrl[param1];
      }
      
      public function fromJson(param1:Object, param2:ILogger) : ConvoAudioListDef
      {
         var _loc3_:Object = null;
         var _loc4_:ConvoAudioDef = null;
         EngineJsonDef.validateThrow(param1,schema,param2);
         for each(_loc3_ in param1.audios)
         {
            _loc4_ = new ConvoAudioDef().fromJson(_loc3_,param2);
            this.addDef(_loc4_);
         }
         return this;
      }
      
      public function save() : Object
      {
         var _loc2_:ConvoAudioDef = null;
         var _loc1_:Object = {"audios":[]};
         for each(_loc2_ in this.defs)
         {
            _loc1_.audios.push(_loc2_.save());
         }
         return _loc1_;
      }
   }
}

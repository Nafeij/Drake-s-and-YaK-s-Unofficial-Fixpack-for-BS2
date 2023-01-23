package engine.saga
{
   import engine.core.logging.ILogger;
   
   public class SagaCampMusicDef
   {
      
      public static const schema:Object = {
         "name":"SagaCampMusicDef",
         "type":"object",
         "properties":{"entries":{
            "type":"array",
            "items":SagaCampMusicEntryDef.schema
         }}
      };
       
      
      public var entries:Vector.<SagaCampMusicEntryDef>;
      
      private var valids:Vector.<SagaCampMusicEntryDef>;
      
      public function SagaCampMusicDef()
      {
         this.entries = new Vector.<SagaCampMusicEntryDef>();
         this.valids = new Vector.<SagaCampMusicEntryDef>();
         super();
      }
      
      public function fromJson(param1:Object, param2:ILogger) : SagaCampMusicDef
      {
         var _loc3_:Object = null;
         var _loc4_:SagaCampMusicEntryDef = null;
         if(param1.entries)
         {
            for each(_loc3_ in param1.entries)
            {
               _loc4_ = new SagaCampMusicEntryDef().fromJson(_loc3_,param2);
               this.entries.push(_loc4_);
            }
         }
         return this;
      }
      
      public function toJson() : Object
      {
         var _loc2_:SagaCampMusicEntryDef = null;
         var _loc1_:Object = {"entries":[]};
         for each(_loc2_ in this.entries)
         {
            _loc1_.entries.push(_loc2_.toJson());
         }
         return _loc1_;
      }
      
      public function pickOneMusic(param1:Saga, param2:String) : String
      {
         var _loc3_:SagaCampMusicEntryDef = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         this.valids.splice(0,this.valids.length);
         for each(_loc3_ in this.entries)
         {
            if(_loc3_.event != param2)
            {
               if(_loc3_.isValid(param1))
               {
                  this.valids.push(_loc3_);
                  _loc4_ = 1;
                  while(_loc4_ < _loc3_.weight && _loc4_ < 10)
                  {
                     this.valids.push(_loc3_);
                     _loc4_++;
                  }
               }
            }
         }
         if(this.valids.length > 0)
         {
            _loc5_ = param1.rng.nextMax(this.valids.length - 1);
            _loc3_ = this.valids[_loc5_];
            return _loc3_.event;
         }
         return null;
      }
   }
}

package engine.saga
{
   import engine.core.util.StringUtil;
   import engine.saga.happening.HappeningDefBag;
   import engine.saga.happening.HappeningDefBagVars;
   
   public class SagaDefSaveInfo
   {
       
      
      public var sagaDef:SagaDef;
      
      public var sagaDef_j:Object;
      
      public var happenings_j:Object;
      
      public var filenames:Array;
      
      public var jsons:Array;
      
      public var srcFilename:String;
      
      public function SagaDefSaveInfo(param1:SagaDef)
      {
         this.filenames = [];
         this.jsons = [];
         super();
         this.sagaDef = param1;
         this.srcFilename = param1.url;
         this.srcFilename = StringUtil.stripSuffix(this.srcFilename,".z");
         this.sagaDef_j = SagaDefVars.toJson(this.sagaDef);
         this.filenames.push(this.srcFilename);
         this.jsons.push(this.sagaDef_j);
         var _loc2_:String = HappeningDefBag.getHappeningsUrl(this.srcFilename);
         this.filenames.push(_loc2_);
         if(Boolean(param1.happenings) && Boolean(param1.happenings.numHappenings))
         {
            this.happenings_j = HappeningDefBagVars.save(param1.happenings);
         }
         this.jsons.push(this.happenings_j);
      }
      
      public function collectOutputs(param1:Array, param2:Array) : void
      {
         var _loc4_:String = null;
         var _loc5_:Object = null;
         var _loc3_:int = 0;
         while(_loc3_ < this.filenames.length)
         {
            _loc4_ = this.filenames[_loc3_];
            _loc5_ = this.jsons[_loc3_];
            param1.push(_loc5_);
            param2.push(_loc4_);
            _loc3_++;
         }
      }
   }
}

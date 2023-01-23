package engine.scene.def
{
   import engine.core.util.StableJson;
   import engine.core.util.StringUtil;
   import engine.saga.happening.HappeningDefBag;
   import engine.saga.happening.HappeningDefBagVars;
   
   public class SceneDefSaveInfo
   {
       
      
      public var sceneDef:SceneDef;
      
      public var sceneDef_j:Object;
      
      public var happenings_j:Object;
      
      public var filenames:Array;
      
      public var jsons:Array;
      
      public var srcFilename:String;
      
      public function SceneDefSaveInfo(param1:SceneDef, param2:Boolean)
      {
         var _loc3_:String = null;
         this.filenames = [];
         this.jsons = [];
         super();
         this.sceneDef = param1;
         this.srcFilename = param1.url;
         this.srcFilename = StringUtil.stripSuffix(this.srcFilename,".z");
         if(param1.url.indexOf("btl_training.json") >= 0)
         {
            param1 = param1;
         }
         this.sceneDef_j = SceneDefVars.toJson(this.sceneDef);
         this.filenames.push(this.srcFilename);
         this.jsons.push(this.sceneDef_j);
         if(!param2)
         {
            _loc3_ = HappeningDefBag.getHappeningsUrl(this.srcFilename);
            this.filenames.push(_loc3_);
            if(Boolean(param1.happenings) && Boolean(param1.happenings.numHappenings))
            {
               this.happenings_j = HappeningDefBagVars.save(param1.happenings);
            }
            this.jsons.push(this.happenings_j);
         }
         else
         {
            if(param1.split_happenings)
            {
               this.sceneDef_j.split_happenings = true;
            }
            if(!param1.split_happenings && param1.happenings && Boolean(param1.happenings.numHappenings))
            {
               this.sceneDef_j.happenings = HappeningDefBagVars.save(param1.happenings);
               delete this.sceneDef_j["split_happenings"];
            }
         }
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
      
      public function assembleFileJson() : Object
      {
         var _loc1_:Object = JSON.parse(StableJson.stringifyObject(this.sceneDef_j,"\t"));
         if(this.happenings_j)
         {
            _loc1_.happenings = this.happenings_j;
         }
         return _loc1_;
      }
   }
}

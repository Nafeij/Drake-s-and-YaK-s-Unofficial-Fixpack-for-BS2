package engine.tourney
{
   import engine.core.logging.ILogger;
   
   public class TourneyDefList
   {
       
      
      public var defs:Vector.<TourneyDef>;
      
      public function TourneyDefList(param1:Object, param2:ILogger)
      {
         var _loc3_:Object = null;
         var _loc4_:TourneyDef = null;
         this.defs = new Vector.<TourneyDef>();
         super();
         for each(_loc3_ in param1)
         {
            _loc4_ = new TourneyDef();
            _loc4_.fromJson(_loc3_);
            this.defs.push(_loc4_);
         }
      }
      
      public function findTourneyDef(param1:String) : TourneyDef
      {
         var _loc2_:TourneyDef = null;
         for each(_loc2_ in this.defs)
         {
            if(_loc2_.name == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
   }
}

package engine.saga.happening
{
   import engine.core.logging.ILogger;
   
   public class HappeningDefBagVars extends HappeningDefBag
   {
       
      
      public function HappeningDefBagVars(param1:String, param2:*)
      {
         super(param1,param2);
      }
      
      public static function save(param1:HappeningDefBag) : Object
      {
         var _loc3_:HappeningDef = null;
         if(!param1)
         {
            return null;
         }
         var _loc2_:Array = [];
         for each(_loc3_ in param1.list)
         {
            _loc2_.push(HappeningDefVars.save(_loc3_));
         }
         return _loc2_;
      }
      
      public function fromJson(param1:Object, param2:ILogger, param3:Boolean) : HappeningDefBagVars
      {
         var _loc4_:Object = null;
         var _loc5_:HappeningDefVars = null;
         if(!(param1 is Array))
         {
            throw new ArgumentError("bad bag");
         }
         for each(_loc4_ in param1)
         {
            _loc5_ = new HappeningDefVars(this).fromJson(_loc4_,param2,param3);
            if(!(param3 && !_loc5_.enabled))
            {
               if(getHappeningDef(_loc5_.id))
               {
                  param2.error("Duplicate happening [" + _loc5_.id + "] already present in " + this);
               }
               else
               {
                  addHappeningDef(_loc5_);
               }
            }
         }
         return this;
      }
   }
}

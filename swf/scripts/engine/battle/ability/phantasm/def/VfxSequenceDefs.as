package engine.battle.ability.phantasm.def
{
   import engine.core.logging.ILogger;
   import engine.core.util.ArrayUtil;
   
   public class VfxSequenceDefs
   {
       
      
      public var vfxds:Vector.<VfxSequenceDef>;
      
      public var totalWeight:Number = 1;
      
      public function VfxSequenceDefs()
      {
         this.vfxds = new Vector.<VfxSequenceDef>();
         super();
      }
      
      public function get hasVfxds() : Boolean
      {
         return Boolean(this.vfxds) && Boolean(this.vfxds.length);
      }
      
      public function hasVfxd(param1:VfxSequenceDef) : Boolean
      {
         if(!param1)
         {
            return false;
         }
         return this.vfxds.indexOf(param1) >= 0;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : VfxSequenceDefs
      {
         var _loc4_:VfxSequenceDef = null;
         var _loc3_:Array = param1 as Array;
         if(!_loc3_)
         {
            throw new ArgumentError("nope");
         }
         this.vfxds = ArrayUtil.arrayToDefVector(_loc3_,VfxSequenceDef,param2,this.vfxds) as Vector.<VfxSequenceDef>;
         this.totalWeight = 0;
         for each(_loc4_ in this.vfxds)
         {
            if(!_loc4_.always)
            {
               this.totalWeight += _loc4_.weight;
            }
         }
         if(this.totalWeight <= 0)
         {
            this.totalWeight = 1;
         }
         return this;
      }
      
      public function toJson() : Object
      {
         if(this.vfxds)
         {
            return ArrayUtil.defVectorToArray(this.vfxds,true);
         }
         return [];
      }
      
      public function addVfxds(param1:VfxSequenceDefs) : void
      {
         var _loc2_:VfxSequenceDef = null;
         if(!param1.hasVfxds)
         {
            return;
         }
         for each(_loc2_ in param1.vfxds)
         {
            this.addVfxd(_loc2_.clone());
         }
      }
      
      public function addVfxd(param1:VfxSequenceDef) : void
      {
         this.vfxds.push(param1);
         this.totalWeight += param1.weight;
      }
      
      public function getVfxdById(param1:String) : VfxSequenceDef
      {
         var _loc2_:VfxSequenceDef = null;
         for each(_loc2_ in this.vfxds)
         {
            if(_loc2_.id == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function createNewId() : String
      {
         var _loc3_:String = null;
         var _loc1_:String = "NewVfx_";
         var _loc2_:int = 0;
         while(_loc2_ < 100)
         {
            _loc3_ = _loc1_ + _loc2_;
            if(!this.getVfxdById(_loc3_))
            {
               return _loc3_;
            }
            _loc2_++;
         }
         return "unknown id";
      }
   }
}

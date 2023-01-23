package engine.anim.def
{
   public class AnimMixDef
   {
       
      
      public var name:String;
      
      public var entries:Vector.<AnimMixEntryDef>;
      
      protected var totalWeight:int;
      
      public var start:AnimMixEntryDef;
      
      public var mixdefault:Boolean;
      
      public function AnimMixDef()
      {
         this.entries = new Vector.<AnimMixEntryDef>();
         super();
      }
      
      public function getMix(param1:String) : AnimMixEntryDef
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.entries.length)
         {
            if(this.entries[_loc2_].anim == param1)
            {
               return this.entries[_loc2_];
            }
            _loc2_++;
         }
         return null;
      }
      
      public function randomlySelect(param1:AnimMixEntryDef) : AnimMixEntryDef
      {
         var _loc6_:AnimMixEntryDef = null;
         var _loc7_:int = 0;
         var _loc2_:int = this.totalWeight;
         if(Boolean(param1) && this.entries.length > 0)
         {
            _loc2_ -= param1.weight;
         }
         var _loc3_:int = Math.random() * _loc2_;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         while(_loc5_ < this.entries.length)
         {
            _loc6_ = this.entries[_loc5_];
            if(_loc6_ != param1)
            {
               if(!(_loc6_.weight == 0 && _loc2_ > 0))
               {
                  _loc7_ = _loc4_ + _loc6_.weight;
                  if(_loc3_ >= _loc4_ && _loc3_ <= _loc7_)
                  {
                     return _loc6_;
                  }
               }
            }
            _loc5_++;
         }
         return param1;
      }
   }
}

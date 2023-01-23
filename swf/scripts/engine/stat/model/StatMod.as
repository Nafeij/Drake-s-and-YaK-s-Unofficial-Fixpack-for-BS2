package engine.stat.model
{
   import engine.core.util.StringUtil;
   import engine.stat.def.StatModDef;
   
   public class StatMod
   {
       
      
      public var amount:int;
      
      public var provider:IStatModProvider;
      
      public var charges:int;
      
      public var stat:Stat;
      
      public var consumed:Boolean;
      
      public function StatMod(param1:Stat, param2:IStatModProvider, param3:int, param4:int)
      {
         super();
         this.charges = param4;
         this.stat = param1;
         this.provider = param2;
         this.amount = param3;
         param1.statModModifyValue(param3);
      }
      
      public static function addStatMod(param1:Stats, param2:IStatModProvider, param3:StatModDef) : void
      {
         if(!param1.hasStat(param3.stat))
         {
            param1.addStat(param3.stat,0);
         }
         var _loc4_:Stat = param1.getStat(param3.stat);
         _loc4_.addMod(param2,param3.amount,0);
      }
      
      public function getDebugString() : String
      {
         var _loc1_:* = "";
         _loc1_ += StringUtil.numberWithSign(this.amount,0);
         if(this.charges)
         {
            _loc1_ += " charges=" + this.charges;
         }
         if(this.consumed)
         {
            _loc1_ += " consumed";
         }
         return _loc1_ + (" " + this.provider);
      }
      
      internal function synchronizeTo(param1:Stat, param2:StatMod) : void
      {
         this.stat = param1;
         this.charges = param2.charges;
         this.provider = param2.provider;
         this.amount = param2.amount;
      }
      
      public function consume() : void
      {
         if(this.consumed)
         {
            return;
         }
         if(this.charges > 0)
         {
            --this.charges;
            if(this.charges == 0)
            {
               this.internalConsume();
               if(this.provider)
               {
                  this.provider.handleStatModUsed(this);
               }
            }
         }
      }
      
      public function internalConsume() : void
      {
         if(!this.consumed)
         {
            this.consumed = true;
            this.stat.statModModifyValue(-this.amount);
         }
      }
   }
}

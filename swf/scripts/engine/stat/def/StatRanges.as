package engine.stat.def
{
   import engine.core.util.StringUtil;
   import flash.utils.Dictionary;
   
   public class StatRanges
   {
       
      
      private var _statsRangesByType:Dictionary;
      
      private var _statRanges:Vector.<StatRange>;
      
      public function StatRanges()
      {
         this._statsRangesByType = new Dictionary();
         this._statRanges = new Vector.<StatRange>();
         super();
      }
      
      public function toDebugString() : String
      {
         var _loc2_:StatRange = null;
         var _loc1_:* = "";
         for each(_loc2_ in this._statRanges)
         {
            _loc1_ += StringUtil.padRight(_loc2_.type.name," ",12);
            _loc1_ += "=" + StringUtil.padLeft(_loc2_.min.toString()," ",2) + ", " + StringUtil.padLeft(_loc2_.max.toString()," ",2);
            _loc1_ += "\n";
         }
         return _loc1_;
      }
      
      public function clone() : StatRanges
      {
         var _loc2_:StatRange = null;
         var _loc1_:StatRanges = new StatRanges();
         for each(_loc2_ in this._statRanges)
         {
            _loc1_.addStatRange(_loc2_.type,_loc2_.min,_loc2_.max);
         }
         return _loc1_;
      }
      
      public function getStatRange(param1:StatType) : StatRange
      {
         return this._statsRangesByType[param1];
      }
      
      public function getStatRangeByIndex(param1:int) : StatRange
      {
         return this._statRanges[param1];
      }
      
      public function get numStatRanges() : int
      {
         return this._statRanges.length;
      }
      
      public function hasStatRange(param1:StatType) : Boolean
      {
         return param1 in this._statsRangesByType;
      }
      
      public function addStatRange(param1:StatType, param2:int, param3:int) : StatRange
      {
         if(this.hasStatRange(param1))
         {
            throw new ArgumentError("already hasStat " + param1);
         }
         var _loc4_:StatRange = new StatRange(param1,param2,param3);
         this._statRanges.push(_loc4_);
         this._statsRangesByType[_loc4_.type] = _loc4_;
         return _loc4_;
      }
   }
}

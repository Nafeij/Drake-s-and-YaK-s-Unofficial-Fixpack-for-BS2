package game.gui.page
{
   import engine.core.util.ArrayUtil;
   import flash.utils.Dictionary;
   import game.session.actions.VsType;
   
   public class VsMonitorTypeEntry
   {
       
      
      public var type:VsType;
      
      public var powers:Array;
      
      public var countsArray:Array;
      
      public var counts:Dictionary;
      
      private var _playerQueuePower:int;
      
      public function VsMonitorTypeEntry(param1:VsType)
      {
         this.powers = new Array();
         this.countsArray = new Array();
         this.counts = new Dictionary();
         super();
         this.type = param1;
      }
      
      public function setPowers(param1:Array, param2:Array) : Boolean
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         if(param1.length != param2.length)
         {
            throw new ArgumentError("invalid counts");
         }
         if(ArrayUtil.isEqual(this.powers,param1) && ArrayUtil.isEqual(this.countsArray,param2))
         {
            return false;
         }
         this.powers = param1.concat();
         this.countsArray = param2.concat();
         this.counts = new Dictionary();
         var _loc3_:int = 0;
         while(_loc3_ < this.powers.length)
         {
            _loc4_ = int(this.powers[_loc3_]);
            _loc5_ = int(param2[_loc3_]);
            this.counts[_loc4_] = _loc5_;
            _loc3_++;
         }
         return true;
      }
      
      public function hasOnePower(param1:int) : Boolean
      {
         return this.powers.length == 1 && this.powers[0] == param1;
      }
      
      public function hasPower(param1:int) : Boolean
      {
         return this.powers.indexOf(param1) >= 0;
      }
      
      public function set playerQueuePower(param1:int) : void
      {
         if(this._playerQueuePower == param1)
         {
            return;
         }
         this._playerQueuePower = param1;
      }
      
      private function setCount(param1:int, param2:int) : void
      {
         var _loc3_:int = 0;
         if(this.counts[param1] != undefined)
         {
            this.counts[param1] = param2;
            _loc3_ = this.powers.indexOf(param1);
            if(_loc3_ >= 0)
            {
               if(param2 == 0)
               {
                  this.countsArray.splice(_loc3_,1);
                  this.powers.splice(_loc3_,1);
                  delete this.counts[param1];
               }
               else
               {
                  this.countsArray[_loc3_] = param2;
               }
            }
         }
      }
      
      public function getCount(param1:int) : int
      {
         var _loc2_:int = 0;
         if(this.counts[param1] != undefined)
         {
            _loc2_ = int(this.counts[param1]);
         }
         return _loc2_;
      }
   }
}

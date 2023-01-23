package engine.entity.def
{
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.core.logging.ILogger;
   import flash.utils.Dictionary;
   
   public class Shitlist
   {
       
      
      public var entity:IBattleEntity;
      
      public var def:ShitlistDef;
      
      public var entries:Vector.<ShitlistEntry>;
      
      public var byEntity:Dictionary;
      
      public var logger:ILogger;
      
      public function Shitlist(param1:IBattleEntity, param2:ShitlistDef, param3:ILogger)
      {
         this.entries = new Vector.<ShitlistEntry>();
         this.byEntity = new Dictionary();
         super();
         this.entity = param1;
         this.def = param2;
         this.logger = param3;
      }
      
      public function getShitlistWeight(param1:IBattleEntity) : int
      {
         var _loc2_:ShitlistEntry = this.byEntity[param1];
         return !!_loc2_ ? _loc2_.weight : 0;
      }
      
      public function evaluateShitlist() : void
      {
         var _loc2_:IBattleEntity = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc1_:IBattleBoard = this.entity.board;
         for each(_loc2_ in _loc1_.entities)
         {
            if(!(!_loc2_.alive || Boolean(_loc2_.usable) || !this.entity.canAttack(_loc2_) || !this.entity.awareOf(_loc2_)))
            {
               _loc4_ = this.def.computeShitlistWeight(_loc2_,this.logger);
               this._updateEntry(_loc2_,_loc4_);
            }
         }
         this.entries.sort(this._entryComparator);
         _loc3_ = this.entries.indexOf(null);
         if(_loc3_ >= 0)
         {
            this.entries.splice(_loc3_,this.entries.length);
         }
      }
      
      private function _updateEntry(param1:IBattleEntity, param2:int) : void
      {
         var _loc4_:ShitlistEntry = null;
         var _loc3_:int = 0;
         while(_loc3_ < this.entries.length)
         {
            _loc4_ = this.entries[_loc3_];
            if(_loc4_.target == param1)
            {
               if(param2)
               {
                  _loc4_.weight = param2;
               }
               else
               {
                  this.entries[_loc3_] = null;
                  delete this.byEntity[param1];
               }
               return;
            }
            _loc3_++;
         }
         if(param2)
         {
            _loc4_ = new ShitlistEntry(param1,param2);
            this.entries.push(_loc4_);
            this.byEntity[param1] = _loc4_;
         }
      }
      
      private function _entryComparator(param1:ShitlistEntry, param2:ShitlistEntry) : int
      {
         if(Boolean(param1) && !param2)
         {
            return -1;
         }
         if(Boolean(param2) && !param1)
         {
            return 1;
         }
         if(!param2 && !param1)
         {
            return 0;
         }
         if(param1.weight > param2.weight)
         {
            return -1;
         }
         if(param1.weight < param2.weight)
         {
            return 1;
         }
         return 0;
      }
   }
}

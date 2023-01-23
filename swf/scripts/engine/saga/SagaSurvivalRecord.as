package engine.saga
{
   import engine.battle.board.model.IBattleBoard;
   
   public class SagaSurvivalRecord
   {
       
      
      public var battles:Vector.<SagaSurvivalRecord_Battle>;
      
      public function SagaSurvivalRecord()
      {
         this.battles = new Vector.<SagaSurvivalRecord_Battle>();
         super();
      }
      
      public function fromJson(param1:Object) : SagaSurvivalRecord
      {
         var _loc2_:Object = null;
         for each(_loc2_ in param1.battles)
         {
            this.battles.push(new SagaSurvivalRecord_Battle().fromJson(_loc2_));
         }
         return this;
      }
      
      public function toJson() : Object
      {
         return {"battles":this.toJson_battles()};
      }
      
      private function toJson_battles() : Object
      {
         var _loc2_:SagaSurvivalRecord_Battle = null;
         var _loc1_:Array = [];
         for each(_loc2_ in this.battles)
         {
            _loc1_.push(_loc2_.toJson());
         }
         return _loc1_;
      }
      
      private function fetchBattleByProgress(param1:int) : SagaSurvivalRecord_Battle
      {
         while(this.battles.length <= param1)
         {
            this.battles.push(new SagaSurvivalRecord_Battle());
         }
         return this.battles[param1];
      }
      
      public function handleBattleStart(param1:IBattleBoard) : void
      {
         var _loc2_:Saga = Saga.instance;
         var _loc3_:SagaSurvivalRecord_Battle = this.fetchBattleByProgress(_loc2_.survivalProgress);
         _loc3_.storeStart(param1);
      }
      
      public function handleBattleFinish(param1:IBattleBoard) : void
      {
         var _loc2_:Saga = Saga.instance;
         var _loc3_:SagaSurvivalRecord_Battle = this.fetchBattleByProgress(_loc2_.survivalProgress);
         _loc3_.storeEnd(param1);
      }
      
      public function handleBattleRespawn(param1:IBattleBoard) : void
      {
         var _loc2_:Saga = Saga.instance;
         var _loc3_:SagaSurvivalRecord_Battle = this.fetchBattleByProgress(_loc2_.survivalProgress);
         _loc3_.storeRespawn(param1);
      }
   }
}
